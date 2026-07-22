import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_coach_interaction_surface_contracts.dart';
import 'package:pool_os/contracts/execution_outcome_projection_contracts.dart';
import 'package:pool_os/contracts/player_profile_projection_contracts.dart';
import 'package:pool_os/contracts/recommendation_inbox_contracts.dart';

const productAnalyticsProjectionContractVersion = 1;

class ProductAnalyticsEntry {
  const ProductAnalyticsEntry({
    required this.analyticsEntryId,
    required this.playerId,
    required this.capabilityId,
    required this.position,
    required this.recommendationId,
    required this.executionOutcomeId,
    required this.interactionId,
    required this.profileDigest,
    required this.recommendationDigest,
    required this.executionDigest,
    required this.interactionDigest,
  });

  final String analyticsEntryId;
  final String playerId;
  final String capabilityId;
  final int position;
  final String recommendationId;
  final String executionOutcomeId;
  final String interactionId;
  final String profileDigest;
  final String recommendationDigest;
  final String executionDigest;
  final String interactionDigest;

  Map<String, dynamic> toJson() => {
        'analyticsEntryId': analyticsEntryId,
        'playerId': playerId,
        'capabilityId': capabilityId,
        'position': position,
        'recommendationId': recommendationId,
        'executionOutcomeId': executionOutcomeId,
        'interactionId': interactionId,
        'profileDigest': profileDigest,
        'recommendationDigest': recommendationDigest,
        'executionDigest': executionDigest,
        'interactionDigest': interactionDigest,
      };
}

class ProductAnalyticsProjectionContract {
  const ProductAnalyticsProjectionContract._({
    required this.id,
    required this.playerId,
    required this.capabilityId,
    required this.profileDigest,
    required this.recommendationDigest,
    required this.executionDigest,
    required this.interactionDigest,
    required this.entries,
    required this.digest,
  });

  factory ProductAnalyticsProjectionContract.create({
    required PlayerProfileProjectionContract profile,
    required RecommendationInboxContract recommendationInbox,
    required ExecutionOutcomeProjectionContract executionOutcome,
    required AICoachInteractionSurfaceContract interactionSurface,
    required List<ProductAnalyticsEntry> entries,
  }) {
    final playerId = profile.playerId;
    if (profile.entries.isEmpty ||
        playerId != recommendationInbox.playerId ||
        playerId != executionOutcome.playerId ||
        playerId != interactionSurface.playerId ||
        recommendationInbox.digest != executionOutcome.inboxDigest ||
        executionOutcome.digest != interactionSurface.executionOutcomeDigest ||
        recommendationInbox.entries.length != executionOutcome.entries.length ||
        executionOutcome.entries.length != interactionSurface.entries.length ||
        entries.length != interactionSurface.entries.length ||
        entries.isEmpty) {
      throw ArgumentError('Product analytics inputs are stale or foreign.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final positions = <int>{};
    final analyticsIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final recommendation = recommendationInbox.entries[index];
      final execution = executionOutcome.entries[index];
      final interaction = interactionSurface.entries[index];
      if (entry.position != index + 1 ||
          entry.position != recommendation.position ||
          entry.position != execution.position ||
          entry.position != interaction.position ||
          entry.playerId != playerId ||
          entry.capabilityId != interactionSurface.capabilityId ||
          entry.recommendationId != recommendation.recommendationId ||
          entry.executionOutcomeId != execution.executionOutcomeId ||
          entry.interactionId != interaction.interactionId ||
          entry.profileDigest != profile.digest ||
          entry.recommendationDigest != recommendationInbox.digest ||
          entry.executionDigest != executionOutcome.digest ||
          entry.interactionDigest != interactionSurface.digest ||
          entry.analyticsEntryId.trim().isEmpty ||
          entry.recommendationId.trim().isEmpty ||
          entry.executionOutcomeId.trim().isEmpty ||
          entry.interactionId.trim().isEmpty ||
          !positions.add(entry.position) ||
          !analyticsIds.add(entry.analyticsEntryId)) {
        throw ArgumentError('Product analytics provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': productAnalyticsProjectionContractVersion,
      'playerId': playerId,
      'capabilityId': interactionSurface.capabilityId,
      'profileDigest': profile.digest,
      'recommendationDigest': recommendationInbox.digest,
      'executionDigest': executionOutcome.digest,
      'interactionDigest': interactionSurface.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductAnalyticsProjectionContract._(
      id: 'product-analytics.${digest.substring(0, 16)}',
      playerId: playerId,
      capabilityId: interactionSurface.capabilityId,
      profileDigest: profile.digest,
      recommendationDigest: recommendationInbox.digest,
      executionDigest: executionOutcome.digest,
      interactionDigest: interactionSurface.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String capabilityId;
  final String profileDigest;
  final String recommendationDigest;
  final String executionDigest;
  final String interactionDigest;
  final List<ProductAnalyticsEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': productAnalyticsProjectionContractVersion,
        'id': id,
        'playerId': playerId,
        'capabilityId': capabilityId,
        'profileDigest': profileDigest,
        'recommendationDigest': recommendationDigest,
        'executionDigest': executionDigest,
        'interactionDigest': interactionDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ProductAnalyticsProjector {
  const ProductAnalyticsProjector();

  ProductAnalyticsProjectionContract project({
    required PlayerProfileProjectionContract profile,
    required RecommendationInboxContract recommendationInbox,
    required ExecutionOutcomeProjectionContract executionOutcome,
    required AICoachInteractionSurfaceContract interactionSurface,
  }) =>
      ProductAnalyticsProjectionContract.create(
        profile: profile,
        recommendationInbox: recommendationInbox,
        executionOutcome: executionOutcome,
        interactionSurface: interactionSurface,
        entries: [
          for (var index = 0;
              index < interactionSurface.entries.length;
              index++)
            ProductAnalyticsEntry(
              analyticsEntryId:
                  'product-analytics-entry.${interactionSurface.entries[index].interactionId}',
              playerId: profile.playerId,
              capabilityId: interactionSurface.capabilityId,
              position: interactionSurface.entries[index].position,
              recommendationId:
                  recommendationInbox.entries[index].recommendationId,
              executionOutcomeId:
                  executionOutcome.entries[index].executionOutcomeId,
              interactionId: interactionSurface.entries[index].interactionId,
              profileDigest: profile.digest,
              recommendationDigest: recommendationInbox.digest,
              executionDigest: executionOutcome.digest,
              interactionDigest: interactionSurface.digest,
            ),
        ],
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
