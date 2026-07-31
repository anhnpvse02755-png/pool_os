// EPIC 08 — Marketplace Service tests.
//
// Covers all 7 deliverable surface methods.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_engine.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_pipeline.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_service.dart';
import 'package:pool_os/features/marketplace/domain/marketplace_request.dart';
import 'package:pool_os/features/marketplace/domain/capability.dart';

MarketplaceService _service() => MarketplaceService(defaultMarketplacePipeline());

void main() {
  group('MarketplaceService — 7 deliverable surfaces', () {
    // Wave 1
    test('review returns implemented contribution', () async {
      final r = await _service().review(ReviewRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        equipmentId: 'e1',
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('review'));
    });

    test('rating returns implemented contribution', () async {
      final r = await _service().rating(MarketplaceRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('rating'));
    });

    test('comparison returns implemented contribution', () async {
      final r = await _service().comparison(ComparisonRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        equipmentIds: ['e1', 'e2'],
        mode: ComparisonMode.two,
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('comparison'));
    });

    // Wave 2
    test('listing returns implemented contribution', () async {
      final r = await _service().listing(ListingRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        equipmentId: 'e1',
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('listing'));
    });

    test('search returns implemented contribution', () async {
      final r = await _service().search(SearchRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        query: const SearchQuery(query: 'cue'),
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('search'));
    });

    // Wave 3
    test('wishlist returns implemented contribution', () async {
      final r = await _service().wishlist(WishlistRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        equipmentId: 'e1',
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('wishlist'));
    });

    test('inventory returns implemented contribution', () async {
      final r = await _service().inventory(InventoryRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, contains('inventory'));
    });

    test('dashboard aggregates all 7 engines', () async {
      final r = await _service().dashboard(MarketplaceRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, containsAll([
        'review', 'rating', 'comparison',
        'listing', 'search',
        'wishlist', 'inventory',
      ]));
    });

    test('all contributions have CapabilityStatus.implemented', () async {
      final r = await _service().dashboard(MarketplaceRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      for (final c in r.contributions) {
        expect(c.status, CapabilityStatus.implemented,
            reason: '${c.engineId} should be implemented');
      }
    });
  });
}
