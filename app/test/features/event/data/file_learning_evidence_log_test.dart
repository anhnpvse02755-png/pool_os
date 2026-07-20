import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/event/data/file_stop_shot_evidence_log.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('pool_os_evidence_');
    file = File('${directory.path}${Platform.pathSeparator}evidence.jsonl');
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
  });
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
