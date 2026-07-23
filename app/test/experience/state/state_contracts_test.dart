import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/state/state_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';
import 'package:pool_os/shared/foundation/value_object.dart';

void main() {
  test('state contracts defensively copy metadata collections', () {
    final capabilities = [StateCapability.readOnly];
    final versions = [_version('v1')];
    final metadata = StateMetadata(
      identity: _identity(),
      version: versions.single,
      capabilities: capabilities,
    );
    final compatibility = StateCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(StateCapability.mutable);
    versions.add(_version('v2'));

    expect(metadata.capabilities, [StateCapability.readOnly]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => metadata.capabilities.clear(), throwsUnsupportedError);
    expect(
      () => compatibility.supportedVersions.clear(),
      throwsUnsupportedError,
    );
  });

  test('state markers retain compile-time contract boundaries', () {
    ExperienceState<_StateValue>? state;
    ReadOnlyState<_StateValue>? readOnly;
    MutableState<_StateValue>? mutable;
    LocalState<_StateValue>? local;
    SharedState<_StateValue>? shared;
    SessionState<_StateValue>? session;

    _acceptState(state);
    _acceptState(readOnly);
    _acceptState(mutable);
    _acceptState(local);
    _acceptState(shared);
    _acceptState(session);

    expect(
      [state, readOnly, mutable, local, shared, session],
      everyElement(isNull),
    );
  });
}

void _acceptState(ExperienceState<_StateValue>? state) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

StateIdentity _identity() =>
    StateIdentity(_id('experience.state.identity', 'foundation'));

StateVersion _version(String value) =>
    StateVersion(_id('experience.state.version', value));

final class _StateValue extends ValueObject {
  const _StateValue(this.value);

  final String value;

  @override
  List<Object?> get components => [value];
}
