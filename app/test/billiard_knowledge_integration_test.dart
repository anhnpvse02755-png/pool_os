import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/knowledge/data/knowledge_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Pool OS loads and validates the package knowledge pack', () async {
    final catalog = await KnowledgeRepository().load();

    expect(catalog.validate(), isEmpty);
    expect(catalog.packVersion, '1.3.0');
    expect(catalog.entryById('fundamental.stance.basic'), isNotNull);
    expect(catalog.pathById('path.beginner.fundamentals'), isNotNull);
    expect(catalog.entries, hasLength(36));
  });

  test('Coach article mappings resolve to real package entries', () async {
    final catalog = await KnowledgeRepository().load();
    for (final knowledgeId in [
      KnowledgeId.practiceStopShot,
      KnowledgeId.practicePosition,
      KnowledgeId.practiceBreak,
      KnowledgeId.practiceSafety,
    ]) {
      final articleId = KnowledgeRegistry.articleFor(knowledgeId);
      expect(articleId, isNotNull, reason: knowledgeId);
      expect(catalog.entryById(articleId!), isNotNull, reason: articleId);
    }
  });
}
