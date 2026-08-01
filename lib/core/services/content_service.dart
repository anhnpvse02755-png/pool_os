import 'dart:convert';
import 'package:flutter/services.dart';

/// Content Service - loads production JSON content
class ContentService {
  static const String _painsPath = 'assets/pains/';
  static const String _drillsPath = 'assets/drills/';
  static const String _knowledgePath = 'assets/knowledge/';

  /// Load all pains from JSON files
  Future<Map<String, dynamic>> loadAllPains() async {
    final pains = <String, dynamic>{};

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      final painFiles = manifestMap.keys
          .where((key) => key.startsWith(_painsPath) && key.endsWith('.json'))
          .toList();

      for (final filePath in painFiles) {
        final content = await rootBundle.loadString(filePath);
        final pain = json.decode(content) as Map<String, dynamic>;
        final id = pain['id'] as String;
        pains[id] = pain;
      }
    } catch (e) {
      // Fallback: return empty map
    }

    return pains;
  }

  /// Load all drills from JSON files
  Future<Map<String, dynamic>> loadAllDrills() async {
    final drills = <String, dynamic>{};

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      final drillFiles = manifestMap.keys
          .where((key) => key.startsWith(_drillsPath) && key.endsWith('.json'))
          .toList();

      for (final filePath in drillFiles) {
        final content = await rootBundle.loadString(filePath);
        final drill = json.decode(content) as Map<String, dynamic>;
        final id = drill['id'] as String;
        drills[id] = drill;
      }
    } catch (e) {
      // Fallback: return empty map
    }

    return drills;
  }

  /// Load all knowledge from JSON files
  Future<Map<String, dynamic>> loadAllKnowledge() async {
    final knowledge = <String, dynamic>{};

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifestMap = json.decode(manifestContent) as Map<String, dynamic>;

      final knowledgeFiles = manifestMap.keys
          .where((key) => key.startsWith(_knowledgePath) && key.endsWith('.json'))
          .toList();

      for (final filePath in knowledgeFiles) {
        final content = await rootBundle.loadString(filePath);
        final know = json.decode(content) as Map<String, dynamic>;
        final id = know['id'] as String;
        knowledge[id] = know;
      }
    } catch (e) {
      // Fallback: return empty map
    }

    return knowledge;
  }

  /// Get complete chain: Pain → Knowledge → Drill
  Future<Map<String, dynamic>?> getCompleteChain(String painId) async {
    final pains = await loadAllPains();
    final pain = pains[painId];

    if (pain == null) return null;

    final relatedDrillIds = pain['relatedDrills'] as List<dynamic>?;
    final relatedGoalId = (pain['relatedGoals'] as List<dynamic>?)?.firstOrNull as String?;

    if (relatedDrillIds == null || relatedDrillIds.isEmpty) return null;

    final drills = await loadAllDrills();
    final drillId = relatedDrillIds.first as String;
    final drill = drills[drillId];

    final knowledge = await loadAllKnowledge();
    final knowledgeId = drill?['videoSegment']?.toString().split('-').first ?? '';

    return {
      'pain': pain,
      'drill': drill,
      'knowledge': knowledge[knowledgeId],
      'goal': relatedGoalId,
    };
  }

  /// Count complete chains (Pain → Drill with content)
  Future<int> countCompleteChains() async {
    final pains = await loadAllPains();
    final drills = await loadAllDrills();

    int count = 0;

    for (final pain in pains.values) {
      final relatedDrills = pain['relatedDrills'] as List<dynamic>?;
      if (relatedDrills != null && relatedDrills.isNotEmpty) {
        final drillId = relatedDrills.first;
        if (drills.containsKey(drillId)) {
          count++;
        }
      }
    }

    return count;
  }
}
