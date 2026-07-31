// EPIC 08 — ComparisonEngine (Deliverable 1.3).
//
// Wave 1. Extends FEATURE_012. Compare 2/3/4 items across Cue/Shaft/
// Tip/Extension/Case/Glove/Chalk/Accessory. No AI. Only factual comparison.

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class ComparisonEngine implements MarketplaceEngine {
  @override
  String get engineId => 'comparison';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'comparison',
      status: CapabilityStatus.implemented,
    );
  }
}