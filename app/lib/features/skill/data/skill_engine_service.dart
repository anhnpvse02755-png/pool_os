import '../domain/models/models.dart';
import '../../event/data/repositories/event_repository.dart';
import '../../shot/data/repositories/shot_repository.dart';
import '../../statistics/data/repositories/statistics_repository.dart';

class SkillEngineService {
  final EventRepository eventRepository;
  final ShotRepository shotRepository;
  final StatisticsRepository statisticsRepository;

  final List<SkillCalculator> _calculators;

  SkillEngineService({
    required this.eventRepository,
    required this.shotRepository,
    required this.statisticsRepository,
  }) : _calculators = [
          StrokeSkillCalculator(),
          PositionSkillCalculator(),
          DecisionSkillCalculator(),
          PatternSkillCalculator(),
          BreakSkillCalculator(),
          SafetySkillCalculator(),
          MentalSkillCalculator(),
          ConsistencySkillCalculator(),
          EquipmentSkillCalculator(),
          RecoverySkillCalculator(),
        ];

  List<SkillCalculator> get calculators => _calculators;

  SkillCalculator? getCalculator(String category) {
    try {
      return _calculators.firstWhere((c) => c.category == category);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double>> calculateMetrics({
    required int playerId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final shots = await shotRepository.getShotsByPlayerId(playerId);
    final events = await eventRepository.getEventsByPlayerId(playerId);

    final filteredShots = shots.where((s) {
      if (fromDate != null && s.createdAt.isBefore(fromDate)) return false;
      if (toDate != null && s.createdAt.isAfter(toDate)) return false;
      return true;
    }).toList();

    final filteredEvents = events.where((e) {
      if (fromDate != null && e.createdAt.isBefore(fromDate)) return false;
      if (toDate != null && e.createdAt.isAfter(toDate)) return false;
      return true;
    }).toList();

    return _deriveMetrics(filteredShots, filteredEvents);
  }

  Map<String, double> _deriveMetrics(List<dynamic> shots, List<dynamic> events) {
    final metrics = <String, double>{};

    if (shots.isEmpty) return metrics;

    final madeShots = shots.where((s) => s.result == 'made').length;
    final totalShots = shots.length;
    final shotAccuracy = totalShots > 0 ? (madeShots / totalShots) * 100 : 0.0;

    metrics['shot_accuracy'] = shotAccuracy;

    final positionsWithQuality = shots
        .where((s) => s.positionQuality != null)
        .map((s) => _parsePositionQuality(s.positionQuality as String?))
        .where((q) => q > 0)
        .toList();
    if (positionsWithQuality.isNotEmpty) {
      metrics['avg_position_quality'] =
          positionsWithQuality.reduce((a, b) => a + b) / positionsWithQuality.length;
    }

    final naturalRouteEvents = events.where((e) => e.type == 'natural_route').length;
    final totalPositionEvents = events.where((e) => e.category == 'position').length;
    if (totalPositionEvents > 0) {
      metrics['natural_route'] = (naturalRouteEvents / totalPositionEvents) * 100;
    }

    final longPotEvents = events.where((e) => e.type == 'long_pot').length;
    final thinCutEvents = events.where((e) => e.type == 'thin_cut').length;
    if (totalPositionEvents > 0) {
      metrics['long_pot_percent'] = (longPotEvents / totalPositionEvents) * 100;
      metrics['thin_cut_percent'] = (thinCutEvents / totalPositionEvents) * 100;
    }

    final strokeEvents = events.where((e) => e.category == 'stroke').toList();
    if (strokeEvents.isNotEmpty) {
      final hitchEvents = strokeEvents.where((e) => e.type == 'stroke_hitch').length;
      final gripEvents = strokeEvents.where((e) => e.type == 'grip_tight').length;
      metrics['stroke_hitch_rate'] = (hitchEvents / strokeEvents.length) * 100;
      metrics['grip_tight_rate'] = (gripEvents / strokeEvents.length) * 100;
    }

    final decisionEvents = events.where((e) => e.category == 'decision').toList();
    if (decisionEvents.isNotEmpty) {
      metrics['decision_accuracy_percent'] =
          (decisionEvents.where((e) => e.type == 'attack').length / decisionEvents.length) * 100;
    }

    final mentalEvents = events.where((e) => e.category == 'mental').toList();
    if (mentalEvents.isNotEmpty) {
      final pressureEvents = mentalEvents.where((e) => e.type == 'pressure_shot').toList();
      final pressureMade = pressureEvents.where((e) => e.metadataJson != null).length;
      if (pressureEvents.isNotEmpty) {
        metrics['pressure_success_percent'] = (pressureMade / pressureEvents.length) * 100;
      }
    }

    final confidenValues = shots
        .where((s) => s.confidence != null)
        .map((s) => _parseConfidence(s.confidence as String?))
        .where((c) => c > 0)
        .toList();
    if (confidenValues.isNotEmpty) {
      metrics['avg_confidence'] =
          confidenValues.reduce((a, b) => a + b) / confidenValues.length;
    }

    final safetyEvents = events.where((e) => e.type == 'safety').toList();
    if (safetyEvents.isNotEmpty) {
      metrics['safety_success_percent'] =
          (safetyEvents.where((e) => e.severity == 'low').length / safetyEvents.length) * 100;
    }

    metrics['run_out_percent'] = shotAccuracy * 0.7;
    metrics['avg_balls_per_rack'] = shotAccuracy * 4;
    metrics['break_success_percent'] = shotAccuracy * 80;
    metrics['scratch_percent'] = events.where((e) => e.type == 'scratch').length /
        (events.isNotEmpty ? events.length : 1) * 100;
    metrics['consistency_score'] = _calculateConsistency(shots);
    metrics['equipment_adaptation'] = _calculateEquipmentAdaptation(events);
    metrics['recovery_percent'] = shotAccuracy * 0.85;

    return metrics;
  }

  double _parsePositionQuality(String? quality) {
    switch (quality?.toLowerCase()) {
      case 'excellent':
        return 100;
      case 'good':
        return 80;
      case 'fair':
        return 60;
      case 'poor':
        return 40;
      default:
        return 0;
    }
  }

  double _parseConfidence(String? confidence) {
    switch (confidence?.toLowerCase()) {
      case 'high':
        return 90;
      case 'medium':
        return 70;
      case 'low':
        return 50;
      default:
        return 70;
    }
  }

  double _calculateConsistency(List<dynamic> shots) {
    if (shots.length < 5) return 70.0;

    final results = shots.map((s) => s.result == 'made' ? 1.0 : 0.0).toList();
    final mean = results.reduce((a, b) => a + b) / results.length;

    final variance = results.map((r) => (r - mean) * (r - mean)).reduce((a, b) => a + b) / results.length;
    final stdDev = variance > 0 ? variance * 0.5 : 0.0;

    return ((1 - stdDev) * 100).clamp(0, 100);
  }

  double _calculateEquipmentAdaptation(List<dynamic> events) {
    final equipmentEvents = events.where((e) => e.category == 'equipment').toList();
    if (equipmentEvents.isEmpty) return 80.0;

    final houseCueUsage = equipmentEvents.where((e) => e.type == 'house_cue').length;
    final newCueUsage = equipmentEvents.where((e) => e.type == 'new_cue').length;

    if (houseCueUsage > 0 || newCueUsage > 0) {
      return 70.0;
    }
    return 85.0;
  }

  Future<PlayerSkill> calculateSkill({
    required int playerId,
    required String category,
    int? sessionId,
  }) async {
    final calculator = getCalculator(category);
    if (calculator == null) {
      throw Exception('No calculator found for category: $category');
    }

    final metrics = await calculateMetrics(playerId: playerId);
    final relevantMetrics = <String, double>{};

    for (final metricId in calculator.requiredMetrics.keys) {
      relevantMetrics[metricId] = metrics[metricId] ?? 0.0;
    }

    final eventDataList = await _getEventDataForPlayer(playerId);
    final skillScore = calculator.calculate(eventDataList, relevantMetrics, metrics.length);

    return PlayerSkill(
      playerId: playerId,
      category: category,
      score: skillScore.score,
      confidence: skillScore.confidence,
      trend: skillScore.trend,
      calculatedAt: DateTime.now(),
      metricSources: skillScore.contributingMetrics,
    );
  }

  Future<List<EventData>> _getEventDataForPlayer(int playerId) async {
    final events = await eventRepository.getEventsByPlayerId(playerId);
    return events
        .where((e) => e.shotId != null)
        .map((e) => EventData(
              shotId: e.shotId!,
              category: e.category,
              type: e.type,
              severity: e.severity,
              confidence: e.confidence,
              metadataJson: e.metadataJson,
              createdAt: e.createdAt,
            ))
        .toList();
  }

  Future<List<PlayerSkill>> calculateAllSkills({required int playerId}) async {
    final skills = <PlayerSkill>[];

    for (final calculator in _calculators) {
      try {
        final skill = await calculateSkill(
          playerId: playerId,
          category: calculator.category,
        );
        skills.add(skill);
      } catch (e) {
        // Skip failed calculations
      }
    }

    return skills;
  }

  SkillCategory? getSkillCategory(String name) {
    try {
      return SkillCategory.values.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}
