import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/core/runtime/core_runtime.dart';
import 'package:pool_os/core/runtime/runtime_configuration.dart';
import 'package:pool_os/core/runtime/runtime_ports.dart';
import 'package:pool_os/shared/foundation/failure.dart';
import 'package:pool_os/shared/foundation/result.dart';

import 'runtime_test_doubles.dart';

void main() {
  test('composition root bootstraps immutable canonical configuration', () {
    final composition = CoreRuntimeComposition(
      configuration: ImmutableRuntimeConfiguration(const {
        'runtime.version': '1',
        'runtime.environment': 'product',
      }),
      clock: FixedClock(DateTime.utc(2026, 7, 23)),
      uuidGenerator: SequenceUuidGenerator(const ['uuid-1']),
      logger: RecordingRuntimeLogger(),
    );

    final result = composition.bootstrap();
    expect(result, isA<Success<CoreRuntimeState>>());
    final state = (result as Success<CoreRuntimeState>).value;
    expect(state.environment, 'product');
    expect(state.configuration.keys,
        orderedEquals(['runtime.environment', 'runtime.version']));
    expect(() => state.configuration['x'] = 'y', throwsUnsupportedError);
    expect(composition.clock!.nowUtc(), DateTime.utc(2026, 7, 23));
    expect(
        composition.uuidGenerator!.nextIdentifier('runtime.request').canonical,
        'runtime.request:uuid-1');
  });

  test('bootstrap fails closed when required configuration is absent', () {
    final result = CoreRuntimeComposition(
      configuration:
          ImmutableRuntimeConfiguration(const {'runtime.version': '1'}),
    ).bootstrap();

    expect(result, isA<FailureResult<CoreRuntimeState>>());
    final failure = (result as FailureResult<CoreRuntimeState>).failure;
    expect(failure.category, FailureCategory.boundaryInvalid);
    expect(failure.retryDirective, RetryDirective.newIntentOnly);
    expect(failure.sourceOwner, 'core.runtime');
  });

  test('runtime logging remains an injected interface', () {
    final logger = RecordingRuntimeLogger();
    logger.record(RuntimeLogEntry(
      eventId: 'event-1',
      level: RuntimeLogLevel.info,
      source: 'core.runtime',
      code: 'bootstrap.ready',
      context: const {'environment': 'product'},
    ));

    expect(logger.entries, hasLength(1));
    expect(logger.entries.single.context['environment'], 'product');
  });
}
