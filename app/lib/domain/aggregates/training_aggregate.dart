import '../../shared/foundation/immutable.dart';
import '../entities/external_references.dart';
import '../entities/training_session.dart';
import '../shared/entity_ids.dart';
import 'aggregate_root.dart';

/// Structural Training composition only. No eligibility or workflow behavior.
final class TrainingAggregate
    extends AggregateRoot<SessionId, TrainingSession> {
  TrainingAggregate({
    required super.root,
    Iterable<KnowledgeReference> knowledgeReferences = const [],
    Iterable<EvidenceReference> evidenceReferences = const [],
    Iterable<GenericEntityId> simulationRequestIds = const [],
  })  : knowledgeReferences = immutableList(knowledgeReferences),
        evidenceReferences = immutableList(evidenceReferences),
        simulationRequestIds = immutableList(simulationRequestIds);

  final List<KnowledgeReference> knowledgeReferences;
  final List<EvidenceReference> evidenceReferences;
  final List<GenericEntityId> simulationRequestIds;
}
