import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/foundation/application_context.dart';
import 'package:pool_os/framework/execution/execution_pipeline.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('traverses stages deterministically by order then identity', () async {
    final executionOrder = <String>[];
    final pipeline = ExecutionPipeline<_TextValue>(stages: [
      _Stage('zeta', 20, executionOrder, (value) => '$value-C'),
      _Stage('beta', 10, executionOrder, (value) => '$value-B'),
      _Stage('alpha', 10, executionOrder, (value) => '$value-A'),
    ]);

    final result = await pipeline.execute(
      initialValue: const _TextValue('start'),
      context: _context(_CancellationToken(false)),
    );

    expect(result.isSuccess, isTrue);
    expect(result.value, const _TextValue('start-A-B-C'));
    expect(executionOrder, ['alpha', 'beta', 'zeta']);
    expect(
      result.diagnostics.traversedStages.map((identity) => identity.value),
      ['alpha', 'beta', 'zeta'],
    );
  });

  test('fails fast and fails closed without running later stages', () async {
    final executionOrder = <String>[];
    final failure = StateError('stage failed');
    final pipeline = ExecutionPipeline<_TextValue>(stages: [
      _Stage('first', 1, executionOrder, (value) => '$value-1'),
      _Stage('failure', 2, executionOrder, (_) => throw failure),
      _Stage('never', 3, executionOrder, (value) => '$value-3'),
    ]);

    final result = await pipeline.execute(
      initialValue: const _TextValue('start'),
      context: _context(_CancellationToken(false)),
    );

    expect(result.isFailure, isTrue);
    expect(result.value, isNull);
    expect(result.error, same(failure));
    expect(result.diagnostics.failedStage?.value, 'failure');
    expect(executionOrder, ['first', 'failure']);
  });

  test('propagates stage errors when policy requires it', () async {
    final failure = StateError('propagated');
    final pipeline = ExecutionPipeline<_TextValue>(
      stages: [
        _Stage('failure', 1, [], (_) => throw failure),
      ],
      policy: const ExecutionPolicy(rethrowStageErrors: true),
    );

    expect(
      () => pipeline.execute(
        initialValue: const _TextValue('start'),
        context: _context(_CancellationToken(false)),
      ),
      throwsA(same(failure)),
    );
  });

  test('cancellation stops traversal before the next stage', () async {
    final token = _CancellationToken(false);
    final executionOrder = <String>[];
    final pipeline = ExecutionPipeline<_TextValue>(stages: [
      _Stage('first', 1, executionOrder, (value) {
        token.isCancelled = true;
        return '$value-1';
      }),
      _Stage('second', 2, executionOrder, (value) => '$value-2'),
    ]);

    final result = await pipeline.execute(
      initialValue: const _TextValue('start'),
      context: _context(token),
    );

    expect(result.cancelled, isTrue);
    expect(result.value, isNull);
    expect(result.diagnostics.cancelledStage?.value, 'second');
    expect(executionOrder, ['first']);
  });

  test('snapshots stage input and rejects duplicate identities', () {
    final stage = _Stage('only', 1, [], (value) => value.toString());
    final stages = <ExecutionStage<_TextValue>>[stage];
    final pipeline = ExecutionPipeline<_TextValue>(stages: stages);
    stages.clear();

    expect(pipeline.stages, [stage]);
    expect(() => pipeline.stages.clear(), throwsUnsupportedError);
    expect(
      () => ExecutionPipeline<_TextValue>(stages: [stage, stage]),
      throwsArgumentError,
    );
  });
}

final class _Stage implements ExecutionStage<_TextValue> {
  _Stage(
    String identity,
    this.order,
    this.executionOrder,
    this.transform,
  ) : identity = _id('product.execution-stage', identity);

  @override
  final RuntimeIdentifier identity;

  @override
  final int order;

  final List<String> executionOrder;
  final String Function(String value) transform;

  @override
  Future<_TextValue> execute(
    _TextValue value,
    ExecutionContext context,
  ) async {
    executionOrder.add(identity.value);
    return _TextValue(transform(value.value));
  }
}

final class _TextValue extends ValueObject {
  const _TextValue(this.value);

  final String value;

  @override
  List<Object?> get components => [value];

  @override
  String toString() => value;
}

final class _CancellationToken implements CancellationToken {
  _CancellationToken(this.isCancelled);

  bool isCancelled;

  @override
  bool get isCancellationRequested => isCancelled;
}

ExecutionContext _context(CancellationToken token) => ExecutionContext(
      application: ApplicationExecutionContext(
        request: ApplicationRequestContext(
          requestId: _id('product.execution-request', 'request-1'),
          correlationId: _id('product.execution-correlation', 'correlation-1'),
          requestedAtUtc: DateTime.utc(2026, 7, 24),
        ),
        cancellationToken: token,
      ),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
