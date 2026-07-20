import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/stop_shot_contracts.dart';
import 'package:pool_os/features/coach/application/stop_shot_runtime.dart';
import 'package:pool_os/features/coach/presentation/stop_shot_providers.dart';
import 'package:pool_os/features/event/data/file_stop_shot_evidence_log.dart';
import 'package:pool_os/features/event/domain/stop_shot_evidence_log.dart';
import 'package:pool_os/features/mastery/domain/learning_decision_engine.dart';
import 'package:pool_os/features/training_center/presentation/screens/stop_shot_slice_screen.dart';

void main() {
  late ExecutableKnowledgePack pack;

  setUpAll(() {
    pack = ExecutableKnowledgePack.fromJsonString(
      File('../packages/billiard_knowledge/assets/executable_pack_v0_6.json')
          .readAsStringSync(),
    );
  });

  test('22/25 keeps Stop Shot selected; 23/25 unlocks Follow Shot', () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 20),
    );

    final below = await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'run-22',
      successes: 22,
    );
    expect(below.mastery.mastered, isFalse);
    expect(below.decision.recommendations.selected.id, 'control.stop_shot');
    expect(
      below.decision.recommendations.alternatives.map((item) => item.id),
      isNot(contains('mistake.poor_speed_control')),
    );
    expect(
      below.decision.trace.map((reason) => reason.code),
      containsAll([
        DecisionReasonCodes.outcomeMeasured,
        DecisionReasonCodes.belowMasteryThreshold,
        DecisionReasonCodes.recommendationSelected,
      ]),
    );
    expect(
      below.decision.trace.every((reason) => reason.policyVersion.isNotEmpty),
      isTrue,
    );

    final achieved = await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'run-23',
      successes: 23,
    );
    expect(achieved.mastery.mastered, isTrue);
    expect(
      achieved.decision.recommendations.selected.id,
      followShotKnowledgeId,
    );
    expect(achieved.decision.knowledgeVersion, pack.knowledgeVersion);
    expect(achieved.decision.knowledgeDigest, pack.contentDigest);
    expect(achieved.decision.policyVersion, 'learning-decision/0.6.0');
  });

  test('Follow Shot has an independent Outcome, Mastery and recommendation',
      () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 20, 11),
    );
    await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'stop-mastered',
      successes: 23,
    );
    final beforeFollow = await runtime.replayTechnique(followShotKnowledgeId);
    expect(beforeFollow.mastery.evidenceCount, 0);
    expect(beforeFollow.technique.outcome.requiredSuccesses, 23);

    final below = await runtime.recordCompletedDrill(
      knowledgeId: followShotKnowledgeId,
      commandId: 'follow-22',
      successes: 22,
    );
    expect(below.mastery.mastered, isFalse);
    expect(below.decision.recommendations.selected.id, followShotKnowledgeId);

    final achieved = await runtime.recordCompletedDrill(
      knowledgeId: followShotKnowledgeId,
      commandId: 'follow-23',
      successes: 23,
    );
    expect(achieved.mastery.mastered, isTrue);
    expect(
      achieved.decision.recommendations.selected.id,
      'next.position_control.placeholder',
    );
    expect(achieved.mastery.evidenceCount, 2);
  });

  test('Mistake lifecycle is observed, persistent, replayable and resolved',
      () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 20, 12),
    );
    final initial = await runtime.replayMistake(poorSpeedControlMistakeId);
    expect(initial.assessment.state, MistakeLifecycleState.unobserved);

    final detected = await runtime.recordMistakeObservation(
      knowledgeId: poorSpeedControlMistakeId,
      commandId: 'mistake-detected',
      resolved: false,
      confidence: 0.8,
    );
    expect(detected.assessment.state, MistakeLifecycleState.persistent);
    expect(detected.assessment.confidence, 0.8);
    expect(
      detected.decision.recommendations.selected.id,
      poorSpeedControlMistakeId,
    );
    expect(
      detected.decision.trace.map((reason) => reason.code),
      contains(DecisionReasonCodes.mistakePersistent),
    );
    final mistakeBatch = (await log.readAll()).single;
    expect(mistakeBatch.observation?.source, 'human_review');
    expect(mistakeBatch.attempt, isNull);
    expect(mistakeBatch.measurement, isNull);

    final replayed = await LearningRuntime(
      pack: pack,
      evidenceLog: log,
    ).replayMistake(poorSpeedControlMistakeId);
    expect(replayed.assessment.state, MistakeLifecycleState.persistent);

    MistakeSnapshot? resolved;
    for (var index = 1; index <= 3; index++) {
      resolved = await runtime.recordMistakeObservation(
        knowledgeId: poorSpeedControlMistakeId,
        commandId: 'mistake-resolved-$index',
        resolved: true,
        confidence: 1,
      );
    }
    expect(resolved, isNotNull);
    expect(resolved!.assessment.state, MistakeLifecycleState.resolved);
    expect(
      resolved.decision.recommendations.selected.id,
      'status.no_correction_required',
    );
    expect(resolved.assessment.observationCount, 4);
    expect(resolved.assessment.cleanObservationStreak, 3);
  });

  test('rolling completed window replaces a previous mastered run', () async {
    var tick = 0;
    final runtime = LearningRuntime(
      pack: pack,
      evidenceLog: _MemoryStopShotEvidenceLog(),
      clock: () => DateTime.utc(2026, 7, 20, 12, 30, tick++),
    );
    final mastered = await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'rolling-23',
      successes: 23,
    );
    expect(mastered.mastery.mastered, isTrue);

    final regressed = await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'rolling-22',
      successes: 22,
    );
    expect(regressed.mastery.mastered, isFalse);
    expect(regressed.mastery.successes, 22);
  });

  test('active Foundation correction blocks Position Control unlock', () async {
    var tick = 0;
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(
      pack: pack,
      evidenceLog: log,
      clock: () => DateTime.utc(2026, 7, 20, 12, 45, tick++),
    );
    await runtime.recordMistakeObservation(
      knowledgeId: poorSpeedControlMistakeId,
      commandId: 'blocking-mistake',
      resolved: false,
      confidence: 1,
    );
    final blocked = await runtime.recordCompletedDrill(
      knowledgeId: followShotKnowledgeId,
      commandId: 'follow-mastered-but-blocked',
      successes: 23,
    );
    expect(blocked.mastery.mastered, isTrue);
    expect(
      blocked.decision.recommendations.selected.id,
      poorSpeedControlMistakeId,
    );
    expect(
      blocked.decision.trace.map((reason) => reason.code),
      contains(DecisionReasonCodes.activeCorrectionBlocksUnlock),
    );

    for (var index = 1; index <= 3; index++) {
      await runtime.recordMistakeObservation(
        knowledgeId: poorSpeedControlMistakeId,
        commandId: 'clean-$index',
        resolved: true,
        confidence: 1,
      );
    }
    final unlocked = await runtime.replayTechnique(followShotKnowledgeId);
    expect(
      unlocked.decision.recommendations.selected.id,
      'next.position_control.placeholder',
    );
  });

  test('duplicate command is idempotent and does not append twice', () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(pack: pack, evidenceLog: log);

    await runtime.recordCompletedDrill(
        knowledgeId: stopShotKnowledgeId,
        commandId: 'same-command',
        successes: 20);
    await runtime.recordCompletedDrill(
        knowledgeId: stopShotKnowledgeId,
        commandId: 'same-command',
        successes: 20);

    expect(await log.readAll(), hasLength(1));
    expect(
      (await runtime.replayTechnique(stopShotKnowledgeId))
          .mastery
          .evidenceCount,
      1,
    );
  });

  test('Evidence v1 versions batch and events independently with a digest',
      () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(pack: pack, evidenceLog: log);
    await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'versioned',
      successes: 18,
    );

    final json = (await log.readAll()).single.toJson();
    expect(json['batchSchemaVersion'], evidenceBatchSchemaVersion);
    expect(json['digest'], isA<String>());
    final events = json['events'] as List<dynamic>;
    final byType = {for (final event in events) event['type']: event};
    expect(
      byType[DrillAttemptCompleted.eventType]['schemaVersion'],
      drillAttemptCompletedSchemaVersion,
    );
    expect(
      byType[OutcomeMeasured.eventType]['schemaVersion'],
      outcomeMeasuredSchemaVersion,
    );
    expect(
      byType[ObservationRecorded.eventType]['schemaVersion'],
      observationRecordedSchemaVersion,
    );
    final observation = byType[ObservationRecorded.eventType]['payload'];
    expect(observation['source'], 'manual_drill_summary');
    expect(observation['confidence'], 1);
    expect(observation['capturedAt'], isA<String>());
  });

  test('Evidence rejects tampering and unknown event versions', () async {
    final log = _MemoryStopShotEvidenceLog();
    final runtime = LearningRuntime(pack: pack, evidenceLog: log);
    await runtime.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'protected',
      successes: 18,
    );
    final original = (await log.readAll()).single.toJson();

    final tampered = _deepCopy(original);
    final tamperedMeasurement = (tampered['events'] as List<dynamic>)
        .firstWhere((event) => event['type'] == OutcomeMeasured.eventType);
    tamperedMeasurement['payload']['successes'] = 25;
    expect(
      () => StopShotEvidenceBatch.fromJson(tampered),
      throwsA(isA<EvidenceContractException>()),
    );

    final unknownVersion = _deepCopy(original);
    (unknownVersion['events'] as List<dynamic>)[0]['schemaVersion'] = 99;
    unknownVersion['digest'] = _evidenceDigest(unknownVersion);
    expect(
      () => StopShotEvidenceBatch.fromJson(unknownVersion),
      throwsA(isA<EvidenceContractException>()),
    );
  });

  test('legacy Sprint 0 evidence is explicitly upcast to the v1 contract', () {
    final occurredAt = DateTime.utc(2026, 7, 20).toIso8601String();
    final legacy = <String, dynamic>{
      'commandId': 'legacy-command',
      'events': [
        {
          'type': 'DrillAttemptCompleted',
          'eventId': 'legacy.attempt',
          'commandId': 'legacy-command',
          'occurredAt': occurredAt,
          'knowledgeId': 'control.stop_shot',
          'drillId': 'B002',
          'attempts': 25,
          'successes': 20,
          'knowledgeVersion': '0.1.0',
        },
        {
          'type': 'OutcomeMeasured',
          'eventId': 'legacy.outcome',
          'commandId': 'legacy-command',
          'occurredAt': occurredAt,
          'outcomeId': 'control.stop_shot.outcome',
          'successes': 20,
          'attempts': 25,
          'achieved': true,
          'knowledgeVersion': '0.1.0',
        },
      ],
    };

    final upcast = StopShotEvidenceBatch.fromJson(legacy);
    expect(upcast.upcastFromLegacy, isTrue);
    expect(upcast.batchSchemaVersion, evidenceBatchSchemaVersion);
    expect(upcast.digest, hasLength(64));
    final roundTrip = StopShotEvidenceBatch.fromJson(upcast.toJson());
    expect(roundTrip.commandId, 'legacy-command');
    expect(roundTrip.upcastFromLegacy, isFalse);
  });

  test('runtime and policies contain no knowledge ID special-case', () {
    final sources = [
      File('lib/features/coach/application/stop_shot_runtime.dart'),
      File('lib/features/mastery/domain/learning_decision_engine.dart'),
    ].map((file) => file.readAsStringSync()).join('\n');
    expect(sources, isNot(contains('control.stop_shot')));
    expect(RegExp(r'if\s*\([^)]*knowledgeId\s*==').hasMatch(sources), isFalse);
  });

  test('canonical golden fixtures replay to the accepted behavior', () async {
    final fixture = jsonDecode(
      File('../architecture/reference_behavior/canonical_golden_0_6.json')
          .readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(fixture['status'], 'accepted');
    expect(fixture['datasetVersion'], '0.6.0');
    expect(fixture['knowledgeDigest'], pack.contentDigest);
    for (final rawCase in fixture['cases'] as List<dynamic>) {
      final testCase = Map<String, dynamic>.from(rawCase as Map);
      final expected = Map<String, dynamic>.from(testCase['expected'] as Map);
      final evidence = testCase['evidence'] as List<dynamic>;
      final log = _MemoryStopShotEvidenceLog();
      final runtime = LearningRuntime(
        pack: pack,
        evidenceLog: log,
        clock: () => DateTime.utc(2026, 7, 20, 13),
      );
      if (testCase['subjectKind'] == 'technique') {
        TechniqueSnapshot? snapshot;
        for (var index = 0; index < evidence.length; index++) {
          final item = Map<String, dynamic>.from(evidence[index] as Map);
          snapshot = await runtime.recordCompletedDrill(
            knowledgeId: testCase['knowledgeId'] as String,
            commandId: '${testCase['id']}.$index',
            successes: item['successes'] as int,
          );
        }
        expect(snapshot?.mastery.mastered, expected['mastered'],
            reason: testCase['id'] as String);
        expect(snapshot?.decision.recommendations.selected.id,
            expected['selectedRecommendationId'],
            reason: testCase['id'] as String);
        expect(snapshot?.decision.trace.map((reason) => reason.code),
            contains(expected['reasonCode']),
            reason: testCase['id'] as String);
      } else {
        MistakeSnapshot? snapshot;
        for (var index = 0; index < evidence.length; index++) {
          final item = Map<String, dynamic>.from(evidence[index] as Map);
          snapshot = await runtime.recordMistakeObservation(
            knowledgeId: testCase['knowledgeId'] as String,
            commandId: '${testCase['id']}.$index',
            resolved: item['resolved'] as bool,
            confidence: (item['confidence'] as num).toDouble(),
          );
        }
        expect(snapshot?.assessment.state.name, expected['lifecycleState'],
            reason: testCase['id'] as String);
        expect(snapshot?.decision.recommendations.selected.id,
            expected['selectedRecommendationId'],
            reason: testCase['id'] as String);
        expect(snapshot?.decision.trace.map((reason) => reason.code),
            contains(expected['reasonCode']),
            reason: testCase['id'] as String);
      }
    }
  });

  test('file log rebuilds the same mastery and decision after restart',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('pool_os_stop_shot_');
    addTearDown(() => directory.delete(recursive: true));
    final file =
        File('${directory.path}${Platform.pathSeparator}evidence.jsonl');
    DateTime clock() => DateTime.utc(2026, 7, 20, 10);
    final first = LearningRuntime(
      pack: pack,
      evidenceLog: FileStopShotEvidenceLog(file),
      clock: clock,
    );
    final recorded = await first.recordCompletedDrill(
      knowledgeId: stopShotKnowledgeId,
      commandId: 'persistent-run',
      successes: 23,
    );

    final restarted = LearningRuntime(
      pack: pack,
      evidenceLog: FileStopShotEvidenceLog(file),
      clock: clock,
    );
    final replayed = await restarted.replayTechnique(stopShotKnowledgeId);

    expect(replayed.mastery.score, recorded.mastery.score);
    expect(replayed.mastery.evidenceCount, 1);
    expect(replayed.decision.id, recorded.decision.id);
    expect(
      replayed.decision.recommendations.selected.id,
      recorded.decision.recommendations.selected.id,
    );
    expect(file.readAsLinesSync(), hasLength(1));
  });

  testWidgets('Experience renders the DecisionRecord after a completed drill',
      (tester) async {
    final log = _MemoryStopShotEvidenceLog();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stopShotPackProvider.overrideWith((ref) async => pack),
          stopShotEvidenceLogProvider.overrideWith((ref) async => log),
        ],
        child: const MaterialApp(home: StopShotSliceScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('stop-shot-hit')),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pump();

    for (var i = 0; i < 23; i++) {
      await tester.tap(find.byKey(const Key('stop-shot-hit')));
      await tester.pump();
    }
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(const Key('stop-shot-miss')));
      await tester.pump();
    }
    await tester.ensureVisible(find.byKey(const Key('stop-shot-save')));
    await tester.tap(find.byKey(const Key('stop-shot-save')));
    await tester.pumpAndSettle();

    expect(find.text('Follow Shot'), findsOneWidget);
    expect(find.textContaining('Mastery 92%'), findsOneWidget);
    expect(await log.readAll(), hasLength(1));
  });

  testWidgets('Experience runs Follow Shot through the same consumer contract',
      (tester) async {
    final log = _MemoryStopShotEvidenceLog();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          stopShotPackProvider.overrideWith((ref) async => pack),
          stopShotEvidenceLogProvider.overrideWith((ref) async => log),
        ],
        child: const MaterialApp(
          home: StopShotSliceScreen(knowledgeId: followShotKnowledgeId),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('stop-shot-hit')),
      300,
      scrollable: find.byType(Scrollable),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -160));
    await tester.pump();
    for (var i = 0; i < 23; i++) {
      await tester.tap(find.byKey(const Key('stop-shot-hit')));
      await tester.pump();
    }
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.byKey(const Key('stop-shot-miss')));
      await tester.pump();
    }
    await tester.ensureVisible(find.byKey(const Key('stop-shot-save')));
    await tester.tap(find.byKey(const Key('stop-shot-save')));
    await tester.pumpAndSettle();

    expect(find.text('Position Control đã sẵn sàng'), findsOneWidget);
    expect(find.textContaining('Mastery 92%'), findsOneWidget);
    expect((await log.readAll()).single.attempt?.knowledgeId,
        followShotKnowledgeId);
  });
}

Map<String, dynamic> _deepCopy(Map<String, dynamic> value) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);

String _evidenceDigest(Map<String, dynamic> value) {
  final payload = Map<String, dynamic>.from(value)..remove('digest');
  return sha256.convert(utf8.encode(jsonEncode(payload))).toString();
}

class _MemoryStopShotEvidenceLog implements StopShotEvidenceLog {
  final List<StopShotEvidenceBatch> _batches = [];

  @override
  Future<bool> append(StopShotEvidenceBatch batch) async {
    if (_batches.any((item) => item.commandId == batch.commandId)) return false;
    _batches.add(batch);
    return true;
  }

  @override
  Future<List<StopShotEvidenceBatch>> readAll() async =>
      List.unmodifiable(_batches);
}
