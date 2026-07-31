// EPIC 08 — MarketplaceService. THE sole entry point.
//
// PO 2026-07-31 architecture:
//
//   Marketplace UI → MarketplaceService → MarketplacePipeline → 7 Engines → Equipment Repository
//
// Strict rule: UI never reaches engines directly. MarketplaceService is the
// only public surface. Marketplace NEVER owns Equipment (FEATURE 010-012).

import 'package:pool_os/features/marketplace/domain/marketplace_pipeline.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_request.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_response.dart';

class MarketplaceService {
  final MarketplacePipeline _pipeline;
  const MarketplaceService(this._pipeline);

  // Wave 1 — Review / Rating / Comparison
  Future<MarketplaceResponse> review(ReviewRequest req) => _pipeline.review(req);
  Future<MarketplaceResponse> rating(MarketplaceRequest req) => _pipeline.rating(req);
  Future<MarketplaceResponse> comparison(ComparisonRequest req) => _pipeline.comparison(req);

  // Wave 2 — Listing / Search
  Future<MarketplaceResponse> listing(ListingRequest req) => _pipeline.listing(req);
  Future<MarketplaceResponse> search(SearchRequest req) => _pipeline.search(req);

  // Wave 3 — Wishlist / Inventory
  Future<MarketplaceResponse> wishlist(WishlistRequest req) => _pipeline.wishlist(req);
  Future<MarketplaceResponse> inventory(InventoryRequest req) => _pipeline.inventory(req);

  // Aggregated
  Future<MarketplaceResponse> dashboard(MarketplaceRequest req) => _pipeline.dashboard(req);
}
