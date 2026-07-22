import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/application/application_service_wiring_planner.dart';
import 'package:pool_os/contracts/product_shell_contracts.dart';

const productFeatureAssemblyPlannerVersion = 1;
const productFeatureAssemblyPlannerPolicyVersion =
    'product-feature-assembly-planner/1.0.0';

enum ProductFeatureAssemblyLogPhase {
  validateInputs,
  orderFeatures,
  bindWiringProvenance,
  completed,
}

class ProductFeatureAssemblyEntry {
  const ProductFeatureAssemblyEntry._({
    required this.assemblyEntryId,
    required this.featureId,
    required this.shellEntryId,
    required this.category,
    required this.visible,
    required this.parentFeatureId,
    required this.position,
    required this.shellDigest,
    required this.wiringPlanDigest,
    required this.digest,
  });

  factory ProductFeatureAssemblyEntry.create({
    required String featureId,
    required String shellEntryId,
    required String category,
    required bool visible,
    required String? parentFeatureId,
    required int position,
    required String shellDigest,
    required String wiringPlanDigest,
  }) {
    if (featureId.isEmpty ||
        shellEntryId.isEmpty ||
        category.isEmpty ||
        position < 0 ||
        shellDigest.isEmpty ||
        wiringPlanDigest.isEmpty ||
        parentFeatureId == featureId) {
      throw ArgumentError('Product feature assembly entry is incomplete.');
    }
    final assemblyEntryId = 'product-feature-assembly.$featureId';
    final payload = {
      'assemblyEntryId': assemblyEntryId,
      'featureId': featureId,
      'shellEntryId': shellEntryId,
      'category': category,
      'visible': visible,
      'parentFeatureId': parentFeatureId,
      'position': position,
      'shellDigest': shellDigest,
      'wiringPlanDigest': wiringPlanDigest,
    };
    return ProductFeatureAssemblyEntry._(
      assemblyEntryId: assemblyEntryId,
      featureId: featureId,
      shellEntryId: shellEntryId,
      category: category,
      visible: visible,
      parentFeatureId: parentFeatureId,
      position: position,
      shellDigest: shellDigest,
      wiringPlanDigest: wiringPlanDigest,
      digest: _digest(payload),
    );
  }

  final String assemblyEntryId;
  final String featureId;
  final String shellEntryId;
  final String category;
  final bool visible;
  final String? parentFeatureId;
  final int position;
  final String shellDigest;
  final String wiringPlanDigest;
  final String digest;

  Map<String, dynamic> toJson() => {
        'assemblyEntryId': assemblyEntryId,
        'featureId': featureId,
        'shellEntryId': shellEntryId,
        'category': category,
        'visible': visible,
        'parentFeatureId': parentFeatureId,
        'position': position,
        'shellDigest': shellDigest,
        'wiringPlanDigest': wiringPlanDigest,
        'digest': digest,
      };
}

class ProductFeatureAssemblyLogEntry {
  const ProductFeatureAssemblyLogEntry._({
    required this.phase,
    required this.position,
    required this.shellDigest,
    required this.wiringPlanDigest,
    required this.assemblySetDigest,
    required this.eventCode,
    required this.digest,
  });

  factory ProductFeatureAssemblyLogEntry.create({
    required ProductFeatureAssemblyLogPhase phase,
    required int position,
    required String shellDigest,
    required String wiringPlanDigest,
    required String assemblySetDigest,
  }) {
    if (position < 0 ||
        shellDigest.isEmpty ||
        wiringPlanDigest.isEmpty ||
        assemblySetDigest.isEmpty) {
      throw ArgumentError('Product feature assembly log is incomplete.');
    }
    final eventCode = 'product-feature-assembly.${phase.name}';
    final payload = {
      'phase': phase.name,
      'position': position,
      'shellDigest': shellDigest,
      'wiringPlanDigest': wiringPlanDigest,
      'assemblySetDigest': assemblySetDigest,
      'eventCode': eventCode,
    };
    return ProductFeatureAssemblyLogEntry._(
      phase: phase,
      position: position,
      shellDigest: shellDigest,
      wiringPlanDigest: wiringPlanDigest,
      assemblySetDigest: assemblySetDigest,
      eventCode: eventCode,
      digest: _digest(payload),
    );
  }

