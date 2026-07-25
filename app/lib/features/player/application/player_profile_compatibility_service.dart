import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/player_repository.dart';
import '../domain/player_lifecycle_failure.dart';
import '../domain/player_profile_compatibility.dart';

final playerProfileCompatibilityServiceProvider =
    Provider<PlayerProfileCompatibilityService>((ref) {
  return PlayerProfileCompatibilityService(
    sourceReader: ref.watch(playerRepositoryProvider),
  );
});

final class PlayerProfileCompatibilityService
    implements PlayerProfileCompatibilityReadPort {
  const PlayerProfileCompatibilityService({
    required PlayerProfileRawSourceReader sourceReader,
    PlayerProfileCompatibilityAdapter adapter =
        const PlayerProfileCompatibilityAdapter(),
  })  : _sourceReader = sourceReader,
        _adapter = adapter;

  final PlayerProfileRawSourceReader _sourceReader;
  final PlayerProfileCompatibilityAdapter _adapter;

  @override
  Future<PlayerProfileCompatibilityResult> readByLegacyPlayerId(
    int legacyPlayerId,
  ) async {
    final source = await _read(
      () => _sourceReader.readPlayerProfileRawSource(legacyPlayerId),
    );
    if (source == null) {
      throw const PlayerProfileException(
        PlayerProfileFailureCode.targetNotFound,
      );
    }
    return _adapter.adapt(source);
  }

  @override
  Future<PlayerProfileCompatibilityResult?> readActivePlayer() async {
    final source = await _read(
      _sourceReader.readActivePlayerProfileRawSource,
    );
    return source == null ? null : _adapter.adapt(source);
  }

  @override
  CanonicalPlayerProfileSnapshot decodeSnapshot(String rawJson) =>
      _adapter.decodeSnapshot(rawJson);

  @override
  PlayerProfileRepresentations adaptSnapshot(
    CanonicalPlayerProfileSnapshot snapshot,
  ) =>
      _adapter.adaptSnapshot(snapshot);

  Future<PlayerProfileRawSource?> _read(
    Future<PlayerProfileRawSource?> Function() action,
  ) async {
    try {
      return await action();
    } on PlayerProfileSourceException catch (error) {
      throw PlayerProfileException(
        switch (error.kind) {
          PlayerProfileSourceFailureKind.database =>
            PlayerProfileFailureCode.databaseFailure,
          PlayerProfileSourceFailureKind.sourceRead =>
            PlayerProfileFailureCode.sourceReadFailure,
        },
        cause: error.cause,
      );
    } on PlayerLifecycleException catch (error) {
      throw PlayerProfileException(
        switch (error.code) {
          PlayerLifecycleFailureCode.invariantViolated =>
            PlayerProfileFailureCode.activeInvariantViolated,
          PlayerLifecycleFailureCode.databaseFailure =>
            PlayerProfileFailureCode.databaseFailure,
          PlayerLifecycleFailureCode.targetNotFound =>
            PlayerProfileFailureCode.targetNotFound,
        },
        cause: error.cause,
      );
    }
  }
}
