import '../../shared/foundation/immutable.dart';
import '../entities/coach_session.dart';
import '../shared/entity_ids.dart';
import 'aggregate_root.dart';

/// Structural Coach boundary composition only. No AI behavior is present.
final class CoachAggregate extends AggregateRoot<SessionId, CoachSession> {
  CoachAggregate({
    required super.root,
    Iterable<GenericEntityId> responseReferenceIds = const [],
    Iterable<GenericEntityId> executionReferenceIds = const [],
  })  : responseReferenceIds = immutableList(responseReferenceIds),
        executionReferenceIds = immutableList(executionReferenceIds);

  final List<GenericEntityId> responseReferenceIds;
  final List<GenericEntityId> executionReferenceIds;
}
