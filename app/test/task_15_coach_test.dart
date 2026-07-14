import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/brain/coach_brain.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/context/coach_context.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/coach/domain/findings/shot_context_producer.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart' show ShotResult;

/// TASK 15 — Coach Intelligence V2.
///
/// Two independently-testable layers, which is the whole point of separating
/// facts from decisions:
///  - ShotContextProducer (in-memory DB): emits pure-fact findings with the
///    correct training/match/ghost split; carries no severity/priority/text.
///  - CoachBrain (pure, no DB): given hand-built CoachContext, makes the
///    decisions — confidence, priority, grouping, the single primary action,
///    positive reinforcement, and refuses to over-conclude on thin data.
void main() {
  group('ShotContextProducer (Phần: derive context split)', () {
    late AppDatabase db;
    late ShotContextProducer producer;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      producer = ShotContextProducer(
        SessionRepository(db),
        MatchRepository(db),
        RackRepository(db),
        ShotRepository(db),
      );
    });
    tearDown(() async => db.close());

    Future<int> makeSession(String type, DateTime startedAt) {
      return db.into(db.sessions).insert(SessionsCompanion.insert(
            sessionType: type,
            startedAt: startedAt,
          ));
    }

    Future<int> makeMatch(int sessionId, String gameType) {
      return db.into(db.matches).insert(MatchesCompanion.insert(
            sessionId: sessionId,
            matchNumber: 1,
            gameType: gameType,
          ));
    }

    Future<int> makeRack(int matchId) {
      return db.into(db.racks).insert(RacksCompanion.insert(
            matchId: matchId,
            rackNumber: 1,
            result: true,
          ));
    }

    Future<void> addShots(int rackId, String type, int made, int missed,
        {DateTime? at}) async {
      var n = 1;
      for (var i = 0; i < made; i++) {
        await db.into(db.shots).insert(ShotsCompanion.insert(
              rackId: rackId,
              shotNumber: n++,
              shotType: type,
              difficulty: 'medium',
              result: ShotResult.made,
              createdAt: Value(at ?? DateTime(2026, 7, 1)),
            ));
      }
      for (var i = 0; i < missed; i++) {
        await db.into(db.shots).insert(ShotsCompanion.insert(
              rackId: rackId,
              shotNumber: n++,
              shotType: type,
              difficulty: 'medium',
              result: ShotResult.missed,
              createdAt: Value(at ?? DateTime(2026, 7, 1)),
            ));
      }
    }

    test('splits one shot type into training / match / ghost', () async {
      // Training: 9/10 made. Match: 6/10 made. Ghost: 3/4 made.
      final trainSession = await makeSession('training', DateTime(2026, 7, 1));
      final trainMatch = await makeMatch(trainSession, 'practice_match');
      await addShots(await makeRack(trainMatch), 'stopShot', 9, 1);

      final matchSession = await makeSession('match', DateTime(2026, 7, 1));
      final matchMatch = await makeMatch(matchSession, '9ball');
      await addShots(await makeRack(matchMatch), 'stopShot', 6, 4);

      final ghostSession = await makeSession('practice', DateTime(2026, 7, 1));
      final ghostMatch = await makeMatch(ghostSession, 'ghost_challenge');
      await addShots(await makeRack(ghostMatch), 'stopShot', 3, 1);

      final findings = await producer.produce(now: DateTime(2026, 7, 2));
      final stop = findings.firstWhere((f) => f.metricId == 'shot.stopShot');

      expect(stop.context(PlayStyleContext.training).attempts, 10);
      expect(stop.context(PlayStyleContext.training).made, 9);
      expect(stop.context(PlayStyleContext.match).attempts, 10);
      expect(stop.context(PlayStyleContext.match).made, 6);
      expect(stop.context(PlayStyleContext.ghost).attempts, 4);
      expect(stop.context(PlayStyleContext.ghost).made, 3);
      expect(stop.source, FindingSource.shots);
    });

    test('stamps recent vs prior windows for trajectory', () async {
      final s = await makeSession('training', DateTime(2026, 7, 1));
      final m = await makeMatch(s, 'practice_match');
      final r = await makeRack(m);
      // Prior window (40 days ago): 5/10. Recent (2 days ago): 8/10.
      await addShots(r, 'longPot', 5, 5, at: DateTime(2026, 6, 1));
      await addShots(r, 'longPot', 8, 2, at: DateTime(2026, 7, 12));

      final findings = await producer.produce(now: DateTime(2026, 7, 14));
      final lp = findings.firstWhere((f) => f.metricId == 'shot.longPot');
      expect(lp.data['recentAttempts'], 10);
      expect(lp.data['recentMade'], 8);
      expect(lp.data['priorAttempts'], 10);
      expect(lp.data['priorMade'], 5);
    });
  });

  group('CoachBrain (pure decision-maker)', () {
    final brain = CoachBrain();

    Finding shotFinding(
      String shotType, {
      required int trainA,
      required int trainM,
      required int matchA,
      required int matchM,
    }) {
      final total = trainA + matchA;
      final made = trainM + matchM;
      return Finding(
        metricId: 'shot.$shotType',
        source: FindingSource.shots,
        value: total == 0 ? null : made / total,
        sampleSize: total,
        byContext: {
          PlayStyleContext.training:
              ContextValue(attempts: trainA, made: trainM),
          PlayStyleContext.match: ContextValue(attempts: matchA, made: matchM),
        },
        data: {'shotType': shotType},
      );
    }

    Finding coverage(FindingSource src, int count) => Finding(
          metricId: 'coverage.${src.name}',
          source: FindingSource.coverage,
          sampleSize: count,
          value: count.toDouble(),
          data: {'coveredSource': src.name},
        );

    test('reliable training-vs-match gap ⇒ one high-confidence under-pressure insight', () {
      final ctx = CoachContext.fromFindings([
        // training 95% (19/20), match 61% (11/18) — a real, well-sampled gap.
        shotFinding('stopShot', trainA: 20, trainM: 19, matchA: 18, matchM: 11),
        coverage(FindingSource.shots, 38),
        coverage(FindingSource.skill, 3),
      ]);
      final out = brain.decide(ctx);

      final gap = out.feed.where((i) => i.topic == CoachTopic.underPressure);
      expect(gap.length, 1);
      expect(gap.first.priority, CoachPriority.critical);
      expect(gap.first.confidence, CoachConfidence.high);
      expect(gap.first.action, isNotNull);
      // The single primary action is this weakness's action (not a positive one).
      expect(out.primaryAction, isNotNull);
      expect(out.primaryAction!.knowledgeId, gap.first.action!.knowledgeId);
    });

    test('only-training data ⇒ blocked-by-missing-data, no match conclusion', () {
      final ctx = CoachContext.fromFindings([
        shotFinding('stopShot', trainA: 30, trainM: 28, matchA: 0, matchM: 0),
        coverage(FindingSource.shots, 30),
      ]);
      final out = brain.decide(ctx);

      // Brain must NOT emit an under-pressure conclusion with no match data.
      expect(out.feed.any((i) => i.topic == CoachTopic.underPressure), isFalse);
      // It should prompt for match data instead.
      final blocked =
          out.feed.where((i) => i.priority == CoachPriority.missingData);
      expect(blocked, isNotEmpty);
      expect(blocked.first.action, isNotNull);
    });

    test('low sample ⇒ low/insufficient confidence, no over-conclusion', () {
      final ctx = CoachContext.fromFindings([
        // 2 train / 2 match shots — far below the reliable threshold.
        shotFinding('bank', trainA: 2, trainM: 2, matchA: 2, matchM: 0),
        coverage(FindingSource.shots, 4),
      ]);
      final out = brain.decide(ctx);
      // No reliable-weakness insight should be produced off 2+2 shots.
      expect(
        out.feed.any((i) =>
            i.topic == CoachTopic.underPressure &&
            i.confidence == CoachConfidence.high),
        isFalse,
      );
    });

    test('improving trajectory ⇒ positive reinforcement, never the primary action', () {
      final improving = Finding(
        metricId: 'shot.longPot',
        source: FindingSource.shots,
        sampleSize: 20,
        byContext: {
          PlayStyleContext.match: const ContextValue(attempts: 20, made: 14),
        },
        data: {
          'shotType': 'longPot',
          'recentAttempts': 10,
          'recentMade': 8,
          'priorAttempts': 10,
          'priorMade': 5,
        },
      );
      final ctx = CoachContext.fromFindings([
        improving,
        coverage(FindingSource.shots, 20),
      ]);
      final out = brain.decide(ctx);

      final positive = out.feed.where((i) => i.isPositive);
      expect(positive, isNotEmpty);
      expect(positive.first.priority, CoachPriority.celebrate);
      // A positive card is never chosen as the single hero action.
      if (out.primaryAction != null) {
        final positiveActions =
            positive.map((p) => p.action?.knowledgeId).toSet();
        expect(positiveActions.contains(out.primaryAction!.knowledgeId), isFalse);
      }
    });

    test('no readiness today ⇒ a timely readiness action', () {
      final ctx = CoachContext.fromFindings([
        shotFinding('stopShot', trainA: 20, trainM: 18, matchA: 18, matchM: 16),
        Finding(
          metricId: 'readiness.today',
          source: FindingSource.readiness,
          sampleSize: 0,
          data: const {'loggedToday': false},
        ),
        coverage(FindingSource.shots, 38),
        coverage(FindingSource.readiness, 0),
      ]);
      final out = brain.decide(ctx);
      expect(out.feed.any((i) => i.topic == CoachTopic.readiness), isTrue);
    });

    test('empty context ⇒ onboarding feed with a starting action', () {
      final ctx = CoachContext.fromFindings([
        coverage(FindingSource.shots, 0),
        coverage(FindingSource.skill, 0),
      ]);
      final out = brain.decide(ctx);
      expect(out.isOnboarding || out.feed.length == 1, isTrue);
      expect(out.primaryAction, isNotNull);
    });

    test('priority ordering follows the CoachPriority hierarchy; deterministic', () {
      final ctx = CoachContext.fromFindings([
        shotFinding('stopShot', trainA: 20, trainM: 19, matchA: 18, matchM: 10),
        Finding(
          metricId: 'shot.longPot',
          source: FindingSource.shots,
          sampleSize: 20,
          byContext: {
            PlayStyleContext.match: const ContextValue(attempts: 20, made: 14),
          },
          data: {
            'shotType': 'longPot',
            'recentAttempts': 10,
            'recentMade': 8,
            'priorAttempts': 10,
            'priorMade': 5,
          },
        ),
        coverage(FindingSource.shots, 40),
      ]);
      final first = brain.decide(ctx).feed;
      final second = brain.decide(ctx).feed;
      // Deterministic: same context → same ordered ids.
      expect(first.map((i) => i.id).toList(),
          second.map((i) => i.id).toList());
      // Ranked by priority index (non-decreasing).
      for (var i = 1; i < first.length; i++) {
        expect(first[i].priority.index >= first[i - 1].priority.index, isTrue);
      }
      // Every feed item carries the schema version.
      expect(first.every((i) => i.version == kCoachFeedVersion), isTrue);
    });
  });
}
