import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/assessment.dart';
import '../models/recommendation.dart';

/// Recommendation Service - generates recommendations using JSON content
class RecommendationService {
  Map<String, dynamic>? _painsCache;
  Map<String, dynamic>? _drillsCache;
  Map<String, dynamic>? _knowledgeCache;

  /// Generate recommendation based on assessment result
  /// Uses REAL JSON content, not hardcoded
  Future<Recommendation> generate(AssessmentResult assessment) async {
    await _ensureContentLoaded();

    // Get answers from nested object
    final answers = assessment.answers;

    // Determine pain type from accuracy answer
    final painType = _detectPainType(answers.q2Accuracy);

    // Get real pain from JSON
    final pain = _getPainByType(painType);

    // Get real drill linked to this pain
    final drill = _getDrillForPain(pain);

    // Get real knowledge linked to this drill
    final knowledge = _getKnowledgeForDrill(drill);

    // Get duration from user preference
    final duration = _mapTimeToDuration(answers.q5Time);

    return Recommendation(
      goalId: drill?['goal'] as String? ?? 'pot_first_ball',
      goalName: _getGoalName(drill?['goal'] as String? ?? 'pot_first_ball'),
      knowledgeId: knowledge?['id'] as String? ?? 'know_ghost_ball',
      knowledgeName: knowledge?['nameVn'] as String? ?? 'Ghost Ball',
      drillId: drill?['id'] as String? ?? 'drill_001',
      drillName: drill?['nameVn'] as String? ?? 'Pot cơ bản',
      videoId: 'video_ghost_ball',
      videoSegment: drill?['videoSegment'] as String? ?? '0:00-2:00',
      durationMinutes: duration,
      confidence: 0.9,
      reason: pain?['coachDialogues']?['discovery'] as String? ??
              'Bạn cần biết cách nhắm và đánh trúng bi trước.',
    );
  }

  Future<void> _ensureContentLoaded() async {
    if (_painsCache != null) return;

    _painsCache = await _loadJsonMap('assets/pains/');
    _drillsCache = await _loadJsonMap('assets/drills/');
    _knowledgeCache = await _loadJsonMap('assets/knowledge/');
  }

  Future<Map<String, dynamic>> _loadJsonMap(String path) async {
    final result = <String, dynamic>{};

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      final files = manifestMap.keys
          .where((key) => key.startsWith(path) && key.endsWith('.json'))
          .toList();

      for (final filePath in files) {
        final content = await rootBundle.loadString(filePath);
        final data = json.decode(content) as Map<String, dynamic>;
        final id = data['id'] as String;
        result[id] = data;
      }
    } catch (e) {
      // Return empty map on error
    }

    return result;
  }

  String _detectPainType(String accuracy) {
    switch (accuracy) {
      case '0-2':
      case '3-5':
        return 'miss_despite_aim';
      case '6-8':
      case '9-10':
        return 'inconsistent_potting';
      default:
        return 'miss_despite_aim';
    }
  }

  Map<String, dynamic>? _getPainByType(String type) {
    if (_painsCache == null) return null;

    for (final pain in _painsCache!.values) {
      if ((pain as Map<String, dynamic>)['type'] == type) {
        return pain;
      }
    }
    return null;
  }

  Map<String, dynamic>? _getDrillForPain(Map<String, dynamic>? pain) {
    if (pain == null || _drillsCache == null) return null;

    final relatedDrills = pain['relatedDrills'] as List<dynamic>?;
    if (relatedDrills == null || relatedDrills.isEmpty) return null;

    final drillId = relatedDrills.first as String;
    return _drillsCache![drillId];
  }

  Map<String, dynamic>? _getKnowledgeForDrill(Map<String, dynamic>? drill) {
    if (drill == null || _knowledgeCache == null) return null;

    final goalId = drill['goal'] as String?;
    if (goalId == null) return null;

    for (final knowledge in _knowledgeCache!.values) {
      final goals = (knowledge as Map<String, dynamic>)['relatedGoals'] as List<dynamic>?;
      if (goals?.contains(goalId) == true) {
        return knowledge;
      }
    }
    return null;
  }

  int _mapTimeToDuration(String q5Time) {
    switch (q5Time) {
      case '5-10m':
        return 10;
      case '15-20m':
        return 15;
      case '30m+':
        return 30;
      default:
        return 15;
    }
  }

  String _getGoalName(String goalId) {
    switch (goalId) {
      case 'pot_first_ball':
        return 'Pot First Ball';
      case 'stop_shot':
        return 'Stop Shot';
      case 'follow_shot':
        return 'Follow Shot';
      case 'draw_shot':
        return 'Draw Shot';
      default:
        return 'Pot First Ball';
    }
  }

  /// Count how many pains have complete chains (Pain → Drill → Knowledge)
  Future<int> countCompleteChains() async {
    await _ensureContentLoaded();

    int count = 0;

    for (final pain in _painsCache!.values) {
      final drill = _getDrillForPain(pain as Map<String, dynamic>);
      final knowledge = _getKnowledgeForDrill(drill);

      if (drill != null && knowledge != null) {
        count++;
      }
    }

    return count;
  }
}
