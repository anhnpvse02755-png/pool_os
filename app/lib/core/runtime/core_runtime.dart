import '../../shared/foundation/failure.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import 'runtime_ports.dart';

final class CoreRuntimeState {
  CoreRuntimeState({
    required this.environment,
    required Map<String, String> configuration,
  }) : configuration = immutableCanonicalMap(configuration);

  final String environment;
  final Map<String, String> configuration;
}

final class CoreRuntimeComposition {
  const CoreRuntimeComposition({
    required this.configuration,
    this.clock,
    this.uuidGenerator,
    this.logger,
  });

  final RuntimeConfiguration configuration;
  final Clock? clock;
  final UuidGenerator? uuidGenerator;
  final RuntimeLogger? logger;

  Result<CoreRuntimeState> bootstrap() {
    final environment = configuration.value('runtime.environment')?.trim();
    if (environment == null || environment.isEmpty) {
      return FailureResult(
        Failure(
          id: 'core.bootstrap.environment.missing',
          code: 'core.runtime.configuration_missing',
          category: FailureCategory.boundaryInvalid,
          sourceOwner: 'core.runtime',
          stage: 'bootstrap.configuration',
          retryDirective: RetryDirective.newIntentOnly,
          recoveryActions: const ['provideCompatibleConfiguration'],
        ),
      );
    }

    return Success(
      CoreRuntimeState(
        environment: environment,
        configuration: configuration.snapshot(),
      ),
    );
  }
}
