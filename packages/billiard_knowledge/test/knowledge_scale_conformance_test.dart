import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_compiler_v0.dart' as compiler;
import '../tool/knowledge_publication.dart';
import '../tool/knowledge_release_candidate.dart';

void main() {
  late List<_ScaleFixture> fixtures;
  late List<KnowledgeEntryCandidate> candidates;
  late Map<String, EntryCandidateReviewDecision> reviews;
  late Map<String, dynamic> masteryPolicies;
  late KnowledgeGeneralizationResult result;

  setUpAll(() {
    fixtures = _scaleFixtures(75);
    candidates = [
      for (final fixture in fixtures)
        KnowledgeEntryCandidate.fromCompiledSource(
          compiler.compileKnowledgeEntrySource(fixture.markdown),
        ),
    ];
    reviews = {
      for (var index = 0; index < candidates.length; index++)
        candidates[index].entryId: _review(
          candidates[index],
          accepted: index < 70,
        ),
    };
    masteryPolicies = compiler.parseYamlObject(
      File('corpus/mastery_policies.yaml').readAsStringSync(),
    );
    result = const KnowledgeReleaseCandidateBuilder().build(
      candidates: candidates,
      reviewsByEntryId: reviews,
    );
  });

  group('M2.1 Knowledge Scale Conformance', () {
    test('75 Markdown candidates isolate quarantine and publish 70 entries',
        () {
      expect(candidates, hasLength(75));
      expect(result.eligible, hasLength(70));
      expect(result.quarantined, hasLength(5));
      expect(
        result.quarantined.map((item) => item.code).toSet(),
        {EntryCandidateQuarantineCode.reviewRejected},
      );

      final eligibleIds = result.eligible.map((item) => item.entryId).toSet();
      final eligibleSources = fixtures
          .where((fixture) => eligibleIds.contains(fixture.id))
          .map((fixture) => fixture.markdown)
          .toList();
      final compiled = compiler.compileKnowledgeCorpus(
        eligibleSources,
        masteryPolicyDocument: masteryPolicies,
      );
      final pack = ExecutableKnowledgePack.fromJsonString(compiled);
      expect(pack.entries, hasLength(70));
      expect(
        pack.entries.map((entry) => entry.kind).toSet(),
        ExecutableKnowledgeKind.values.toSet(),
      );
      final categories = pack.entries
          .map((entry) => entry.payload)
          .whereType<TechniquePayload>()
          .map((payload) => payload.masteryCategory)
          .toSet();
      expect(
        categories,
        containsAll({
          MasteryCategory.foundation,
          MasteryCategory.coreCompetitive,
          MasteryCategory.advanced,
        }),
      );

      final directory = Directory.systemTemp.createTempSync(
        'pool_os_scale_publication_',
      );
      try {
        final publicationPipeline = KnowledgePublicationPipeline(directory);
        final packageReview = PublicationReviewDecision.create(
          outcome: PublicationReviewOutcome.accepted,
          candidateContentDigest: pack.contentDigest,
          compilerVersion: pack.compilerVersion,
          releaseCandidateContentDigest: result.releaseCandidate.contentDigest,
          reviewer: 'Scale Conformance Fixture',
          decidedAt: '2026-07-21T00:00:00.000Z',
        );
        final publication = publicationPipeline.submitCandidate(
          candidateId:
              'scale-${result.releaseCandidate.contentDigest.substring(0, 12)}',
          compile: () => compiled,
          review: packageReview,
          releaseCandidateContentDigest: result.releaseCandidate.contentDigest,
        );

        expect(publication.status, PublicationCandidateStatus.published);
        expect(
          publication.publication!.releaseCandidateContentDigest,
          result.releaseCandidate.contentDigest,
        );
        expect(publicationPipeline.current().contentDigest, pack.contentDigest);
      } finally {
        directory.deleteSync(recursive: true);
      }
    });

    test('candidate and source ordering cannot change deterministic digests',
        () {
      final reorderedCandidates = <KnowledgeEntryCandidate>[
        for (var index = 0; index < candidates.length; index += 2)
          candidates[index],
        for (var index = 1; index < candidates.length; index += 2)
          candidates[index],
      ].reversed.toList();
      final reordered = const KnowledgeReleaseCandidateBuilder().build(
        candidates: reorderedCandidates,
        reviewsByEntryId: reviews,
      );

      expect(
        reordered.releaseCandidate.contentDigest,
        result.releaseCandidate.contentDigest,
      );
      expect(
        reordered.releaseCandidate.toJson(),
        result.releaseCandidate.toJson(),
      );

      final normalPack = compiler.compileKnowledgeCorpus(
        fixtures.map((item) => item.markdown).toList(),
        masteryPolicyDocument: masteryPolicies,
      );
      final reversedPack = compiler.compileKnowledgeCorpus(
        fixtures.reversed.map((item) => item.markdown).toList(),
        masteryPolicyDocument: masteryPolicies,
      );
      expect(reversedPack, normalPack);
    });

    test('resolved dependency content participates in the RC digest', () {
      final changedFixture = fixtures.first.copyWith(
        markdown: fixtures.first.markdown.replaceFirst(
          'Scale summary 0',
          'Scale summary 0 changed',
        ),
      );
      final changedCandidate = KnowledgeEntryCandidate.fromCompiledSource(
        compiler.compileKnowledgeEntrySource(changedFixture.markdown),
      );
      final changedCandidates = [changedCandidate, ...candidates.skip(1)];
      final changedReviews = {...reviews}..[changedCandidate.entryId] = _review(
          changedCandidate,
          accepted: true,
        );
      final changed = const KnowledgeReleaseCandidateBuilder().build(
        candidates: changedCandidates,
        reviewsByEntryId: changedReviews,
      );

      expect(
        changed.releaseCandidate.contentDigest,
        isNot(result.releaseCandidate.contentDigest),
      );
      final edge = changed.releaseCandidate.resolvedDependencies.singleWhere(
        (dependency) => dependency.entryId == fixtures[1].id,
      );
      expect(edge.dependencyId, changedCandidate.entryId);
      expect(
        edge.resolvedDependencyContentDigest,
        changedCandidate.contentDigest,
      );

      final registry = PublishedKnowledgeVersionRegistry()
        ..register(
          knowledgeVersion: result.releaseCandidate.knowledgeVersion,
          releaseCandidateContentDigest: result.releaseCandidate.contentDigest,
        );
      registry.register(
        knowledgeVersion: result.releaseCandidate.knowledgeVersion,
        releaseCandidateContentDigest: result.releaseCandidate.contentDigest,
      );
      expect(
        () => registry.register(
          knowledgeVersion: changed.releaseCandidate.knowledgeVersion,
          releaseCandidateContentDigest: changed.releaseCandidate.contentDigest,
        ),
        throwsA(isA<KnowledgeGeneralizationException>()),
      );
    });

    test('compiler and RC schema versions participate in the digest', () {
      final nextCompilerCandidates = [
        for (final fixture in fixtures)
          KnowledgeEntryCandidate.fromCompiledSource(
            compiler.compileKnowledgeEntrySource(fixture.markdown),
            compilerVersion: '0.6.2-scale-fixture',
          ),
      ];
      final nextCompilerReviews = {
        for (var index = 0; index < nextCompilerCandidates.length; index++)
          nextCompilerCandidates[index].entryId: _review(
            nextCompilerCandidates[index],
            accepted: index < 70,
          ),
      };
      final nextCompiler = const KnowledgeReleaseCandidateBuilder().build(
        candidates: nextCompilerCandidates,
        reviewsByEntryId: nextCompilerReviews,
      );
      final nextSchema = ReleaseCandidateSnapshot.create(
        schemaVersion: releaseCandidateSchemaVersion + 1,
        compilerVersion: result.releaseCandidate.compilerVersion,
        knowledgeVersion: result.releaseCandidate.knowledgeVersion,
        entries: result.releaseCandidate.entries,
        resolvedDependencies: result.releaseCandidate.resolvedDependencies,
      );

      expect(
        nextCompiler.releaseCandidate.contentDigest,
        isNot(result.releaseCandidate.contentDigest),
      );
      expect(
        nextSchema.contentDigest,
        isNot(result.releaseCandidate.contentDigest),
      );
    });

    test('review audit metadata cannot change the RC content digest', () {
      final differentAuditReviews = {
        for (var index = 0; index < candidates.length; index++)
          candidates[index].entryId: EntryCandidateReviewDecision.create(
            entryId: candidates[index].entryId,
            candidateDigest: candidates[index].candidateDigest,
            outcome: index < 70
                ? EntryCandidateReviewOutcome.accepted
                : EntryCandidateReviewOutcome.rejected,
            reviewer: 'Different Scale Reviewer',
            decidedAt: '2026-08-01T12:34:56.000Z',
            reason: index < 70 ? null : 'Different audit reason.',
          ),
      };

      final rebuilt = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: differentAuditReviews,
      );

      expect(
        rebuilt.releaseCandidate.contentDigest,
        result.releaseCandidate.contentDigest,
      );
      expect(
        rebuilt.quarantined.map((item) => item.reviewDecisionDigest),
        isNot(
          result.quarantined.map((item) => item.reviewDecisionDigest),
        ),
      );
    });

    test('a quarantined dependency only removes its dependent chain', () {
      final middleReviews = {
        for (final candidate in candidates)
          candidate.entryId: _review(candidate, accepted: true),
      };
      middleReviews[candidates[10].entryId] = _review(
        candidates[10],
        accepted: false,
      );

      final evaluated = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: middleReviews,
      );

      expect(evaluated.eligible, hasLength(10));
      expect(
        evaluated.quarantined
            .firstWhere(
              (item) => item.candidate.entryId == candidates[10].entryId,
            )
            .code,
        EntryCandidateQuarantineCode.reviewRejected,
      );
      expect(
        evaluated.quarantined
            .firstWhere(
              (item) => item.candidate.entryId == candidates[11].entryId,
            )
            .code,
        EntryCandidateQuarantineCode.dependencyUnavailable,
      );
      expect(
        evaluated.eligible.map((item) => item.entryId),
        contains(candidates[9].entryId),
      );
    });

    test('an RC remains immutable when later reviews become accepted', () {
      final originalDigest = result.releaseCandidate.contentDigest;
      final originalEntryIds = result.releaseCandidate.entries
          .map((entry) => entry.entryId)
          .toList();
      final acceptedReviews = {
        for (final candidate in candidates)
          candidate.entryId: _review(candidate, accepted: true),
      };

      final next = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: acceptedReviews,
      );

      expect(result.releaseCandidate.entries, hasLength(70));
      expect(
        result.releaseCandidate.entries.map((entry) => entry.entryId),
        originalEntryIds,
      );
      expect(result.releaseCandidate.contentDigest, originalDigest);
      expect(next.releaseCandidate.entries, hasLength(75));
      expect(next.releaseCandidate.contentDigest, isNot(originalDigest));
      expect(
        () => result.releaseCandidate.entries.add(candidates.last),
        throwsUnsupportedError,
      );
    });

    test('RC implementation contains no Knowledge ID branch', () {
      final source = File(
        'tool/knowledge_release_candidate.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('scale.entry')));
      expect(source, isNot(contains('control.stop_shot')));
      expect(source, isNot(contains('if (candidate.entryId ==')));
    });
  });
}

