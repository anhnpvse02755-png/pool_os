// EPIC 08 — MarketplacePipeline (all 3 waves registered).

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_response.dart';
import 'package:pool_os/features/marketplace/domain/capability.dart';
import 'package:pool_os/features/marketplace/domain/engines/review_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/rating_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/comparison_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/listing_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/search_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/wishlist_engine.dart';
import 'package:pool_os/features/marketplace/domain/engines/inventory_engine.dart';

class MarketplacePipeline {
  final List<MarketplaceEngine> _engines;
  const MarketplacePipeline(this._engines);

  MarketplaceEngine? _byId(String id) {
    for (final e in _engines) {
      if (e.engineId == id) return e;
    }
    return null;
  }

  Future<MarketplaceResponse> _run(
    String playerId,
    DateTime now,
    MarketplaceRequest request,
    List<String> ids,
  ) async {
    final contributions = <MarketplaceContribution>[];
    for (final id in ids) {
      final engine = _byId(id);
      if (engine == null) {
        contributions.add(MarketplaceContribution(
          engineId: id,
          status: CapabilityStatus.planned,
          reason: const CapabilityReason(
            code: 'engine_not_registered',
            message: 'Not yet registered in the pipeline.',
          ),
        ));
        continue;
      }
      contributions.add(await engine.run(request));
    }
    return MarketplaceResponse(
      playerId: playerId,
      generatedAt: now,
      contributions: contributions,
    );
  }

  // Wave 1
  Future<MarketplaceResponse> review(ReviewRequest req) =>
      _run(req.playerId, req.asOf, req, const ['review']);

  Future<MarketplaceResponse> rating(MarketplaceRequest req) =>
      _run(req.playerId, req.asOf, req, const ['rating']);

  Future<MarketplaceResponse> comparison(ComparisonRequest req) =>
      _run(req.playerId, req.asOf, req, const ['comparison']);

  // Wave 2
  Future<MarketplaceResponse> listing(ListingRequest req) =>
      _run(req.playerId, req.asOf, req, const ['listing']);

  Future<MarketplaceResponse> search(SearchRequest req) =>
      _run(req.playerId, req.asOf, req, const ['search']);

  // Wave 3
  Future<MarketplaceResponse> wishlist(WishlistRequest req) =>
      _run(req.playerId, req.asOf, req, const ['wishlist']);

  Future<MarketplaceResponse> inventory(InventoryRequest req) =>
      _run(req.playerId, req.asOf, req, const ['inventory']);

  // Aggregated dashboard
  Future<MarketplaceResponse> dashboard(MarketplaceRequest req) =>
      _run(req.playerId, req.asOf, req, const [
        'review', 'rating', 'comparison',
        'listing', 'search',
        'wishlist', 'inventory',
      ]);
}

MarketplacePipeline defaultMarketplacePipeline() {
  return MarketplacePipeline(<MarketplaceEngine>[
    ReviewEngine(),
    RatingEngine(),
    ComparisonEngine(),
    ListingEngine(),
    SearchEngine(),
    WishlistEngine(),
    InventoryEngine(),
  ]);
}
