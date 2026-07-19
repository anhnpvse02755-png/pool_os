import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late KnowledgeCatalog catalog;

  setUpAll(() async {
    final raw = await File('assets/pack_v1.json').readAsString();
    catalog = KnowledgeCatalog.fromJsonString(raw);
  });

  test('the production pack passes structural validation', () {
    expect(catalog.validate(), isEmpty);
    expect(catalog.packVersion, '1.3.0');
    expect(catalog.entries, hasLength(36));
    expect(catalog.paths, hasLength(4));
    expect(catalog.sources, hasLength(15));
    expect(catalog.entries.every((entry) => entry.layers.length >= 3), isTrue);
  });

  test('Vietnamese search works without diacritics', () {
    final results = catalog.search(const KnowledgeQuery(text: 'cau tay'));
    expect(results, isNotEmpty);
    expect(
      results.take(2).map((result) => result.entry.id).toSet(),
      {
        'fundamental.bridge.open',
        'fundamental.bridge.closed',
      },
    );
  });

  test('English terms are found while Vietnamese is the display locale', () {
    final results = catalog.search(const KnowledgeQuery(text: 'open bridge'));
    expect(results, isNotEmpty);
    expect(results.first.entry.title.vi, 'Cầu tay mở');
  });

  test('search tolerates a small spelling error', () {
    final results = catalog.search(
      const KnowledgeQuery(text: 'aligment', locale: 'en'),
    );
    expect(results, isNotEmpty);
    expect(results.first.entry.id, 'fundamental.alignment.visual');
  });

  test('the beginner learning path resolves every step and depth', () {
    final path = catalog.pathById('path.beginner.fundamentals');
    expect(path, isNotNull);
    for (final step in path!.steps) {
      final entry = catalog.entryById(step.entryId);
      expect(entry, isNotNull);
      expect(entry!.layer(step.minimumDepth), isNotNull);
    }
  });

  test('all learning paths resolve every step and requested depth', () {
    for (final path in catalog.paths) {
      expect(path.steps, isNotEmpty, reason: path.id);
      for (final step in path.steps) {
        final entry = catalog.entryById(step.entryId);
        expect(entry, isNotNull, reason: '${path.id}: ${step.entryId}');
        expect(entry!.layer(step.minimumDepth), isNotNull,
            reason: '${path.id}: ${step.entryId}');
      }
    }
  });

  test('v1 covers the core Pool OS knowledge domains', () {
    final topics = catalog.entries.map((entry) => entry.topic).toSet();
    expect(
      topics,
      containsAll({
        'aiming',
        'break',
        'cue_ball_control',
        'equipment',
        'mental_game',
        'position_play',
        'rules',
        'safety',
        'stroke_errors',
      }),
    );
    expect(catalog.entries.map((entry) => entry.kind).toSet(),
        containsAll(KnowledgeKind.values));
  });

  test('Vietnamese control and safety queries find the intended articles', () {
    expect(
      catalog.search(const KnowledgeQuery(text: 'keo bi')).first.entry.id,
      'control.draw_shot',
    );
    expect(
      catalog.search(const KnowledgeQuery(text: 'danh thu')).first.entry.id,
      'strategy.safety.objective',
    );
  });

  test('Stop Shot is the reference article with all five explanation levels',
      () {
    final stopShot = catalog.entryById('control.stop_shot')!;
    for (final depth in ExplanationDepth.values) {
      expect(stopShot.layer(depth), isNotNull, reason: depth.name);
    }
    expect(stopShot.layer(ExplanationDepth.engine)!.paragraphs, isNotEmpty);
  });

  test('the researched cue-ball slice has all five explanation levels', () {
    const researchedEntries = {
      'control.stop_shot',
      'control.follow_shot',
      'control.draw_shot',
      'control.speed',
      'control.tangent_line',
      'physics.throw.awareness',
      'physics.squirt',
      'physics.swerve',
      'term.tro',
      'term.cu_le',
    };

    for (final id in researchedEntries) {
      final entry = catalog.entryById(id);
      expect(entry, isNotNull, reason: id);
      for (final depth in ExplanationDepth.values) {
        expect(entry!.layer(depth), isNotNull, reason: '$id: ${depth.name}');
      }
    }
  });

  test('Vietnamese table terms are first-class searchable entries', () {
    expect(
      catalog.search(const KnowledgeQuery(text: 'tro')).first.entry.id,
      'term.tro',
    );
    expect(
      catalog.search(const KnowledgeQuery(text: 'cu le')).first.entry.id,
      'term.cu_le',
    );
    expect(catalog.entryById('term.tro')!.reviewState, ReviewState.draft);
    expect(catalog.entryById('term.cu_le')!.reviewState, ReviewState.draft);
  });

  test('squirt and swerve remain distinct but linked concepts', () {
    final squirt = catalog.entryById('physics.squirt')!;
    final swerve = catalog.entryById('physics.swerve')!;

    expect(squirt.summary.en, contains('immediate'));
    expect(swerve.summary.en, contains('curves on the cloth'));
    expect(
      catalog.relationTargets(squirt, RelationType.related).map((e) => e.id),
      contains(swerve.id),
    );
  });

  test('deep layers retain research and simulation provenance', () {
    final throwEntry = catalog.entryById('physics.throw.awareness')!;
    expect(
      throwEntry.sourceIds,
      containsAll({
        'source.drdave.throw',
        'source.mathavan.collision_2014',
        'source.pooltool.joss',
      }),
    );
    expect(
      catalog.entryById('rule.legal_shot.basic')!.sourceIds,
      contains('source.vietnam.rules_2002'),
    );
  });

  test('public graph API resolves related entries', () {
    final stance = catalog.entryById('fundamental.stance.basic')!;
    final related = catalog.relatedTo(stance);
    expect(
      related.map((entry) => entry.id),
      contains('fundamental.stroke.delivery'),
    );
  });
}
