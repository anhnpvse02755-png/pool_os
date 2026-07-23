import '../../shared/foundation/value_object.dart';

/// Immutable typed request carrier for future concrete use-case contracts.
final class UseCaseRequest<TPayload extends ValueObject> extends ValueObject {
  const UseCaseRequest({required this.payload});

  final TPayload payload;

  @override
  List<Object?> get components => [payload];
}

/// Immutable typed response carrier for future concrete use-case contracts.
final class UseCaseResponse<TPayload extends ValueObject> extends ValueObject {
  const UseCaseResponse({required this.payload});

  final TPayload payload;

  @override
  List<Object?> get components => [payload];
}
