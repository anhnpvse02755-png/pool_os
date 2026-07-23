import '../product/runtime/product_runtime_assembly_contracts.dart';
import '../shared/foundation/identifier.dart';
import '../shared/foundation/immutable.dart';
import '../shared/foundation/value_object.dart';

final class BootstrapConfiguration {
  BootstrapConfiguration({
    required this.assembly,
    required this.requiredIdentity,
    required this.requiredVersion,
    Iterable<ProductRuntimeCapability> requiredCapabilities = const [],
  }) : requiredCapabilities = immutableList(requiredCapabilities);

  final ProductRuntimeAssemblyContract assembly;
  final ProductRuntimeIdentity requiredIdentity;
  final ProductRuntimeVersion requiredVersion;
  final List<ProductRuntimeCapability> requiredCapabilities;
}

final class BootstrapContext extends ValueObject {
  const BootstrapContext({required this.correlationId});

  final RuntimeIdentifier correlationId;

  @override
  List<Object?> get components => [correlationId];
}

final class BootstrapDiagnostics extends ValueObject {
  BootstrapDiagnostics({
    Iterable<RuntimeIdentifier> checks = const [],
  }) : checks = immutableList(checks);

  final List<RuntimeIdentifier> checks;

  @override
  List<Object?> get components => [checks.length, ...checks];
}

final class BootstrapResult extends ValueObject {
  const BootstrapResult({
    required this.context,
    required this.runtimeMetadata,
    required this.diagnostics,
  });

  final BootstrapContext context;
  final ProductRuntimeMetadata runtimeMetadata;
  final BootstrapDiagnostics diagnostics;

  @override
  List<Object?> get components => [context, runtimeMetadata, diagnostics];
}

final class ProductBootstrap {
  const ProductBootstrap();

  BootstrapResult initialize(
    BootstrapConfiguration configuration,
    BootstrapContext context,
  ) {
    final metadata = configuration.assembly.metadata;
    if (metadata.identity != configuration.requiredIdentity) {
      throw ArgumentError.value(
        configuration.requiredIdentity,
        'configuration.requiredIdentity',
        'Runtime identity does not match the assembly contract',
      );
    }
    if (metadata.version != configuration.requiredVersion) {
      throw ArgumentError.value(
        configuration.requiredVersion,
        'configuration.requiredVersion',
        'Runtime version does not match the assembly contract',
      );
    }

    final availableCapabilities = {
      for (final capability in metadata.capabilities)
        capability.identity: capability,
    };
    if (availableCapabilities.length != metadata.capabilities.length) {
      throw ArgumentError.value(
        metadata.capabilities,
        'configuration.assembly.metadata.capabilities',
        'Runtime capabilities must be unique',
      );
    }
    for (final capability in configuration.requiredCapabilities) {
      if (!availableCapabilities.containsKey(capability.identity)) {
        throw ArgumentError.value(
          capability,
          'configuration.requiredCapabilities',
          'Required runtime capability is not declared by the assembly',
        );
      }
    }

    return BootstrapResult(
      context: context,
      runtimeMetadata: metadata,
      diagnostics: BootstrapDiagnostics(
        checks: [
          _check('identity-compatible'),
          _check('version-compatible'),
          _check('capabilities-available'),
        ],
      ),
    );
  }
}

RuntimeIdentifier _check(String value) => RuntimeIdentifier(
      namespace: 'product.bootstrap.check',
      value: value,
    );
