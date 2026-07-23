import '../../shared/foundation/value_object.dart';
import '../entities/entity.dart';
import '../shared/entity_ids.dart';
import '../shared/scalar_values.dart';
import '../shared/temporal_values.dart';

abstract class AggregateRoot<TId extends EntityId, TRoot extends Entity<TId>>
    extends ValueObject {
  const AggregateRoot({required this.root});

  final TRoot root;

  TId get id => root.id;
  VersionNumber get version => root.version;
  UtcTimestamp get createdAt => root.createdAt;

  @override
  List<Object?> get components => [id];
}
