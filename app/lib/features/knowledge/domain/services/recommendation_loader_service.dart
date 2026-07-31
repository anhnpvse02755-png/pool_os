import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// Recommendation metadata model
class RecommendationMetadata {
  final String version;
  final int totalRecommendations;
  final List<String> supportedLevels;

  const RecommendationMetadata({
    required this.version,
    required this.totalRecommendations,
    required this.supportedLevels,
  });

  factory RecommendationMetadata.fromJson(Map<String, dynamic> json) {
    return RecommendationMetadata(
      version: json['version'] as String? ?? '1.0.0',
      totalRecommendations: json['totalRecommendations'] as int? ?? 0,
      supportedLevels: (json['supportedLevels'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
    );
  }
}

/// Recommendation result model
class Recommendation {
  final KnowledgeItem item;
  final double score;
  final String reason;

  const Recommendation({
    required this.item,
    required this.score,
    required this.reason,
  });
}

/// Player profile model for recommendations
class PlayerProfile {
  final String currentLevel;
  final Set<String> strengthAreas;
  final Set<String> weaknessAreas;
  final Set<String> completedItems;
  final Set<String> interests;
  final int practiceHoursPerWeek;
  final String preferredGameType;

  const PlayerProfile({
    required this.currentLevel,
    this.strengthAreas = const {},
    this.weaknessAreas = const {},
    this.completedItems = const {},
    this.interests = const {},
    this.practiceHoursPerWeek = 0,
    this.preferredGameType = '8-ball',
  });
}

/// Recommendation loader service.
/// Completely independent - Pool OS calls only this service.
final recommendationLoaderProvider = Provider<RecommendationLoaderService>((ref) {
  return RecommendationLoaderService(ref.watch(knowledgeRepositoryProvider));
});

class RecommendationLoaderService {
  final KnowledgeRepository _repository;
  static const String _metadataPath = 'assets/knowledge/recommendation_metadata.json';
  
  RecommendationMetadata? _metadata;

  RecommendationLoaderService(this._repository);

  /// Get personalized recommendations based on player profile
  ///
  /// EPIC 05 PO 2026-07-31 — capability-disabled. Spec §5 Forbidden list:
  /// "No Recommendation". UI surfaces the closure via
  /// `RecommendationCapability.unavailable`. Legacy RFC-REC-001 algorithm
  /// body retained for post-Beta reference only.
  Future<List<Recommendation>> getRecommended(PlayerProfile profile) async {
    throw _capabilityClosed('getRecommended');
  }

  /// Get recommended items for a specific skill — capability-disabled.
  Future<List<KnowledgeItem>> getRecommendedForSkill(
    String skillId,
    String level,
  ) async {
    throw _capabilityClosed('getRecommendedForSkill');
  }

  /// Get related recommendations based on a knowledge item — capability-disabled.
  Future<List<KnowledgeItem>> getRelatedRecommendations(KnowledgeItem item) async {
    throw _capabilityClosed('getRelatedRecommendations');
  }

  /// Get recommendations based on mistakes — capability-disabled.
  Future<List<KnowledgeItem>> getBasedOnMistakes(List<String> mistakeIds) async {
    throw _capabilityClosed('getBasedOnMistakes');
  }

  /// PO 2026-07-31 — capability closure guard.
  Never _capabilityClosed(String entry) {
    throw UnsupportedError(
      'Recommendation capability is closed in Pool OS Beta (PO 2026-07-31, '
      'spec §5 Forbidden). Entry "$entry" disabled.',
    );
  }

  /// Get metadata
  Future<RecommendationMetadata> getMetadata() async {
    if (_metadata != null) return _metadata!;
    
    try {
      final raw = await rootBundle.loadString(_metadataPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _metadata = RecommendationMetadata.fromJson(json);
      return _metadata!;
    } catch (e) {
      _metadata = const RecommendationMetadata(
        version: '1.0.0',
        totalRecommendations: 0,
        supportedLevels: [],
      );
      return _metadata!;
    }
  }

  double _calculateScore(KnowledgeItem item, PlayerProfile profile) {
    double score = 0;
    
    // Difficulty match (prefer slightly challenging)
    switch (item.difficulty) {
      case KnowledgeDifficulty.beginner:
        if (profile.currentLevel == 'I') score += 10;
        else if (profile.currentLevel == 'H') score += 5;
        break;
      case KnowledgeDifficulty.intermediate:
        if (profile.currentLevel == 'H') score += 10;
        else if (profile.currentLevel == 'G') score += 5;
        break;
      case KnowledgeDifficulty.advanced:
        if (profile.currentLevel == 'G') score += 10;
        else if (profile.currentLevel == 'F') score += 5;
        break;
      case KnowledgeDifficulty.professional:
        if (profile.currentLevel == 'E' || profile.currentLevel == 'D') score += 10;
        break;
    }
    
    // Weakness area match
    if (profile.weaknessAreas.contains(item.category)) {
      score += 15;
    }
    
    // Interest match
    if (profile.interests.contains(item.category)) {
      score += 5;
    }
    
    // Already has prerequisites completed
    final prereqsCompleted = item.prerequisites
        .where((p) => profile.completedItems.contains(p))
        .length;
    score += prereqsCompleted * 3;
    
    // Practice time bonus
    if (profile.practiceHoursPerWeek >= 10) {
      score += 5;
    }
    
    return score;
  }

  String _getRecommendationReason(KnowledgeItem item, PlayerProfile profile) {
    if (profile.weaknessAreas.contains(item.category)) {
      return 'Addresses your ${item.category} skills';
    }
    
    if (item.prerequisites.isNotEmpty) {
      final completedPrereqs = item.prerequisites
          .where((p) => profile.completedItems.contains(p))
          .length;
      if (completedPrereqs == item.prerequisites.length) {
        return 'You have completed prerequisites';
      }
    }
    
    return 'Recommended for your level';
  }
}
