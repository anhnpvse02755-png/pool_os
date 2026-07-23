import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../foundation/application_context.dart';

export '../foundation/application_context.dart' show CancellationToken;
export '../foundation/application_handlers.dart' show ApplicationPipeline;

enum PipelineStage { beforeHandler, handler, afterHandler }

abstract interface class PipelineOrdering {
  int get order;
}

final class PipelineExecutionMetadata extends ValueObject {
  const PipelineExecutionMetadata({
    required this.executionId,
    required this.stage,
    required this.order,
  });

  final RuntimeIdentifier executionId;
  final PipelineStage stage;
  final int order;

  @override
  List<Object?> get components => [executionId, stage, order];
}

final class PipelineExecutionResult<TPayload extends ValueObject>
    extends ValueObject {
  const PipelineExecutionResult({
    required this.metadata,
    required this.payload,
  });

  final PipelineExecutionMetadata metadata;
  final TPayload payload;

  @override
  List<Object?> get components => [metadata, payload];
}

abstract interface class PipelineContinuation<TRequest, TResult> {
  Future<Result<TResult>> proceed(
    TRequest request,
    ApplicationExecutionContext context,
  );
}

abstract interface class PipelineBehavior<TRequest, TResult>
    implements PipelineOrdering {
  Future<Result<TResult>> invoke(
    TRequest request,
    ApplicationExecutionContext context,
    PipelineContinuation<TRequest, TResult> continuation,
  );
}
