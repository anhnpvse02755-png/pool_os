import 'dart:convert';

import 'package:crypto/crypto.dart';

const playerProfileContractVersion = 1;
const playerProgressSnapshotVersion = 1;
const coachInputContractVersion = 1;

class PlayerProfileContract {
  PlayerProfileContract({
    required this.playerId,
    required this.dominantHand,
    required this.locale,
    List<String> preferences = const [],
    List<String> historyReferences = const [],
  })  : preferences = List.unmodifiable([...preferences]..sort()),
        historyReferences = List.unmodifiable([...historyReferences]..sort());

  final String playerId;
  final String dominantHand;
  final String locale;
  final List<String> preferences;
  final List<String> historyReferences;

  Map<String, dynamic> toJson() => {
        'schemaVersion': playerProfileContractVersion,
        'playerId': playerId,
        'dominantHand': dominantHand,
        'locale': locale,
        'preferences': preferences,
        'historyReferences': historyReferences,
      };
}

class PlayerTechniqueState {
  const PlayerTechniqueState({
    required this.knowledgeId,
    required this.successes,
    required this.attempts,
    required this.score,
    required this.mastered,
    required this.evidenceCount,
  });

  final String knowledgeId;
  final int successes;
  final int attempts;
  final double score;
  final bool mastered;
  final int evidenceCount;

  Map<String, dynamic> toJson() => {
        'knowledgeId': knowledgeId,
        'successes': successes,
        'attempts': attempts,
        'score': score,
        'mastered': mastered,
        'evidenceCount': evidenceCount,
      };
}

class PlayerMistakeState {
  const PlayerMistakeState({
    required this.knowledgeId,
    required this.state,
    required this.observationCount,
    required this.confidence,
    required this.cleanObservationStreak,
  });

  final String knowledgeId;
  final String state;
  final int observationCount;
  final double confidence;
  final int cleanObservationStreak;

  Map<String, dynamic> toJson() => {
        'knowledgeId': knowledgeId,
        'state': state,
        'observationCount': observationCount,
        'confidence': confidence,
        'cleanObservationStreak': cleanObservationStreak,
      };
}

class PlayerModelState {
  PlayerModelState({
    required List<PlayerTechniqueState> mastery,
    required List<PlayerMistakeState> mistakes,
    required List<String> preferences,
    required List<String> historyReferences,
  })  : mastery = List.unmodifiable(
          [...mastery]..sort((a, b) => a.knowledgeId.compareTo(b.knowledgeId)),
        ),
        mistakes = List.unmodifiable(
          [...mistakes]..sort((a, b) => a.knowledgeId.compareTo(b.knowledgeId)),
        ),
        preferences = List.unmodifiable([...preferences]..sort()),
        historyReferences = List.unmodifiable([...historyReferences]..sort());

  final List<PlayerTechniqueState> mastery;
  final List<PlayerMistakeState> mistakes;
  final List<String> preferences;
  final List<String> historyReferences;

  Map<String, dynamic> toJson() => {
        'mastery': mastery.map((item) => item.toJson()).toList(),
        'mistakes': mistakes.map((item) => item.toJson()).toList(),
        'preferences': preferences,
        'historyReferences': historyReferences,
      };
}

class PlayerProgressSnapshot {
  const PlayerProgressSnapshot._({
    required this.playerId,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
    required this.sourceDecisionReferences,
    required this.state,
    required this.digest,
  });

  factory PlayerProgressSnapshot.create({
    required String playerId,
    required String knowledgeVersion,
    required String knowledgeDigest,
    required List<String> sourceDecisionReferences,
    required PlayerModelState state,
  }) {
    final references = [...sourceDecisionReferences]..sort();
    final payload = {
      'schemaVersion': playerProgressSnapshotVersion,
      'playerId': playerId,
      'knowledgeVersion': knowledgeVersion,
      'knowledgeDigest': knowledgeDigest,
      'sourceDecisionReferences': references,
      'state': state.toJson(),
    };
    return PlayerProgressSnapshot._(
      playerId: playerId,
      knowledgeVersion: knowledgeVersion,
      knowledgeDigest: knowledgeDigest,
      sourceDecisionReferences: List.unmodifiable(references),
      state: state,
      digest: _digest(payload),
    );
  }

  final String playerId;
  final String knowledgeVersion;
  final String knowledgeDigest;
  final List<String> sourceDecisionReferences;
  final PlayerModelState state;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': playerProgressSnapshotVersion,
        'playerId': playerId,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
        'sourceDecisionReferences': sourceDecisionReferences,
        'state': state.toJson(),
        'digest': digest,
      };
}

class CoachInputContract {
  CoachInputContract({
    required this.profile,
    required this.progress,
  }) : digest = _digest({
          'schemaVersion': coachInputContractVersion,
          'profile': profile.toJson(),
          'progressDigest': progress.digest,
        }) {
    if (profile.playerId != progress.playerId) {
      throw ArgumentError('Coach input player IDs do not match.');
    }
  }

  final PlayerProfileContract profile;
  final PlayerProgressSnapshot progress;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachInputContractVersion,
        'profile': profile.toJson(),
        'progress': progress.toJson(),
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
