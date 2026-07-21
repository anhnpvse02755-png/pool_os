import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:pool_os/contracts/runtime_delivery_projection_contracts.dart';
import 'package:pool_os/contracts/runtime_service_exposure_contracts.dart';

const productNavigationPolicyVersion = 1;
const productShellContractVersion = 1;
const productShellPolicyVersion = 'product-navigation-policy/1.0.0';

enum ProductNavigationCategory {
  home,
  training,
  coach,
  ai,
  analytics,
  settings,
}

class ProductNavigationPolicyEntry {
  const ProductNavigationPolicyEntry({
    required this.featureId,
    required this.category,
    required this.position,
    required this.visible,
    this.parentFeatureId,
  });

  final String featureId;
  final ProductNavigationCategory category;
  final int position;
  final bool visible;
  final String? parentFeatureId;

  Map<String, dynamic> toJson() => {
        'featureId': featureId,
        'category': category.name,
        'position': position,
        'visible': visible,
        'parentFeatureId': parentFeatureId,
      };
}

class ProductNavigationPolicy {
  const ProductNavigationPolicy._({
    required this.id,
    required this.entries,
    required this.digest,
  });

  factory ProductNavigationPolicy.create({
    required List<ProductNavigationPolicyEntry> entries,
  }) {
    final ordered = [...entries]
      ..sort((left, right) => left.position.compareTo(right.position));
    final ids = ordered.map((entry) => entry.featureId).toSet();
    final positions = ordered.map((entry) => entry.position).toSet();
    if (ordered.isEmpty ||
        ids.length != ordered.length ||
        positions.length != ordered.length ||
        ordered.asMap().entries.any(
              (entry) => entry.value.position != entry.key,
            ) ||
        ordered.any(
          (entry) =>
              entry.featureId.trim().isEmpty ||
              (entry.parentFeatureId != null &&
                  (!ids.contains(entry.parentFeatureId) ||
                      entry.parentFeatureId == entry.featureId)),
        )) {
      throw ArgumentError('Product navigation policy is invalid.');
    }
    final positionsById = {
      for (final entry in ordered) entry.featureId: entry.position,
    };
    if (ordered.any(
      (entry) =>
          entry.parentFeatureId != null &&
          positionsById[entry.parentFeatureId]! >= entry.position,
    )) {
      throw ArgumentError('Product navigation policy contains a cycle.');
    }
    final payload = {
      'schemaVersion': productNavigationPolicyVersion,
      'policyVersion': productShellPolicyVersion,
      'entries': ordered.map((entry) => entry.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductNavigationPolicy._(
      id: 'product-navigation-policy.${digest.substring(0, 16)}',
      entries: List.unmodifiable(ordered),
      digest: digest,
    );
  }

  final String id;
  final List<ProductNavigationPolicyEntry> entries;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': productNavigationPolicyVersion,
        'policyVersion': productShellPolicyVersion,
        'id': id,
        'entries': entries.map((entry) => entry.toJson()).toList(),
        'digest': digest,
      };
}

class ProductNavigationNode {
  const ProductNavigationNode({
    required this.featureId,
    required this.category,
    required this.visible,
    required this.parentFeatureId,
    required this.deliveryId,
    required this.deliveryDigest,
    required this.exposureDigest,
    required this.position,
  });

  final String featureId;
  final ProductNavigationCategory category;
  final bool visible;
  final String? parentFeatureId;
  final String deliveryId;
  final String deliveryDigest;
  final String exposureDigest;
  final int position;

  Map<String, dynamic> toJson() => {
        'featureId': featureId,
        'category': category.name,
        'visible': visible,
        'parentFeatureId': parentFeatureId,
        'deliveryId': deliveryId,
        'deliveryDigest': deliveryDigest,
        'exposureDigest': exposureDigest,
        'position': position,
      };
}

class ProductNavigationEdge {
  const ProductNavigationEdge({
    required this.edgeId,
    required this.parentFeatureId,
    required this.childFeatureId,
    required this.position,
  });

  final String edgeId;
  final String parentFeatureId;
  final String childFeatureId;
  final int position;

  Map<String, dynamic> toJson() => {
        'edgeId': edgeId,
        'parentFeatureId': parentFeatureId,
        'childFeatureId': childFeatureId,
        'position': position,
      };
}

class ProductShellContract {
  const ProductShellContract._({
    required this.id,
    required this.exposureDigest,
    required this.deliveryDigest,
    required this.policyDigest,
    required this.nodes,
    required this.edges,
    required this.digest,
  });

