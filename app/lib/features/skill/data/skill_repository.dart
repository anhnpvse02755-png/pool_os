import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../player/data/database/app_database.dart';
import '../../player/data/providers/database_providers.dart';
import '../domain/models/skill.dart';
import '../domain/models/skill_history.dart';

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository(ref.watch(databaseProvider));
});

class SkillRepository {
  final AppDatabase _db;

  SkillRepository(this._db);

  Future<List<PlayerSkill>> getAllSkills() async {
    final results = await _db.select(_db.skills).get();
    return results.map((row) => PlayerSkill(
      id: row.id,
      playerId: row.playerId,
      category: row.category,
      score: row.score,
      confidence: row.confidence,
      trend: row.trend,
      calculatedAt: row.calculatedAt,
      version: row.version,
    )).toList();
  }

  Future<List<PlayerSkill>> getSkillsByPlayerId(int playerId) async {
    final query = _db.select(_db.skills)
      ..where((s) => s.playerId.equals(playerId));
    final results = await query.get();

    return results.map((row) => PlayerSkill(
      id: row.id,
      playerId: row.playerId,
      category: row.category,
      score: row.score,
      confidence: row.confidence,
      trend: row.trend,
      calculatedAt: row.calculatedAt,
      version: row.version,
    )).toList();
  }

  Future<PlayerSkill?> getSkillByPlayerAndCategory(int playerId, String category) async {
    final query = _db.select(_db.skills)
      ..where((s) => s.playerId.equals(playerId));
    query.where((s) => s.category.equals(category));
    query.limit(1);
    final result = await query.getSingleOrNull();

    if (result == null) return null;

    return PlayerSkill(
      id: result.id,
      playerId: result.playerId,
      category: result.category,
      score: result.score,
      confidence: result.confidence,
      trend: result.trend,
      calculatedAt: result.calculatedAt,
      version: result.version,
    );
  }

  Future<int> upsertSkill(PlayerSkill skill) async {
    final existing = await getSkillByPlayerAndCategory(skill.playerId, skill.category);

    if (existing != null) {
      final query = _db.update(_db.skills)
        ..where((s) => s.id.equals(existing.id!));
      await query.write(SkillsCompanion(
        score: Value(skill.score),
        confidence: Value(skill.confidence),
        trend: Value(skill.trend),
        calculatedAt: Value(skill.calculatedAt ?? DateTime.now()),
        version: Value(existing.version + 1),
      ));
      return existing.id!;
    } else {
      return _db.into(_db.skills).insert(SkillsCompanion.insert(
        playerId: skill.playerId,
        category: skill.category,
        score: skill.score,
        confidence: skill.confidence,
        trend: skill.trend,
        calculatedAt: skill.calculatedAt ?? DateTime.now(),
      ));
    }
  }

  Future<void> deleteSkill(int id) async {
    final query = _db.delete(_db.skills)
      ..where((s) => s.id.equals(id));
    await query.go();
  }

  Future<List<PlayerSkillHistory>> getSkillHistory(int skillId, {int limit = 10}) async {
    final query = _db.select(_db.skillHistoryTable)
      ..where((h) => h.skillId.equals(skillId))
      ..orderBy([(h) => OrderingTerm.desc(h.createdAt)])
      ..limit(limit);
    final results = await query.get();

    return results.map((row) => PlayerSkillHistory(
      id: row.id,
      skillId: row.skillId,
      sessionId: row.sessionId,
      score: row.score,
      confidence: row.confidence,
      trend: row.trend,
      createdAt: row.createdAt,
    )).toList();
  }

  Future<List<PlayerSkillHistory>> getSkillHistoryByPlayer(int playerId, {int limit = 20}) async {
    final playerSkills = await getSkillsByPlayerId(playerId);
    if (playerSkills.isEmpty) return [];

    final skillIds = playerSkills.map((s) => s.id!).toList();

    final query = _db.select(_db.skillHistoryTable)
      ..where((h) => h.skillId.isIn(skillIds))
      ..orderBy([(h) => OrderingTerm.desc(h.createdAt)])
      ..limit(limit);
    final results = await query.get();

    return results.map((row) => PlayerSkillHistory(
      id: row.id,
      skillId: row.skillId,
      sessionId: row.sessionId,
      score: row.score,
      confidence: row.confidence,
      trend: row.trend,
      createdAt: row.createdAt,
    )).toList();
  }

  Future<int> addSkillHistory(PlayerSkillHistory history) async {
    return _db.into(_db.skillHistoryTable).insert(
      SkillHistoryTableCompanion.insert(
        skillId: history.skillId,
        sessionId: history.sessionId,
        score: history.score,
        confidence: history.confidence,
        trend: history.trend,
        createdAt: history.createdAt,
      ),
    );
  }

  Future<Map<String, double>> getSkillTrends(int playerId) async {
    final skills = await getSkillsByPlayerId(playerId);
    final trends = <String, double>{};

    for (final skill in skills) {
      final history = await getSkillHistory(skill.id!, limit: 5);
      if (history.length >= 2) {
        final oldest = history.last;
        final newest = history.first;
        trends[skill.category] = newest.score - oldest.score;
      }
    }

    return trends;
  }
}
