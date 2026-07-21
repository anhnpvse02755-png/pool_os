import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';

class PlayerModelProjector {
  const PlayerModelProjector();

  PlayerProgressSnapshot project({
    required PlayerProfileContract profile,
    required List<LearningSnapshot> learningSnapshots,
  }) {
    if (learningSnapshots.isEmpty) {
      throw ArgumentError('Player Model requires Learning Runtime snapshots.');
    }
    final pack = learningSnapshots.first.pack;
    if (learningSnapshots.any(
      (snapshot) =>
          snapshot.pack.contentDigest != pack.contentDigest ||
          snapshot.pack.knowledgeVersion != pack.knowledgeVersion,
    )) {
      throw ArgumentError('Learning snapshots must use one Knowledge pack.');
    }

    final techniques = <PlayerTechniqueState>[];
    final mistakes = <PlayerMistakeState>[];
    final references = <String>[];
    final entryIds = <String>{};
    for (final snapshot in learningSnapshots) {
      if (!entryIds.add(snapshot.entry.id)) {
        throw ArgumentError(
          'Player Model received duplicate snapshot ${snapshot.entry.id}.',
        );
      }
      references.add('${snapshot.entry.id}:${snapshot.decision.id}');
      switch (snapshot) {
        case TechniqueSnapshot value:
          techniques.add(
            PlayerTechniqueState(
              knowledgeId: value.entry.id,
              successes: value.mastery.successes,
              attempts: value.mastery.attempts,
              score: value.mastery.score,
              mastered: value.mastery.mastered,
              evidenceCount: value.mastery.evidenceCount,
            ),
          );
        case MistakeSnapshot value:
          mistakes.add(
            PlayerMistakeState(
              knowledgeId: value.entry.id,
              state: value.assessment.state.name,
              observationCount: value.assessment.observationCount,
              confidence: value.assessment.confidence,
              cleanObservationStreak: value.assessment.cleanObservationStreak,
            ),
          );
      }
    }
    return PlayerProgressSnapshot.create(
      playerId: profile.playerId,
      knowledgeVersion: pack.knowledgeVersion,
      knowledgeDigest: pack.contentDigest,
      sourceDecisionReferences: references,
      state: PlayerModelState(
        mastery: techniques,
        mistakes: mistakes,
        preferences: profile.preferences,
        historyReferences: profile.historyReferences,
      ),
    );
  }

  CoachInputContract coachInput({
    required PlayerProfileContract profile,
    required PlayerProgressSnapshot progress,
  }) =>
      CoachInputContract(profile: profile, progress: progress);
}
