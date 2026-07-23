import 'failure.dart';

sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  });

  Result<R> map<R>(R Function(T value) transform);

  Result<R> flatMap<R>(Result<R> Function(T value) transform);
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      onSuccess(value);

  @override
  Result<R> map<R>(R Function(T value) transform) =>
      Success<R>(transform(value));

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      transform(value);
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      onFailure(failure);

  @override
  Result<R> map<R>(R Function(T value) transform) => FailureResult<R>(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      FailureResult<R>(failure);
}
