// EPIC 08 — canonical request shapes.

import 'package:pool_os/features/marketplace/domain/models/marketplace_models.dart';

class MarketplaceRequest {
  final String playerId;
  final DateTime asOf;
  const MarketplaceRequest({required this.playerId, required this.asOf});
}

class ReviewRequest extends MarketplaceRequest {
  final String equipmentId;
  final int? rating;
  final String? title;
  final String? body;
  final List<String>? pros;
  final List<String>? cons;
  final List<String>? imageUrls;
  final String? action; // create | edit | delete | publish
  final String? reviewId;
  const ReviewRequest({
    required super.playerId,
    required super.asOf,
    required this.equipmentId,
    this.rating,
    this.title,
    this.body,
    this.pros,
    this.cons,
    this.imageUrls,
    this.action,
    this.reviewId,
  });
}

class ComparisonRequest extends MarketplaceRequest {
  final List<String> equipmentIds;
  final ComparisonMode mode;
  const ComparisonRequest({
    required super.playerId,
    required super.asOf,
    required this.equipmentIds,
    required this.mode,
  });
}

class ListingRequest extends MarketplaceRequest {
  final String? listingId;
  final String? equipmentId;
  final double? price;
  final ListingCondition? condition;
  final String? description;
  final String? location;
  final String? action; // create | edit | publish | reserve | markSold | archive
  const ListingRequest({
    required super.playerId,
    required super.asOf,
    this.listingId,
    this.equipmentId,
    this.price,
    this.condition,
    this.description,
    this.location,
    this.action,
  });
}

class WishlistRequest extends MarketplaceRequest {
  final String? itemId;
  final String? equipmentId;
  final String? action; // add | remove | favorite | moveToInventory
  const WishlistRequest({
    required super.playerId,
    required super.asOf,
    this.itemId,
    this.equipmentId,
    this.action,
  });
}

class InventoryRequest extends MarketplaceRequest {
  final String? recordId;
  final InventoryGroup? group;
  final String? action; // add | update | archive
  const InventoryRequest({
    required super.playerId,
    required super.asOf,
    this.recordId,
    this.group,
    this.action,
  });
}

class SearchRequest extends MarketplaceRequest {
  final SearchQuery query;
  const SearchRequest({
    required super.playerId,
    required super.asOf,
    required this.query,
  });
}

// Re-export enums needed in requests (defined in marketplace_models.dart)