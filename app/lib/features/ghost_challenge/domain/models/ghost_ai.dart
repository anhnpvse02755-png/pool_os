import 'dart:math';

class GhostAi {
  final Random _random = Random();

  static const List<String> _shotTypes = [
    'straight',
    'cut',
    'bank',
    'massé',
    'jump',
    'spin',
  ];

  static const Map<String, double> _baseSuccessRates = {
    'easy': 0.85,
    'medium': 0.65,
    'hard': 0.45,
    'expert': 0.25,
  };

  double _skillLevel;

  GhostAi({double skillLevel = 0.6}) : _skillLevel = skillLevel.clamp(0.0, 1.0);

  double get skillLevel => _skillLevel;

  void setSkillLevel(double level) {
    _skillLevel = level.clamp(0.0, 1.0);
  }

  String getRandomShotType() {
    return _shotTypes[_random.nextInt(_shotTypes.length)];
  }

  String getRandomDifficulty() {
    final roll = _random.nextDouble();
    if (roll < 0.2) return 'easy';
    if (roll < 0.5) return 'medium';
    if (roll < 0.8) return 'hard';
    return 'expert';
  }

  bool makeShot({String? difficulty, String? shotType}) {
    final diff = difficulty ?? getRandomDifficulty();
    final type = shotType ?? getRandomShotType();

    double successRate = _baseSuccessRates[diff] ?? 0.5;

    switch (type) {
      case 'straight':
        successRate += 0.05;
        break;
      case 'cut':
        successRate += 0.0;
        break;
      case 'bank':
        successRate -= 0.15;
        break;
      case 'massé':
        successRate -= 0.25;
        break;
      case 'jump':
        successRate -= 0.20;
        break;
      case 'spin':
        successRate -= 0.05;
        break;
    }

    successRate = successRate.clamp(0.05, 0.95);
    successRate *= (0.8 + (_skillLevel * 0.4));

    return _random.nextDouble() < successRate;
  }

  bool makeBreak() {
    final breakSuccess = _random.nextDouble();
    final adjustedSkill = _skillLevel * 1.2;
    return breakSuccess < (0.4 + adjustedSkill * 0.4);
  }

  int getBallsPocketedOnBreak() {
    if (!makeBreak()) return 0;
    final pocketed = _random.nextDouble();
    if (pocketed < 0.3) return 1;
    if (pocketed < 0.6) return 2;
    if (pocketed < 0.85) return 3;
    return 4;
  }

  String getDifficultyForRack(int rackNumber) {
    final adjustedSkill = _skillLevel + (rackNumber * 0.02);
    final roll = _random.nextDouble();

    if (adjustedSkill > 0.8) {
      if (roll < 0.3) return 'hard';
      if (roll < 0.6) return 'medium';
      if (roll < 0.9) return 'expert';
      return 'easy';
    } else if (adjustedSkill > 0.5) {
      if (roll < 0.3) return 'medium';
      if (roll < 0.6) return 'easy';
      if (roll < 0.85) return 'hard';
      return 'expert';
    } else {
      if (roll < 0.4) return 'easy';
      if (roll < 0.7) return 'medium';
      if (roll < 0.9) return 'hard';
      return 'expert';
    }
  }

  Map<String, dynamic> generateShotResult(int rackNumber) {
    final difficulty = getDifficultyForRack(rackNumber);
    final shotType = getRandomShotType();
    final made = makeShot(difficulty: difficulty, shotType: shotType);

    return {
      'made': made,
      'shotType': shotType,
      'difficulty': difficulty,
      'ballsPocketed': made ? _getBallsPocketed(difficulty) : 0,
    };
  }

  int _getBallsPocketed(String difficulty) {
    final base = switch (difficulty) {
      'easy' => 2,
      'medium' => 2,
      'hard' => 3,
      'expert' => 4,
      _ => 1,
    };
    return base + (_random.nextBool() ? 1 : 0);
  }

  GhostPerformance getPerformanceSnapshot() {
    return GhostPerformance(
      skillLevel: _skillLevel,
      estimatedWinRate: _estimateWinRate(),
      strongAreas: _getStrongAreas(),
      weakAreas: _getWeakAreas(),
    );
  }

  double _estimateWinRate() {
    return (_skillLevel * 0.5) + 0.25;
  }

  List<String> _getStrongAreas() {
    final areas = <String>[];
    if (_skillLevel > 0.7) {
      areas.add('consistency');
    }
    if (_skillLevel > 0.6) {
      areas.add('position_play');
    }
    if (_skillLevel > 0.5) {
      areas.add('shot_selection');
    }
    return areas;
  }

  List<String> _getWeakAreas() {
    final areas = <String>[];
    if (_skillLevel < 0.4) {
      areas.add('pressure_shots');
    }
    if (_skillLevel < 0.5) {
      areas.add('bank_shots');
    }
    if (_skillLevel < 0.6) {
      areas.add('position_control');
    }
    return areas;
  }
}

class GhostPerformance {
  final double skillLevel;
  final double estimatedWinRate;
  final List<String> strongAreas;
  final List<String> weakAreas;

  GhostPerformance({
    required this.skillLevel,
    required this.estimatedWinRate,
    required this.strongAreas,
    required this.weakAreas,
  });

  String get skillLabel {
    if (skillLevel >= 0.8) return 'Elite';
    if (skillLevel >= 0.6) return 'Advanced';
    if (skillLevel >= 0.4) return 'Intermediate';
    return 'Beginner';
  }
}
