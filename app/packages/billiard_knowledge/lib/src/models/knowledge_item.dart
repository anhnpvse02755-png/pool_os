import 'knowledge_enums.dart';

/// Represents a single knowledge item (technique, mistake, strategy, etc.)
///
/// This is the main content unit in the billiard knowledge library.
/// Each item contains complete information about a specific skill or concept.
class KnowledgeItem {
  /// Unique identifier (e.g., "stroke.fundamentals")
  final String id;

  /// Type of knowledge item
  final KnowledgeType type;

  /// Difficulty level required
  final KnowledgeDifficulty difficulty;

  /// Category (e.g., "stroke", "aim", "bridge")
  final String category;

  /// Title in English
  final String title;

  /// Title in Vietnamese (may be empty)
  final String titleVi;

  /// Brief summary/overview
  final String summary;

  /// Detailed purpose and importance
  final String purpose;

  /// Setup steps for practicing
  final List<String> setup;

  /// Execution instructions
  final List<String> execution;

  /// Success criteria
  final List<String> successCriteria;

  /// Failure indicators
  final List<String> failureCriteria;

  /// Common mistakes and how to fix them
  final List<KnowledgeMistake> commonMistakes;

  /// Media assets (images, videos, diagrams)
  final KnowledgeMedia media;

  /// Related knowledge references
  final List<KnowledgeRef> relatedKnowledge;

  /// Required prerequisite items
  final List<String> prerequisites;

  /// Recommended next skill
  final KnowledgeRef? nextRecommended;

  /// Estimated learning time in minutes
  final int estLearningMinutes;

  /// Estimated skill gain (0-100)
  final Map<String, double> estimatedSkillGain;

  /// Tags for categorization
  final List<String> tags;

  /// Keywords for search
  final List<String> keywords;

  /// Status of verification
  final KnowledgeStatus status;

  /// Coach notes (instructor-only content)
  final String? coachNotes;

  /// Sources/references
  final List<String> sources;

  /// Version string
  final String version;

  /// Last updated timestamp
  final DateTime? updatedAt;

  const KnowledgeItem({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.title,
    required this.titleVi,
    required this.summary,
    required this.purpose,
    required this.setup,
    required this.execution,
    required this.successCriteria,
    required this.failureCriteria,
    required this.commonMistakes,
    required this.media,
    required this.relatedKnowledge,
    required this.prerequisites,
    this.nextRecommended,
    required this.estLearningMinutes,
    required this.estimatedSkillGain,
    required this.tags,
    required this.keywords,
    required this.status,
    this.coachNotes,
    required this.sources,
    required this.version,
    this.updatedAt,
  });

