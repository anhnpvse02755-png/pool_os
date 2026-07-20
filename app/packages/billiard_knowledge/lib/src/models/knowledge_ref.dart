import 'knowledge_enums.dart';

/// Reference to another knowledge item
class KnowledgeRef {
  /// ID of the referenced item
  final String id;

  /// Reference title (optional, can be looked up)
  final String? title;

  /// Relationship type
  final RelationType relationType;

  /// Weight/strength of relationship (0.0-1.0)
  final double weight;

  const KnowledgeRef({
    required this.id,
    this.title,
    this.relationType = RelationType.related,
    this.weight = 1.0,
  });

  factory KnowledgeRef.fromJson(Map<String, dynamic> json) {
    return KnowledgeRef(
      id: json['id'] as String? ?? json['refId'] as String? ?? '',
      title: json['title'] as String?,
      relationType: RelationType.fromString(
        json['relationType'] as String? ?? 'related',
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'relationType': relationType.name,
      'weight': weight,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeRef && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
