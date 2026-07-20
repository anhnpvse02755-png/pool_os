import 'dart:convert';

import 'models.dart';
import 'text_normalizer.dart';

class KnowledgeValidationIssue {
  final String code;
  final String message;
  final String? entryId;

  const KnowledgeValidationIssue({
    required this.code,
    required this.message,
    this.entryId,
  });
}

class KnowledgeQuery {
  final String text;
  final String locale;
  final Set<KnowledgeKind> kinds;
  final Set<AudienceLevel> levels;
  final Set<String> topics;
  final Set<BilliardDiscipline> disciplines;

  const KnowledgeQuery({
    this.text = '',
    this.locale = 'vi',
    this.kinds = const {},
    this.levels = const {},
    this.topics = const {},
    this.disciplines = const {},
  });
}

class KnowledgeSearchResult {
  final KnowledgeEntry entry;
  final int score;

  const KnowledgeSearchResult({required this.entry, required this.score});
}

class KnowledgeCatalog {
  final String packVersion;
  final DateTime generatedAt;
  final List<SourceCitation> sources;
  final List<KnowledgeEntry> entries;
  final List<LearningPath> paths;

  late final Map<String, KnowledgeEntry> _entriesById = {
    for (final entry in entries) entry.id: entry,
  };
  late final Map<String, LearningPath> _pathsById = {
    for (final path in paths) path.id: path,
  };

  KnowledgeCatalog({
    required this.packVersion,
    required this.generatedAt,
    required this.sources,
    required this.entries,
    required this.paths,
  });

