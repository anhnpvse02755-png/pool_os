import 'dart:convert';

import 'package:crypto/crypto.dart';

const int equipmentPerformanceProjectionVersion = 1;

final class EquipmentPerformanceProjection {
  EquipmentPerformanceProjection._({
    required this.playerId,
    required this.equipmentId,
    required this.totalMatches,
    required this.matchWinRate,
    required this.totalTrainingSessions,
    required this.trainingSuccessRate,
    required this.recordedDurationSeconds,
    required this.lastUsed,
    required this.sourceDigest,
    required this.digest,
  });

  factory EquipmentPerformanceProjection.create({
    required int playerId,
    required int equipmentId,
    required int totalMatches,
    required double matchWinRate,
    required int totalTrainingSessions,
    required double trainingSuccessRate,
    required int recordedDurationSeconds,
    required DateTime? lastUsed,
    required String sourceDigest,
  }) {
    if (playerId <= 0 ||
        equipmentId <= 0 ||
        totalMatches < 0 ||
        totalTrainingSessions < 0 ||
        recordedDurationSeconds < 0 ||
        !_rateIsValid(matchWinRate) ||
        !_rateIsValid(trainingSuccessRate) ||
        sourceDigest.trim().isEmpty) {
      throw ArgumentError('Equipment performance projection is invalid.');
    }
    final canonicalLastUsed = lastUsed?.toUtc();
    final payload = <String, Object?>{
      'schemaVersion': equipmentPerformanceProjectionVersion,
      'playerId': playerId,
      'equipmentId': equipmentId,
      'totalMatches': totalMatches,
      'matchWinRate': _rate(matchWinRate),
      'totalTrainingSessions': totalTrainingSessions,
      'trainingSuccessRate': _rate(trainingSuccessRate),
      'recordedDurationSeconds': recordedDurationSeconds,
      'lastUsed': canonicalLastUsed?.toIso8601String(),
      'sourceDigest': sourceDigest,
    };
    return EquipmentPerformanceProjection._(
      playerId: playerId,
      equipmentId: equipmentId,
      totalMatches: totalMatches,
      matchWinRate: _rate(matchWinRate),
      totalTrainingSessions: totalTrainingSessions,
      trainingSuccessRate: _rate(trainingSuccessRate),
      recordedDurationSeconds: recordedDurationSeconds,
      lastUsed: canonicalLastUsed,
      sourceDigest: sourceDigest,
      digest: equipmentPerformanceDigest(payload),
    );
  }

  final int playerId;
  final int equipmentId;
  final int totalMatches;
  final double matchWinRate;
  final int totalTrainingSessions;
  final double trainingSuccessRate;
  final int recordedDurationSeconds;
  final DateTime? lastUsed;
  final String sourceDigest;
  final String digest;

  Map<String, Object?> toJson() => {
        'schemaVersion': equipmentPerformanceProjectionVersion,
        'playerId': playerId,
        'equipmentId': equipmentId,
        'totalMatches': totalMatches,
        'matchWinRate': matchWinRate,
        'totalTrainingSessions': totalTrainingSessions,
        'trainingSuccessRate': trainingSuccessRate,
        'recordedDurationSeconds': recordedDurationSeconds,
        'lastUsed': lastUsed?.toIso8601String(),
        'sourceDigest': sourceDigest,
        'digest': digest,
      };
}

String equipmentPerformanceDigest(Object? value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();

bool _rateIsValid(double value) => value.isFinite && value >= 0 && value <= 100;

double _rate(double value) => (value * 100).round() / 100;
