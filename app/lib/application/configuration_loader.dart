import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/configuration_adapter_planner.dart';
import 'package:pool_os/contracts/runtime_configuration_environment_projection_contracts.dart';

const configurationLoaderContractVersion = 1;
const configurationLoaderPolicyVersion = 'configuration-loader/1.0.0';

abstract interface class ConfigurationValueProvider {
  Future<List<LoadedConfigurationEntry>> load(
    ConfigurationLoadRequest request,
  );
}

class ConfigurationOwnership {
  const ConfigurationOwnership({
    required this.configurationEntryId,
    required this.configurationId,
    required this.environmentId,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.deliveryId,
    required this.deliveryTarget,
    required this.configurationProvenanceDigest,
    required this.position,
  });

  final String configurationEntryId;
  final String configurationId;
  final String environmentId;
  final String runtimeNodeId;
  final String serviceId;
  final String deliveryId;
  final String deliveryTarget;
  final String configurationProvenanceDigest;
  final int position;

  Map<String, dynamic> toJson() => {
        'configurationEntryId': configurationEntryId,
        'configurationId': configurationId,
        'environmentId': environmentId,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'deliveryId': deliveryId,
        'deliveryTarget': deliveryTarget,
        'configurationProvenanceDigest': configurationProvenanceDigest,
        'position': position,
      };
}

class ConfigurationLoadRequest {
  ConfigurationLoadRequest._({
    required this.configurationProjectionId,
    required this.configurationProjectionDigest,
    required this.configurationAdapterPlanId,
    required this.configurationAdapterPlanDigest,
    required List<ConfigurationOwnership> ownership,
    required this.digest,
  }) : ownership = List.unmodifiable(ownership);

  final String configurationProjectionId;
  final String configurationProjectionDigest;
  final String configurationAdapterPlanId;
  final String configurationAdapterPlanDigest;
  final List<ConfigurationOwnership> ownership;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': configurationLoaderContractVersion,
        'policyVersion': configurationLoaderPolicyVersion,
        'configurationProjectionId': configurationProjectionId,
        'configurationProjectionDigest': configurationProjectionDigest,
        'configurationAdapterPlanId': configurationAdapterPlanId,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'ownership': ownership.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class LoadedConfigurationValue {
  const LoadedConfigurationValue({required this.name, required this.value});

  final String name;
  final String value;
}

class LoadedConfigurationEntry {
  LoadedConfigurationEntry({
    required this.configurationEntryId,
    required List<LoadedConfigurationValue> values,
  }) : values = List.unmodifiable(values);

  final String configurationEntryId;
  final List<LoadedConfigurationValue> values;
}

class RuntimeConfigurationEntry {
  RuntimeConfigurationEntry._({
    required this.configurationEntryId,
    required this.configurationId,
    required this.environmentId,
    required this.runtimeNodeId,
    required this.serviceId,
    required this.deliveryId,
    required this.deliveryTarget,
    required this.configurationProvenanceDigest,
    required this.position,
    required Map<String, String> values,
    required this.digest,
  }) : values = UnmodifiableMapView(values);

  final String configurationEntryId;
  final String configurationId;
  final String environmentId;
  final String runtimeNodeId;
  final String serviceId;
  final String deliveryId;
  final String deliveryTarget;
  final String configurationProvenanceDigest;
  final int position;
  final Map<String, String> values;
  final String digest;

  Map<String, dynamic> toJson() => {
        'configurationEntryId': configurationEntryId,
        'configurationId': configurationId,
        'environmentId': environmentId,
        'runtimeNodeId': runtimeNodeId,
        'serviceId': serviceId,
        'deliveryId': deliveryId,
        'deliveryTarget': deliveryTarget,
        'configurationProvenanceDigest': configurationProvenanceDigest,
        'position': position,
        'values': values,
        'digest': digest,
      };
}

class RuntimeConfiguration {
  RuntimeConfiguration._({
    required this.id,
    required this.configurationProjectionId,
    required this.configurationProjectionDigest,
    required this.configurationAdapterPlanId,
    required this.configurationAdapterPlanDigest,
    required this.loadRequestDigest,
    required List<RuntimeConfigurationEntry> entries,
    required this.digest,
  }) : entries = List.unmodifiable(entries);

