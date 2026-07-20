enum KnowledgeKind {
  concept,
  technique,
  commonMistake,
  terminology,
  rule,
  equipment,
  mental,
  strategy;

  static KnowledgeKind parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => KnowledgeKind.concept,
      );
}

enum BilliardDiscipline {
  universal,
  pool,
  snooker,
  carom,
  chineseEightBall;

  static BilliardDiscipline parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => BilliardDiscipline.universal,
      );
}

enum RelationType {
  related,
  prerequisite,
  child,
  advancedInto,
  opposite,
  uses,
  commonMistake,
  correctedBy,
  governedBy;

  static RelationType parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => RelationType.related,
      );
}

enum AudienceLevel {
  beginner,
  fundamental,
  intermediate,
  advanced,
  professional;

  static AudienceLevel parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => AudienceLevel.beginner,
      );
}

enum ExplanationDepth {
  result,
  cause,
  principles,
  physics,
  engine;

  static ExplanationDepth parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => ExplanationDepth.result,
      );
}

enum ReviewState {
  draft,
  reviewed,
  verified,
  deprecated;

  static ReviewState parse(String value) => values.firstWhere(
        (item) => item.name == value,
        orElse: () => ReviewState.draft,
      );
}

class LocalizedText {
  final String en;
  final String vi;

  const LocalizedText({required this.en, required this.vi});

  String resolve(String locale) => locale == 'vi' ? vi : en;

