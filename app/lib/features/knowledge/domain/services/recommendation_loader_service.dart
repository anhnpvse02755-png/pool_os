// EPIC 05 PO 2026-07-31 — Recommendation Loader Service, capability-closed.
//
// Spec §5 Forbidden list: "No Recommendation". Per EPIC 04 Capability
// Pattern, every public entry point returns
// [CapabilityResult.notAvailable] with a deterministic reason. No
// exceptions thrown.
//
// Models `RecommendationMetadata`, `RecommendationResource`,
// `PlayerProfile`, and `KnowledgeItem` (referenced as `dynamic` to
// avoid forcing the package re-export identifier) are retained so
// post-Beta work can re-enable the feature without a schema change.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/knowledge/domain/knowledge_capability.dart';

/// Recommendation metadata model — kept for post-Beta.
@immutable
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
              .toList() ??
          <String>[],
    );
  }
}

/// Recommendation resource — kept for post-Beta.
@immutable
class RecommendationResource {
  final String id;
  final String type;
  final String title;
  final String description;
  final int priority;

  const RecommendationResource({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.priority = 0,
  });
}

/// Player profile (loader variant) — kept for post-Beta.
@immutable
class PlayerProfileLoader {
  final String id;
  final String level;

  const PlayerProfileLoader({
    required this.id,
    required this.level,
  });
}

/// Recommendation Loader Service — capability-closed in Beta.
class RecommendationLoaderService {
  /// Get personalized recommendations — capability-disabled.
  Future<CapabilityResult<List<RecommendationResource>>> getRecommended(
    dynamic profile,
  ) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get recommended items for a specific skill — capability-disabled.
  Future<CapabilityResult<List<dynamic>>> getRecommendedForSkill(
    String skillId,
    String level,
  ) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get related recommendations based on a knowledge item — capability-disabled.
  Future<CapabilityResult<List<dynamic>>> getRelatedRecommendations(
    dynamic item,
  ) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Get recommendations based on mistakes — capability-disabled.
  Future<CapabilityResult<List<dynamic>>> getBasedOnMistakes(
    List<String> mistakeIds,
  ) async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }

  /// Static metadata — capability-disabled.
  Future<CapabilityResult<RecommendationMetadata>> getMetadata() async {
    return CapabilityResult.notAvailable(RecommendationCapability.reason);
  }
}

/// Provider wired to the capability-closed service.
final recommendationLoaderServiceProvider =
    Provider<RecommendationLoaderService>((ref) {
  return RecommendationLoaderService();
});