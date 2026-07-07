class Rack {
  final int? id;
  final int matchId;
  final int rackNumber;
  final bool result;
  final String? notes;
  final DateTime createdAt;
  final String? biggestMistake;
  final String? biggestStrength;
  final int? confidence;
  
  // FIX-003: Match Mode fields
  final int ballsPotted;
  final int largestRun;
  final bool breakSuccess;
  final bool breakScratch;
  final bool breakFoul;
  final int easyMissCount;
  final int hardMissCount;
  final int scratchErrorCount;
  final int positionErrorCount;
  final int safetyErrorCount;
  final int kickErrorCount;
  final int jumpErrorCount;
  final List<String> bestStrengths;
  final List<String> biggestMistakes;

  Rack({
    this.id,
    required this.matchId,
    required this.rackNumber,
    required this.result,
    this.notes,
    DateTime? createdAt,
    this.biggestMistake,
    this.biggestStrength,
    this.confidence,
    this.ballsPotted = 0,
    this.largestRun = 0,
    this.breakSuccess = false,
    this.breakScratch = false,
    this.breakFoul = false,
    this.easyMissCount = 0,
    this.hardMissCount = 0,
    this.scratchErrorCount = 0,
    this.positionErrorCount = 0,
    this.safetyErrorCount = 0,
    this.kickErrorCount = 0,
    this.jumpErrorCount = 0,
    this.bestStrengths = const [],
    this.biggestMistakes = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Rack copyWith({
    int? id,
    int? matchId,
    int? rackNumber,
    bool? result,
    String? notes,
    DateTime? createdAt,
    String? biggestMistake,
    String? biggestStrength,
    int? confidence,
    int? ballsPotted,
    int? largestRun,
    bool? breakSuccess,
    bool? breakScratch,
    bool? breakFoul,
    int? easyMissCount,
    int? hardMissCount,
    int? scratchErrorCount,
    int? positionErrorCount,
    int? safetyErrorCount,
    int? kickErrorCount,
    int? jumpErrorCount,
    List<String>? bestStrengths,
    List<String>? biggestMistakes,
  }) {
    return Rack(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      rackNumber: rackNumber ?? this.rackNumber,
      result: result ?? this.result,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      biggestMistake: biggestMistake ?? this.biggestMistake,
      biggestStrength: biggestStrength ?? this.biggestStrength,
      confidence: confidence ?? this.confidence,
      ballsPotted: ballsPotted ?? this.ballsPotted,
      largestRun: largestRun ?? this.largestRun,
      breakSuccess: breakSuccess ?? this.breakSuccess,
      breakScratch: breakScratch ?? this.breakScratch,
      breakFoul: breakFoul ?? this.breakFoul,
      easyMissCount: easyMissCount ?? this.easyMissCount,
      hardMissCount: hardMissCount ?? this.hardMissCount,
      scratchErrorCount: scratchErrorCount ?? this.scratchErrorCount,
      positionErrorCount: positionErrorCount ?? this.positionErrorCount,
      safetyErrorCount: safetyErrorCount ?? this.safetyErrorCount,
      kickErrorCount: kickErrorCount ?? this.kickErrorCount,
      jumpErrorCount: jumpErrorCount ?? this.jumpErrorCount,
      bestStrengths: bestStrengths ?? this.bestStrengths,
      biggestMistakes: biggestMistakes ?? this.biggestMistakes,
    );
  }
}
