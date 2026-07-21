import 'package:pool_os/contracts/coach_adaptation_projection_contracts.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';

class CoachAdaptationProjector {
  const CoachAdaptationProjector();

  CoachAdaptationProjectionContract project({
    required CoachContextContract context,
    required TrainingOutcomeProjectionContract outcomeProjection,
  }) {
    if (outcomeProjection.playerId != context.profile.playerId ||
        !context.experience.sessions.any(
            (session) => session.sessionId == outcomeProjection.sessionId)) {
      throw ArgumentError('Coach Adaptation Outcome is stale or foreign.');
    }
    final items = outcomeProjection.items
        .map((item) => CoachAdaptationItemContract(
              position: item.position,
              recommendationId: item.recommendationId,
              outcome: item.kind,
              action: coachAdaptationActionFor(item.kind),
            ))
        .toList();
    return CoachAdaptationProjectionContract.create(
      context: context,
      outcomeProjection: outcomeProjection,
      items: items,
    );
  }
}
