import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/application_bootstrap_contracts.dart';
import 'package:pool_os/contracts/dependency_composition_root_contracts.dart';

const applicationBootstrapHostVersion = 1;
const applicationBootstrapHostPolicyVersion =
    'application-bootstrap-host/1.0.0';

enum ApplicationBootstrapPhase {
  validateBootstrap,
  invokeCompositionRoot,
  bindBootstrapEntries,
  completed,
}

class ApplicationBootstrapBinding {
  const ApplicationBootstrapBinding({
    required this.bootstrapEntryId,
    required this.compositionEntryId,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.position,
  });

  final String bootstrapEntryId;
  final String compositionEntryId;
  final String runtimeNodeId;
  final String serviceId;
  final int position;

  Map<String, dynamic> toJson() => {
        'bootstrapEntryId': bootstrapEntryId,
        'compositionEntryId': compositionEntryId,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'position': position,
      };
}

class ApplicationBootstrapHostConfiguration {
  const ApplicationBootstrapHostConfiguration._({
    required this.hostId,
    required this.bootstrapId,
    required this.bootstrapDigest,
    required this.compositionRootId,
    required this.compositionRootDigest,
    required this.bindings,
    required this.digest,
  });

  factory ApplicationBootstrapHostConfiguration.create({
    required ApplicationBootstrapContract bootstrap,
    required DependencyCompositionRootContract compositionRoot,
  }) {
    if (bootstrap.entries.isEmpty ||
        compositionRoot.entries.isEmpty ||
        compositionRoot.bootstrapId != bootstrap.id ||
        compositionRoot.bootstrapDigest != bootstrap.digest ||
        compositionRoot.entries.length != bootstrap.entries.length) {
      throw ArgumentError(
          'Application bootstrap host inputs are incompatible.');
    }
    final bindings = <ApplicationBootstrapBinding>[];
    final entryIds = <String>{};
    final serviceIds = <String>{};
    for (var position = 0; position < bootstrap.entries.length; position++) {
      final bootstrapEntry = bootstrap.entries[position];
      final compositionEntry = compositionRoot.entries[position];
      if (bootstrapEntry.position != position ||
          compositionEntry.position != position ||
          compositionEntry.bootstrapEntryId !=
              bootstrapEntry.bootstrapEntryId ||
          compositionEntry.runtimeNodeId != bootstrapEntry.runtimeNodeId ||
          compositionEntry.serviceId != bootstrapEntry.serviceId ||
          compositionEntry.bootstrapDigest != bootstrap.digest ||
          !entryIds.add(compositionEntry.compositionEntryId) ||
          !serviceIds.add(compositionEntry.serviceId)) {
        throw ArgumentError(
          'Application bootstrap host dependency order is invalid.',
        );
      }
      bindings.add(
        ApplicationBootstrapBinding(
          bootstrapEntryId: bootstrapEntry.bootstrapEntryId,
          compositionEntryId: compositionEntry.compositionEntryId,
          runtimeNodeId: bootstrapEntry.runtimeNodeId,
          serviceId: bootstrapEntry.serviceId,
          position: position,
        ),
      );
    }
    final hostId =
        'application-bootstrap-host.${bootstrap.id}.${compositionRoot.id}';
    final payload = {
      'hostVersion': applicationBootstrapHostVersion,
      'policyVersion': applicationBootstrapHostPolicyVersion,
      'hostId': hostId,
      'bootstrapId': bootstrap.id,
      'bootstrapDigest': bootstrap.digest,
      'compositionRootId': compositionRoot.id,
      'compositionRootDigest': compositionRoot.digest,
      'bindings': bindings.map((binding) => binding.toJson()).toList(),
    };
    return ApplicationBootstrapHostConfiguration._(
      hostId: hostId,
      bootstrapId: bootstrap.id,
      bootstrapDigest: bootstrap.digest,
      compositionRootId: compositionRoot.id,
      compositionRootDigest: compositionRoot.digest,
      bindings: List.unmodifiable(bindings),
      digest: _digest(payload),
    );
  }

  final String hostId;
  final String bootstrapId;
  final String bootstrapDigest;
  final String compositionRootId;
  final String compositionRootDigest;
  final List<ApplicationBootstrapBinding> bindings;
  final String digest;

