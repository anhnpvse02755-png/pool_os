import '../../shared/foundation/immutable.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class SettingsProfile extends Entity<GenericEntityId> {
  SettingsProfile({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.userProfileId,
    required this.lifecycleState,
    Iterable<GenericEntityId> configurationReferenceIds = const [],
  }) : configurationReferenceIds = immutableList(configurationReferenceIds);

  final GenericEntityId userProfileId;
  final NonEmptyString lifecycleState;
  final List<GenericEntityId> configurationReferenceIds;
}