  final ProductFeatureAssemblyLogPhase phase;
  final int position;
  final String shellDigest;
  final String wiringPlanDigest;
  final String assemblySetDigest;
  final String eventCode;
  final String digest;

  Map<String, dynamic> toJson() => {
        'phase': phase.name,
        'position': position,
        'shellDigest': shellDigest,
        'wiringPlanDigest': wiringPlanDigest,
        'assemblySetDigest': assemblySetDigest,
        'eventCode': eventCode,
        'digest': digest,
      };
}

class ProductFeatureAssemblyPlan {
  const ProductFeatureAssemblyPlan._({
    required this.id,
    required this.wiringPlanId,
    required this.wiringPlanDigest,
    required this.productShellId,
    required this.productShellDigest,
    required this.entries,
    required this.log,
    required this.digest,
  });

  factory ProductFeatureAssemblyPlan.create({
    required ApplicationServiceWiringPlan wiringPlan,
    required ProductShellContract productShell,
    required List<ProductFeatureAssemblyEntry> entries,
    required List<ProductFeatureAssemblyLogEntry> log,
  }) {
    _validateInputs(wiringPlan: wiringPlan, productShell: productShell);
    if (entries.length != productShell.nodes.length) {
      throw ArgumentError('Product feature assembly coverage is incomplete.');
    }
    final shellByFeature = {
      for (final node in productShell.nodes) node.featureId: node,
    };
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final assemblyIds = <String>{};
    final featureIds = <String>{};
    final shellEntryIds = <String>{};
    final positions = <int>{};
    for (var position = 0; position < ordered.length; position++) {
      final entry = ordered[position];
      final shellNode = shellByFeature[entry.featureId];
      final expectedShellEntryId =
          'product-shell-entry.${productShell.id}.${entry.featureId}';
      final expected = ProductFeatureAssemblyEntry.create(
        featureId: entry.featureId,
        shellEntryId: expectedShellEntryId,
        category: entry.category,
        visible: entry.visible,
        parentFeatureId: entry.parentFeatureId,
        position: position,
        shellDigest: productShell.digest,
        wiringPlanDigest: wiringPlan.digest,
      );
      if (shellNode == null ||
          entry.position != position ||
          shellNode.position != position ||
          entry.shellEntryId != expectedShellEntryId ||
          entry.category != shellNode.category.name ||
          entry.visible != shellNode.visible ||
          entry.parentFeatureId != shellNode.parentFeatureId ||
          entry.shellDigest != productShell.digest ||
          entry.wiringPlanDigest != wiringPlan.digest ||
          entry.assemblyEntryId != expected.assemblyEntryId ||
          entry.digest != expected.digest ||
          !assemblyIds.add(entry.assemblyEntryId) ||
          !featureIds.add(entry.featureId) ||
          !shellEntryIds.add(entry.shellEntryId) ||
          !positions.add(entry.position)) {
        throw ArgumentError('Product feature assembly provenance is invalid.');
      }
    }

    final assemblySetDigest =
        _digest(ordered.map((entry) => entry.toJson()).toList());
    final orderedLog = [...log]
      ..sort((left, right) => left.position.compareTo(right.position));
    if (orderedLog.length != ProductFeatureAssemblyLogPhase.values.length) {
      throw ArgumentError('Product feature assembly log is incomplete.');
    }
    for (var position = 0; position < orderedLog.length; position++) {
      final entry = orderedLog[position];
      final expected = ProductFeatureAssemblyLogEntry.create(
        phase: ProductFeatureAssemblyLogPhase.values[position],
        position: position,
        shellDigest: productShell.digest,
        wiringPlanDigest: wiringPlan.digest,
        assemblySetDigest: assemblySetDigest,
      );
      if (entry.phase != expected.phase ||
          entry.position != expected.position ||
          entry.shellDigest != expected.shellDigest ||
          entry.wiringPlanDigest != expected.wiringPlanDigest ||
          entry.assemblySetDigest != expected.assemblySetDigest ||
          entry.eventCode != expected.eventCode ||
          entry.digest != expected.digest) {
        throw ArgumentError('Product feature assembly log is invalid.');
      }
    }

    final payload = {
      'plannerVersion': productFeatureAssemblyPlannerVersion,
      'policyVersion': productFeatureAssemblyPlannerPolicyVersion,
      'wiringPlanId': wiringPlan.id,
      'wiringPlanDigest': wiringPlan.digest,
      'productShellId': productShell.id,
      'productShellDigest': productShell.digest,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
      'log': orderedLog.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductFeatureAssemblyPlan._(
      id: 'product-feature-assembly-plan.${digest.substring(0, 16)}',
      wiringPlanId: wiringPlan.id,
      wiringPlanDigest: wiringPlan.digest,
      productShellId: productShell.id,
      productShellDigest: productShell.digest,
      entries: List.unmodifiable(ordered),
      log: List.unmodifiable(orderedLog),
      digest: digest,
    );
  }

  final String id;
  final String wiringPlanId;
  final String wiringPlanDigest;
  final String productShellId;
  final String productShellDigest;
  final List<ProductFeatureAssemblyEntry> entries;
  final List<ProductFeatureAssemblyLogEntry> log;
  final String digest;

  Map<String, dynamic> toJson() => {
        'plannerVersion': productFeatureAssemblyPlannerVersion,
        'policyVersion': productFeatureAssemblyPlannerPolicyVersion,
        'id': id,
        'wiringPlanId': wiringPlanId,
        'wiringPlanDigest': wiringPlanDigest,
        'productShellId': productShellId,
        'productShellDigest': productShellDigest,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'log': log.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ProductFeatureAssemblyPlanner {
  const ProductFeatureAssemblyPlanner();

  ProductFeatureAssemblyPlan plan({
    required ApplicationServiceWiringPlan wiringPlan,
    required ProductShellContract productShell,
  }) {
    _validateInputs(wiringPlan: wiringPlan, productShell: productShell);
    final entries = [
      for (final node in productShell.nodes)
        ProductFeatureAssemblyEntry.create(
          featureId: node.featureId,
          shellEntryId:
              'product-shell-entry.${productShell.id}.${node.featureId}',
          category: node.category.name,
          visible: node.visible,
          parentFeatureId: node.parentFeatureId,
          position: node.position,
          shellDigest: productShell.digest,
          wiringPlanDigest: wiringPlan.digest,
        ),
    ]..sort((left, right) => left.position.compareTo(right.position));
    final assemblySetDigest =
        _digest(entries.map((entry) => entry.toJson()).toList());
    return ProductFeatureAssemblyPlan.create(
      wiringPlan: wiringPlan,
      productShell: productShell,
      entries: entries,
      log: [
        for (var position = 0;
            position < ProductFeatureAssemblyLogPhase.values.length;
            position++)
          ProductFeatureAssemblyLogEntry.create(
            phase: ProductFeatureAssemblyLogPhase.values[position],
            position: position,
            shellDigest: productShell.digest,
            wiringPlanDigest: wiringPlan.digest,
            assemblySetDigest: assemblySetDigest,
          ),
      ],
    );
  }
}

void _validateInputs({
  required ApplicationServiceWiringPlan wiringPlan,
  required ProductShellContract productShell,
}) {
  if (wiringPlan.entries.isEmpty || productShell.nodes.isEmpty) {
    throw ArgumentError('Product feature assembly inputs are incomplete.');
  }
}

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
