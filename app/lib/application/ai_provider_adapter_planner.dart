import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/transport_adapter_planner.dart';
import 'package:pool_os/contracts/ai_coach_interaction_surface_contracts.dart';

const aiProviderAdapterPlannerVersion = 1;
const aiProviderAdapterPlannerPolicyVersion =
    'ai-provider-adapter-planner/1.0.0';

enum AIProviderAdapterLogPhase {
  validateInputs,
  orderFeatures,
  bindAIInteractionProvenance,
  completed,
}

class AIProviderAdapterEntry {
  const AIProviderAdapterEntry._({
    required this.aiProviderAdapterEntryId,
    required this.featureId,
    required this.transportAdapterEntryId,
    required this.position,
    required this.transportAdapterPlanDigest,
    required this.aiCoachInteractionSurfaceDigest,
    required this.provenanceDigest,
    required this.digest,
  });

  factory AIProviderAdapterEntry.create({
    required String featureId,
    required String transportAdapterEntryId,
    required int position,
    required String transportAdapterPlanDigest,
    required String aiCoachInteractionSurfaceDigest,
  }) {
    if (featureId.isEmpty ||
        transportAdapterEntryId.isEmpty ||
        position < 0 ||
        transportAdapterPlanDigest.isEmpty ||
        aiCoachInteractionSurfaceDigest.isEmpty) {
      throw ArgumentError('AI provider adapter entry is incomplete.');
    }
    final aiProviderAdapterEntryId = 'ai-provider-adapter.$featureId';
    final provenanceDigest = _digest({
      'transportAdapterPlanDigest': transportAdapterPlanDigest,
      'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
    });
    final payload = {
      'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
      'featureId': featureId,
      'transportAdapterEntryId': transportAdapterEntryId,
      'position': position,
      'transportAdapterPlanDigest': transportAdapterPlanDigest,
      'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
      'provenanceDigest': provenanceDigest,
    };
    return AIProviderAdapterEntry._(
      aiProviderAdapterEntryId: aiProviderAdapterEntryId,
      featureId: featureId,
      transportAdapterEntryId: transportAdapterEntryId,
      position: position,
      transportAdapterPlanDigest: transportAdapterPlanDigest,
      aiCoachInteractionSurfaceDigest: aiCoachInteractionSurfaceDigest,
      provenanceDigest: provenanceDigest,
      digest: _digest(payload),
    );
  }

  final String aiProviderAdapterEntryId;
  final String featureId;
  final String transportAdapterEntryId;
  final int position;
  final String transportAdapterPlanDigest;
  final String aiCoachInteractionSurfaceDigest;
  final String provenanceDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'aiProviderAdapterEntryId': aiProviderAdapterEntryId,
        'featureId': featureId,
        'transportAdapterEntryId': transportAdapterEntryId,
        'position': position,
        'transportAdapterPlanDigest': transportAdapterPlanDigest,
        'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
        'provenanceDigest': provenanceDigest,
        'digest': digest,
      };
}

