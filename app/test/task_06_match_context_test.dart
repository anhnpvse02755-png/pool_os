import 'dart:io';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' show AppDatabase;
import 'package:pool_os/features/match/data/repositories/match_context_repository.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';

/// Task 06 Match Context: pre- and post-match state persist per Match (schema
/// v16), the two halves are written independently, multi-select lists JSON
/// round-trip, and everything survives a database restart. Data-only.
void main() {
  late AppDatabase db;
  late MatchContextRepository repo;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    repo = MatchContextRepository(database);
    return database;
  }

  setUp(() {
    db = openDb(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('pre-match context round-trips including matchGoals list', () async {
    await repo.savePreMatch(MatchContext(
      matchId: 1,
      purpose: MatchPurpose.compete,
      opponent: MatchOpponent.strong,
      tableFamiliarity: Familiarity.unfamiliar,
      roomFamiliarity: Familiarity.familiar,
      lighting: Lighting.good,
      warmupLevel: WarmupLevel.full,
      matchGoals: const [MatchGoal.stopShot, MatchGoal.position],
    ));

    final ctx = await repo.getByMatchId(1);
    expect(ctx, isNotNull);
    expect(ctx!.purpose, MatchPurpose.compete);
    expect(ctx.opponent, MatchOpponent.strong);
    expect(ctx.warmupLevel, WarmupLevel.full);
    expect(ctx.matchGoals, containsAll([MatchGoal.stopShot, MatchGoal.position]));
    expect(ctx.hasPre, isTrue);
    expect(ctx.hasPost, isFalse);
  });

  test('post-match written after pre-match keeps both halves', () async {
    await repo.savePreMatch(MatchContext(
      matchId: 2,
      purpose: MatchPurpose.practice,
      warmupLevel: WarmupLevel.light,
    ));
    await repo.savePostMatch(MatchContext(
      matchId: 2,
      fatigueLevel: FatigueLevel.tired,
      fatigueAreas: const [FatigueArea.arm, FatigueArea.eyes],
      mentalState: MentalState.ok,
      selfRating: 4,
      biggestFactor: BiggestFactor.easyMiss,
    ));

    final ctx = await repo.getByMatchId(2);
    expect(ctx, isNotNull);
    // Pre-match survives the post-match write.
    expect(ctx!.purpose, MatchPurpose.practice);
    expect(ctx.warmupLevel, WarmupLevel.light);
    // Post-match stored.
    expect(ctx.fatigueLevel, FatigueLevel.tired);
    expect(ctx.fatigueAreas, containsAll([FatigueArea.arm, FatigueArea.eyes]));
    expect(ctx.selfRating, 4);
    expect(ctx.biggestFactor, BiggestFactor.easyMiss);
    expect(ctx.hasPre, isTrue);
    expect(ctx.hasPost, isTrue);
  });

  test('post-match with no prior pre-match creates the row', () async {
    await repo.savePostMatch(MatchContext(
      matchId: 3,
      fatigueLevel: FatigueLevel.none,
      selfRating: 5,
    ));
    final ctx = await repo.getByMatchId(3);
    expect(ctx, isNotNull);
    expect(ctx!.hasPre, isFalse);
    expect(ctx.hasPost, isTrue);
    expect(ctx.selfRating, 5);
  });

  test('context survives a database restart (schema v16 durable)', () async {
    final dir = await Directory.systemTemp.createTemp('task06_');
    final file = File('${dir.path}/pool_os_test.db');
    try {
      db = openDb(NativeDatabase(file));
      await repo.savePreMatch(MatchContext(
        matchId: 7,
        purpose: MatchPurpose.tournament,
        warmupLevel: WarmupLevel.playedHot,
        matchGoals: const [MatchGoal.breakGoal],
      ));
      await repo.savePostMatch(MatchContext(
        matchId: 7,
        fatigueLevel: FatigueLevel.veryTired,
        fatigueAreas: const [FatigueArea.shoulder],
      ));
      await db.close();

      db = openDb(NativeDatabase(file));
      final ctx = await repo.getByMatchId(7);
      expect(ctx, isNotNull);
      expect(ctx!.purpose, MatchPurpose.tournament);
      expect(ctx.warmupLevel, WarmupLevel.playedHot);
      expect(ctx.matchGoals, contains(MatchGoal.breakGoal));
      expect(ctx.fatigueLevel, FatigueLevel.veryTired);
      expect(ctx.fatigueAreas, contains(FatigueArea.shoulder));
    } finally {
      await db.close();
      if (await dir.exists()) await dir.delete(recursive: true);
      db = openDb(NativeDatabase.memory());
    }
  });
}
