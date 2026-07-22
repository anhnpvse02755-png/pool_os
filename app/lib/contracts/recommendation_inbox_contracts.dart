import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_decision_view_contracts.dart';
import 'package:pool_os/contracts/ordered_recommendation_view_contracts.dart';

const recommendationInboxContractVersion = 1;

class RecommendationInboxEntry {
  const RecommendationInboxEntry({
    required this.inboxEntryId,
    required this.recommendationId,
    required this.recommendationDigest,
    required this.decisionViewDigest,
    required this.recommendationViewDigest,
    required this.playerId,
    required this.position,
    required this.planningNodeId,
    required this.priorityBand,
    required this.executionId,
    required this.executionDigest,
  });

  final String inboxEntryId;
  final String recommendationId;
  final String recommendationDigest;
  final String decisionViewDigest;
  final String recommendationViewDigest;
  final String playerId;
  final int position;
  final String planningNodeId;
  final RecommendationPriorityBand priorityBand;
  final String? executionId;
  final String? executionDigest;

  Map<String, dynamic> toJson() => {
        'inboxEntryId': inboxEntryId,
        'recommendationId': recommendationId,
        'recommendationDigest': recommendationDigest,
        'decisionViewDigest': decisionViewDigest,
        'recommendationViewDigest': recommendationViewDigest,
        'playerId': playerId,
        'position': position,
        'planningNodeId': planningNodeId,
        'priorityBand': priorityBand.name,
        if (executionId != null) 'executionId': executionId,
        if (executionDigest != null) 'executionDigest': executionDigest,
      };
}

class RecommendationInboxContract {
  const RecommendationInboxContract._({
    required this.id,
    required this.playerId,
    required this.decisionViewDigest,
    required this.recommendationViewDigest,
    required this.entries,
    required this.digest,
  });

  factory RecommendationInboxContract.create({
    required CoachDecisionViewContract decisionView,
    required OrderedRecommendationViewContract recommendationView,
    required List<RecommendationInboxEntry> entries,
  }) {
    if (decisionView.playerId != recommendationView.playerId ||
        decisionView.entries.isEmpty ||
        recommendationView.items.isEmpty ||
        entries.length != recommendationView.items.length) {
      throw ArgumentError('Recommendation inbox inputs are stale or foreign.');
    }
    final decisionByPosition = {
      for (final item in decisionView.entries) item.position: item,
    };
    final recommendationIds = <String>{};
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (ordered.length != recommendationView.items.length) {
      throw ArgumentError('Recommendation inbox entries are incomplete.');
    }
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final item = recommendationView.items[index];
      final decisionEntry = decisionByPosition[entry.position - 1];
      if (entry.position != item.position ||
          decisionEntry == null ||
          entry.recommendationId != item.recommendationId ||
          entry.recommendationDigest != item.recommendationDigest ||
          entry.playerId != recommendationView.playerId ||
          entry.planningNodeId != decisionEntry.planningNodeId ||
          entry.decisionViewDigest != decisionView.digest ||
          entry.recommendationViewDigest != recommendationView.digest ||
          entry.priorityBand != item.band ||
          entry.executionId != item.executionId ||
          entry.executionDigest != item.executionDigest ||
          !recommendationIds.add(entry.recommendationId)) {
        throw ArgumentError('Recommendation inbox provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': recommendationInboxContractVersion,
      'playerId': recommendationView.playerId,
      'decisionViewDigest': decisionView.digest,
      'recommendationViewDigest': recommendationView.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RecommendationInboxContract._(
      id: 'recommendation-inbox.${digest.substring(0, 16)}',
      playerId: recommendationView.playerId,
      decisionViewDigest: decisionView.digest,
      recommendationViewDigest: recommendationView.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String decisionViewDigest;
  final String recommendationViewDigest;
  final List<RecommendationInboxEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': recommendationInboxContractVersion,
        'id': id,
        'playerId': playerId,
        'decisionViewDigest': decisionViewDigest,
        'recommendationViewDigest': recommendationViewDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class RecommendationInboxProjector {
  const RecommendationInboxProjector();

  RecommendationInboxContract project({
    required CoachDecisionViewContract decisionView,
    required OrderedRecommendationViewContract recommendationView,
  }) {
    final decisionByPosition = {
      for (final entry in decisionView.entries) entry.position: entry,
    };
    for (final item in recommendationView.items) {
      if (!decisionByPosition.containsKey(item.position - 1)) {
        throw ArgumentError('Recommendation inbox has an orphan reference.');
      }
    }
    return RecommendationInboxContract.create(
      decisionView: decisionView,
      recommendationView: recommendationView,
      entries: [
        for (final item in recommendationView.items)
          RecommendationInboxEntry(
            inboxEntryId: 'recommendation-inbox-entry.${item.recommendationId}',
            recommendationId: item.recommendationId,
            recommendationDigest: item.recommendationDigest,
            decisionViewDigest: decisionView.digest,
            recommendationViewDigest: recommendationView.digest,
            playerId: recommendationView.playerId,
            position: item.position,
            planningNodeId:
                decisionByPosition[item.position - 1]!.planningNodeId,
            priorityBand: item.band,
            executionId: item.executionId,
            executionDigest: item.executionDigest,
          ),
      ],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