EntryCandidateReviewDecision _review(
  KnowledgeEntryCandidate candidate, {
  required bool accepted,
}) =>
    EntryCandidateReviewDecision.create(
      entryId: candidate.entryId,
      candidateDigest: candidate.candidateDigest,
      outcome: accepted
          ? EntryCandidateReviewOutcome.accepted
          : EntryCandidateReviewOutcome.rejected,
      reviewer: 'Scale Conformance Fixture',
      decidedAt: '2026-07-21T00:00:00.000Z',
      reason: accepted ? null : 'Synthetic review rejection.',
    );

List<_ScaleFixture> _scaleFixtures(int count) => [
      for (var index = 0; index < count; index++) _fixture(index),
    ];

_ScaleFixture _fixture(int index) {
  final id = 'scale.entry.e${index.toString().padLeft(3, '0')}';
  final dependency = index == 0
      ? 'relations: []'
      : 'relations:\n  - scale.entry.e${(index - 1).toString().padLeft(3, '0')}';
  final kindIndex = index % 3;
  final kind =
      switch (kindIndex) { 0 => 'technique', 1 => 'mistake', _ => 'concept' };
  final category = switch ((index ~/ 3) % 3) {
    0 => 'foundation',
    1 => 'coreCompetitive',
    _ => 'advanced',
  };
  final payload = switch (kind) {
    'technique' => _techniquePayload(index, category),
    'mistake' => _mistakePayload(index, category),
    _ => _conceptPayload(index),
  };
  return _ScaleFixture(
    id: id,
    markdown: '''
---
schemaVersion: 1
id: $id
kind: $kind
knowledgeVersion: scale.1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: Scale Entry $index
summary: Scale summary $index
capabilities: []
$dependency
payload:
$payload
---
Scale conformance body $index.
''',
  );
}