  final String id;
  final String configurationProjectionId;
  final String configurationProjectionDigest;
  final String configurationAdapterPlanId;
  final String configurationAdapterPlanDigest;
  final String loadRequestDigest;
  final List<RuntimeConfigurationEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': configurationLoaderContractVersion,
        'policyVersion': configurationLoaderPolicyVersion,
        'id': id,
        'configurationProjectionId': configurationProjectionId,
        'configurationProjectionDigest': configurationProjectionDigest,
        'configurationAdapterPlanId': configurationAdapterPlanId,
        'configurationAdapterPlanDigest': configurationAdapterPlanDigest,
        'loadRequestDigest': loadRequestDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ConfigurationLoader {
  const ConfigurationLoader();

  Future<RuntimeConfiguration> load({
    required RuntimeConfigurationEnvironmentProjectionContract
        configurationProjection,
    required ConfigurationAdapterPlan configurationAdapterPlan,
    required ConfigurationValueProvider provider,
  }) async {
    final ownership = _validateAndProjectOwnership(
      configurationProjection: configurationProjection,
      configurationAdapterPlan: configurationAdapterPlan,
    );
    final requestPayload = {
      'schemaVersion': configurationLoaderContractVersion,
      'policyVersion': configurationLoaderPolicyVersion,
      'configurationProjectionId': configurationProjection.id,
      'configurationProjectionDigest': configurationProjection.digest,
      'configurationAdapterPlanId': configurationAdapterPlan.id,
      'configurationAdapterPlanDigest': configurationAdapterPlan.digest,
      'ownership': ownership.map((entry) => entry.toJson()).toList(),
    };
    final request = ConfigurationLoadRequest._(
      configurationProjectionId: configurationProjection.id,
      configurationProjectionDigest: configurationProjection.digest,
      configurationAdapterPlanId: configurationAdapterPlan.id,
      configurationAdapterPlanDigest: configurationAdapterPlan.digest,
      ownership: ownership,
      digest: _digest(requestPayload),
    );
    final loaded = await provider.load(request);
    final loadedById = <String, LoadedConfigurationEntry>{};
    for (final entry in loaded) {
      if (entry.configurationEntryId.isEmpty ||
          loadedById.containsKey(entry.configurationEntryId)) {
        throw StateError('Loaded configuration contains duplicate identity.');
      }
      loadedById[entry.configurationEntryId] = entry;
    }
    if (loadedById.length != ownership.length ||
        loadedById.keys.any(
          (id) => !ownership.any((entry) => entry.configurationEntryId == id),
        )) {
      throw StateError('Loaded configuration coverage is invalid.');
    }

    final entries = <RuntimeConfigurationEntry>[];
    for (final owner in ownership) {
      final loadedEntry = loadedById[owner.configurationEntryId];
      if (loadedEntry == null || loadedEntry.values.isEmpty) {
        throw StateError('Required configuration is missing.');
      }
      final values = <String, String>{};
      final orderedValues = [...loadedEntry.values]
        ..sort((left, right) => left.name.compareTo(right.name));
      for (final value in orderedValues) {
        if (value.name.isEmpty || values.containsKey(value.name)) {
          throw StateError('Loaded configuration values are invalid.');
        }
        values[value.name] = value.value;
      }
      final canonicalValues = SplayTreeMap<String, String>.from(values);
      final payload = {
        ...owner.toJson(),
        'values': canonicalValues,
      };
      entries.add(RuntimeConfigurationEntry._(
        configurationEntryId: owner.configurationEntryId,
        configurationId: owner.configurationId,
        environmentId: owner.environmentId,
        runtimeNodeId: owner.runtimeNodeId,
        serviceId: owner.serviceId,
        deliveryId: owner.deliveryId,
        deliveryTarget: owner.deliveryTarget,
        configurationProvenanceDigest: owner.configurationProvenanceDigest,
        position: owner.position,
        values: canonicalValues,
        digest: _digest(payload),
      ));
    }
    final payload = {
      'schemaVersion': configurationLoaderContractVersion,
      'policyVersion': configurationLoaderPolicyVersion,
      'configurationProjectionId': configurationProjection.id,
      'configurationProjectionDigest': configurationProjection.digest,
      'configurationAdapterPlanId': configurationAdapterPlan.id,
      'configurationAdapterPlanDigest': configurationAdapterPlan.digest,
      'loadRequestDigest': request.digest,
      'entries': entries.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return RuntimeConfiguration._(
      id: 'runtime-configuration.${digest.substring(0, 16)}',
      configurationProjectionId: configurationProjection.id,
      configurationProjectionDigest: configurationProjection.digest,
      configurationAdapterPlanId: configurationAdapterPlan.id,
      configurationAdapterPlanDigest: configurationAdapterPlan.digest,
      loadRequestDigest: request.digest,
      entries: entries,
      digest: digest,
    );
  }
}

List<ConfigurationOwnership> _validateAndProjectOwnership({
  required RuntimeConfigurationEnvironmentProjectionContract
      configurationProjection,
  required ConfigurationAdapterPlan configurationAdapterPlan,
}) {
  if (configurationProjection.id.isEmpty ||
      configurationProjection.digest.isEmpty ||
      configurationProjection.entries.isEmpty ||
      configurationAdapterPlan.id.isEmpty ||
      configurationAdapterPlan.digest.isEmpty ||
      configurationAdapterPlan.entries.isEmpty ||
      configurationAdapterPlan.configurationProjectionId !=
          configurationProjection.id ||
      configurationAdapterPlan.configurationProjectionDigest !=
          configurationProjection.digest) {
    throw ArgumentError('Configuration loader inputs are incompatible.');
  }
  final adapterIds = <String>{};
  final featureIds = <String>{};
  for (var position = 0;
      position < configurationAdapterPlan.entries.length;
      position++) {
    final entry = configurationAdapterPlan.entries[position];
    if (entry.position != position ||
        entry.configurationProjectionDigest != configurationProjection.digest ||
        !adapterIds.add(entry.configurationAdapterEntryId) ||
        !featureIds.add(entry.featureId)) {
      throw ArgumentError('Configuration adapter ownership is invalid.');
    }
  }
  final ordered = [...configurationProjection.entries]..sort((left, right) =>
      left.canonicalPosition.compareTo(right.canonicalPosition));
  final entryIds = <String>{};
  final ownershipKeys = <String>{};
  final result = <ConfigurationOwnership>[];
  for (var position = 0; position < ordered.length; position++) {
    final entry = ordered[position];
    final ownershipKey = [
      entry.configurationId,
      entry.environmentId,
      entry.runtimeNodeId,
      entry.serviceId,
      entry.deliveryId,
    ].join('|');
    if (entry.canonicalPosition != position ||
        entry.configurationEntryId.isEmpty ||
        entry.configurationId.isEmpty ||
        entry.environmentId.isEmpty ||
        entry.runtimeNodeId.isEmpty ||
        entry.serviceId.isEmpty ||
        entry.deliveryId.isEmpty ||
        entry.configurationProvenanceDigest.isEmpty ||
        !entryIds.add(entry.configurationEntryId) ||
        !ownershipKeys.add(ownershipKey)) {
      throw ArgumentError('Configuration ownership is invalid.');
    }
    result.add(ConfigurationOwnership(
      configurationEntryId: entry.configurationEntryId,
      configurationId: entry.configurationId,
      environmentId: entry.environmentId,
      runtimeNodeId: entry.runtimeNodeId,
      serviceId: entry.serviceId,
      deliveryId: entry.deliveryId,
      deliveryTarget: entry.deliveryTarget.name,
      configurationProvenanceDigest: entry.configurationProvenanceDigest,
      position: position,
    ));
  }
  return List.unmodifiable(result);
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