  factory ProductShellContract.create({
    required RuntimeServiceExposureContract exposure,
    required RuntimeDeliveryProjectionContract delivery,
    required ProductNavigationPolicy policy,
    required List<ProductNavigationNode> nodes,
    required List<ProductNavigationEdge> edges,
  }) {
    if (delivery.exposureDigest != exposure.digest ||
        nodes.length != policy.entries.length ||
        nodes.length != delivery.entries.length) {
      throw ArgumentError('Product shell source projections are stale.');
    }
    final orderedNodes = [...nodes]
      ..sort((left, right) => left.position.compareTo(right.position));
    final orderedEdges = [...edges]
      ..sort((left, right) => left.position.compareTo(right.position));
    final policyByPosition = {
      for (final entry in policy.entries) entry.position: entry,
    };
    final deliveryByPosition = {
      for (final entry in delivery.entries) entry.position: entry,
    };
    final featureIds = orderedNodes.map((node) => node.featureId).toSet();
    final edgeIds = orderedEdges.map((edge) => edge.edgeId).toSet();
    final expectedEdges = policy.entries
        .where((entry) => entry.parentFeatureId != null)
        .map((entry) => _edgeId(entry.parentFeatureId!, entry.featureId))
        .toSet();
    if (featureIds.length != orderedNodes.length ||
        edgeIds.length != orderedEdges.length ||
        orderedNodes.map((node) => node.position).toSet().length !=
            orderedNodes.length ||
        orderedEdges.map((edge) => edge.position).toSet().length !=
            orderedEdges.length ||
        edgeIds.length != expectedEdges.length ||
        !edgeIds.containsAll(expectedEdges)) {
      throw ArgumentError('Product shell contains duplicate nodes or edges.');
    }
    for (var position = 0; position < orderedNodes.length; position++) {
      final node = orderedNodes[position];
      final policyEntry = policyByPosition[position];
      final deliveryEntry = deliveryByPosition[position];
      if (policyEntry == null ||
          deliveryEntry == null ||
          node.position != position ||
          node.featureId != policyEntry.featureId ||
          node.category != policyEntry.category ||
          node.visible != policyEntry.visible ||
          node.parentFeatureId != policyEntry.parentFeatureId ||
          node.deliveryId != deliveryEntry.deliveryId ||
          node.deliveryDigest != delivery.digest ||
          node.exposureDigest != exposure.digest) {
        throw ArgumentError('Product shell policy or provenance is broken.');
      }
      if (node.parentFeatureId != null &&
          !featureIds.contains(node.parentFeatureId)) {
        throw ArgumentError('Product shell contains an orphan parent.');
      }
    }
    for (var position = 0; position < orderedEdges.length; position++) {
      final edge = orderedEdges[position];
      if (edge.position != position ||
          edge.edgeId != _edgeId(edge.parentFeatureId, edge.childFeatureId) ||
          !featureIds.contains(edge.parentFeatureId) ||
          !featureIds.contains(edge.childFeatureId)) {
        throw ArgumentError('Product shell navigation topology is invalid.');
      }
    }
    final payload = {
      'schemaVersion': productShellContractVersion,
      'exposureDigest': exposure.digest,
      'deliveryDigest': delivery.digest,
      'policyDigest': policy.digest,
      'nodes': orderedNodes.map((node) => node.toJson()).toList(),
      'edges': orderedEdges.map((edge) => edge.toJson()).toList(),
    };
    final digest = _digest(payload);
    return ProductShellContract._(
      id: 'product-shell.${digest.substring(0, 16)}',
      exposureDigest: exposure.digest,
      deliveryDigest: delivery.digest,
      policyDigest: policy.digest,
      nodes: List.unmodifiable(orderedNodes),
      edges: List.unmodifiable(orderedEdges),
      digest: digest,
    );
  }

  final String id;
  final String exposureDigest;
  final String deliveryDigest;
  final String policyDigest;
  final List<ProductNavigationNode> nodes;
  final List<ProductNavigationEdge> edges;
  final String digest;

  Map<String, dynamic> toJson() => {
        'schemaVersion': productShellContractVersion,
        'id': id,
        'exposureDigest': exposureDigest,
        'deliveryDigest': deliveryDigest,
        'policyDigest': policyDigest,
        'nodes': nodes.map((node) => node.toJson()).toList(),
        'edges': edges.map((edge) => edge.toJson()).toList(),
        'digest': digest,
      };
}

class ProductShellBuilder {
  const ProductShellBuilder();

  ProductShellContract build({
    required RuntimeServiceExposureContract exposure,
    required RuntimeDeliveryProjectionContract delivery,
    required ProductNavigationPolicy policy,
  }) {
    if (policy.entries.length != delivery.entries.length) {
      throw ArgumentError('Product navigation policy does not cover delivery.');
    }
    final nodes = [
      for (var position = 0; position < policy.entries.length; position++)
        ProductNavigationNode(
          featureId: policy.entries[position].featureId,
          category: policy.entries[position].category,
          visible: policy.entries[position].visible,
          parentFeatureId: policy.entries[position].parentFeatureId,
          deliveryId: delivery.entries[position].deliveryId,
          deliveryDigest: delivery.digest,
          exposureDigest: exposure.digest,
          position: position,
        ),
    ];
    final edges = <ProductNavigationEdge>[];
    for (final entry in policy.entries) {
      if (entry.parentFeatureId != null) {
        edges.add(
          ProductNavigationEdge(
            edgeId: _edgeId(entry.parentFeatureId!, entry.featureId),
            parentFeatureId: entry.parentFeatureId!,
            childFeatureId: entry.featureId,
            position: edges.length,
          ),
        );
      }
    }
    return ProductShellContract.create(
      exposure: exposure,
      delivery: delivery,
      policy: policy,
      nodes: nodes,
      edges: edges,
    );
  }
}

String _edgeId(String parent, String child) =>
    'navigation-edge:$parent->$child';

String _digest(Object value) =>
    sha256.convert(utf8.encode(jsonEncode(value))).toString();
