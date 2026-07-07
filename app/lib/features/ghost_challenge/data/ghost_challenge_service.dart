import 'dart:math';
import '../domain/models/ghost_challenge.dart';
import '../domain/models/ghost_ai.dart';

class GhostChallengeService {
  late GhostAi _ghostAi;
  GhostChallenge? _currentChallenge;
  final Random _random = Random();

  GhostChallengeService({double initialSkillLevel = 0.6}) {
    _ghostAi = GhostAi(skillLevel: initialSkillLevel);
  }

  GhostChallenge? get currentChallenge => _currentChallenge;

  void setGhostSkillLevel(double level) {
    _ghostAi.setSkillLevel(level);
  }

  double get ghostSkillLevel => _ghostAi.skillLevel;

  GhostChallenge startChallenge({
    required int matchId,
    int targetScore = 5,
    double? ghostSkillLevel,
  }) {
    if (ghostSkillLevel != null) {
      _ghostAi.setSkillLevel(ghostSkillLevel);
    }

    _currentChallenge = GhostChallenge(
      matchId: matchId,
      targetScore: targetScore,
    );

    return _currentChallenge!;
  }

  GhostTurnResult playTurn({
    required bool playerWonRack,
    String? playerShotType,
    String? playerDifficulty,
    bool? playerMadeShot,
  }) {
    if (_currentChallenge == null || _currentChallenge!.isComplete) {
      throw StateError('No active challenge or challenge is complete');
    }

    final rackNumber = _currentChallenge!.racksPlayed + 1;

    if (playerWonRack) {
      _currentChallenge = _currentChallenge!.copyWith(
        playerScore: _currentChallenge!.playerScore + 1,
        racksPlayed: rackNumber,
        shotHistory: [
          ..._currentChallenge!.shotHistory,
          GhostShot(
            rackNumber: rackNumber,
            shooter: 'player',
            made: true,
            shotType: playerShotType ?? 'unknown',
            difficulty: playerDifficulty ?? 'medium',
          ),
        ],
      );
    } else {
      final ghostResult = _ghostAi.generateShotResult(rackNumber);

      _currentChallenge = _currentChallenge!.copyWith(
        ghostScore: _currentChallenge!.ghostScore + 1,
        racksPlayed: rackNumber,
        shotHistory: [
          ..._currentChallenge!.shotHistory,
          GhostShot(
            rackNumber: rackNumber,
            shooter: 'ghost',
            made: ghostResult['made'] as bool,
            shotType: ghostResult['shotType'] as String,
            difficulty: ghostResult['difficulty'] as String,
          ),
        ],
      );
    }

    return GhostTurnResult(
      challenge: _currentChallenge!,
      ghostShot: _currentChallenge!.shotHistory.last,
      isComplete: _currentChallenge!.isComplete,
      winner: _currentChallenge!.winner,
    );
  }

  GhostTurnResult recordPlayerWin({
    String? shotType,
    String? difficulty,
    bool? madeShot,
  }) {
    return playTurn(
      playerWonRack: true,
      playerShotType: shotType,
      playerDifficulty: difficulty,
      playerMadeShot: madeShot,
    );
  }

  GhostTurnResult recordPlayerLoss({
    String? shotType,
    String? difficulty,
    bool? madeShot,
  }) {
    return playTurn(
      playerWonRack: false,
      playerShotType: shotType,
      playerDifficulty: difficulty,
      playerMadeShot: madeShot,
    );
  }

  GhostTurnResult simulateGhostTurn(int rackNumber) {
    if (_currentChallenge == null) {
      throw StateError('No active challenge');
    }

    final result = _ghostAi.generateShotResult(rackNumber);

    final shot = GhostShot(
      rackNumber: rackNumber,
      shooter: 'ghost',
      made: result['made'] as bool,
      shotType: result['shotType'] as String,
      difficulty: result['difficulty'] as String,
    );

    return GhostTurnResult(
      challenge: _currentChallenge!.copyWith(
        shotHistory: [..._currentChallenge!.shotHistory, shot],
      ),
      ghostShot: shot,
      isComplete: false,
      winner: null,
    );
  }

  Map<String, dynamic> getChallengeStatistics() {
    if (_currentChallenge == null) {
      return {};
    }

    final playerShots = _currentChallenge!.shotHistory
        .where((s) => s.shooter == 'player')
        .toList();
    final ghostShots = _currentChallenge!.shotHistory
        .where((s) => s.shooter == 'ghost')
        .toList();

    return {
      'totalRacks': _currentChallenge!.racksPlayed,
      'playerScore': _currentChallenge!.playerScore,
      'ghostScore': _currentChallenge!.ghostScore,
      'playerAccuracy': playerShots.isEmpty
          ? 0.0
          : playerShots.where((s) => s.made).length / playerShots.length,
      'ghostAccuracy': ghostShots.isEmpty
          ? 0.0
          : ghostShots.where((s) => s.made).length / ghostShots.length,
      'averageDifficulty': _calculateAverageDifficulty(_currentChallenge!.shotHistory),
      'toughestShot': _getToughestShot(_currentChallenge!.shotHistory),
      'easiestShot': _getEasiestShot(_currentChallenge!.shotHistory),
    };
  }

  double _calculateAverageDifficulty(List<GhostShot> shots) {
    if (shots.isEmpty) return 0.0;

    const difficultyValues = {'easy': 1.0, 'medium': 2.0, 'hard': 3.0, 'expert': 4.0};
    final total = shots.fold<double>(
      0.0,
      (sum, shot) => sum + (difficultyValues[shot.difficulty] ?? 2.0),
    );
    return total / shots.length;
  }

  GhostShot? _getToughestShot(List<GhostShot> shots) {
    final missedHardShots = shots
        .where((s) => !s.made && (s.difficulty == 'hard' || s.difficulty == 'expert'))
        .toList();
    return missedHardShots.isNotEmpty ? missedHardShots.last : null;
  }

  GhostShot? _getEasiestShot(List<GhostShot> shots) {
    final missedEasyShots = shots
        .where((s) => !s.made && s.difficulty == 'easy')
        .toList();
    return missedEasyShots.isNotEmpty ? missedEasyShots.last : null;
  }

  List<GhostShot> getShotHistory() {
    return _currentChallenge?.shotHistory ?? [];
  }

  void resetChallenge() {
    _currentChallenge = null;
  }

  GhostPerformance getGhostPerformance() {
    return _ghostAi.getPerformanceSnapshot();
  }

  Map<String, List<double>> getSkillDistribution() {
    return {
      'player': _generateRandomSkillDistribution(),
      'ghost': _generateRandomSkillDistribution(),
    };
  }

  List<double> _generateRandomSkillDistribution() {
    final base = _random.nextDouble() * 0.3 + 0.4;
    return [
      base + _random.nextDouble() * 0.2,
      base - 0.1 + _random.nextDouble() * 0.2,
      base + _random.nextDouble() * 0.15,
      base - 0.05 + _random.nextDouble() * 0.2,
      base + _random.nextDouble() * 0.1,
      base - 0.15 + _random.nextDouble() * 0.2,
    ];
  }
}

class GhostTurnResult {
  final GhostChallenge challenge;
  final GhostShot? ghostShot;
  final bool isComplete;
  final String? winner;

  GhostTurnResult({
    required this.challenge,
    this.ghostShot,
    required this.isComplete,
    this.winner,
  });
}
