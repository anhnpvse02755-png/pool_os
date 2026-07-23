import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/pipeline/pipeline_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('pipeline execution values preserve immutable typed metadata', () {
    final metadata = PipelineExecutionMetadata(
      executionId: RuntimeIdentifier(
        namespace: 'application.pipeline',
        value: 'execution-1',
      ),
      stage: PipelineStage.beforeHandler,
      order: 10,
    );
    final payload = RuntimeIdentifier(
      namespace: 'application.payload',
      value: 'payload-1',
    );

    expect(
      PipelineExecutionResult<RuntimeIdentifier>(
        metadata: metadata,
        payload: payload,
      ),
      PipelineExecutionResult<RuntimeIdentifier>(
        metadata: metadata,
        payload: payload,
      ),
    );
  });

  test('pipeline ports retain compile-time generic boundaries', () {
    ApplicationPipeline<String, int>? pipeline;
    PipelineBehavior<String, int>? behavior;
    PipelineContinuation<String, int>? continuation;
    CancellationToken? cancellation;

    _acceptPipeline<String, int>(pipeline);
    _acceptBehavior<String, int>(behavior);
    _acceptContinuation<String, int>(continuation);

    expect(
      [pipeline, behavior, continuation, cancellation],
      everyElement(isNull),
    );
  });
}

void _acceptPipeline<TRequest, TResult>(
  ApplicationPipeline<TRequest, TResult>? pipeline,
) {}

void _acceptBehavior<TRequest, TResult>(
  PipelineBehavior<TRequest, TResult>? behavior,
) {}

void _acceptContinuation<TRequest, TResult>(
  PipelineContinuation<TRequest, TResult>? continuation,
) {}
