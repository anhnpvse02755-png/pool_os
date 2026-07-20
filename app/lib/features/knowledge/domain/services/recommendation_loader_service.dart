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
  Future<List<Recommendation>> getRecommended(PlayerProfile profile) async {
    final all = await _repository.getAll();
    final scored = <Recommendation>[];
    
    for (final item in all) {
      if (profile.completedItems.contains(item.id)) continue;
      
      double score = _calculateScore(item, profile);
      if (score > 0) {
        scored.add(Recommendation(
          item: item,
          score: score,
          reason: _getRecommendationReason(item, profile),
        ));
      }
    }
    
    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));
    
    return scored.take(20).toList();
  }

  /// Get recommended items for a specific skill
  Future<List<KnowledgeItem>> getRecommendedForSkill(
    String skillId, 
    String level,
  ) async {
    final all = await _repository.getAll();
    
    return all.where((item) {
      return item.skillId == skillId &&
          item.recommendedFor.contains(level);
    }).toList();
  }

  /// Get related recommendations based on a knowledge item
  Future<List<KnowledgeItem>> getRelatedRecommendations(KnowledgeItem item) async {
    return _repository.related(item);
  }

  /// Get recommendations based on mistakes
  Future<List<KnowledgeItem>> getBasedOnMistakes(List<String> mistakeIds) async {
    final all = await _repository.getAll();
    final recommendations = <KnowledgeItem>[];
    
    final mistakeSet = mistakeIds.toSet();
    
    for (final item in all) {
      // Find corrections that address these mistakes
      if (item.commonMistakes.isNotEmpty) {
        final hasMatchingMistake = item.commonMistakes.any((m) {
          return mistakeSet.any((mistakeId) {
            final mistakeName = mistakeId.split('.').last.replaceAll('_', ' ').toLowerCase();
            return m.toLowerCase().contains(mistakeName) ||
                   mistakeName.contains(m.toLowerCase());
          });
        });
        if (hasMatchingMistake) {
          recommendations.add(item);
        }
      }
      
      // Also include technique items that teach corrections
      if (item.corrections.isNotEmpty) {
        for (final mistakeId in mistakeSet) {
          final mistakeName = mistakeId.split('.').last.replaceAll('_', ' ').toLowerCase();
          if (item.corrections.any((c) => c.toLowerCase().contains(mistakeName))) {
            if (!recommendations.contains(item)) {
              recommendations.add(item);
            }
          }
        }
      }
    }
    
    return recommendations;
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