  Map<String, dynamic> toJson() => {
        'hostVersion': applicationBootstrapHostVersion,
        'policyVersion': applicationBootstrapHostPolicyVersion,
        'hostId': hostId,
        'bootstrapId': bootstrapId,
        'bootstrapDigest': bootstrapDigest,
        'compositionRootId': compositionRootId,
        'compositionRootDigest': compositionRootDigest,
        'bindings': bindings.map((binding) => binding.toJson()).toList(),
        'digest': digest,
      };
}

class ApplicationBootstrapLifecycleEntry {
  const ApplicationBootstrapLifecycleEntry({
    required this.phase,
    required this.position,
    required this.configurationDigest,
    required this.eventCode,
    required this.digest,
  });

  final ApplicationBootstrapPhase phase;
  final int position;
  final String configurationDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'configurationDigest': configurationDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ApplicationBootstrapHostRun {
  const ApplicationBootstrapHostRun._({
    required this.id,
    required this.configuration,
    required this.lifecycle,
    required this.digest,
  });

  factory ApplicationBootstrapHostRun.create({
    required ApplicationBootstrapHostConfiguration configuration,
    required List<ApplicationBootstrapLifecycleEntry> lifecycle,
  }) {
    if (lifecycle.length != ApplicationBootstrapPhase.values.length) {
      throw ArgumentError('Application bootstrap lifecycle is incomplete.');
    }
    final ordered = [...lifecycle]
      ..sort((left, right) => left.position.compareTo(right.position));
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final phase = ApplicationBootstrapPhase.values[position];
      final eventCode = 'application-bootstrap.${phase.name}';
      final digest = _digest({
        'phase': phase.name,
        'position': position,
        'configurationDigest': configuration.digest,
        'eventCode': eventCode,
      });
      if (entry.position != position ||
          entry.phase != phase ||
          entry.configurationDigest != configuration.digest ||
          entry.eventCode != eventCode ||
          entry.digest != digest) {
        throw ArgumentError('Application bootstrap lifecycle is invalid.');
      }
    }
    final payload = {
      'hostVersion': applicationBootstrapHostVersion,
      'policyVersion': applicationBootstrapHostPolicyVersion,
      'configuration': configuration.toJson(),
      'lifecycle': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ApplicationBootstrapHostRun._(
      id: 'application-bootstrap-run.${digest.substring(0, 16)}',
      configuration: configuration,
      lifecycle: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final ApplicationBootstrapHostConfiguration configuration;
  final List<ApplicationBootstrapLifecycleEntry> lifecycle;
  final String digest;

  Map<String, dynamic> toJson() => {
        'hostVersion': applicationBootstrapHostVersion,
        'policyVersion': applicationBootstrapHostPolicyVersion,
        'id': id,
        'configuration': configuration.toJson(),
        'lifecycle': lifecycle.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ApplicationBootstrapHost {
  const ApplicationBootstrapHost();

  ApplicationBootstrapHostRun start({
    required ApplicationBootstrapContract bootstrap,
    required DependencyCompositionRootContract compositionRoot,
  }) {
    final configuration = ApplicationBootstrapHostConfiguration.create(
      bootstrap: bootstrap,
      compositionRoot: compositionRoot,
    );
    return ApplicationBootstrapHostRun.create(
      configuration: configuration,
      lifecycle: [
        for (var position = 0;
            position < ApplicationBootstrapPhase.values.length;
            position++)
          _lifecycleEntry(
            phase: ApplicationBootstrapPhase.values[position],
            position: position,
            configurationDigest: configuration.digest,
          ),
      ],
    );
  }
}

ApplicationBootstrapLifecycleEntry _lifecycleEntry({
  required ApplicationBootstrapPhase phase,
  required int position,
  required String configurationDigest,
}) {
  final eventCode = 'application-bootstrap.${phase.name}';
  return ApplicationBootstrapLifecycleEntry(
    phase: phase,
    position: position,
    configurationDigest: configurationDigest,
    eventCode: eventCode,
    digest: _digest({
      'phase': phase.name,
      'position': position,
      'configurationDigest': configurationDigest,
      'eventCode': eventCode,
    }),
  );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
