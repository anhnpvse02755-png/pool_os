import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/data/file_stop_shot_evidence_log.dart';

void main() {
  late Directory directory;
  late File file;
  late File snapshotFile;
  late Directory archiveDirectory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pool_os_evidence_');
    file = File('${directory.path}${Platform.pathSeparator}evidence.jsonl');
    snapshotFile = File('${file.path}.snapshot.json');
    archiveDirectory = Directory('${file.path}.archive');
  });

  tearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });

  group('FileLearningEvidenceLog hardening', () {
    test('serializes concurrent appenders without losing records', () async {
      final logs = List.generate(4, (_) => FileLearningEvidenceLog(file));
      final results = await Future.wait([
        for (var index = 0; index < 40; index++)
          logs[index % logs.length].append(_batch('concurrent-$index', index)),
      ]);

      expect(results, everyElement(isTrue));
      final batches = await FileLearningEvidenceLog(file).readAll();
      expect(batches, hasLength(40));
      expect(batches.map((item) => item.commandId).toSet(), hasLength(40));
      expect(file.readAsLinesSync(), hasLength(40));
    });

    test('deduplicates the same command under a concurrent race', () async {
      final first = FileLearningEvidenceLog(file);
      final second = FileLearningEvidenceLog(file);

      final results = await Future.wait([
        first.append(_batch('same-command', 1)),
        second.append(_batch('same-command', 1)),
      ]);

      expect(results.where((result) => result), hasLength(1));
      expect(results.where((result) => !result), hasLength(1));
      expect(await first.readAll(), hasLength(1));
    });

    test('recovers a truncated final record after an interrupted append',
        () async {
      final log = FileLearningEvidenceLog(file);
      await log.append(_batch('committed-before-crash', 1));
      await file.writeAsString(
        '{"batchSchemaVersion":1,"commandId":"interrupted',
        mode: FileMode.append,
        flush: true,
      );

      final recovered = await log.readAll();

      expect(recovered.map((item) => item.commandId), [
        'committed-before-crash',
      ]);
      expect(file.readAsLinesSync(), hasLength(1));
      expect(
        await log.append(_batch('committed-after-recovery', 2)),
        isTrue,
      );
      expect(await log.readAll(), hasLength(2));
    });

    test('accepts a complete final record that only lacks its newline',
        () async {
      final first = _batch('complete-without-newline', 1);
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(first.toJson()), flush: true);
      final log = FileLearningEvidenceLog(file);

      expect((await log.readAll()).single.commandId, first.commandId);
      await log.append(_batch('next-record', 2));

      final replay = await log.readAll();
      expect(
        replay.map((item) => item.commandId),
        ['complete-without-newline', 'next-record'],
      );
      expect(file.readAsLinesSync(), hasLength(2));
    });

    test('fails loudly for a corrupted record terminated by a newline',
        () async {
      final log = FileLearningEvidenceLog(file);
      await log.append(_batch('valid-record', 1));
      await file.writeAsString(
        '{"corrupted":true}\n',
        mode: FileMode.append,
        flush: true,
      );

      await expectLater(log.readAll(), throwsA(isA<FormatException>()));
      expect(file.readAsLinesSync(), hasLength(2));
    });

    test('snapshot replay is deterministic and equivalent to journal replay',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        snapshotFile: snapshotFile,
      );
      for (var index = 0; index < 10; index++) {
        await log.append(_batch('before-snapshot-$index', index));
      }

      final first = await log.createSnapshot();
      final firstBytes = await snapshotFile.readAsBytes();
      final second = await log.createSnapshot();
      final secondBytes = await snapshotFile.readAsBytes();
      expect(first.recordCount, 10);
      expect(second.digest, first.digest);
      expect(secondBytes, firstBytes);

      for (var index = 10; index < 15; index++) {
        await log.append(_batch('after-snapshot-$index', index));
      }
      final snapshotReplay = await log.readAll();
      final journalReplay = await FileLearningEvidenceLog(
        file,
        snapshotFile: File('${file.path}.unused-snapshot'),
      ).readAll();

      expect(
        snapshotReplay.map((item) => item.commandId),
        journalReplay.map((item) => item.commandId),
      );
      expect(file.readAsLinesSync(), hasLength(15));
    });

    test('corrupted snapshot falls back to the canonical journal', () async {
      final log = FileLearningEvidenceLog(
        file,
        snapshotFile: snapshotFile,
      );
      for (var index = 0; index < 5; index++) {
        await log.append(_batch('journal-$index', index));
      }
      await log.createSnapshot();
      await snapshotFile.writeAsString('{"truncated":', flush: true);

      final replay = await log.readAll();

      expect(replay, hasLength(5));
      expect(replay.last.commandId, 'journal-4');
      expect(file.readAsLinesSync(), hasLength(5));
    });

    test('previous snapshot recovers an interrupted snapshot publication',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        snapshotFile: snapshotFile,
      );
      for (var index = 0; index < 3; index++) {
        await log.append(_batch('first-snapshot-$index', index));
      }
      await log.createSnapshot();
      await log.append(_batch('second-snapshot-record', 4));
      await log.createSnapshot();
      await snapshotFile.writeAsString('{"corrupted":true}', flush: true);

      final replay = await log.readAll();

      expect(replay.map((item) => item.commandId), [
        'first-snapshot-0',
        'first-snapshot-1',
        'first-snapshot-2',
        'second-snapshot-record',
      ]);
    });

    test('compacts active journal into immutable ordered archive segments',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      for (var index = 0; index < 4; index++) {
        await log.append(_batch('first-segment-$index', index));
      }

      final first = await log.compactActiveJournal();
      expect(first.segmentCount, 1);
      expect(first.archivedRecordCount, 4);
      expect(await file.length(), 0);
      final firstSegment = File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      );
      final immutableBytes = await firstSegment.readAsBytes();

      for (var index = 4; index < 7; index++) {
        await log.append(_batch('second-segment-$index', index));
      }
      final second = await log.compactActiveJournal();

      expect(second.segmentCount, 2);
      expect(second.archivedRecordCount, 7);
      expect(await firstSegment.readAsBytes(), immutableBytes);
      await log.createSnapshot();
      await log.append(_batch('after-archive-snapshot', 7));
      final replayWithoutSnapshot = await FileLearningEvidenceLog(
        file,
        snapshotFile: File('${file.path}.unused-snapshot'),
        archiveDirectory: archiveDirectory,
      ).readAll();
      expect(
        (await log.readAll()).map((item) => item.commandId),
        [
          for (var index = 0; index < 4; index++) 'first-segment-$index',
          for (var index = 4; index < 7; index++) 'second-segment-$index',
          'after-archive-snapshot',
        ],
      );
      expect(
        (await log.readAll()).map((item) => item.commandId),
        replayWithoutSnapshot.map((item) => item.commandId),
      );
    });

    test('rejects a modified immutable archive segment', () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      await log.append(_batch('archived', 1));
      await log.compactActiveJournal();
      final segment = File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      );
      await segment.writeAsString(
        '${await segment.readAsString()}{"tampered":true}\n',
        flush: true,
      );

      await expectLater(log.readAll(), throwsA(isA<FormatException>()));
    });

    test('rejects a manifest that references a missing archive segment',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      await log.append(_batch('missing-segment', 1));
      await log.compactActiveJournal();
      await File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      ).delete();

      await expectLater(log.readAll(), throwsA(isA<FormatException>()));
    });

    test('ignores an orphan segment while canonical journal is intact',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      await log.append(_batch('canonical-1', 1));
      await log.append(_batch('canonical-2', 2));
      await archiveDirectory.create(recursive: true);
      await File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      ).writeAsString('{"orphan":true}\n', flush: true);

      expect(
        (await log.readAll()).map((item) => item.commandId),
        ['canonical-1', 'canonical-2'],
      );
    });

    test('rejects orphan segments when no canonical journal remains', () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      await archiveDirectory.create(recursive: true);
      await File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      ).writeAsString('${jsonEncode(_batch('orphan-only', 1).toJson())}\n');

      await expectLater(log.readAll(), throwsA(isA<FormatException>()));
    });

    test('recovers a crash after pending archive manifest publication',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      for (var index = 0; index < 3; index++) {
        await log.append(_batch('pending-$index', index));
      }
      await log.compactActiveJournal();
      final segment = File(
        '${archiveDirectory.path}${Platform.pathSeparator}'
        'segment-000001.jsonl',
      );
      final segmentBytes = await segment.readAsBytes();
      await file.writeAsBytes(segmentBytes, flush: true);
      final manifestFile = File(
        '${archiveDirectory.path}${Platform.pathSeparator}manifest.json',
      );
      final manifest = Map<String, dynamic>.from(
        jsonDecode(await manifestFile.readAsString()) as Map,
      )
        ..['state'] = 'pending'
        ..['pendingJournalByteLength'] = segmentBytes.length
        ..['pendingJournalPrefixDigest'] =
            sha256.convert(segmentBytes).toString()
        ..remove('digest');
      manifest['digest'] =
          sha256.convert(utf8.encode(jsonEncode(manifest))).toString();
      await manifestFile.writeAsString(
        '${jsonEncode(manifest)}\n',
        flush: true,
      );

      final replay = await log.readAll();

      expect(replay, hasLength(3));
      expect(await file.length(), 0);
      final recoveredManifest = Map<String, dynamic>.from(
        jsonDecode(await manifestFile.readAsString()) as Map,
      );
      expect(recoveredManifest['state'], 'committed');
      expect(recoveredManifest['pendingJournalByteLength'], 0);
    });

    test('replays through either durable archive manifest copy', () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      await log.append(_batch('durable-manifest', 1));
      await log.compactActiveJournal();
      final primary = File(
        '${archiveDirectory.path}${Platform.pathSeparator}manifest.json',
      );
      final backup = File('${primary.path}.backup');
      final validManifest = await backup.readAsBytes();

      await primary.writeAsString('{"corrupted":', flush: true);
      expect((await log.readAll()).single.commandId, 'durable-manifest');

      await primary.writeAsBytes(validManifest, flush: true);
      await backup.delete();
      expect((await log.readAll()).single.commandId, 'durable-manifest');
    });

    test('keeps command idempotency across archive and active journal',
        () async {
      final log = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      final batch = _batch('archived-command', 1);
      await log.append(batch);
      await log.compactActiveJournal();

      expect(await log.append(batch), isFalse);
      expect(await log.readAll(), hasLength(1));
      expect(await file.length(), 0);
    });

    test('serializes compaction with a concurrent append without data loss',
        () async {
      final compactingLog = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      final appendingLog = FileLearningEvidenceLog(
        file,
        archiveDirectory: archiveDirectory,
      );
      for (var index = 0; index < 5; index++) {
        await compactingLog.append(_batch('before-race-$index', index));
      }

      await Future.wait([
        compactingLog.compactActiveJournal(),
        appendingLog.append(_batch('during-race', 6)),
      ]);

      final replay = await compactingLog.readAll();
      expect(replay, hasLength(6));
      expect(replay.map((item) => item.commandId).toSet(), hasLength(6));
      expect(replay.last.commandId, 'during-race');
    });

    test('preserves source version across journal snapshot and archive replay',
        () async {
      await file.parent.create(recursive: true);
      await file.writeAsString(
        '${jsonEncode(_legacyBatchJson('legacy-cross-version'))}\n',
        flush: true,
      );
      final log = FileLearningEvidenceLog(
        file,
        snapshotFile: snapshotFile,
        archiveDirectory: archiveDirectory,
      );
      await log.append(_batch('current-cross-version', 2));

      expect(
        (await log.readAll()).map((item) => item.sourceSchemaVersion),
        [0, 1],
      );
      await log.createSnapshot();
      expect(
        (await log.readAll()).map((item) => item.sourceSchemaVersion),
        [0, 1],
      );

      await log.compactActiveJournal();
      await log.createSnapshot();
      final replay = await FileLearningEvidenceLog(
        file,
        snapshotFile: snapshotFile,
        archiveDirectory: archiveDirectory,
      ).readAll();

      expect(replay.map((item) => item.commandId), [
        'legacy-cross-version',
        'current-cross-version',
      ]);
      expect(replay.map((item) => item.sourceSchemaVersion), [0, 1]);
      expect(replay.first.upcastFromLegacy, isTrue);
    });
  });
}

