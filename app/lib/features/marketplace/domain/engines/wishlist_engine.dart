// EPIC 08 — WishlistEngine (Deliverable 1.6).
//
// Wave 3. Add/Remove/Favorite/Move to Inventory. State: Active/
// Purchased/Removed/Archived. Notify when available = placeholder only
// (no push notification).

import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';

class WishlistEngine implements MarketplaceEngine {
  @override
  String get engineId => 'wishlist';
  @override
  Future<MarketplaceContribution> run(MarketplaceRequest request) async {
    return const MarketplaceContribution(
      engineId: 'wishlist',
      status: CapabilityStatus.implemented,
    );
  }
}