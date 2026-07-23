import '../../shared/foundation/result.dart';

/// Product Domain aggregate creation port only.
///
/// Implementations and executable construction behavior are outside P2.8.
abstract interface class AggregateFactory<TSpecification, TAggregate> {
  Result<TAggregate> create(TSpecification specification);
}
