// RFC-KB-002 — Knowledge domain model (Layer: domain).
//
// A KnowledgeItem is ONE original synthesized coaching article. This is the
// single schema for EVERY knowledge type. Frozen decisions (see RFC-KB-002):
//  - Drill is NOT a KnowledgeType. Drills live in DrillLibrary (the built-in
//    drill repository) and are only REFERENCED here via `drillRefs` (a list of
//    DrillLibrary codes). Never embed/copy drill content into a KnowledgeItem.
//  - `id` is a stable semantic string (e.g. `tech.stop.basic`). Once published
//    it is IMMUTABLE — substantial changes create a new item + deprecate the old.
//  - `KnowledgeStatus` (verified/beta/draft) lives ONLY here, never on Drill.
//  - `estimatedSkillGain` is a per-skill weight MAP `{skillId: 0-100}`.
//  - `sources[]` is internal/CMS-only — NEVER rendered to the user.
//
// Pure Dart + fromJson/toJson so the source can later switch from bundled assets
// to a Knowledge API with no model change (CMS-ready). No persistence, no Drift.

/// The kind of knowledge. Deliberately EXCLUDES `drill` — drills are external
/// referenced resources resolved from DrillLibrary, not KnowledgeItems.
enum KnowledgeType {
  technique,
  commonMistake,
  equipment,
  mental,
  strategy;

  String get code => name;

  static KnowledgeType fromCode(String code) => KnowledgeType.values.firstWhere(
        (t) => t.code == code,
        orElse: () => KnowledgeType.technique,
      );

  String get labelKey => 'kb_type_$name';
}

/// Content maturity. Shown to the user as a badge so there is no fake
/// completeness. Lives ONLY on Knowledge.
enum KnowledgeStatus {
  verified,
  beta,
  draft;

  String get code => name;

  static KnowledgeStatus fromCode(String code) => KnowledgeStatus.values
      .firstWhere((s) => s.code == code, orElse: () => KnowledgeStatus.beta);

  String get labelKey => 'kb_status_$name';
}

/// Difficulty tier of the content.
enum KnowledgeDifficulty {
  beginner,
  intermediate,
  advanced,
  professional;

  String get code => name;

  static KnowledgeDifficulty fromCode(String code) => KnowledgeDifficulty.values
      .firstWhere((d) => d.code == code,
          orElse: () => KnowledgeDifficulty.beginner);

  String get labelKey => 'kb_difficulty_$name';
}

/// A graph edge to another KnowledgeItem. Drills are NOT referenced this way —
/// they use [KnowledgeItem.drillRefs].
class KnowledgeRef {
  final String id;
  final KnowledgeType type;

  const KnowledgeRef({required this.id, required this.type});

  factory KnowledgeRef.fromJson(Map<String, dynamic> json) => KnowledgeRef(
        id: json['id'] as String,
        type: KnowledgeType.fromCode(json['type'] as String? ?? 'technique'),
      );

  Map<String, dynamic> toJson() => {'id': id, 'type': type.code};
}

/// Optional media references (paths only — no media is generated for V1). The UI
/// renders a "coming soon" placeholder whenever a slot is null.
class KnowledgeMedia {
  final String? video;
  final String? gif;
  final String? animation;
  final String? diagram;

  const KnowledgeMedia({this.video, this.gif, this.animation, this.diagram});

  bool get hasAny => video != null || gif != null || animation != null || diagram != null;

  factory KnowledgeMedia.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const KnowledgeMedia();
    return KnowledgeMedia(
      video: json['video'] as String?,
      gif: json['gif'] as String?,
      animation: json['animation'] as String?,
      diagram: json['diagram'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (video != null) 'video': video,
        if (gif != null) 'gif': gif,
        if (animation != null) 'animation': animation,
        if (diagram != null) 'diagram': diagram,
      };
}

/// One knowledge article. See the file header for the frozen decisions.
class KnowledgeItem {
  // --- Identity / taxonomy ---
  final String id; // semantic, immutable once published
  final KnowledgeType type;
  final String? skillId; // maps to a Coach SkillCategory code
  final String? parentId; // nesting (Cue Ball Control -> Stop Shot -> Level 1)
  final String category;
  final KnowledgeDifficulty difficulty;
  final KnowledgeStatus status;
  final String title;
  final String titleVi;

  // --- Content ---
  final String summary;
  final String purpose;
  final List<String> prerequisites;
  final List<String> setup;
  final List<String> execution;
  final List<String> successCriteria;
  final List<String> failureCriteria;
  final List<String> commonMistakes;
  final List<String> corrections;
  final String coachNotes;
  final List<String> keywords;
  final int estLearningMinutes;
  final KnowledgeMedia media;

  // --- Graph (single scheme) ---
  final List<KnowledgeRef> relatedKnowledge; // edges to other KnowledgeItems
  final List<String> drillRefs; // DrillLibrary codes — referenced, never embedded

