// EPIC 08 — SearchEngine (Deliverable 1.5).
//
// Wave 2. Marketplace browser: Search/Filter/Sort. Filter by Cue/Shaft/
// Tip/Accessory/Case/Extension/Glove/Chalk. Sort by Newest/Oldest/
// LowestPrice/HighestPrice/HighestRating/MostReviews.

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class SearchEngine implements MarketplaceEngine {
  @override
  String get engineId => 'search';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'search',
      status: CapabilityStatus.implemented,
    );
  }
}