String _techniquePayload(int index, String category) {
  final requiredSuccesses = switch (category) {
    'foundation' => 10,
    'coreCompetitive' => 9,
    _ => 8,
  };
  return '''
  masteryCategory: $category
  outcome:
    description: Scale outcome $index
    successRadiusCm: 20
    requiredSuccesses: $requiredSuccesses
    requiredAttempts: 10
  measurement:
    id: measurement.scale.$index
    drillId: SCALE-$index
    attempts: 10
    successDefinition: Scale success $index
  drill:
    id: SCALE-$index
    title: Scale Drill $index
    instructions:
      - Execute scale drill $index
  nextRecommendation:
    id: next.scale.$index
    title: Scale Next $index
    targetType: placeholder''';
}

String _mistakePayload(int index, String category) => '''
  masteryCategory: $category
  resolutionPolicy:
    type: consecutive_clean
    requiredConsecutiveClean: 3
  symptom: Scale symptom $index
  correction: Scale correction $index
  causes:
    - Scale cause $index''';

String _conceptPayload(int index) => '''
  explanation: Scale explanation $index
  keyPoints:
    - Scale point $index''';

class _ScaleFixture {
  const _ScaleFixture({required this.id, required this.markdown});

  final String id;
  final String markdown;

  _ScaleFixture copyWith({String? markdown}) => _ScaleFixture(
        id: id,
        markdown: markdown ?? this.markdown,
      );
}
