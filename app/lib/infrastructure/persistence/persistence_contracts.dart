import '../../shared/foundation/identifier.dart';
import '../../shared/foundation/immutable.dart';
import '../../shared/foundation/result.dart';
import '../../shared/foundation/value_object.dart';
import '../contracts/infrastructure_contracts.dart';

enum PersistenceCapability { read, write, transaction }

abstract interface class PersistenceAdapter<TModel extends ValueObject> {
  AdapterCapabilityMetadata get metadata;
}

abstract interface class PersistenceReadAdapter<TId extends ValueObject,
    TModel extends ValueObject> implements PersistenceAdapter<TModel> {
  Future<Result<AdapterExecutionResult<TModel>>> read(
    TId id,
    AdapterExecutionContext context,
  );
}

abstract interface class PersistenceWriteAdapter<TId extends ValueObject,
    TModel extends ValueObject> implements PersistenceAdapter<TModel> {
  Future<Result<AdapterExecutionResult<TModel>>> write(
    TId id,
    TModel model,
    AdapterExecutionContext context,
  );
}

final class PersistenceTransactionContext extends ValueObject {
  PersistenceTransactionContext({
    required this.transactionId,
    required this.execution,
    Iterable<PersistenceCapability> capabilities = const [],
  }) : capabilities = immutableList(capabilities);

  final RuntimeIdentifier transactionId;
  final AdapterExecutionContext execution;
  final List<PersistenceCapability> capabilities;

  @override
  List<Object?> get components => [
        transactionId,
        execution,
        capabilities.length,
        ...capabilities,
      ];
}

final class PersistenceTransactionResult extends ValueObject {
  PersistenceTransactionResult({
    required this.transactionId,
    required this.provenance,
    Iterable<AdapterIdentity> participants = const [],
  }) : participants = immutableList(participants);

  final RuntimeIdentifier transactionId;
  final AdapterProvenance provenance;
  final List<AdapterIdentity> participants;

  @override
  List<Object?> get components => [
        transactionId,
        provenance,
        participants.length,
        ...participants,
      ];
}

abstract interface class PersistenceTransaction {
  Future<Result<PersistenceTransactionResult>> execute(
    PersistenceTransactionContext context,
  );
}
