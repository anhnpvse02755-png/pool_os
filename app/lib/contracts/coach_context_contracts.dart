import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/experience_projection_contracts.dart';
import 'package:pool_os/contracts/learning_eligibility_contracts.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';

const coachContextContractVersion = 2;

class CoachContextVersionBinding {
  const CoachContextVersionBinding({
    required this.playerProfileVersion,
    required this.playerProgressVersion,
    required this.experienceSnapshotVersion,
    required this.learningEligibilityVersion,
    required this.learningEligibilityDigest,
    required this.knowledgeVersion,
    required this.knowledgeDigest,
  });

  final int playerProfileVersion;
  final int playerProgressVersion;
  final int experienceSnapshotVersion;
  final int learningEligibilityVersion;
  final String learningEligibilityDigest;
  final String knowledgeVersion;
  final String knowledgeDigest;

  Map<String, dynamic> toJson() => {
        'playerProfileVersion': playerProfileVersion,
        'playerProgressVersion': playerProgressVersion,
        'experienceSnapshotVersion': experienceSnapshotVersion,
        'learningEligibilityVersion': learningEligibilityVersion,
        'learningEligibilityDigest': learningEligibilityDigest,
        'knowledgeVersion': knowledgeVersion,
        'knowledgeDigest': knowledgeDigest,
      };
}

class CoachContextContract {
  const CoachContextContract._({
    required this.profile,
    required this.progress,
    required this.experience,
    required this.eligibility,
    required this.versions,
    required this.digest,
  });

  factory CoachContextContract.create({
    required PlayerProfileContract profile,
    required PlayerProgressSnapshot progress,
    required ExperienceSnapshot experience,
    required LearningEligibilityProjection eligibility,
  }) {
    if (profile.playerId != progress.playerId ||
        progress.playerId != experience.playerId) {
      throw ArgumentError('Coach Context player identities do not match.');
    }
    if (experience.playerProgressDigest != progress.digest) {
      throw ArgumentError(
          'Coach Context Experience uses stale Player Progress.');
    }
    if (experience.knowledgeVersion != progress.knowledgeVersion ||
        experience.knowledgeDigest != progress.knowledgeDigest ||
        eligibility.knowledgeVersion != progress.knowledgeVersion ||
        eligibility.knowledgeDigest != progress.knowledgeDigest) {
      throw ArgumentError('Coach Context Knowledge identities do not match.');
    }
    final versions = CoachContextVersionBinding(
      playerProfileVersion: playerProfileContractVersion,
      playerProgressVersion: playerProgressSnapshotVersion,
      experienceSnapshotVersion: experienceSnapshotContractVersion,
      learningEligibilityVersion: learningEligibilityProjectionVersion,
      learningEligibilityDigest: eligibility.digest,
      knowledgeVersion: progress.knowledgeVersion,
      knowledgeDigest: progress.knowledgeDigest,
    );
    final payload = {
      'schemaVersion': coachContextContractVersion,
      'versions': versions.toJson(),
      'profile': profile.toJson(),
      'progress': progress.toJson(),
      'experience': experience.toJson(),
      'eligibility': eligibility.toJson(),
    };
    return CoachContextContract._(
      profile: profile,
      progress: progress,
      experience: experience,
      eligibility: eligibility,
      versions: versions,
      digest: _digest(payload),
    );
  }

  final PlayerProfileContract profile;
  final PlayerProgressSnapshot progress;
  final ExperienceSnapshot experience;
  final LearningEligibilityProjection eligibility;
  final CoachContextVersionBinding versions;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachContextContractVersion,
        'versions': versions.toJson(),
        'profile': profile.toJson(),
        'progress': progress.toJson(),
        'experience': experience.toJson(),
        'eligibility': eligibility.toJson(),
        'digest': digest,
      };
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
