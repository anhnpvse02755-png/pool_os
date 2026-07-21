import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/player_model_contracts.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';

const playerProfileProjectionContractVersion = 1;

class PlayerProfileEntry {
  const PlayerProfileEntry({
    required this.playerId,
    required this.featureId,
    required this.position,
    required this.progressDigest,
    required this.shellDigest,
  });

  final String playerId;
  final String featureId;
  final int position;
  final String progressDigest;
  final String shellDigest;

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'featureId': featureId,
        'position': position,
        'progressDigest': progressDigest,
        'shellDigest': shellDigest,
      };
}

class PlayerProfileProjectionContract {
  const PlayerProfileProjectionContract._({
    required this.id,
    required this.playerId,
    required this.progressDigest,
    required this.shellDigest,
    required this.entries,
    required this.digest,
  });

  factory PlayerProfileProjectionContract.create({
    required PlayerProgressSnapshot progress,
    required ProductShellContract shell,
    required List<PlayerProfileEntry> entries,
  }) {
    if (progress.playerId.trim().isEmpty || shell.nodes.isEmpty) {
      throw ArgumentError('Player profile projection sources are invalid.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final featureIds = ordered.map((entry) => entry.featureId).toSet();
    final positions = ordered.map((entry) => entry.position).toSet();
    final shellByPosition = {
      for (final node in shell.nodes) node.position: node,
    };
    if (ordered.length != shell.nodes.length ||
        featureIds.length != ordered.length ||
        positions.length != ordered.length) {
      throw ArgumentError(
          'Player profile entries are incomplete or duplicate.');
    }
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final shellNode = shellByPosition[position];
      if (shellNode == null ||
          entry.position != position ||
          entry.playerId != progress.playerId ||
          entry.featureId != shellNode.featureId ||
          entry.progressDigest != progress.digest ||
          entry.shellDigest != shell.digest) {
        throw ArgumentError('Player profile provenance is stale or foreign.');
      }
    }
    final payload = {
      'schemaVersion': playerProfileProjectionContractVersion,
      'playerId': progress.playerId,
      'progressDigest': progress.digest,
      'shellDigest': shell.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return PlayerProfileProjectionContract._(
      id: 'player-profile-projection.${digest.substring(0, 16)}',
      playerId: progress.playerId,
      progressDigest: progress.digest,
      shellDigest: shell.digest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String playerId;
  final String progressDigest;
  final String shellDigest;
  final List<PlayerProfileEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': playerProfileProjectionContractVersion,
        'id': id,
        'playerId': playerId,
        'progressDigest': progressDigest,
        'shellDigest': shellDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class PlayerProfileProjector {
  const PlayerProfileProjector();

  PlayerProfileProjectionContract project({
    required PlayerProgressSnapshot progress,
    required ProductShellContract shell,
  }) {
    final entries = [
      for (final node in shell.nodes)
        PlayerProfileEntry(
          playerId: progress.playerId,
          featureId: node.featureId,
          position: node.position,
          progressDigest: progress.digest,
          shellDigest: shell.digest,
        ),
    ];
    return PlayerProfileProjectionContract.create(
      progress: progress,
      shell: shell,
      entries: entries,
    );
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
