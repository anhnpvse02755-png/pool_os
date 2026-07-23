import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/bootstrap/product_bootstrap.dart';
import 'package:pool_os/product/runtime/product_runtime_assembly_contracts.dart';
import 'package:pool_os/shared/foundation/identifier.dart';

void main() {
  test('initializes an approved runtime contract without executing features',
      () {
    final metadata = _metadata();
    final context =
        BootstrapContext(correlationId: _id('correlation', 'run-1'));
    final result = const ProductBootstrap().initialize(
      BootstrapConfiguration(
        assembly: _AssemblyFixture(metadata),
        requiredIdentity: metadata.identity,
        requiredVersion: metadata.version,
        requiredCapabilities: [_capability('composition')],
      ),
      context,
    );

    expect(result.context, context);
    expect(result.runtimeMetadata, metadata);
    expect(
      result.diagnostics.checks.map((check) => check.value),
      ['identity-compatible', 'version-compatible', 'capabilities-available'],
    );
  });

  test('bootstrap configuration and result collections are immutable', () {
    final metadata = _metadata();
    final requiredCapabilities = [_capability('composition')];
    final configuration = BootstrapConfiguration(
      assembly: _AssemblyFixture(metadata),
      requiredIdentity: metadata.identity,
      requiredVersion: metadata.version,
      requiredCapabilities: requiredCapabilities,
    );

    requiredCapabilities.clear();
    final result = const ProductBootstrap().initialize(
      configuration,
      BootstrapContext(correlationId: _id('correlation', 'run-2')),
    );

    expect(configuration.requiredCapabilities, [_capability('composition')]);
    expect(
      () => configuration.requiredCapabilities.clear(),
      throwsUnsupportedError,
    );
    expect(() => result.diagnostics.checks.clear(), throwsUnsupportedError);
  });

  test('fails closed for incompatible runtime identity or version', () {
    final metadata = _metadata();
    final assembly = _AssemblyFixture(metadata);
    final context =
        BootstrapContext(correlationId: _id('correlation', 'run-3'));

    expect(
      () => const ProductBootstrap().initialize(
        BootstrapConfiguration(
          assembly: assembly,
          requiredIdentity: ProductRuntimeIdentity(
            _id('product.runtime.identity', 'other'),
          ),
          requiredVersion: metadata.version,
        ),
        context,
      ),
      throwsArgumentError,
    );
    expect(
      () => const ProductBootstrap().initialize(
        BootstrapConfiguration(
          assembly: assembly,
          requiredIdentity: metadata.identity,
          requiredVersion: ProductRuntimeVersion(
            _id('product.runtime.version', 'v2'),
          ),
        ),
        context,
      ),
      throwsArgumentError,
    );
  });

  test('fails closed for missing or duplicate runtime capabilities', () {
    final metadata = _metadata();
    final context =
        BootstrapContext(correlationId: _id('correlation', 'run-4'));

    expect(
      () => const ProductBootstrap().initialize(
        BootstrapConfiguration(
          assembly: _AssemblyFixture(metadata),
          requiredIdentity: metadata.identity,
          requiredVersion: metadata.version,
          requiredCapabilities: [_capability('missing')],
        ),
        context,
      ),
      throwsArgumentError,
    );

    final duplicateMetadata = ProductRuntimeMetadata(
      identity: metadata.identity,
      version: metadata.version,
      capabilities: [_capability('composition'), _capability('composition')],
    );
    expect(
      () => const ProductBootstrap().initialize(
        BootstrapConfiguration(
          assembly: _AssemblyFixture(duplicateMetadata),
          requiredIdentity: duplicateMetadata.identity,
          requiredVersion: duplicateMetadata.version,
        ),
        context,
      ),
      throwsArgumentError,
    );
  });
}

final class _AssemblyFixture implements ProductRuntimeAssemblyContract {
  const _AssemblyFixture(this.metadata);

  @override
  final ProductRuntimeMetadata metadata;
}

ProductRuntimeMetadata _metadata() => ProductRuntimeMetadata(
      identity: ProductRuntimeIdentity(
        _id('product.runtime.identity', 'pool-os'),
      ),
      version: ProductRuntimeVersion(_id('product.runtime.version', 'v1')),
      capabilities: [_capability('composition')],
    );

ProductRuntimeCapability _capability(String value) => ProductRuntimeCapability(
      _id('product.runtime.capability', value),
    );

RuntimeIdentifier _id(String namespace, String value) =>
    RuntimeIdentifier(namespace: namespace, value: value);
