import '../../shared/foundation/value_object.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';

final class EvidenceReference extends ValueObject {
  const EvidenceReference({
    required this.id,
    required this.version,
    required this.digest,
    required this.sourceOwner,
  });

  final GenericEntityId id;
  final VersionNumber version;
  final NonEmptyString digest;
  final NonEmptyString sourceOwner;

  @override
  List<Object?> get components => [id, version, digest, sourceOwner];
}

final class KnowledgeReference extends ValueObject {
  const KnowledgeReference({
    required this.id,
    required this.version,
    required this.digest,
    required this.provenance,
  });

  final GenericEntityId id;
  final VersionNumber version;
  final NonEmptyString digest;
  final NonEmptyString provenance;

  @override
  List<Object?> get components => [id, version, digest, provenance];
}
