import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/match_repository.dart';
import '../domain/match_identity_compatibility.dart';

final matchIdentityCompatibilityServiceProvider =
    Provider<MatchIdentityCompatibilityService>((ref) {
  return MatchIdentityCompatibilityService(
    sourceReader: ref.watch(matchRepositoryProvider),
  );
});

final class MatchIdentityCompatibilityService
    implements MatchIdentityCompatibilityReadPort {
  const MatchIdentityCompatibilityService({
    required MatchIdentityRawSourceReader sourceReader,
    MatchIdentityCompatibilityAdapter adapter =
        const MatchIdentityCompatibilityAdapter(),
  })  : _sourceReader = sourceReader,
        _adapter = adapter;

  final MatchIdentityRawSourceReader _sourceReader;
  final MatchIdentityCompatibilityAdapter _adapter;

  @override
  Future<MatchIdentityCompatibilityResult> readByLegacyMatchId(
    int legacyMatchId,
  ) async {
    final source = await _read(
      () => _sourceReader.readMatchIdentityRawSource(legacyMatchId),
    );
    if (source == null) {
      throw const MatchIdentityException(
        MatchIdentityFailureCode.targetNotFound,
      );
    }
    return _adapter.adapt(source);
  }

  @override
  CanonicalMatchIdentitySnapshot decodeSnapshot(String rawJson) =>
      _adapter.decodeSnapshot(rawJson);

  @override
  MatchIdentityRepresentations adaptSnapshot(
    CanonicalMatchIdentitySnapshot snapshot,
  ) =>
      _adapter.adaptSnapshot(snapshot);

  Future<MatchIdentityRawSource?> _read(
    Future<MatchIdentityRawSource?> Function() action,
  ) async {
    try {
      return await action();
    } on MatchIdentitySourceException catch (error) {
      throw MatchIdentityException(
        switch (error.kind) {
          MatchIdentitySourceFailureKind.database =>
            MatchIdentityFailureCode.databaseFailure,
          MatchIdentitySourceFailureKind.sourceRead =>
            MatchIdentityFailureCode.sourceReadFailure,
        },
        cause: error.cause,
      );
    }
  }
}
