import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/coach_context_contracts.dart';
import 'package:pool_os/contracts/training_session_workspace_contracts.dart';

const coachDecisionViewContractVersion = 1;

class CoachDecisionViewEntry {
  const CoachDecisionViewEntry({
    required this.playerId,
    required this.position,
    required this.planningNodeId,
    required this.workspaceDigest,
    required this.coachContextDigest,
  });

  final String playerId;
  final int position;
  final String planningNodeId;
  final String workspaceDigest;
  final String coachContextDigest;

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'position': position,
        'planningNodeId': planningNodeId,
        'workspaceDigest': workspaceDigest,
        'coachContextDigest': coachContextDigest,
      };
}

class CoachDecisionViewContract {
  const CoachDecisionViewContract._({
    required this.id,
    required this.playerId,
    required this.workspaceDigest,
    required this.coachContextDigest,
    required this.entries,
    required this.digest,
  });

  factory CoachDecisionViewContract.create({
    required TrainingSessionWorkspaceContract workspace,
    required CoachContextContract context,
    required List<CoachDecisionViewEntry> entries,
  }) {
    if (workspace.playerId != context.profile.playerId ||
        workspace.entries.isEmpty ||
        entries.length != workspace.entries.length) {
      throw ArgumentError('Coach decision view inputs are stale or foreign.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final workspaceNodeIds = {
      for (final entry in workspace.entries) entry.planningNodeId,
    };
    final nodeIds = ordered.map((entry) => entry.planningNodeId).toSet();
    final positions = ordered.map((entry) => entry.position).toSet();
    if (nodeIds.length != ordered.length ||
        positions.length != ordered.length) {
      throw ArgumentError('Coach decision view entries are duplicate.');
    }
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      if (entry.position != position ||
          entry.playerId != context.profile.playerId ||
          !workspaceNodeIds.contains(entry.planningNodeId) ||
          entry.workspaceDigest != workspace.digest ||
          entry.coachContextDigest != context.digest) {
        throw ArgumentError('Coach decision view provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': coachDecisionViewContractVersion,
      'playerId': context.profile.playerId,
      'workspaceDigest': workspace.digest,
      'coachContextDigest': context.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return CoachDecisionViewContract._(
      id: 'coach-decision-view.${digest.substring(0, 16)}',
      playerId: context.profile.playerId,
      workspaceDigest: workspace.digest,
      coachContextDigest: context.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String workspaceDigest;
  final String coachContextDigest;
  final List<CoachDecisionViewEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': coachDecisionViewContractVersion,
        'id': id,
        'playerId': playerId,
        'workspaceDigest': workspaceDigest,
        'coachContextDigest': coachContextDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class CoachDecisionViewProjector {
  const CoachDecisionViewProjector();

  CoachDecisionViewContract project({
    required TrainingSessionWorkspaceContract workspace,
    required CoachContextContract context,
  }) {
    final source = [...workspace.entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    return CoachDecisionViewContract.create(
      workspace: workspace,
      context: context,
      entries: [
        for (var position = 0; position < source.length; position++)
          CoachDecisionViewEntry(
            playerId: context.profile.playerId,
            position: position,
            planningNodeId: source[position].planningNodeId,
            workspaceDigest: workspace.digest,
            coachContextDigest: context.digest,
          ),
      ],
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