Map<String, dynamic> _legacyBatchJson(String commandId) {
  final occurredAt = DateTime.utc(2026, 7, 20).toIso8601String();
  return {
    'commandId': commandId,
    'events': [
      {
        'type': 'DrillAttemptCompleted',
        'eventId': '$commandId.attempt',
        'commandId': commandId,
        'occurredAt': occurredAt,
        'knowledgeId': 'control.stop_shot',
        'drillId': 'B002',
        'attempts': 25,
        'successes': 20,
        'knowledgeVersion': '0.1.0',
      },
      {
        'type': 'OutcomeMeasured',
        'eventId': '$commandId.outcome',
        'commandId': commandId,
        'occurredAt': occurredAt,
        'outcomeId': 'control.stop_shot.outcome',
        'successes': 20,
        'attempts': 25,
        'achieved': true,
        'knowledgeVersion': '0.1.0',
      },
    ],
  };
}

LearningEvidenceBatch _batch(String commandId, int second) {
  final capturedAt = DateTime.utc(2026, 7, 20, 12, 0, second);
  return LearningEvidenceBatch.createObservation(
    batchId: 'batch.$commandId',
    commandId: commandId,
    observation: ObservationRecorded(
      observationId: '$commandId.observation',
      commandId: commandId,
      observationType: 'hardening.test',
      source: 'failure_test',
      confidence: 1,
      capturedAt: capturedAt,
      subjectId: 'control.stop_shot',
      payload: const {'resolved': false},
      knowledgeVersion: '0.2.1',
    ),
  );
}