  factory KnowledgeCatalog.fromJsonString(String raw) =>
      KnowledgeCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  factory KnowledgeCatalog.fromJson(
    Map<String, dynamic> json,
  ) =>
      KnowledgeCatalog(
        packVersion: json['packVersion'] as String? ?? '0.0.0',
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        sources: (json['sources'] as List? ?? const [])
            .map(
                (item) => SourceCitation.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
        entries: (json['entries'] as List? ?? const [])
            .map(
                (item) => KnowledgeEntry.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
        paths: (json['paths'] as List? ?? const [])
            .map((item) => LearningPath.fromJson(item as Map<String, dynamic>))
            .toList(growable: false),
      );

  KnowledgeEntry? entryById(String id) => _entriesById[id];

  LearningPath? pathById(String id) => _pathsById[id];

  List<KnowledgeEntry> byDiscipline(BilliardDiscipline discipline) => entries
      .where(
        (entry) =>
            entry.discipline == discipline ||
            entry.discipline == BilliardDiscipline.universal,
      )
      .toList(growable: false);

  List<KnowledgeEntry> byDrillRef(String drillRef) => entries
      .where(
        (entry) =>
            entry.drillRefs.contains(drillRef) ||
            entry.mistakes.any(
              (mistake) => mistake.drillRefs.contains(drillRef),
            ),
      )
      .toList(growable: false);

  List<KnowledgeEntry> relationTargets(
    KnowledgeEntry entry,
    RelationType type,
  ) =>
      entry.relations
          .where((relation) => relation.type == type)
          .map((relation) => entryById(relation.targetId))
          .whereType<KnowledgeEntry>()
          .toList(growable: false);

  List<KnowledgeEntry> relatedTo(KnowledgeEntry entry) => entry.relatedEntryIds
      .map(entryById)
      .whereType<KnowledgeEntry>()
      .toList(growable: false);

  List<KnowledgeSearchResult> search(KnowledgeQuery query) {
    final normalizedQuery = normalizeKnowledgeText(query.text);
    final tokens =
        normalizedQuery.split(' ').where((token) => token.isNotEmpty);
    final results = <KnowledgeSearchResult>[];

    for (final entry in entries) {
      if (query.kinds.isNotEmpty && !query.kinds.contains(entry.kind)) continue;
      if (query.levels.isNotEmpty && !query.levels.contains(entry.level)) {
        continue;
      }
      if (query.topics.isNotEmpty && !query.topics.contains(entry.topic)) {
        continue;
      }
      if (query.disciplines.isNotEmpty &&
          !query.disciplines.contains(entry.discipline)) {
        continue;
      }

      var score = normalizedQuery.isEmpty ? 1 : 0;
      // Index both languages regardless of the display locale so EN -> VI and
      // VI -> EN lookup behave identically.
      final title = normalizeKnowledgeText(
        '${entry.title.en} ${entry.title.vi}',
      );
      final summary = normalizeKnowledgeText(
        '${entry.summary.en} ${entry.summary.vi}',
      );
      final aliases = normalizeKnowledgeText(
        [
          ...entry.aliases,
          ...entry.synonyms,
          ...entry.abbreviations,
          ...entry.commonMisspellings,
        ].join(' '),
      );
      final metadata = normalizeKnowledgeText(
        '${entry.topic} ${entry.categoryPath.join(' ')} ${entry.tags.join(' ')} '
        '${entry.kind.name} ${entry.discipline.name}',
      );
      final content = normalizeKnowledgeText(
        entry.layers
            .expand((layer) => [...layer.paragraphs, ...layer.keyPoints])
            .map((text) => '${text.en} ${text.vi}')
            .join(' '),
      );

      for (final token in tokens) {
        // Short Vietnamese table terms such as "tro" must outrank incidental
        // substrings in words such as "control". Keep substring and fuzzy
        // matching below for partial queries, but prefer whole vocabulary
        // tokens in titles and aliases.
        if (_containsWholeToken(title, token)) score += 20;
        if (_containsWholeToken(aliases, token)) score += 18;
        if (title.contains(token)) score += 12;
        if (aliases.contains(token)) score += 10;
        if (metadata.contains(token)) score += 6;
        if (summary.contains(token)) score += 4;
        if (content.contains(token)) score += 1;
        if (score == 0 && _hasFuzzyMatch(token, [title, aliases])) score += 2;
      }
      if (score > 0) {
        results.add(KnowledgeSearchResult(entry: entry, score: score));
      }
    }

    results.sort((a, b) {
      final scoreOrder = b.score.compareTo(a.score);
      return scoreOrder != 0 ? scoreOrder : a.entry.id.compareTo(b.entry.id);
    });
    return results;
  }

  bool _containsWholeToken(String text, String token) =>
      ' $text '.contains(' $token ');

  List<KnowledgeValidationIssue> validate() {
    final issues = <KnowledgeValidationIssue>[];
    final sourceIds = <String>{};
    final entryIds = <String>{};
    final pathIds = <String>{};

    for (final source in sources) {
      if (!sourceIds.add(source.id)) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'duplicate_source_id',
            message: 'Duplicate source id: ${source.id}',
          ),
        );
      }
      if (!source.url.hasScheme ||
          (source.url.scheme != 'https' && source.url.scheme != 'http')) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'invalid_source_url',
            message: 'Source ${source.id} must use an HTTP(S) URL.',
          ),
        );
      }
    }

    for (final entry in entries) {
      if (!entryIds.add(entry.id)) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'duplicate_entry_id',
            message: 'Duplicate entry id: ${entry.id}',
            entryId: entry.id,
          ),
        );
      }
      if (entry.title.en.trim().isEmpty || entry.title.vi.trim().isEmpty) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'missing_title',
            message: 'Both English and Vietnamese titles are required.',
            entryId: entry.id,
          ),
        );
      }
      if (entry.summary.en.trim().isEmpty || entry.summary.vi.trim().isEmpty) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'missing_summary',
            message: 'Both English and Vietnamese summaries are required.',
            entryId: entry.id,
          ),
        );
      }
      if (entry.layers.isEmpty) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'missing_layers',
            message: 'At least one explanation layer is required.',
            entryId: entry.id,
          ),
        );
      }
      final depths = <ExplanationDepth>{};
      for (final layer in entry.layers) {
        if (!depths.add(layer.depth)) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'duplicate_depth',
              message: 'Duplicate ${layer.depth.name} layer.',
              entryId: entry.id,
            ),
          );
        }
        final hasContent =
            layer.paragraphs.isNotEmpty || layer.keyPoints.isNotEmpty;
        final localizedContent = [
          layer.heading,
          ...layer.paragraphs,
          ...layer.keyPoints,
        ];
        if (!hasContent ||
            localizedContent.any(
              (text) => text.en.trim().isEmpty || text.vi.trim().isEmpty,
            )) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'incomplete_layer',
              message:
                  '${layer.depth.name} requires bilingual heading and content.',
              entryId: entry.id,
            ),
          );
        }
      }
      if (entry.reviewState == ReviewState.reviewed &&
          !{
            ExplanationDepth.result,
            ExplanationDepth.cause,
            ExplanationDepth.principles,
          }.every(depths.contains)) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'reviewed_missing_core_depth',
            message: 'Reviewed content requires result, cause, and principles.',
            entryId: entry.id,
          ),
        );
      }
      if (entry.reviewState != ReviewState.draft && entry.sourceIds.isEmpty) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'published_without_source',
            message: 'Reviewed content requires at least one source.',
            entryId: entry.id,
          ),
        );
      }
      for (final sourceId in entry.sourceIds) {
        if (!sourceIds.contains(sourceId)) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'unknown_source',
              message: 'Unknown source: $sourceId',
              entryId: entry.id,
            ),
          );
        }
      }
    }

    for (final entry in entries) {
      for (final relation in entry.relations) {
        if (relation.targetId == entry.id) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'self_relation',
              message: '${entry.id} cannot relate to itself.',
              entryId: entry.id,
            ),
          );
        }
        if (!entryIds.contains(relation.targetId)) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'unknown_related_entry',
              message: 'Unknown related entry: ${relation.targetId}',
              entryId: entry.id,
            ),
          );
        }
      }
    }

    for (final path in paths) {
      if (!pathIds.add(path.id)) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'duplicate_path_id',
            message: 'Duplicate path id: ${path.id}',
          ),
        );
      }
      if (path.steps.isEmpty) {
        issues.add(
          KnowledgeValidationIssue(
            code: 'empty_path',
            message: 'Learning path ${path.id} has no steps.',
          ),
        );
      }
      final stepIds = <String>{};
      for (final step in path.steps) {
        if (!stepIds.add(step.entryId)) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'duplicate_path_step',
              message: '${path.id} repeats ${step.entryId}.',
            ),
          );
        }
        final entry = _entriesById[step.entryId];
        if (entry == null) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'unknown_path_entry',
              message: 'Unknown path entry: ${step.entryId}',
            ),
          );
        } else if (entry.layer(step.minimumDepth) == null) {
          issues.add(
            KnowledgeValidationIssue(
              code: 'missing_path_depth',
              message:
                  '${step.entryId} has no ${step.minimumDepth.name} layer.',
              entryId: step.entryId,
            ),
          );
        }
      }
    }
    return issues;
  }
}

bool _hasFuzzyMatch(String query, List<String> fields) {
  if (query.length < 4) return false;
  for (final field in fields) {
    for (final word in field.split(' ')) {
      if ((word.length - query.length).abs() <= 2 &&
          _editDistance(word, query) <= 2) {
        return true;
      }
    }
  }
  return false;
}

int _editDistance(String a, String b) {
  var previous = List<int>.generate(b.length + 1, (index) => index);
  for (var i = 0; i < a.length; i++) {
    final current = <int>[i + 1];
    for (var j = 0; j < b.length; j++) {
      final insert = current[j] + 1;
      final delete = previous[j + 1] + 1;
      final replace = previous[j] + (a[i] == b[j] ? 0 : 1);
      current.add([insert, delete, replace].reduce((x, y) => x < y ? x : y));
    }
    previous = current;
  }
  return previous.last;
}
