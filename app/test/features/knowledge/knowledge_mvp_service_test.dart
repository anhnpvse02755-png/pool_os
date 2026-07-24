import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/knowledge/application/knowledge_mvp_service.dart';

void main() {
  group('KnowledgeMvpService', () {
    test('returns catalog categories through the query execution pipeline',
        () async {
      final view = await _service.browse(const KnowledgeBrowseRequest());

      expect(view.results.map((result) => result.entry.id), [
        'control.stop_shot',
        'strategy.safety.objective',
        'terms.stun',
      ]);
      expect(
        view.categories,
        [
          const KnowledgeCategorySummary(
            kind: KnowledgeKind.technique,
            count: 1,
          ),
          const KnowledgeCategorySummary(
            kind: KnowledgeKind.terminology,
            count: 1,
          ),
          const KnowledgeCategorySummary(
            kind: KnowledgeKind.strategy,
            count: 1,
          ),
        ],
      );
    });

    test('reuses canonical bilingual catalog search', () async {
      final view = await _service.browse(const KnowledgeBrowseRequest(
        text: 'bi dung',
        locale: 'vi',
      ));

      expect(view.results.first.entry.id, 'terms.stun');
    });

    test('filters by Knowledge category without a second classifier', () async {
      final view = await _service.browse(const KnowledgeBrowseRequest(
        kind: KnowledgeKind.strategy,
      ));

      expect(view.results.single.entry.id, 'strategy.safety.objective');
    });

    test('combines category and audience filters deterministically', () async {
      const request = KnowledgeBrowseRequest(
        kind: KnowledgeKind.technique,
        level: AudienceLevel.beginner,
      );
      final first = await _service.browse(request);
      final second = await _service.browse(request);

      expect(first.results.single.entry.id, 'control.stop_shot');
      expect(first, second);
    });
  });
}

final _service = KnowledgeMvpService(() async => testKnowledgeCatalog);

final testKnowledgeCatalog = KnowledgeCatalog(
  packVersion: 'test-v1',
  generatedAt: DateTime.utc(2026, 7, 24),
  sources: const [],
  entries: const [
    KnowledgeEntry(
      id: 'control.stop_shot',
      kind: KnowledgeKind.technique,
      level: AudienceLevel.beginner,
      reviewState: ReviewState.draft,
      topic: 'control',
      title: LocalizedText(en: 'Stop Shot', vi: 'Cú dừng'),
      summary: LocalizedText(en: 'Stop the cue ball.', vi: 'Dừng bi cái.'),
      layers: [_testLayer],
      sourceIds: [],
    ),
    KnowledgeEntry(
      id: 'strategy.safety.objective',
      kind: KnowledgeKind.strategy,
      level: AudienceLevel.intermediate,
      reviewState: ReviewState.draft,
      topic: 'safety',
      title: LocalizedText(en: 'Safety Objective', vi: 'Mục tiêu an toàn'),
      summary: LocalizedText(en: 'Plan a safety.', vi: 'Lập thế an toàn.'),
      layers: [_testLayer],
      sourceIds: [],
    ),
    KnowledgeEntry(
      id: 'terms.stun',
      kind: KnowledgeKind.terminology,
      level: AudienceLevel.fundamental,
      reviewState: ReviewState.draft,
      topic: 'terms',
      title: LocalizedText(en: 'Stun', vi: 'Bi đứng'),
      summary: LocalizedText(en: 'A stun-ball term.', vi: 'Thuật ngữ bi đứng.'),
      layers: [_testLayer],
      sourceIds: [],
    ),
  ],
  paths: const [
    LearningPath(
      id: 'path.control',
      title: LocalizedText(en: 'Control Path', vi: 'Lộ trình điều bi'),
      description: LocalizedText(
        en: 'Learn cue-ball control.',
        vi: 'Học điều khiển bi cái.',
      ),
      level: AudienceLevel.beginner,
      steps: [LearningStep(entryId: 'control.stop_shot')],
    ),
  ],
);

const _testLayer = ContentLayer(
  depth: ExplanationDepth.result,
  heading: LocalizedText(en: 'Result', vi: 'Kết quả'),
  paragraphs: [LocalizedText(en: 'Practice.', vi: 'Luyện tập.')],
);
