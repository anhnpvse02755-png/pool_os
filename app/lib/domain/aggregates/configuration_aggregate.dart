import '../../shared/foundation/immutable.dart';
import '../entities/settings_profile.dart';
import '../shared/entity_ids.dart';
import 'aggregate_root.dart';

/// Structural configuration composition only. No policy/default resolution.
final class ConfigurationAggregate
    extends AggregateRoot<GenericEntityId, SettingsProfile> {
  ConfigurationAggregate({
    required super.root,
    Iterable<GenericEntityId> configurationReferenceIds = const [],
  }) : configurationReferenceIds = immutableList(configurationReferenceIds);

  final List<GenericEntityId> configurationReferenceIds;
}