  factory LocalizedText.fromJson(Map<String, dynamic> json) => LocalizedText(
        en: json['en'] as String? ?? '',
        vi: json['vi'] as String? ?? json['en'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {'en': en, 'vi': vi};
}

class SourceCitation {
  final String id;
  final String title;
  final String publisher;
  final Uri url;
  final String sourceType;
  final DateTime accessedAt;

  const SourceCitation({
    required this.id,
    required this.title,
    required this.publisher,
    required this.url,
    required this.sourceType,
    required this.accessedAt,
  });

  factory SourceCitation.fromJson(Map<String, dynamic> json) => SourceCitation(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        publisher: json['publisher'] as String? ?? '',
        url: Uri.parse(json['url'] as String? ?? ''),
        sourceType: json['sourceType'] as String? ?? 'web',
        accessedAt: DateTime.parse(json['accessedAt'] as String),
      );
}

class KnowledgeExample {
  final LocalizedText situation;
  final LocalizedText explanation;

  const KnowledgeExample({required this.situation, required this.explanation});

  factory KnowledgeExample.fromJson(Map<String, dynamic> json) =>
      KnowledgeExample(
        situation: LocalizedText.fromJson(
          json['situation'] as Map<String, dynamic>? ?? const {},
        ),
        explanation: LocalizedText.fromJson(
          json['explanation'] as Map<String, dynamic>? ?? const {},
        ),
      );
}

class KnowledgeMedia {
  final String id;
  final String type;
  final Uri? uri;
  final LocalizedText altText;
  final String? license;
  final String? sourceId;

  const KnowledgeMedia({
    required this.id,
    required this.type,
    this.uri,
    required this.altText,
    this.license,
    this.sourceId,
  });

  factory KnowledgeMedia.fromJson(Map<String, dynamic> json) => KnowledgeMedia(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'image',
        uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
        altText: LocalizedText.fromJson(
          json['altText'] as Map<String, dynamic>? ?? const {},
        ),
        license: json['license'] as String?,
        sourceId: json['sourceId'] as String?,
      );
}

class KnowledgeRelation {
  final String targetId;
  final RelationType type;

  const KnowledgeRelation({required this.targetId, required this.type});

  factory KnowledgeRelation.fromJson(Map<String, dynamic> json) =>
      KnowledgeRelation(
        targetId: json['targetId'] as String,
        type: RelationType.parse(json['type'] as String? ?? 'related'),
      );
}

class ContentLayer {
  final ExplanationDepth depth;
  final LocalizedText heading;
  final List<LocalizedText> paragraphs;
  final List<LocalizedText> keyPoints;

  const ContentLayer({
    required this.depth,
    required this.heading,
    this.paragraphs = const [],
    this.keyPoints = const [],
  });

  factory ContentLayer.fromJson(Map<String, dynamic> json) => ContentLayer(
        depth: ExplanationDepth.parse(json['depth'] as String? ?? 'result'),
        heading: LocalizedText.fromJson(
          json['heading'] as Map<String, dynamic>? ?? const {},
        ),
        paragraphs: _localizedList(json['paragraphs']),
        keyPoints: _localizedList(json['keyPoints']),
      );
}

class MistakeGuide {
  final LocalizedText symptom;
  final LocalizedText cause;
  final LocalizedText correction;
  final List<String> drillRefs;

  const MistakeGuide({
    required this.symptom,
    required this.cause,
    required this.correction,
    this.drillRefs = const [],
  });

  factory MistakeGuide.fromJson(Map<String, dynamic> json) => MistakeGuide(
        symptom: LocalizedText.fromJson(
          json['symptom'] as Map<String, dynamic>? ?? const {},
        ),
        cause: LocalizedText.fromJson(
          json['cause'] as Map<String, dynamic>? ?? const {},
        ),
        correction: LocalizedText.fromJson(
          json['correction'] as Map<String, dynamic>? ?? const {},
        ),
        drillRefs: _stringList(json['drillRefs']),
      );
}

class KnowledgeEntry {
  final String id;
  final KnowledgeKind kind;
  final BilliardDiscipline discipline;
  final AudienceLevel level;
  final ReviewState reviewState;
  final String topic;
  final List<String> categoryPath;
  final LocalizedText title;
  final LocalizedText summary;
  final String? pronunciation;
  final List<String> aliases;
  final List<String> synonyms;
  final List<String> abbreviations;
  final List<String> commonMisspellings;
  final List<String> tags;
  final List<ContentLayer> layers;
  final List<KnowledgeExample> examples;
  final List<LocalizedText> whenToUse;
  final List<LocalizedText> whenNotToUse;
  final List<LocalizedText> advantages;
  final List<LocalizedText> disadvantages;
  final List<LocalizedText> professionalTips;
  final List<MistakeGuide> mistakes;
  final List<KnowledgeRelation> relations;
  final List<String> drillRefs;
  final List<KnowledgeMedia> media;
  final List<String> sourceIds;
  final int revision;

  const KnowledgeEntry({
    required this.id,
    required this.kind,
    this.discipline = BilliardDiscipline.universal,
    required this.level,
    required this.reviewState,
    required this.topic,
    this.categoryPath = const [],
    required this.title,
    required this.summary,
    this.pronunciation,
    this.aliases = const [],
    this.synonyms = const [],
    this.abbreviations = const [],
    this.commonMisspellings = const [],
    this.tags = const [],
    required this.layers,
    this.examples = const [],
    this.whenToUse = const [],
    this.whenNotToUse = const [],
    this.advantages = const [],
    this.disadvantages = const [],
    this.professionalTips = const [],
    this.mistakes = const [],
    this.relations = const [],
    this.drillRefs = const [],
    this.media = const [],
    required this.sourceIds,
    this.revision = 1,
  });

  List<String> get relatedEntryIds =>
      relations.map((relation) => relation.targetId).toList(growable: false);

  ContentLayer? layer(ExplanationDepth depth) {
    for (final layer in layers) {
      if (layer.depth == depth) return layer;
    }
    return null;
  }

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) => KnowledgeEntry(
        id: json['id'] as String,
        kind: KnowledgeKind.parse(json['kind'] as String? ?? 'concept'),
        discipline: BilliardDiscipline.parse(
          json['discipline'] as String? ?? 'universal',
        ),
        level: AudienceLevel.parse(json['level'] as String? ?? 'beginner'),
        reviewState:
            ReviewState.parse(json['reviewState'] as String? ?? 'draft'),
        topic: json['topic'] as String? ?? '',
        categoryPath: _stringList(json['categoryPath']),
        title: LocalizedText.fromJson(
          json['title'] as Map<String, dynamic>? ?? const {},
        ),
        summary: LocalizedText.fromJson(
          json['summary'] as Map<String, dynamic>? ?? const {},
        ),
        pronunciation: json['pronunciation'] as String?,
        aliases: _stringList(json['aliases']),
        synonyms: _stringList(json['synonyms']),
        abbreviations: _stringList(json['abbreviations']),
        commonMisspellings: _stringList(json['commonMisspellings']),
        tags: _stringList(json['tags']),
        layers: (json['layers'] as List? ?? const [])
            .map((item) => ContentLayer.fromJson(item as Map<String, dynamic>))
            .toList(),
        examples: (json['examples'] as List? ?? const [])
            .map((item) =>
                KnowledgeExample.fromJson(item as Map<String, dynamic>))
            .toList(),
        whenToUse: _localizedList(json['whenToUse']),
        whenNotToUse: _localizedList(json['whenNotToUse']),
        advantages: _localizedList(json['advantages']),
        disadvantages: _localizedList(json['disadvantages']),
        professionalTips: _localizedList(json['professionalTips']),
        mistakes: (json['mistakes'] as List? ?? const [])
            .map((item) => MistakeGuide.fromJson(item as Map<String, dynamic>))
            .toList(),
        relations: json['relations'] is List
            ? (json['relations'] as List)
                .map(
                  (item) =>
                      KnowledgeRelation.fromJson(item as Map<String, dynamic>),
                )
                .toList()
            : _stringList(json['relatedEntryIds'])
                .map(
                  (id) => KnowledgeRelation(
                      targetId: id, type: RelationType.related),
                )
                .toList(),
        drillRefs: _stringList(json['drillRefs']),
        media: (json['media'] as List? ?? const [])
            .map(
                (item) => KnowledgeMedia.fromJson(item as Map<String, dynamic>))
            .toList(),
        sourceIds: _stringList(json['sourceIds']),
        revision: (json['revision'] as num?)?.toInt() ?? 1,
      );
}

class LearningStep {
  final String entryId;
  final ExplanationDepth minimumDepth;
  final List<String> drillRefs;

