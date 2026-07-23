import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/application/mapping/mapping_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('mapping values defensively protect canonical data', () {
    final source = {'z': 'last', 'a': 'first'};
    final context = MappingContext(
      correlationId: RuntimeIdentifier(
        namespace: 'application.correlation',
        value: 'correlation-1',
      ),
      attributes: source,
    );
    final failure = MappingFailure(
      code: RuntimeIdentifier(
        namespace: 'application.mapping',
        value: 'unavailable',
      ),
      messageKey: 'mapping.unavailable',
    );
    final failures = [failure];
    final result = MappingResult<RuntimeIdentifier>(
      metadata: MappingMetadata(
        mappingId: RuntimeIdentifier(
          namespace: 'application.mapping',
          value: 'mapping-1',
        ),
        direction: MappingDirection.forward,
      ),
      failures: failures,
    );
    source['later'] = 'ignored';
    failures.clear();

    expect(context.attributes.keys, ['a', 'z']);
    expect(result.failures, [failure]);
    expect(() => result.failures.clear(), throwsUnsupportedError);
  });

  test('mapping ports retain compile-time generic boundaries', () {
    Mapper<String, RuntimeIdentifier>? mapper;
    BidirectionalMapper<RuntimeIdentifier, RuntimeIdentifier>? bidirectional;

    _acceptMapper(mapper);
    _acceptBidirectional(bidirectional);

    expect([mapper, bidirectional], everyElement(isNull));
  });
}

void _acceptMapper(Mapper<String, RuntimeIdentifier>? mapper) {}

void _acceptBidirectional(
  BidirectionalMapper<RuntimeIdentifier, RuntimeIdentifier>? mapper,
) {}
