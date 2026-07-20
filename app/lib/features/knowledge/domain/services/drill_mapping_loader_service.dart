import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// Drill mapping metadata model
class DrillMappingMetadata {
  final String version;
  final int totalMappings;
  final int totalDrills;
  final int totalTechniques;

  const DrillMappingMetadata({
    required this.version,
    required this.totalMappings,
    required this.totalDrills,
    required this.totalTechniques,
  });

  factory DrillMappingMetadata.fromJson(Map<String, dynamic> json) {
    return DrillMappingMetadata(
      version: json['version'] as String? ?? '1.0.0',
      totalMappings: json['totalMappings'] as int? ?? 0,
      totalDrills: json['totalDrills'] as int? ?? 0,
      totalTechniques: json['totalTechniques'] as int? ?? 0,
    );
  }
}

/// Drill mapping loader service.
/// Maps between knowledge items and drills.
/// Completely independent - Pool OS calls only this service.
final drillMappingLoaderProvider = Provider<DrillMappingLoaderService>((ref) {
  return DrillMappingLoaderService(
    ref.watch(knowledgeRepositoryProvider),
  );
});

class DrillMappingLoaderService {
  final KnowledgeRepository _repository;
  static const String _mappingPath = 'assets/knowledge/drill_mapping.json';
  
  DrillMappingMetadata? _metadata;

  DrillMappingLoaderService(this._repository);

  /// Get all drills for a knowledge item
  List<Drill> getDrillsForKnowledge(KnowledgeItem item) {
    return _repository.drillsFor(item);
  }

  /// Get all drills for multiple knowledge items
  List<Drill> getDrillsForKnowledgeItems(List<KnowledgeItem> items) {
    final drills = <Drill>{};
    for (final item in items) {
      drills.addAll(getDrillsForKnowledge(item));
    }
    return drills.toList();
  }

  /// Get all knowledge items that reference a drill
  Future<List<KnowledgeItem>> getKnowledgeForDrill(String drillCode) async {
    final all = await _repository.getAll();
    return all.where((item) => item.drillRefs.contains(drillCode)).toList();
  }

  /// Get all drills grouped by category
  Map<String, List<Drill>> getDrillsByCategory() {
    return DrillLibrary.getDrillsGroupedByCategory();
  }

  /// Get all drills grouped by difficulty
  Map<String, List<Drill>> getDrillsByDifficulty() {
    final grouped = <String, List<Drill>>{};
    for (final drill in DrillLibrary.getAllDrills()) {
      grouped.putIfAbsent(drill.difficulty.name, () => []).add(drill);
    }
    return grouped;
  }

  /// Get all drills grouped by skill level
  Map<String, List<Drill>> getDrillsBySkillLevel() {
    return DrillLibrary.getDrillsGroupedBySkillLevel();
  }

  /// Get drills by skill ID
  List<Drill> getDrillsBySkill(String skillId) {
    return DrillLibrary.getDrillsBySkill(skillId);
  }

  /// Get drill by code
  Drill? getDrillByCode(String code) {
    return DrillLibrary.getDrillByCode(code);
  }

  /// Get all available drills
  List<Drill> getAllDrills() {
    return DrillLibrary.getAllDrills();
  }

  /// Get drill count
  int getDrillCount() {
    return DrillLibrary.getAllDrills().length;
  }

  /// Get metadata
  Future<DrillMappingMetadata> getMetadata() async {
    if (_metadata != null) return _metadata!;
    
    try {
      final raw = await rootBundle.loadString(_mappingPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      
      final all = await _repository.getAll();
      int totalMappings = 0;
      for (final item in all) {
        totalMappings += item.drillRefs.length;
      }
      
      _metadata = DrillMappingMetadata(
        version: json['metadata']?['version'] as String? ?? '1.0.0',
        totalMappings: totalMappings,
        totalDrills: DrillLibrary.getAllDrills().length,
        totalTechniques: all.where((i) => i.type == KnowledgeType.technique).length,
      );
      return _metadata!;
    } catch (e) {
      _metadata = DrillMappingMetadata(
        version: '1.0.0',
        totalMappings: 0,
        totalDrills: DrillLibrary.getAllDrills().length,
        totalTechniques: 0,
      );
      return _metadata!;
    }
  }

  /// Get drill summary for a knowledge item
  DrillSummary getDrillSummary(KnowledgeItem item) {
    final drills = getDrillsForKnowledge(item);
    if (drills.isEmpty) {
      return const DrillSummary(
        totalDrills: 0,
        avgDifficulty: 0,
        totalDuration: 0,
        categories: [],
      );
    }

    double totalDifficulty = 0;
    int totalDuration = 0;
    final categories = <String>{};

    for (final drill in drills) {
      totalDifficulty += drill.difficultyStars;
      totalDuration += drill.timeLimitMinutes;
      categories.add(drill.category.name);
    }

    return DrillSummary(
      totalDrills: drills.length,
      avgDifficulty: totalDifficulty / drills.length,
      totalDuration: totalDuration,
      categories: categories.toList(),
    );
  }

  /// Search drills by name or description
  List<Drill> searchDrills(String query) {
    final normalizedQuery = query.toLowerCase();
    return DrillLibrary.getAllDrills().where((drill) {
      return drill.name.toLowerCase().contains(normalizedQuery) ||
          drill.nameVi.toLowerCase().contains(normalizedQuery) ||
          drill.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }
}

/// Summary of drills for a knowledge item
class DrillSummary {
  final int totalDrills;
  final double avgDifficulty;
  final int totalDuration;
  final List<String> categories;

  const DrillSummary({
    required this.totalDrills,
    required this.avgDifficulty,
    required this.totalDuration,
    required this.categories,
  });
}
