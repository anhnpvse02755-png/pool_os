import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/recommendation_inbox_contracts.dart';
import 'package:pool_os/contracts/training_outcome_projection_contracts.dart';

const executionOutcomeProjectionContractVersion = 1;

class ExecutionOutcomeEntry {
  const ExecutionOutcomeEntry({
    required this.executionOutcomeId,
    required this.recommendationId,
    required this.inboxDigest,
    required this.executionResultDigest,
    required this.playerId,
    required this.position,
    required this.executionStatus,
    required this.outcomeReference,
  });

  final String executionOutcomeId;
  final String recommendationId;
  final String inboxDigest;
  final String executionResultDigest;
  final String playerId;
  final int position;
  final TrainingOutcomeKind executionStatus;
  final String? outcomeReference;

  Map<String, dynamic> toJson() => {
        'executionOutcomeId': executionOutcomeId,
        'recommendationId': recommendationId,
        'inboxDigest': inboxDigest,
        'executionResultDigest': executionResultDigest,
        'playerId': playerId,
        'position': position,
        'executionStatus': executionStatus.name,
        if (outcomeReference != null) 'outcomeReference': outcomeReference,
      };
}

class ExecutionOutcomeProjectionContract {
  const ExecutionOutcomeProjectionContract._({
    required this.id,
    required this.playerId,
    required this.inboxDigest,
    required this.executionResultDigest,
    required this.entries,
    required this.digest,
  });

  factory ExecutionOutcomeProjectionContract.create({
    required RecommendationInboxContract inbox,
    required TrainingOutcomeProjectionContract executionResult,
    required List<ExecutionOutcomeEntry> entries,
  }) {
    if (inbox.playerId != executionResult.playerId ||
        inbox.entries.isEmpty ||
        executionResult.items.isEmpty ||
        entries.length != inbox.entries.length ||
        entries.length != executionResult.items.length) {
      throw ArgumentError('Execution outcome inputs are stale or foreign.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final recommendationIds = <String>{};
    final positions = <int>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final inboxEntry = inbox.entries[index];
      final outcomeItem = executionResult.items[index];
      if (entry.position != index + 1 ||
          entry.position != inboxEntry.position ||
          entry.position != outcomeItem.position ||
          entry.recommendationId != inboxEntry.recommendationId ||
          entry.recommendationId != outcomeItem.recommendationId ||
          entry.playerId != inbox.playerId ||
          entry.inboxDigest != inbox.digest ||
          entry.executionResultDigest != executionResult.digest ||
          entry.executionStatus != outcomeItem.kind ||
          entry.outcomeReference != outcomeItem.executionRecordId ||
          !recommendationIds.add(entry.recommendationId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Execution outcome provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': executionOutcomeProjectionContractVersion,
      'playerId': inbox.playerId,
      'inboxDigest': inbox.digest,
      'executionResultDigest': executionResult.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ExecutionOutcomeProjectionContract._(
      id: 'execution-outcome.${digest.substring(0, 16)}',
      playerId: inbox.playerId,
      inboxDigest: inbox.digest,
      executionResultDigest: executionResult.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String inboxDigest;
  final String executionResultDigest;
  final List<ExecutionOutcomeEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': executionOutcomeProjectionContractVersion,
        'id': id,
        'playerId': playerId,
        'inboxDigest': inboxDigest,
        'executionResultDigest': executionResultDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ExecutionOutcomeProjector {
  const ExecutionOutcomeProjector();

  ExecutionOutcomeProjectionContract project({
    required RecommendationInboxContract inbox,
    required TrainingOutcomeProjectionContract executionResult,
  }) =>
      ExecutionOutcomeProjectionContract.create(
        inbox: inbox,
        executionResult: executionResult,
        entries: [
          for (final item in executionResult.items)
            ExecutionOutcomeEntry(
              executionOutcomeId: 'execution-outcome.${item.recommendationId}',
              recommendationId: item.recommendationId,
              inboxDigest: inbox.digest,
              executionResultDigest: executionResult.digest,
              playerId: inbox.playerId,
              position: item.position,
              executionStatus: item.kind,
              outcomeReference: item.executionRecordId,
            ),
        ],
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
