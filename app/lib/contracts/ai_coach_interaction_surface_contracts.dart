import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_conversation_memory_contracts.dart';
import 'package:pool_os/contracts/execution_outcome_projection_contracts.dart';

const aiCoachInteractionSurfaceContractVersion = 1;

class AICoachInteractionEntry {
  const AICoachInteractionEntry({
    required this.interactionId,
    required this.playerId,
    required this.executionOutcomeDigest,
    required this.conversationMemoryDigest,
    required this.capabilityId,
    required this.position,
    required this.processingDigest,
  });

  final String interactionId;
  final String playerId;
  final String executionOutcomeDigest;
  final String conversationMemoryDigest;
  final String capabilityId;
  final int position;
  final String processingDigest;

  Map<String, dynamic> toJson() => {
        'interactionId': interactionId,
        'playerId': playerId,
        'executionOutcomeDigest': executionOutcomeDigest,
        'conversationMemoryDigest': conversationMemoryDigest,
        'capabilityId': capabilityId,
        'position': position,
        'processingDigest': processingDigest,
      };
}

class AICoachInteractionSurfaceContract {
  const AICoachInteractionSurfaceContract._({
    required this.id,
    required this.playerId,
    required this.executionOutcomeDigest,
    required this.conversationMemoryDigest,
    required this.capabilityId,
    required this.entries,
    required this.digest,
  });

  factory AICoachInteractionSurfaceContract.create({
    required ExecutionOutcomeProjectionContract executionOutcome,
    required AIConversationMemoryContract conversationMemory,
    required List<AICoachInteractionEntry> entries,
  }) {
    if (executionOutcome.entries.isEmpty ||
        conversationMemory.entries.isEmpty ||
        executionOutcome.entries.length != conversationMemory.entries.length ||
        entries.length != executionOutcome.entries.length) {
      throw ArgumentError('AI Coach interaction coverage is invalid.');
    }
    if (conversationMemory.capabilityId.trim().isEmpty ||
        conversationMemory.digest.trim().isEmpty ||
        executionOutcome.digest.trim().isEmpty) {
      throw ArgumentError('AI Coach interaction provenance is malformed.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final positions = <int>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final outcome = executionOutcome.entries[index];
      final memory = conversationMemory.entries[index];
      if (entry.position != index + 1 ||
          entry.position != outcome.position ||
          entry.position != memory.position ||
          entry.playerId != executionOutcome.playerId ||
          entry.executionOutcomeDigest != executionOutcome.digest ||
          entry.conversationMemoryDigest != conversationMemory.digest ||
          entry.capabilityId != conversationMemory.capabilityId ||
          entry.processingDigest != memory.processingDigest ||
          entry.interactionId != 'ai-coach-interaction.${memory.id}' ||
          memory.processingDigest.trim().isEmpty ||
          !positions.add(entry.position)) {
        throw ArgumentError('AI Coach interaction provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': aiCoachInteractionSurfaceContractVersion,
      'playerId': executionOutcome.playerId,
      'executionOutcomeDigest': executionOutcome.digest,
      'conversationMemoryDigest': conversationMemory.digest,
      'capabilityId': conversationMemory.capabilityId,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return AICoachInteractionSurfaceContract._(
      id: 'ai-coach-interaction-surface.${digest.substring(0, 16)}',
      playerId: executionOutcome.playerId,
      executionOutcomeDigest: executionOutcome.digest,
      conversationMemoryDigest: conversationMemory.digest,
      capabilityId: conversationMemory.capabilityId,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String executionOutcomeDigest;
  final String conversationMemoryDigest;
  final String capabilityId;
  final List<AICoachInteractionEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiCoachInteractionSurfaceContractVersion,
        'id': id,
        'playerId': playerId,
        'executionOutcomeDigest': executionOutcomeDigest,
        'conversationMemoryDigest': conversationMemoryDigest,
        'capabilityId': capabilityId,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class AICoachInteractionSurfaceProjector {
  const AICoachInteractionSurfaceProjector();

  AICoachInteractionSurfaceContract project({
    required ExecutionOutcomeProjectionContract executionOutcome,
    required AIConversationMemoryContract conversationMemory,
  }) =>
      AICoachInteractionSurfaceContract.create(
        executionOutcome: executionOutcome,
        conversationMemory: conversationMemory,
        entries: [
          for (final memory in conversationMemory.entries)
            AICoachInteractionEntry(
              interactionId: 'ai-coach-interaction.${memory.id}',
              playerId: executionOutcome.playerId,
              executionOutcomeDigest: executionOutcome.digest,
              conversationMemoryDigest: conversationMemory.digest,
              capabilityId: conversationMemory.capabilityId,
              position: memory.position,
              processingDigest: memory.processingDigest,
            ),
        ],
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
