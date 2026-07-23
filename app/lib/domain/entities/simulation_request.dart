import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import 'entity.dart';

final class SimulationRequest extends Entity<GenericEntityId> {
  const SimulationRequest({
    required super.id,
    required super.version,
    required super.createdAt,
    required this.scenarioReferenceId,
    required this.scenarioDigest,
    required this.lifecycleState,
  });

  final GenericEntityId scenarioReferenceId;
  final NonEmptyString scenarioDigest;
  final NonEmptyString lifecycleState;
}
