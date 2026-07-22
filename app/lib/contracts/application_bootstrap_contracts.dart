import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_composition_contracts.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_validation_contracts.dart';

const applicationBootstrapContractVersion = 1;
const applicationBootstrapPolicyVersion = 'application-bootstrap/1.0.0';

class ApplicationBootstrapEntry {
  const ApplicationBootstrapEntry({
    required this.bootstrapEntryId,
    required this.runtimeNodeId,
    required this.deliveryId,
    required this.serviceId,
    required this.position,
    required this.runtimeCompositionDigest,
    required this.runtimeValidationDigest,
    required this.runtimeDeliveryDigest,
  });

  final String bootstrapEntryId;
  final String runtimeNodeId;
  final String deliveryId;
  final String serviceId;
  final int position;
  final String runtimeCompositionDigest;
  final String runtimeValidationDigest;
  final String runtimeDeliveryDigest;

  Map<String, dynamic> toJson() => {
        'bootstrapEntryId': bootstrapEntryId,
        'runtimeNodeId': runtimeNodeId,
        'deliveryId': deliveryId,
        'serviceId': serviceId,
        'position': position,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'runtimeValidationDigest': runtimeValidationDigest,
        'runtimeDeliveryDigest': runtimeDeliveryDigest,
      };
}

class ApplicationBootstrapContract {
  const ApplicationBootstrapContract._({
    required this.id,
    required this.runtimeCompositionId,
    required this.runtimeValidationId,
    required this.runtimeDeliveryId,
    required this.runtimeCompositionDigest,
    required this.runtimeValidationDigest,
    required this.runtimeDeliveryDigest,
    required this.entries,
    required this.digest,
  });

  factory ApplicationBootstrapContract.create({
    required RuntimeCompositionContract runtimeComposition,
    required RuntimeValidationContract runtimeValidation,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
    required List<ApplicationBootstrapEntry> entries,
  }) {
    final compositionDigest = runtimeComposition.digest;
    final validationDigest = runtimeValidation.digest;
    final deliveryDigest = runtimeDelivery.digest;
    final validatedCompositionDigest =
        runtimeValidation.artifactDigests['composition'];
    final validatedDeliveryDigest =
        runtimeValidation.artifactDigests['delivery'];
    final nodeIds = runtimeComposition.nodes.map((node) => node.id).toSet();
    if (compositionDigest.trim().isEmpty ||
        validationDigest.trim().isEmpty ||
        deliveryDigest.trim().isEmpty ||
        runtimeValidation.summary.failed != 0 ||
        validatedCompositionDigest != compositionDigest ||
        validatedDeliveryDigest != deliveryDigest ||
        runtimeComposition.nodes.isEmpty ||
        runtimeDelivery.entries.isEmpty ||
        entries.length != runtimeDelivery.entries.length) {
      throw ArgumentError(
          'Application bootstrap inputs are stale or incomplete.');
    }
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final positions = <int>{};
    final entryIds = <String>{};
    final deliveryIds = <String>{};
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final delivery = runtimeDelivery.entries[index];
      if (entry.position != index ||
          entry.position != delivery.position ||
          entry.bootstrapEntryId !=
              'application-bootstrap-entry.${delivery.deliveryId}' ||
          entry.runtimeNodeId != delivery.runtimeNodeId ||
          entry.serviceId != delivery.serviceId ||
          entry.deliveryId != delivery.deliveryId ||
          !nodeIds.contains(entry.runtimeNodeId) ||
          entry.runtimeCompositionDigest != compositionDigest ||
          entry.runtimeValidationDigest != validationDigest ||
          entry.runtimeDeliveryDigest != deliveryDigest ||
          !positions.add(entry.position) ||
          !entryIds.add(entry.bootstrapEntryId) ||
          !deliveryIds.add(entry.deliveryId)) {
        throw ArgumentError('Application bootstrap provenance is invalid.');
      }
    }
    final payload = {
      'schemaVersion': applicationBootstrapContractVersion,
      'policyVersion': applicationBootstrapPolicyVersion,
      'runtimeCompositionId': runtimeComposition.id,
      'runtimeValidationId': runtimeValidation.id,
      'runtimeDeliveryId': runtimeDelivery.id,
      'runtimeCompositionDigest': compositionDigest,
      'runtimeValidationDigest': validationDigest,
      'runtimeDeliveryDigest': deliveryDigest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ApplicationBootstrapContract._(
      id: 'application-bootstrap.${digest.substring(0, 16)}',
      runtimeCompositionId: runtimeComposition.id,
      runtimeValidationId: runtimeValidation.id,
      runtimeDeliveryId: runtimeDelivery.id,
      runtimeCompositionDigest: compositionDigest,
      runtimeValidationDigest: validationDigest,
      runtimeDeliveryDigest: deliveryDigest,
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final String runtimeCompositionId;
  final String runtimeValidationId;
  final String runtimeDeliveryId;
  final String runtimeCompositionDigest;
  final String runtimeValidationDigest;
  final String runtimeDeliveryDigest;
  final List<ApplicationBootstrapEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': applicationBootstrapContractVersion,
        'policyVersion': applicationBootstrapPolicyVersion,
        'id': id,
        'runtimeCompositionId': runtimeCompositionId,
        'runtimeValidationId': runtimeValidationId,
        'runtimeDeliveryId': runtimeDeliveryId,
        'runtimeCompositionDigest': runtimeCompositionDigest,
        'runtimeValidationDigest': runtimeValidationDigest,
        'runtimeDeliveryDigest': runtimeDeliveryDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ApplicationBootstrapBuilder {
  const ApplicationBootstrapBuilder();

  ApplicationBootstrapContract build({
    required RuntimeCompositionContract runtimeComposition,
    required RuntimeValidationContract runtimeValidation,
    required RuntimeDeliveryProjectionContract runtimeDelivery,
  }) =>
      ApplicationBootstrapContract.create(
        runtimeComposition: runtimeComposition,
        runtimeValidation: runtimeValidation,
        runtimeDelivery: runtimeDelivery,
        entries: [
          for (final delivery in runtimeDelivery.entries)
            ApplicationBootstrapEntry(
              bootstrapEntryId:
                  'application-bootstrap-entry.${delivery.deliveryId}',
              runtimeNodeId: delivery.runtimeNodeId,
              deliveryId: delivery.deliveryId,
              serviceId: delivery.serviceId,
              position: delivery.position,
              runtimeCompositionDigest: runtimeComposition.digest,
              runtimeValidationDigest: runtimeValidation.digest,
              runtimeDeliveryDigest: runtimeDelivery.digest,
            ),
        ],
      );
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
