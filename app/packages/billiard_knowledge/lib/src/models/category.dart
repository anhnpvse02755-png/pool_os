import 'knowledge_enums.dart';

/// Represents a knowledge category
class Category {
  /// Category identifier (e.g., "aim", "bridge", "stroke")
  final String id;

  /// Category name in English
  final String name;

  /// Category name in Vietnamese
  final String nameVi;

  /// Parent category (if any)
  final String? parentId;

  /// Description
  final String description;

  /// Icon name (for UI)
  final String icon;

  /// Color hex (for UI)
  final String? color;

  /// Order for display
  final int order;

  /// Item count in this category
  final int itemCount;

  const Category({
    required this.id,
    required this.name,
    required this.nameVi,
    this.parentId,
    required this.description,
    required this.icon,
    this.color,
    required this.order,
    this.itemCount = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      parentId: json['parentId'] as String?,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? 'category',
      color: json['color'] as String?,
      order: json['order'] as int? ?? 0,
      itemCount: json['itemCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameVi': nameVi,
      'parentId': parentId,
      'description': description,
      'icon': icon,
      'color': color,
      'order': order,
      'itemCount': itemCount,
    };
  }

  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a knowledge tag
class Tag {
  /// Tag identifier
  final String id;

  /// Tag name in English
  final String name;

  /// Tag name in Vietnamese
  final String nameVi;

  /// Tag category
  final String? category;

  /// Description
  final String description;

  /// Usage count
  final int usageCount;

  const Tag({
    required this.id,
    required this.name,
    required this.nameVi,
    this.category,
    required this.description,
    this.usageCount = 0,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameVi: json['nameVi'] as String? ?? '',
      category: json['category'] as String?,
      description: json['description'] as String? ?? '',
      usageCount: json['usageCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameVi': nameVi,
      'category': category,
      'description': description,
      'usageCount': usageCount,
    };
  }

  String getName(String language) {
    if (language == 'vi' && nameVi.isNotEmpty) {
      return nameVi;
    }
    return name;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