  /// Create from JSON map
  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as String? ?? '',
      type: KnowledgeType.fromString(json['type'] as String? ?? 'other'),
      difficulty: KnowledgeDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleVi: json['titleVi'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      setup: (json['setup'] as List?)?.map((e) => e.toString()).toList() ?? [],
      execution: (json['execution'] as List?)?.map((e) => e.toString()).toList() ?? [],
      successCriteria: (json['successCriteria'] as List?)?.map((e) => e.toString()).toList() ?? [],
      failureCriteria: (json['failureCriteria'] as List?)?.map((e) => e.toString()).toList() ?? [],
      commonMistakes: (json['commonMistakes'] as List?)
          ?.map((e) => KnowledgeMistake.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      media: json['media'] != null
          ? KnowledgeMedia.fromJson(json['media'] as Map<String, dynamic>)
          : const KnowledgeMedia(),
      relatedKnowledge: (json['relatedKnowledge'] as List?)
          ?.map((e) => KnowledgeRef.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      prerequisites: (json['prerequisites'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      nextRecommended: json['nextRecommended'] != null
          ? KnowledgeRef.fromJson(json['nextRecommended'] as Map<String, dynamic>)
          : null,
      estLearningMinutes: json['estLearningMinutes'] as int? ?? 15,
      estimatedSkillGain: (json['estimatedSkillGain'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ?? {},
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      keywords: (json['keywords'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: KnowledgeStatus.fromString(json['status'] as String? ?? 'draft'),
      coachNotes: json['coachNotes'] as String?,
      sources: (json['sources'] as List?)?.map((e) => e.toString()).toList() ?? [],
      version: json['version'] as String? ?? '1.0.0',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'category': category,
      'title': title,
      'titleVi': titleVi,
      'summary': summary,
      'purpose': purpose,
      'setup': setup,
      'execution': execution,
      'successCriteria': successCriteria,
      'failureCriteria': failureCriteria,
      'commonMistakes': commonMistakes.map((e) => e.toJson()).toList(),
      'media': media.toJson(),
      'relatedKnowledge': relatedKnowledge.map((e) => e.toJson()).toList(),
      'prerequisites': prerequisites,
      'nextRecommended': nextRecommended?.toJson(),
      'estLearningMinutes': estLearningMinutes,
      'estimatedSkillGain': estimatedSkillGain,
      'tags': tags,
      'keywords': keywords,
      'status': status.name,
      'coachNotes': coachNotes,
      'sources': sources,
      'version': version,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get localized title
  String getTitle(String language) {
    if (language == 'vi' && titleVi.isNotEmpty) {
      return titleVi;
    }
    return title;
  }

  /// Get all searchable text
  String get searchableText {
    return [
      title,
      titleVi,
      summary,
      purpose,
      ...keywords,
      ...tags,
    ].join(' ').toLowerCase();
  }

  /// Check if this item matches a search query
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return searchableText.contains(lowerQuery);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'KnowledgeItem($id: $title)';
}

/// Represents a common mistake within a knowledge item
class KnowledgeMistake {
  /// The mistake description
  final String mistake;

  /// How to correct it
  final String correction;

  /// Why it happens
  final String? cause;

  /// Difficulty level this mistake commonly occurs at
  final KnowledgeDifficulty? commonAt;

  const KnowledgeMistake({
    required this.mistake,
    required this.correction,
    this.cause,
    this.commonAt,
  });

  factory KnowledgeMistake.fromJson(Map<String, dynamic> json) {
    return KnowledgeMistake(
      mistake: json['mistake'] as String? ?? '',
      correction: json['correction'] as String? ?? '',
      cause: json['cause'] as String?,
      commonAt: json['commonAt'] != null
          ? KnowledgeDifficulty.fromString(json['commonAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mistake': mistake,
      'correction': correction,
      'cause': cause,
      'commonAt': commonAt?.name,
    };
  }
}

/// Represents media assets for a knowledge item
class KnowledgeMedia {
  /// Image file paths
  final List<String> images;

  /// Video URLs
  final List<String> videos;

  /// Animated GIF paths
  final List<String> gifs;

  /// Diagram file paths
  final List<String> diagrams;

  const KnowledgeMedia({
    this.images = const [],
    this.videos = const [],
    this.gifs = const [],
    this.diagrams = const [],
  });

  factory KnowledgeMedia.fromJson(Map<String, dynamic> json) {
    return KnowledgeMedia(
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      videos: (json['videos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      gifs: (json['gifs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      diagrams: (json['diagrams'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images,
      'videos': videos,
      'gifs': gifs,
      'diagrams': diagrams,
    };
  }

  /// Check if any media is available
  bool get hasAny => images.isNotEmpty || videos.isNotEmpty || gifs.isNotEmpty || diagrams.isNotEmpty;

  /// Get total media count
  int get count => images.length + videos.length + gifs.length + diagrams.length;
}

/// Summary view of a knowledge item (for list displays)
class KnowledgeItemSummary {
  final String id;
  final KnowledgeType type;
  final KnowledgeDifficulty difficulty;
  final String category;
  final String title;
  final String titleVi;
  final String summary;
  final int estLearningMinutes;
  final bool hasMedia;

  const KnowledgeItemSummary({
    required this.id,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.title,
    required this.titleVi,
    required this.summary,
    required this.estLearningMinutes,
    required this.hasMedia,
  });

  factory KnowledgeItemSummary.fromItem(KnowledgeItem item) {
    return KnowledgeItemSummary(
      id: item.id,
      type: item.type,
      difficulty: item.difficulty,
      category: item.category,
      title: item.title,
      titleVi: item.titleVi,
      summary: item.summary,
      estLearningMinutes: item.estLearningMinutes,
      hasMedia: item.media.hasAny,
    );
  }

  factory KnowledgeItemSummary.fromJson(Map<String, dynamic> json) {
    return KnowledgeItemSummary(
      id: json['id'] as String? ?? '',
      type: KnowledgeType.fromString(json['type'] as String? ?? 'other'),
      difficulty: KnowledgeDifficulty.fromString(
        json['difficulty'] as String? ?? 'beginner',
      ),
      category: json['category'] as String? ?? '',
      title: json['title'] as String? ?? '',
      titleVi: json['titleVi'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      estLearningMinutes: json['estLearningMinutes'] as int? ?? 15,
      hasMedia: json['hasMedia'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'difficulty': difficulty.name,
      'category': category,
      'title': title,
      'titleVi': titleVi,
      'summary': summary,
      'estLearningMinutes': estLearningMinutes,
      'hasMedia': hasMedia,
    };
  }

  /// Get localized title
  String getTitle(String language) {
    if (language == 'vi' && titleVi.isNotEmpty) {
      return titleVi;
    }
    return title;
  }
}
