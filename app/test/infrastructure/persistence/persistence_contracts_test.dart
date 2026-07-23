import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/infrastructure/contracts/infrastructure_contracts.dart';
import 'package:pool_os/infrastructure/persistence/persistence_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('persistence transaction metadata defensively copies collections', () {
    final capabilities = [PersistenceCapability.read];
    final participants = [_adapterIdentity('reader')];
    final context = PersistenceTransactionContext(
      transactionId: _identifier('transaction', 'transaction-1'),
      execution: _executionContext(),
      capabilities: capabilities,
    );
    final result = PersistenceTransactionResult(
      transactionId: context.transactionId,
      provenance: _provenance(),
      participants: participants,
    );

    capabilities.add(PersistenceCapability.write);
    participants.add(_adapterIdentity('writer'));

    expect(context.capabilities, [PersistenceCapability.read]);
    expect(result.participants, [_adapterIdentity('reader')]);
    expect(() => context.capabilities.clear(), throwsUnsupportedError);
    expect(() => result.participants.clear(), throwsUnsupportedError);
  });

  test('persistence ports retain compile-time generic boundaries', () {
    PersistenceAdapter<RuntimeIdentifier>? adapter;
    PersistenceReadAdapter<RuntimeIdentifier, RuntimeIdentifier>? read;
    PersistenceWriteAdapter<RuntimeIdentifier, RuntimeIdentifier>? write;
    PersistenceTransaction? transaction;

    _acceptAdapter(adapter);
    _acceptAdapter(read);
    _acceptAdapter(write);
    _acceptTransaction(transaction);

    expect([adapter, read, write, transaction], everyElement(isNull));
  });
}

void _acceptAdapter(
  PersistenceAdapter<RuntimeIdentifier>? adapter,
) {}

void _acceptTransaction(PersistenceTransaction? transaction) {}

RuntimeIdentifier _identifier(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

AdapterIdentity _adapterIdentity(String value) => AdapterIdentity(
      id: _identifier('infrastructure.adapter', value),
      version: _identifier('infrastructure.version', 'v1'),
    );

AdapterProvenance _provenance() => AdapterProvenance(
      source: _identifier('infrastructure.source', 'persistence'),
      digest: 'persistence-digest',
    );

AdapterExecutionContext _executionContext() => AdapterExecutionContext(
      correlationId: _identifier('infrastructure.correlation', 'request-1'),
      capability: AdapterCapabilityMetadata(
        identity: _adapterIdentity('reader'),
        capabilities: const [InfrastructureCapability.read],
      ),
      provenance: _provenance(),
    );
