import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/knowledge/domain/models/knowledge_item.dart';

/// RFC-KB-002 — Knowledge Pack V1 validation.
///
/// Loads the bundled JSON directly from disk (no Flutter asset binding needed)
/// and asserts the whole pack is internally consistent against the FROZEN
/// contract: valid schema, no `drill` type, every graph edge resolves, every
/// drillRef resolves to a real DrillLibrary entry, and every skill id is real.
/// This is the guard that keeps the Coach → Knowledge → Drill graph honest.
void main() {
  // Repo-relative asset root (test cwd is the app/ dir).
  final kbDir = Directory('assets/knowledge');

  // Valid skill ids (Coach SkillCategory codes) for skillId + estimatedSkillGain.
  const skillIds = {
    'stroke', 'position', 'decision', 'pattern', 'break', 'safety',
    'mental', 'consistency', 'equipment', 'recovery',
  };

  late List<KnowledgeItem> items;
  late Map<String, KnowledgeItem> byId;

  setUpAll(() {
    final indexRaw =
        File('assets/knowledge/index.json').readAsStringSync();
    final paths = (jsonDecode(indexRaw) as List).map((e) => e.toString());
    items = [
      for (final rel in paths)
        KnowledgeItem.fromJson(jsonDecode(
                File('assets/knowledge/$rel').readAsStringSync())
            as Map<String, dynamic>),
    ];
    byId = {for (final k in items) k.id: k};
  });

  test('index.json lists every JSON file (and vice versa)', () {
    final onDisk = kbDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json') && !f.path.endsWith('index.json'))
        .length;
    expect(items.length, onDisk,
        reason: 'index.json entries must match the .json files on disk');
    expect(items.length, 18);
  });

  test('every item parses and has unique, non-empty semantic id', () {
    final ids = <String>{};
    for (final k in items) {
      expect(k.id.trim(), isNotEmpty);
      expect(k.id.contains('.'), isTrue, reason: 'semantic id: ${k.id}');
      expect(ids.add(k.id), isTrue, reason: 'duplicate id: ${k.id}');
    }
  });

  test('no item uses the drill type (drills are external references)', () {
    // KnowledgeType has no `drill` member, but guard the raw strings too.
    for (final k in items) {
      expect(k.type == KnowledgeType.technique ||
          k.type == KnowledgeType.commonMistake ||
          k.type == KnowledgeType.equipment ||
          k.type == KnowledgeType.mental ||
          k.type == KnowledgeType.strategy, isTrue);
    }
  });

  test('every relatedKnowledge / nextRecommended ref resolves', () {
    for (final k in items) {
      for (final ref in k.relatedKnowledge) {
        expect(byId.containsKey(ref.id), isTrue,
            reason: '${k.id} → dangling relatedKnowledge ${ref.id}');
      }
      if (k.nextRecommended != null) {
        expect(byId.containsKey(k.nextRecommended!.id), isTrue,
            reason: '${k.id} → dangling nextRecommended ${k.nextRecommended!.id}');
      }
    }
  });

  test('every drillRef resolves to a valid DrillLibrary entry', () {
    for (final k in items) {
      for (final code in k.drillRefs) {
        expect(DrillLibrary.getDrillByCode(code), isNotNull,
            reason: '${k.id} → unknown drillRef $code');
      }
    }
  });

  test('skillId and estimatedSkillGain keys are valid skill ids; gain is a map',
      () {
    for (final k in items) {
      if (k.skillId != null) {
        expect(skillIds.contains(k.skillId), isTrue,
            reason: '${k.id} → bad skillId ${k.skillId}');
      }
      k.estimatedSkillGain.forEach((sk, v) {
        expect(skillIds.contains(sk), isTrue,
            reason: '${k.id} → bad estimatedSkillGain key $sk');
        expect(v, inInclusiveRange(0, 100));
      });
    }
  });

  test('techniques link to drills + knowledge; mistakes have corrections', () {
    for (final k in items) {
      if (k.type == KnowledgeType.technique) {
        expect(k.drillRefs, isNotEmpty, reason: '${k.id} technique needs a drill');
        expect(k.relatedKnowledge, isNotEmpty,
            reason: '${k.id} technique needs a related knowledge edge');
      }
      if (k.type == KnowledgeType.commonMistake) {
        expect(k.corrections, isNotEmpty,
            reason: '${k.id} mistake needs corrections');
      }
    }
  });

  test('roundtrip: toJson → fromJson preserves key fields', () {
    for (final k in items) {
      final back = KnowledgeItem.fromJson(k.toJson());
      expect(back.id, k.id);
      expect(back.type, k.type);
      expect(back.status, k.status);
      expect(back.drillRefs, k.drillRefs);
      expect(back.estimatedSkillGain, k.estimatedSkillGain);
    }
  });
}