  const LearningStep({
    required this.entryId,
    this.minimumDepth = ExplanationDepth.result,
    this.drillRefs = const [],
  });

  factory LearningStep.fromJson(Map<String, dynamic> json) => LearningStep(
        entryId: json['entryId'] as String,
        minimumDepth: ExplanationDepth.parse(
          json['minimumDepth'] as String? ?? 'result',
        ),
        drillRefs: _stringList(json['drillRefs']),
      );
}

class LearningPath {
  final String id;
  final LocalizedText title;
  final LocalizedText description;
  final AudienceLevel level;
  final List<LearningStep> steps;

  const LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.steps,
  });

  factory LearningPath.fromJson(Map<String, dynamic> json) => LearningPath(
        id: json['id'] as String,
        title: LocalizedText.fromJson(
          json['title'] as Map<String, dynamic>? ?? const {},
        ),
        description: LocalizedText.fromJson(
          json['description'] as Map<String, dynamic>? ?? const {},
        ),
        level: AudienceLevel.parse(json['level'] as String? ?? 'beginner'),
        steps: (json['steps'] as List? ?? const [])
            .map((item) => LearningStep.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}

List<String> _stringList(dynamic value) => value is List
    ? value.map((item) => item.toString()).toList(growable: false)
    : const [];

List<LocalizedText> _localizedList(dynamic value) => value is List
    ? value
        .map((item) => LocalizedText.fromJson(item as Map<String, dynamic>))
        .toList(growable: false)
    : const [];
