import 'practice_shot.dart';

/// FIX-003: Practice Session Model for Practice Mode
/// Contains session info and auto-generated summary from shots
class PracticeSession {
  final int? id;
  final int? playerId;
  final int? sessionId;
  final String drillCode;
  final String drillName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? notes;
  
  // Summary (auto-generated from shots)
  final int totalShots;
  final int successfulShots;
  final double successRate;
  final double averageDifficulty;
  final int longestRun;
  final Map<PracticeShotType, int> shotsByType;
  final Map<MissType, int> missesByType;

  PracticeSession({
    this.id,
    this.playerId,
    this.sessionId,
    required this.drillCode,
    required this.drillName,
    required this.startedAt,
    this.completedAt,
    this.notes,
    this.totalShots = 0,
    this.successfulShots = 0,
    this.successRate = 0.0,
    this.averageDifficulty = 0.0,
    this.longestRun = 0,
    this.shotsByType = const {},
    this.missesByType = const {},
  });

  PracticeSession copyWith({
    int? id,
    int? playerId,
    int? sessionId,
    String? drillCode,
    String? drillName,
    DateTime? startedAt,
    DateTime? completedAt,
    String? notes,
    int? totalShots,
    int? successfulShots,
    double? successRate,
    double? averageDifficulty,
    int? longestRun,
    Map<PracticeShotType, int>? shotsByType,
    Map<MissType, int>? missesByType,
  }) {
    return PracticeSession(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      sessionId: sessionId ?? this.sessionId,
      drillCode: drillCode ?? this.drillCode,
      drillName: drillName ?? this.drillName,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      notes: notes ?? this.notes,
      totalShots: totalShots ?? this.totalShots,
      successfulShots: successfulShots ?? this.successfulShots,
      successRate: successRate ?? this.successRate,
      averageDifficulty: averageDifficulty ?? this.averageDifficulty,
      longestRun: longestRun ?? this.longestRun,
      shotsByType: shotsByType ?? this.shotsByType,
      missesByType: missesByType ?? this.missesByType,
    );
  }

  /// FIX-003: Generate summary from a list of shots
  factory PracticeSession.fromShots({
    required String drillCode,
    required String drillName,
    required List<PracticeShot> shots,
    DateTime? startedAt,
  }) {
    if (shots.isEmpty) {
      return PracticeSession(
        drillCode: drillCode,
        drillName: drillName,
        startedAt: startedAt ?? DateTime.now(),
        completedAt: DateTime.now(),
      );
    }

    final totalShots = shots.length;
    final successfulShots = shots.where((s) => s.success).length;
    final successRate = totalShots > 0 ? successfulShots / totalShots : 0.0;
    
    // Calculate average difficulty
    double totalDifficulty = 0;
    for (final shot in shots) {
      totalDifficulty += shot.difficulty;
    }
    final averageDifficulty = totalDifficulty / totalShots;
    
    // Calculate longest run
    int longestRun = 0;
    int currentRun = 0;
    for (final shot in shots) {
      if (shot.success) {
        currentRun++;
        if (currentRun > longestRun) {
          longestRun = currentRun;
        }
      } else {
        currentRun = 0;
      }
    }
    
    // Count shots by type
    final shotsByType = <PracticeShotType, int>{};
    for (final shot in shots) {
      shotsByType[shot.shotType] = (shotsByType[shot.shotType] ?? 0) + 1;
    }
    
    // Count misses by type
    final missesByType = <MissType, int>{};
    for (final shot in shots.where((s) => !s.success && s.missType != null)) {
      missesByType[shot.missType!] = (missesByType[shot.missType!] ?? 0) + 1;
    }

    return PracticeSession(
      drillCode: drillCode,
      drillName: drillName,
      startedAt: startedAt ?? shots.first.createdAt,
      completedAt: shots.last.createdAt,
      totalShots: totalShots,
      successfulShots: successfulShots,
      successRate: successRate,
      averageDifficulty: averageDifficulty,
      longestRun: longestRun,
      shotsByType: shotsByType,
      missesByType: missesByType,
    );
  }

  /// FIX-003: Generate recommendation based on session data
  String generateRecommendation() {
    if (totalShots < 5) {
      return 'Cần thêm dữ liệu để đưa ra khuyến nghị.';
    }

    final recommendations = <String>[];
    
    // Analyze success rate
    if (successRate < 0.5) {
      recommendations.add('Tỷ lệ thành công thấp. Nên tập với độ khó thấp hơn.');
    } else if (successRate > 0.8) {
      recommendations.add('Tỷ lệ thành công cao. Có thể tăng độ khó.');
    }
    
    // Analyze miss patterns
    if (missesByType.isNotEmpty) {
      final sortedMisses = missesByType.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      if (sortedMisses.isNotEmpty) {
        final topMiss = sortedMisses.first;
        recommendations.add('Cần cải thiện: ${topMiss.key.displayNameVi} (${topMiss.value} lần)');
      }
    }
    
    // Analyze position quality
    final positionAvg = shotsByType.isNotEmpty ? 3.0 : 0.0; // Simplified for now
    if (positionAvg < 3) {
      recommendations.add('Nên tập thêm kỹ năng điều bi.');
    }
    
    if (recommendations.isEmpty) {
      return 'Tiếp tục duy trì và phát triển kỹ năng hiện tại.';
    }
    
    return recommendations.join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'sessionId': sessionId,
      'drillCode': drillCode,
      'drillName': drillName,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'notes': notes,
      'totalShots': totalShots,
      'successfulShots': successfulShots,
      'successRate': successRate,
      'averageDifficulty': averageDifficulty,
      'longestRun': longestRun,
      'shotsByType': shotsByType.map((k, v) => MapEntry(k.name, v)),
      'missesByType': missesByType.map((k, v) => MapEntry(k.name, v)),
    };
  }

  factory PracticeSession.fromJson(Map<String, dynamic> json) {
    return PracticeSession(
      id: json['id'] as int?,
      playerId: json['playerId'] as int?,
      sessionId: json['sessionId'] as int?,
      drillCode: json['drillCode'] as String,
      drillName: json['drillName'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      notes: json['notes'] as String?,
      totalShots: json['totalShots'] as int? ?? 0,
      successfulShots: json['successfulShots'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      averageDifficulty: (json['averageDifficulty'] as num?)?.toDouble() ?? 0.0,
      longestRun: json['longestRun'] as int? ?? 0,
      shotsByType: (json['shotsByType'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(
          PracticeShotType.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ) ?? {},
      missesByType: (json['missesByType'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(
          MissType.values.firstWhere((e) => e.name == k),
          v as int,
        ),
      ) ?? {},
    );
  }
}