class AIProviderAdapterLogEntry {
  const AIProviderAdapterLogEntry._({
    required this.phase,
    required this.position,
    required this.transportAdapterPlanDigest,
    required this.aiCoachInteractionSurfaceDigest,
    required this.aiProviderAdapterSetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory AIProviderAdapterLogEntry.create({
    required AIProviderAdapterLogPhase phase,
    required int position,
    required String transportAdapterPlanDigest,
    required String aiCoachInteractionSurfaceDigest,
    required String aiProviderAdapterSetDigest,
  }) {
    if (position < 0 ||
        transportAdapterPlanDigest.isEmpty ||
        aiCoachInteractionSurfaceDigest.isEmpty ||
        aiProviderAdapterSetDigest.isEmpty) {
      throw ArgumentError('AI provider adapter log is incomplete.');
    }
    final eventCode = 'ai-provider-adapter.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'transportAdapterPlanDigest': transportAdapterPlanDigest,
      'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
      'aiProviderAdapterSetDigest': aiProviderAdapterSetDigest,
      'eventCode': eventCode,
    };
    return AIProviderAdapterLogEntry._(
      phase: phase,
      position: position,
      transportAdapterPlanDigest: transportAdapterPlanDigest,
      aiCoachInteractionSurfaceDigest: aiCoachInteractionSurfaceDigest,
      aiProviderAdapterSetDigest: aiProviderAdapterSetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final AIProviderAdapterLogPhase phase;
  final int position;
  final String transportAdapterPlanDigest;
  final String aiCoachInteractionSurfaceDigest;
  final String aiProviderAdapterSetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'transportAdapterPlanDigest': transportAdapterPlanDigest,
        'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
        'aiProviderAdapterSetDigest': aiProviderAdapterSetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class AIProviderAdapterPlan {
  const AIProviderAdapterPlan._({
    required this.id,
    required this.transportAdapterPlanId,
    required this.transportAdapterPlanDigest,
    required this.aiCoachInteractionSurfaceId,
    required this.aiCoachInteractionSurfaceDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory AIProviderAdapterPlan.create({
    required TransportAdapterPlan transportAdapterPlan,
    required AICoachInteractionSurfaceContract aiCoachInteractionSurface,
    required List<AIProviderAdapterEntry> entries,
    required List<AIProviderAdapterLogEntry> log,
  }) {
    _validateInputs(
      transportAdapterPlan: transportAdapterPlan,
      aiCoachInteractionSurface: aiCoachInteractionSurface,
    );
    if (entries.length != transportAdapterPlan.entries.length) {
      throw ArgumentError('AI provider adapter coverage is incomplete.');
    }
    final configurationByFeature = {
      for (final entry in transportAdapterPlan.entries) entry.featureId: entry,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final aiProviderAdapterIds = <String>{};
    final featureIds = <String>{};
    final configurationAdapterIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final configurationEntry = configurationByFeature[entry.featureId];
      final expected = AIProviderAdapterEntry.create(
        featureId: entry.featureId,
        transportAdapterEntryId: entry.transportAdapterEntryId,
        position: position,
        transportAdapterPlanDigest: transportAdapterPlan.digest,
        aiCoachInteractionSurfaceDigest: aiCoachInteractionSurface.digest,
      );
      if (configurationEntry == null ||
          configurationEntry.position != position ||
          entry.position != position ||
          entry.transportAdapterEntryId !=
              configurationEntry.transportAdapterEntryId ||
          entry.transportAdapterPlanDigest != transportAdapterPlan.digest ||
          entry.aiCoachInteractionSurfaceDigest !=
              aiCoachInteractionSurface.digest ||
          entry.aiProviderAdapterEntryId != expected.aiProviderAdapterEntryId ||
          entry.provenanceDigest != expected.provenanceDigest ||
          entry.digest != expected.digest ||
          !aiProviderAdapterIds.add(entry.aiProviderAdapterEntryId) ||
          !featureIds.add(entry.featureId) ||
          !configurationAdapterIds.add(entry.transportAdapterEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('AI provider adapter provenance is invalid.');
      }
    }

    final aiProviderAdapterSetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != AIProviderAdapterLogPhase.values.length) {
      throw ArgumentError('AI provider adapter log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = AIProviderAdapterLogEntry.create(
        phase: AIProviderAdapterLogPhase.values[position],
        position: position,
        transportAdapterPlanDigest: transportAdapterPlan.digest,
        aiCoachInteractionSurfaceDigest: aiCoachInteractionSurface.digest,
        aiProviderAdapterSetDigest: aiProviderAdapterSetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.transportAdapterPlanDigest !=
              expected.transportAdapterPlanDigest ||
          entry.aiCoachInteractionSurfaceDigest !=
              expected.aiCoachInteractionSurfaceDigest ||
          entry.aiProviderAdapterSetDigest !=
              expected.aiProviderAdapterSetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('AI provider adapter log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': aiProviderAdapterPlannerVersion,
      'policyVersion': aiProviderAdapterPlannerPolicyVersion,
      'transportAdapterPlanId': transportAdapterPlan.id,
      'transportAdapterPlanDigest': transportAdapterPlan.digest,
      'aiCoachInteractionSurfaceId': aiCoachInteractionSurface.id,
      'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurface.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return AIProviderAdapterPlan._(
      id: 'ai-provider-adapter-plan.${digest.substring(0, 16)}',
      transportAdapterPlanId: transportAdapterPlan.id,
      transportAdapterPlanDigest: transportAdapterPlan.digest,
      aiCoachInteractionSurfaceId: aiCoachInteractionSurface.id,
      aiCoachInteractionSurfaceDigest: aiCoachInteractionSurface.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String transportAdapterPlanId;
  final String transportAdapterPlanDigest;
  final String aiCoachInteractionSurfaceId;
  final String aiCoachInteractionSurfaceDigest;
  final List<AIProviderAdapterEntry> entries;
  final List<AIProviderAdapterLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': aiProviderAdapterPlannerVersion,
        'policyVersion': aiProviderAdapterPlannerPolicyVersion,
        'id': id,
        'transportAdapterPlanId': transportAdapterPlanId,
        'transportAdapterPlanDigest': transportAdapterPlanDigest,
        'aiCoachInteractionSurfaceId': aiCoachInteractionSurfaceId,
        'aiCoachInteractionSurfaceDigest': aiCoachInteractionSurfaceDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class AIProviderAdapterPlanner {
  const AIProviderAdapterPlanner();

  AIProviderAdapterPlan plan({
    required TransportAdapterPlan transportAdapterPlan,
    required AICoachInteractionSurfaceContract aiCoachInteractionSurface,
  }) {
    _validateInputs(
      transportAdapterPlan: transportAdapterPlan,
      aiCoachInteractionSurface: aiCoachInteractionSurface,
    );
    final entries = [
      for (final configurationEntry in transportAdapterPlan.entries)
        AIProviderAdapterEntry.create(
          featureId: configurationEntry.featureId,
          transportAdapterEntryId: configurationEntry.transportAdapterEntryId,
          position: configurationEntry.position,
          transportAdapterPlanDigest: transportAdapterPlan.digest,
          aiCoachInteractionSurfaceDigest: aiCoachInteractionSurface.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final aiProviderAdapterSetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return AIProviderAdapterPlan.create(
      transportAdapterPlan: transportAdapterPlan,
      aiCoachInteractionSurface: aiCoachInteractionSurface,
      entries: entries,
      log: [
        for (var position = 0;
            position < AIProviderAdapterLogPhase.values.length;
            position++)
          AIProviderAdapterLogEntry.create(
            phase: AIProviderAdapterLogPhase.values[position],
            position: position,
            transportAdapterPlanDigest: transportAdapterPlan.digest,
            aiCoachInteractionSurfaceDigest: aiCoachInteractionSurface.digest,
            aiProviderAdapterSetDigest: aiProviderAdapterSetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required TransportAdapterPlan transportAdapterPlan,
  required AICoachInteractionSurfaceContract aiCoachInteractionSurface,
}) {
  if (transportAdapterPlan.id.isEmpty ||
      transportAdapterPlan.digest.isEmpty ||
      transportAdapterPlan.entries.isEmpty ||
      aiCoachInteractionSurface.id.isEmpty ||
      aiCoachInteractionSurface.digest.isEmpty ||
      aiCoachInteractionSurface.entries.isEmpty) {
    throw ArgumentError('AI provider adapter inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
