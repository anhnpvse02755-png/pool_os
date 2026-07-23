import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/experience/viewmodels/viewmodel_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('view model metadata defensively copies contract collections', () {
    final capabilities = [ProjectionCapability.read];
    final versions = [_version('v1')];
    final projection = ProjectionMetadata(
      identity: _id('view.projection', 'foundation'),
      capabilities: capabilities,
    );
    final compatibility = ViewStateCompatibility(
      requiredVersion: versions.single,
      supportedVersions: versions,
    );

    capabilities.add(ProjectionCapability.refresh);
    versions.add(_version('v2'));

    expect(projection.capabilities, [ProjectionCapability.read]);
    expect(compatibility.supportedVersions, [_version('v1')]);
    expect(() => projection.capabilities.clear(), throwsUnsupportedError);
    expect(
        () => compatibility.supportedVersions.clear(), throwsUnsupportedError);
  });

  test('view model interfaces retain compile-time generic boundaries', () {
    ExperienceViewModel<RuntimeIdentifier>? viewModel;
    ReadOnlyViewModel<RuntimeIdentifier>? readOnly;
    EditableViewModel<RuntimeIdentifier>? editable;

    _acceptViewModel(viewModel);
    _acceptViewModel(readOnly);
    _acceptViewModel(editable);

    expect([viewModel, readOnly, editable], everyElement(isNull));
  });
}

void _acceptViewModel(
  ExperienceViewModel<RuntimeIdentifier>? viewModel,
) {}

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);

ViewStateVersion _version(String value) =>
    ViewStateVersion(_id('view.state.version', value));
