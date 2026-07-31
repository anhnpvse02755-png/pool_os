// EPIC 08 — Marketplace data models (Marketplace owns these per §4).

class EquipmentReview {
  final String id;
  final String playerId;
  final String equipmentId;
  final int rating; // 1–5
  final String title;
  final String body;
  final List<String> pros;
  final List<String> cons;
  final List<String> imageUrls;
  final bool verifiedOwner;
  final ReviewState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EquipmentReview({
    required this.id,
    required this.playerId,
    required this.equipmentId,
    required this.rating,
    required this.title,
    required this.body,
    this.pros = const [],
    this.cons = const [],
    this.imageUrls = const [],
    this.verifiedOwner = false,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum ReviewState { draft, published, hidden, archived }

class EquipmentRating {
  final String equipmentId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution; // star → count
  const EquipmentRating({
    required this.equipmentId,
    required this.averageRating,
    required this.totalReviews,
    this.distribution = const {},
  });
}

class EquipmentComparison {
  final List<String> equipmentIds;
  final List<String> fields;
  final ComparisonMode mode;
  const EquipmentComparison({
    required this.equipmentIds,
    required this.fields,
    required this.mode,
  });
}

enum ComparisonMode { two, three, four }

class Listing {
  final String id;
  final String equipmentId;
  final String sellerId;
  final double price;
  final String currency;
  final ListingCondition condition;
  final String description;
  final List<String> imageUrls;
  final String location;
  final ListingState state;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Listing({
    required this.id,
    required this.equipmentId,
    required this.sellerId,
    required this.price,
    this.currency = 'USD',
    required this.condition,
    required this.description,
    this.imageUrls = const [],
    required this.location,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum ListingCondition { mint, excellent, good, fair, poor }
enum ListingState { draft, published, reserved, sold, archived, cancelled }

class WishlistItem {
  final String id;
  final String playerId;
  final String equipmentId;
  final double? desiredPrice;
  final String notes;
  final int priority;
  final WishlistState state;
  final DateTime addedAt;
  const WishlistItem({
    required this.id,
    required this.playerId,
    required this.equipmentId,
    this.desiredPrice,
    this.notes = '',
    this.priority = 0,
    required this.state,
    required this.addedAt,
  });
}

enum WishlistState { active, purchased, removed, archived }

class InventoryRecord {
  final String id;
  final String playerId;
  final String equipmentId;
  final DateTime? purchaseDate;
  final double? purchasePrice;
  final DateTime? sellDate;
  final double? sellPrice;
  final ListingCondition condition;
  final String notes;
  final OwnershipStatus ownershipStatus;
  final InventoryGroup group;
  const InventoryRecord({
    required this.id,
    required this.playerId,
    required this.equipmentId,
    this.purchaseDate,
    this.purchasePrice,
    this.sellDate,
    this.sellPrice,
    required this.condition,
    this.notes = '',
    required this.ownershipStatus,
    required this.group,
  });
}

enum OwnershipStatus { owned, forSale, sold, archived }
enum InventoryGroup { current, past, wishlistPurchases, forSale, sold, archived }

class SearchQuery {
  final String query;
  final String? category;
  final Map<String, String> filters;
  final SearchSort sort;

  const SearchQuery({
    this.query = '',
    this.category,
    this.filters = const {},
    this.sort = SearchSort.newest,
  });
}

enum SearchSort { newest, oldest, lowestPrice, highestPrice, highestRating, mostReviews }