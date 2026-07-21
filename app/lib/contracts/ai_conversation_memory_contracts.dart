import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/ai_response_processing_contracts.dart';

const aiConversationMemoryContractVersion = 1;
const aiConversationMemoryEntryContractVersion = 1;
const aiConversationMemoryPolicyVersion = 'ai-conversation-memory/1.0.0';

class AIConversationMemoryEntryContract {
  const AIConversationMemoryEntryContract._({
    required this.id,
    required this.position,
    required this.capabilityId,
    required this.processingDigest,
    required this.providerPayloadDigest,
    required this.providerRequestDigest,
    required this.providerResultDigest,
  });

  factory AIConversationMemoryEntryContract.fromProcessing({
    required int position,
    required AIResponseProcessingContract processing,
  }) {
    if (position < 1) {
      throw ArgumentError('Conversation Memory position is invalid.');
    }
    return AIConversationMemoryEntryContract._(
      id: 'ai-memory-entry.${processing.processingDigest.substring(0, 16)}',
      position: position,
      capabilityId: processing.capabilityId,
      processingDigest: processing.processingDigest,
      providerPayloadDigest: processing.providerPayloadDigest,
      providerRequestDigest: processing.providerRequestDigest,
      providerResultDigest: processing.providerResultDigest,
    );
  }

  final String id;
  final int position;
  final String capabilityId;
  final String processingDigest;
  final String providerPayloadDigest;
  final String providerRequestDigest;
  final String providerResultDigest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiConversationMemoryEntryContractVersion,
        'id': id,
        'position': position,
        'capabilityId': capabilityId,
        'processingDigest': processingDigest,
        'providerPayloadDigest': providerPayloadDigest,
        'providerRequestDigest': providerRequestDigest,
        'providerResultDigest': providerResultDigest,
      };
}

class AIConversationMemoryContract {
  const AIConversationMemoryContract._({
    required this.id,
    required this.capabilityId,
    required this.entries,
    required this.digest,
  });

  factory AIConversationMemoryContract.create(
    List<AIResponseProcessingContract> processingArtifacts,
  ) {
    if (processingArtifacts.isEmpty ||
        processingArtifacts
                .map((item) => item.processingDigest)
                .toSet()
                .length !=
            processingArtifacts.length) {
      throw ArgumentError('Conversation Memory interactions are invalid.');
    }
    final ordered = [...processingArtifacts]
      ..sort((a, b) => a.processingDigest.compareTo(b.processingDigest));
    final capabilityId = ordered.first.capabilityId;
    if (ordered.any((item) =>
        item.capabilityId != capabilityId ||
        item.processingDigest.trim().isEmpty ||
        item.providerPayloadDigest.trim().isEmpty ||
        item.providerRequestDigest.trim().isEmpty ||
        item.providerResultDigest.trim().isEmpty)) {
      throw ArgumentError('Conversation Memory provenance is incompatible.');
    }
    final entries = [
      for (var index = 0; index < ordered.length; index++)
        AIConversationMemoryEntryContract.fromProcessing(
          position: index + 1,
          processing: ordered[index],
        ),
    ];
    final payload = {
      'schemaVersion': aiConversationMemoryContractVersion,
      'capabilityId': capabilityId,
      'entries': entries.map((item) => item.toJson()).toList(),
      'policyVersion': aiConversationMemoryPolicyVersion,
    };
    final digest = _digest(payload);
    return AIConversationMemoryContract._(
      id: 'ai-conversation-memory.${digest.substring(0, 16)}',
      capabilityId: capabilityId,
      entries: List.unmodifiable(entries),
      digest: digest,
    );
  }

  final String id;
  final String capabilityId;
  final List<AIConversationMemoryEntryContract> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': aiConversationMemoryContractVersion,
        'id': id,
        'capabilityId': capabilityId,
        'entries': entries.map((item) => item.toJson()).toList(),
        'policyVersion': aiConversationMemoryPolicyVersion,
        'digest': digest,
      };
}

class AIConversationMemoryProjector {
  const AIConversationMemoryProjector();

  AIConversationMemoryContract project(
    List<AIResponseProcessingContract> processingArtifacts,
  ) =>
      AIConversationMemoryContract.create(processingArtifacts);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
