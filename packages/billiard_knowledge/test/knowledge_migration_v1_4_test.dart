import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_migration_v1_4.dart';

void main() {
  late Directory packageRoot;
  late M23MigrationBuild build;

  setUpAll(() {
    packageRoot = Directory.current.absolute;
    build = buildM23Migration(packageRoot);
  });

  group('M2.3 36-entry Migration', () {
    test('all source entries receive a deterministic migration disposition',
        () {
      final manifest = _jsonArtifact(build, 'manifest.json');
      final rows = (manifest['rows'] as List).cast<Map>();
      expect(rows, hasLength(36));
      expect(
        rows.where((row) => row['classification'] == 'migrate_candidate'),
        hasLength(31),
      );
      expect(
        rows.where((row) => row['classification'] == 'merge_existing'),
        hasLength(3),
      );
      final quarantined =
          rows.where((row) => row['classification'] == 'quarantine').toList();
      expect(quarantined, hasLength(2));
      expect(
        quarantined.map((row) => row['sourceId']).toSet(),
        {'term.tro', 'term.cu_le'},
      );
      expect(
        quarantined.map((row) => row['reasonCode']).toSet(),
        {'reviewStateDraft'},
      );
    });

    test('source ordering cannot change authoring, RC, pack, or report bytes',
        () {
      final reversed = buildM23Migration(
        packageRoot,
        reverseSourceOrder: true,
      );
      expect(reversed.artifacts, build.artifacts);
      expect(reversed.report, build.report);
    });

    test('candidate pack contains 35 generalized and provenance-bound entries',
        () {
      final identity = readM23KnowledgeArtifact(
        build.artifacts['candidate_pack.json']!,
      );
      final pack = _jsonArtifact(build, 'candidate_pack.json');
      final entries = (pack['entries'] as List).cast<Map>();
      expect(identity.knowledgeVersion, migrationKnowledgeVersion);
      expect(identity.compilerVersion, migrationCompilerVersion);
      expect(entries, hasLength(35));
      expect(
        entries.map((entry) => entry['kind']).toSet(),
        migrationKnowledgeKinds,
      );
      final byId = {for (final entry in entries) entry['id']: entry};
      expect(byId['term.tro'], isNull);
      expect(byId['term.cu_le'], isNull);
      expect(byId['aim.ghost_ball'], isNull);
      expect(byId['aiming.ghost_ball'], isNotNull);

      final stance = byId['fundamental.stance.basic']!;
      final article = stance['payload'] as Map;
      expect(article['shape'], 'article');
      expect(article['revision'], greaterThanOrEqualTo(1));
      expect(article['sourceIds'], contains('source.drdave.fundamentals'));

      final stop = byId['control.stop_shot']!;
      expect(stop['body'], contains('23/25'));
      expect(stop['body'], isNot(contains('20/25 trở lên')));
    });

    test('legacy prerequisite relations remain associations, not hard edges',
        () {
      final releaseCandidate = _jsonArtifact(
        build,
        'release_candidate.json',
      );
      expect(releaseCandidate['resolvedDependencies'], isEmpty);
      final pack = _jsonArtifact(build, 'candidate_pack.json');
      expect((pack['sources'] as List), hasLength(15));
      final entries = (pack['entries'] as List).cast<Map>();
      final scratch = entries.firstWhere(
        (entry) => entry['id'] == 'rule.scratch.basic',
      );
      expect(scratch['relations'], contains('term.cue_ball'));
      expect(
        (scratch['typedRelations'] as List).cast<Map>().singleWhere(
            (relation) => relation['targetId'] == 'term.cue_ball')['type'],
        'prerequisite',
      );
    });

    test('report proves isolated publication without production activation',
        () {
      final report = build.report;
      expect(report['totalMigrationInputs'], 36);
      expect(report['migrationInputCandidates'], 36);
      expect(report['eligibleMigrationInputs'], 34);
      expect(report['quarantinedMigrationInputs'], 2);
      expect(report['releaseTargetEntries'], 35);
      expect(report['manualGeneratedOutputFixes'], 0);
      expect(report['directPublications'], 0);
      expect(report['sourceRecordsPreserved'], 15);
      expect(report['sourceSnapshotsWithContentHash'], 0);
      expect(report['learningPathsMigrated'], 0);
      expect(report['learningPathsDeferred'], 4);
      expect(report['deterministicRebuild'], 'PASS');
      expect(report['isolatedPublicationPipeline'], 'PASS');
      expect(report['productionActivation'], 'DEFERRED_TO_M2.4');

      final production = ExecutableKnowledgePack.fromJsonString(
        File('assets/executable_pack_v0_6.json').readAsStringSync(),
      );
      expect(production.knowledgeVersion, '0.2.1');
      expect(
        production.contentDigest,
        'da81ba18127c8298276cbdc0ac0f035bf305b73da7489f9309dca52e48a4ee29',
      );
    });

    test('candidate compiler fails loudly on unknown kind or lost provenance',
        () {
      final source = build.artifacts.values.firstWhere(
        (value) =>
            value.startsWith('---\n') && value.contains('"shape":"article"'),
      );
      expect(
        () => compileM23CandidateMarkdown(
          source.replaceFirst('"kind":"', '"kind":"unsupported_'),
        ),
        throwsA(isA<M23MigrationException>()),
      );
      final frontEnd = source.indexOf('\n---\n', 4);
      final front =
          jsonDecode(source.substring(4, frontEnd)) as Map<String, dynamic>;
      front['sourceIds'] = <String>[];
      final withoutSources =
          '---\n${jsonEncode(front)}${source.substring(frontEnd)}';
      expect(
        () => compileM23CandidateMarkdown(withoutSources),
        throwsA(isA<M23MigrationException>()),
      );
    });
  });
}

Map<String, dynamic> _jsonArtifact(M23MigrationBuild build, String path) =>
    jsonDecode(build.artifacts[path]!) as Map<String, dynamic>;