  // --- Coach / recommendation metadata ---
  final List<String> coachTriggers;
  final KnowledgeRef? nextRecommended; // learning path "Next"
  final List<String> recommendedFor; // player levels/ranks (e.g. "H", "G")
  final Map<String, int> estimatedSkillGain; // {skillId: 0-100}

  // --- CMS-prep metadata ---
  final String knowledgeVersion; // content version, separate from app + revision
  final int revision;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? verifiedBy;
  final String? reviewStatus;
  final List<String> sources; // internal/CMS-only — NEVER rendered

  const KnowledgeItem({
    required this.id,
    required this.type,
    this.skillId,
    this.parentId,
    required this.category,
    this.difficulty = KnowledgeDifficulty.beginner,
    this.status = KnowledgeStatus.beta,
    required this.title,
    required this.titleVi,
    this.summary = '',
    this.purpose = '',
    this.prerequisites = const [],
    this.setup = const [],
    this.execution = const [],
    this.successCriteria = const [],
    this.failureCriteria = const [],
    this.commonMistakes = const [],
    this.corrections = const [],
    this.coachNotes = '',
    this.keywords = const [],
    this.estLearningMinutes = 0,
    this.media = const KnowledgeMedia(),
    this.relatedKnowledge = const [],
    this.drillRefs = const [],
    this.coachTriggers = const [],
    this.nextRecommended,
    this.recommendedFor = const [],
    this.estimatedSkillGain = const {},
    this.knowledgeVersion = '1.0.0',
    this.revision = 1,
    this.createdAt,
    this.updatedAt,
    this.verifiedBy,
    this.reviewStatus,
    this.sources = const [],
  });

  static List<String> _strList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as String,
      type: KnowledgeType.fromCode(json['type'] as String? ?? 'technique'),
      skillId: json['skillId'] as String?,
      parentId: json['parentId'] as String?,
      category: json['category'] as String? ?? '',
      difficulty:
          KnowledgeDifficulty.fromCode(json['difficulty'] as String? ?? 'beginner'),
      status: KnowledgeStatus.fromCode(json['status'] as String? ?? 'beta'),
      title: json['title'] as String? ?? '',
      titleVi: json['titleVi'] as String? ?? json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      prerequisites: _strList(json['prerequisites']),
      setup: _strList(json['setup']),
      execution: _strList(json['execution']),
      successCriteria: _strList(json['successCriteria']),
      failureCriteria: _strList(json['failureCriteria']),
      commonMistakes: _strList(json['commonMistakes']),
      corrections: _strList(json['corrections']),
      coachNotes: json['coachNotes'] as String? ?? '',
      keywords: _strList(json['keywords']),
      estLearningMinutes: (json['estLearningMinutes'] as num?)?.toInt() ?? 0,
      media: KnowledgeMedia.fromJson(json['media'] as Map<String, dynamic>?),
      relatedKnowledge: (json['relatedKnowledge'] as List?)
              ?.map((e) => KnowledgeRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      drillRefs: _strList(json['drillRefs']),
      coachTriggers: _strList(json['coachTriggers']),
      nextRecommended: json['nextRecommended'] == null
          ? null
          : KnowledgeRef.fromJson(
              json['nextRecommended'] as Map<String, dynamic>),
      recommendedFor: _strList(json['recommendedFor']),
      estimatedSkillGain: (json['estimatedSkillGain'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          const {},
      knowledgeVersion: json['knowledgeVersion'] as String? ?? '1.0.0',
      revision: (json['revision'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.tryParse(json['updatedAt'] as String),
      verifiedBy: json['verifiedBy'] as String?,
      reviewStatus: json['reviewStatus'] as String?,
      sources: _strList(json['sources']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.code,
        if (skillId != null) 'skillId': skillId,
        if (parentId != null) 'parentId': parentId,
        'category': category,
        'difficulty': difficulty.code,
        'status': status.code,
        'title': title,
        'titleVi': titleVi,
        'summary': summary,
        'purpose': purpose,
        'prerequisites': prerequisites,
        'setup': setup,
        'execution': execution,
        'successCriteria': successCriteria,
        'failureCriteria': failureCriteria,
        'commonMistakes': commonMistakes,
        'corrections': corrections,
        'coachNotes': coachNotes,
        'keywords': keywords,
        'estLearningMinutes': estLearningMinutes,
        'media': media.toJson(),
        'relatedKnowledge': relatedKnowledge.map((e) => e.toJson()).toList(),
        'drillRefs': drillRefs,
        'coachTriggers': coachTriggers,
        if (nextRecommended != null) 'nextRecommended': nextRecommended!.toJson(),
        'recommendedFor': recommendedFor,
        'estimatedSkillGain': estimatedSkillGain,
        'knowledgeVersion': knowledgeVersion,
        'revision': revision,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        if (verifiedBy != null) 'verifiedBy': verifiedBy,
        if (reviewStatus != null) 'reviewStatus': reviewStatus,
        'sources': sources,
      };
}
