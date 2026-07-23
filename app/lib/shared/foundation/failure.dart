import 'immutable.dart';
import 'value_object.dart';

enum FailureCategory {
  boundaryInvalid,
  unauthenticated,
  unauthorized,
  notFound,
  staleConflict,
  duplicateMismatch,
  incompatible,
  provenanceInvalid,
  invariantRejected,
  dependencyUnavailable,
  externalExecutionFailed,
  partial,
  outcomeUnknown,
  cancelled,
  unexpectedDefect,
}

enum RetryDirective {
  prohibited,
  exactRequestOnly,
  afterRefresh,
  newIntentOnly,
  ownerPolicy,
}

final class Failure extends ValueObject {
  Failure({
    required this.id,
    required this.code,
    required this.category,
    required this.sourceOwner,
    required this.stage,
    this.retryDirective = RetryDirective.prohibited,
    Iterable<String> recoveryActions = const [],
    Map<String, String> context = const {},
    this.sourceFailureId,
  })  : recoveryActions = immutableList(recoveryActions),
        context = immutableCanonicalMap(context) {
    _requireToken(id, 'id');
    _requireToken(code, 'code');
    _requireToken(sourceOwner, 'sourceOwner');
    _requireToken(stage, 'stage');
    for (final action in this.recoveryActions) {
      _requireToken(action, 'recoveryAction');
    }
    for (final entry in this.context.entries) {
      _requireToken(entry.key, 'contextKey');
      _requireToken(entry.value, 'contextValue');
    }
  }

  final String id;
  final String code;
  final FailureCategory category;
  final String sourceOwner;
  final String stage;
  final RetryDirective retryDirective;
  final List<String> recoveryActions;
  final Map<String, String> context;
  final String? sourceFailureId;

  @override
  List<Object?> get components => [
        id,
        code,
        category,
        sourceOwner,
        stage,
        retryDirective,
        recoveryActions.length,
        ...recoveryActions,
        context.length,
        for (final entry in context.entries) ...[entry.key, entry.value],
        sourceFailureId,
      ];

  static void _requireToken(String value, String name) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, name, 'Must not be empty');
    }
  }
}
