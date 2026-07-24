import 'dart:convert';

import 'package:crypto/crypto.dart';

const playerProgressProjectionVersion = 1;

enum PlayerSkillDimension {
  breakSkill,
  potting,
  position,
  safety,
  cueBallControl,
  kickJump,
  mental,
  consistency,
}

final class PlayerSkillScore {
  const PlayerSkillScore({required this.dimension, required this.value});

  final PlayerSkillDimension dimension;
  final double value;

  Map<String, Object> toJson() => {
        'dimension': dimension.name,
        'value': value,
      };
}

final class PlayerProgressProjection {
  PlayerProgressProjection._({
    required this.playerId,
    required List<PlayerSkillScore> skills,
    required this.overall,
    required this.confidence,
    required this.trend,
    required this.mastery,
    required List<PlayerSkillDimension> strengths,
    required List<PlayerSkillDimension> weaknesses,
    required List<double> trendPoints,
    required this.sourceMatchCount,
    required this.sourceTrainingCount,
    required this.lastUpdated,
    required this.sourceDigest,
    required this.digest,
  })  : skills = List.unmodifiable(skills),
        strengths = List.unmodifiable(strengths),
        weaknesses = List.unmodifiable(weaknesses),
        trendPoints = List.unmodifiable(trendPoints);

  factory PlayerProgressProjection.create({
    required int playerId,
    required List<PlayerSkillScore> skills,
    required double overall,
    required double confidence,
    required double trend,
    required double mastery,
    required List<PlayerSkillDimension> strengths,
    required List<PlayerSkillDimension> weaknesses,
    required List<double> trendPoints,
    required int sourceMatchCount,
    required int sourceTrainingCount,
    required DateTime lastUpdated,
    required String sourceDigest,
  }) {
    if (playerId <= 0 || sourceDigest.trim().isEmpty) {
      throw ArgumentError('Player progress identity is invalid.');
    }
    final orderedSkills = [...skills]..sort(
        (left, right) => left.dimension.index.compareTo(right.dimension.index));
    if (orderedSkills.length != PlayerSkillDimension.values.length ||
        orderedSkills.map((item) => item.dimension).toSet().length !=
            PlayerSkillDimension.values.length ||
        sourceMatchCount < 0 ||
        sourceTrainingCount < 0) {
      throw ArgumentError('Player progress sources or skills are incomplete.');
    }
    final values = <double>[
      ...orderedSkills.map((item) => item.value),
      overall,
      confidence,
      trend,
      mastery,
      ...trendPoints,
    ];
    if (values.any((value) => !value.isFinite || value < 0 || value > 100)) {
      throw ArgumentError('Player progress scores must be between 0 and 100.');
    }
    final dimensions = PlayerSkillDimension.values.toSet();
    if (strengths.length > 5 ||
        weaknesses.length > 5 ||
        strengths.toSet().length != strengths.length ||
        weaknesses.toSet().length != weaknesses.length ||
        strengths.any((value) => !dimensions.contains(value)) ||
        weaknesses.any((value) => !dimensions.contains(value))) {
      throw ArgumentError('Player progress vectors are invalid.');
    }
    final canonicalUpdated = lastUpdated.toUtc();
    final canonicalStrengths = List<PlayerSkillDimension>.from(strengths);
    final canonicalWeaknesses = List<PlayerSkillDimension>.from(weaknesses);
    final canonicalPoints = List<double>.from(trendPoints);
    final payload = <String, Object>{
      'schemaVersion': playerProgressProjectionVersion,
      'playerId': playerId,
      'skills': orderedSkills.map((item) => item.toJson()).toList(),
      'overall': overall,
      'confidence': confidence,
      'trend': trend,
      'mastery': mastery,
      'strengths': canonicalStrengths.map((item) => item.name).toList(),
      'weaknesses': canonicalWeaknesses.map((item) => item.name).toList(),
      'trendPoints': canonicalPoints,
      'sourceMatchCount': sourceMatchCount,
      'sourceTrainingCount': sourceTrainingCount,
      'lastUpdated': canonicalUpdated.toIso8601String(),
      'sourceDigest': sourceDigest,
    };
    return PlayerProgressProjection._(
      playerId: playerId,
      skills: orderedSkills,
      overall: overall,
      confidence: confidence,
      trend: trend,
      mastery: mastery,
      strengths: canonicalStrengths,
      weaknesses: canonicalWeaknesses,
      trendPoints: canonicalPoints,
      sourceMatchCount: sourceMatchCount,
      sourceTrainingCount: sourceTrainingCount,
      lastUpdated: canonicalUpdated,
      sourceDigest: sourceDigest,
      digest: _digest(payload),
    );
  }

  final int playerId;
  final List<PlayerSkillScore> skills;
  final double overall;
  final double confidence;
  final double trend;
  final double mastery;
  final List<PlayerSkillDimension> strengths;
  final List<PlayerSkillDimension> weaknesses;
  final List<double> trendPoints;
  final int sourceMatchCount;
  final int sourceTrainingCount;
  final DateTime lastUpdated;
  final String sourceDigest;
  final String digest;

  double score(PlayerSkillDimension dimension) =>
      skills.firstWhere((item) => item.dimension == dimension).value;

  Map<String, Object> toJson() => {
        'schemaVersion': playerProgressProjectionVersion,
        'playerId': playerId,
        'skills': skills.map((item) => item.toJson()).toList(),
        'overall': overall,
        'confidence': confidence,
        'trend': trend,
        'mastery': mastery,
        'strengths': strengths.map((item) => item.name).toList(),
        'weaknesses': weaknesses.map((item) => item.name).toList(),
        'trendPoints': trendPoints,
        'sourceMatchCount': sourceMatchCount,
        'sourceTrainingCount': sourceTrainingCount,
        'lastUpdated': lastUpdated.toIso8601String(),
        'sourceDigest': sourceDigest,
        'digest': digest,
      };
}

String playerProgressDigest(Object value) => _digest(value);

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
