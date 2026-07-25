enum PlayerLifecycleFailureCode {
  targetNotFound('player-target-not-found'),
  invariantViolated('active-player-invariant-violated'),
  databaseFailure('active-player-database-failure');

  const PlayerLifecycleFailureCode(this.value);

  final String value;
}

final class PlayerLifecycleException implements Exception {
  const PlayerLifecycleException(this.code, {this.cause});

  final PlayerLifecycleFailureCode code;
  final Object? cause;

  @override
  String toString() => code.value;
}
