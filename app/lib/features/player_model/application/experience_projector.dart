import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/features/coach/application/learning_runtime.dart';

class ExperienceProjectionInput {
  const ExperienceProjectionInput({
    required this.sessionId,
    required this.learningSnapshot,
  });

  final String sessionId;
  final LearningSnapshot learningSnapshot;
}

class ExperienceProjector {
  const ExperienceProjector();

  ExperienceSnapshot project({
    required PlayerProgressSnapshot progress,
    required List<ExperienceProjectionInput> inputs,
  }) {
    if (inputs.isEmpty) {
      throw ArgumentError('Experience projection requires Learning snapshots.');
    }
    final events = inputs.map((input) {
      final snapshot = input.learningSnapshot;
      if (snapshot.pack.knowledgeVersion != progress.knowledgeVersion ||
          snapshot.pack.contentDigest != progress.knowledgeDigest) {
        throw ArgumentError(
          'Experience and Player Model must use one Knowledge pack.',
        );
      }
      final reference = '${snapshot.entry.id}:${snapshot.decision.id}';
      return ExperienceEventContract(
        eventId: 'experience.${snapshot.decision.id}',
        playerId: progress.playerId,
        sessionId: input.sessionId,
        occurredAt: snapshot.decision.createdAt,
        kind: switch (snapshot) {
          TechniqueSnapshot() => ExperienceEventKind.techniqueProgress,
          MistakeSnapshot() => ExperienceEventKind.mistakeState,
        },
        knowledgeId: snapshot.entry.id,
        state: switch (snapshot) {
          TechniqueSnapshot value =>
            value.mastery.mastered ? 'mastered' : 'inProgress',
          MistakeSnapshot value => value.assessment.state.name,
        },
        sourceDecisionReference: reference,
      );
    }).toList(growable: false);
    final timeline = ExperienceTimelineProjection.create(events);
    final bySession = <String, List<ExperienceEventContract>>{};
    for (final event in timeline.events) {
      bySession.putIfAbsent(event.sessionId, () => []).add(event);
    }
    final sessions = bySession.entries
        .map(
          (entry) => SessionSummaryProjection.create(
            sessionId: entry.key,
            events: entry.value,
          ),
        )
        .toList(growable: false);
    return ExperienceSnapshot.create(
      playerId: progress.playerId,
      playerProgressDigest: progress.digest,
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
      timeline: timeline,
      sessions: sessions,
    );
  }
}
