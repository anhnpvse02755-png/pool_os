import '../../shared/foundation/result.dart';

/// Synchronous, infrastructure-neutral Domain service boundary.
///
/// Implementations and executable Domain behavior are intentionally outside
/// the P2.6 contract milestone.
abstract interface class DomainService<TInput, TOutput> {
  Result<TOutput> evaluate(TInput input);
}
