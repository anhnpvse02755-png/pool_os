import '../../shared/foundation/immutable.dart';
import '../entities/user_profile.dart';
import '../shared/entity_ids.dart';
import 'aggregate_root.dart';

/// Structural Product User composition only. Identity policy remains external.
final class UserAggregate extends AggregateRoot<GenericEntityId, UserProfile> {
  UserAggregate({
    required super.root,
    Iterable<GenericEntityId> profileReferenceIds = const [],
  }) : profileReferenceIds = immutableList(profileReferenceIds);

  final List<GenericEntityId> profileReferenceIds;
}
