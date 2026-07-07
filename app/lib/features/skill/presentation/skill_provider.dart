import '../domain/models/models.dart';
import '../data/skill_repository.dart';
import '../data/skill_engine_service.dart';

class SkillProvider {
  final SkillRepository _repository;
  final SkillEngineService _engine;

  SkillProvider({
    required SkillRepository repository,
    required SkillEngineService engine,
  })  : _repository = repository,
        _engine = engine;

  Future<SkillState> loadSkillsForPlayer(int playerId) async {
    try {
      final skills = await _repository.getSkillsByPlayerId(playerId);
      final needsUpdate = _checkIfNeedsUpdate(skills);

      if (needsUpdate) {
        final updatedSkills = await _engine.calculateAllSkills(playerId: playerId);
        for (final skill in updatedSkills) {
          await _repository.upsertSkill(skill);
        }
        return SkillState(
          skills: updatedSkills,
          lastUpdated: DateTime.now(),
        );
      }

      return SkillState(
        skills: skills,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      return SkillState(error: e.toString());
    }
  }

  bool _checkIfNeedsUpdate(List<PlayerSkill> skills) {
    if (skills.isEmpty) return true;

    final now = DateTime.now();
    for (final skill in skills) {
      if (skill.calculatedAt == null) return true;

      final diff = now.difference(skill.calculatedAt!);
      if (diff.inHours >= 24) return true;
    }

    return false;
  }

  Future<PlayerSkill> recalculateSkill({
    required int playerId,
    required String category,
    int? sessionId,
  }) async {
    final skill = await _engine.calculateSkill(
      playerId: playerId,
      category: category,
      sessionId: sessionId,
    );

    final skillId = await _repository.upsertSkill(skill);

    if (sessionId != null) {
      await _repository.addSkillHistory(PlayerSkillHistory(
        skillId: skillId,
        sessionId: sessionId,
        score: skill.score,
        confidence: skill.confidence,
        trend: skill.trend,
      ));
    }

    return skill.copyWith(id: skillId);
  }

  Future<List<PlayerSkill>> recalculateAllSkills({required int playerId}) async {
    final skills = await _engine.calculateAllSkills(playerId: playerId);

    for (final skill in skills) {
      await _repository.upsertSkill(skill);
    }

    return skills;
  }

  Future<List<PlayerSkillHistory>> getSkillCareerHistory({
    required int playerId,
    required String category,
  }) async {
    final skill = await _repository.getSkillByPlayerAndCategory(playerId, category);
    if (skill == null) return [];

    return await _repository.getSkillHistory(skill.id!);
  }

  Future<Map<String, double>> getSkillTrends(int playerId) {
    return _repository.getSkillTrends(playerId);
  }
}
