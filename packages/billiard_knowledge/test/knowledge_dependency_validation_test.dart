import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_compiler_v0.dart' as compiler;
import '../tool/knowledge_release_candidate.dart';

void main() {
  late Map<String, dynamic> masteryPolicies;

  setUpAll(() {
    masteryPolicies = compiler.parseYamlObject(
      File('corpus/mastery_policies.yaml').readAsStringSync(),
    );
  });

  group('M2.2 Production Dependency Validation', () {
    test(
        'production corpus remains valid and legacy relations stay associative',
        () {
      final files = Directory('corpus/articles')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.md'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));
      final sources = files.map((file) => file.readAsStringSync()).toList();
      final candidates = _candidates(sources);
      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: _acceptedReviews(candidates),
      );

      expect(
          compiler.compileKnowledgeCorpus(
            sources,
            masteryPolicyDocument: masteryPolicies,
          ),
          isNotEmpty);
      expect(candidates, hasLength(4));
      expect(candidates.every((candidate) => candidate.dependencies.isEmpty),
          isTrue);
      expect(result.eligible, hasLength(4));
      expect(result.quarantined, isEmpty);
      expect(result.releaseCandidate.resolvedDependencies, isEmpty);
    });

    test('valid requires relations resolve to exact dependency content digests',
        () {
      final sources = [
        _source('production.foundation'),
        _source(
          'production.delivery',
          dependencies: const ['production.foundation'],
        ),
      ];
      final candidates = _candidates(sources);
      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: _acceptedReviews(candidates),
      );
      final foundation = candidates.firstWhere(
        (candidate) => candidate.entryId == 'production.foundation',
      );
      final edge = result.releaseCandidate.resolvedDependencies.single;

      expect(edge.entryId, 'production.delivery');
      expect(edge.dependencyId, foundation.entryId);
      expect(edge.resolvedDependencyContentDigest, foundation.contentDigest);
    });

    test('compiler rejects dangling, self, duplicate, and cyclic dependencies',
        () {
      final cases = <String, List<String>>{
        'danglingDependency': [
          _source(
            'production.dangling',
            dependencies: const ['production.missing'],
          ),
        ],
        'selfDependency': [
          _source(
            'production.self',
            dependencies: const ['production.self'],
          ),
        ],
        'duplicateDependency': [
          _source('production.base'),
          _source(
            'production.duplicate',
            dependencies: const ['production.base', 'production.base'],
          ),
        ],
        'dependencyCycle': [
          _source(
            'production.cycle.a',
            dependencies: const ['production.cycle.b'],
          ),
          _source(
            'production.cycle.b',
            dependencies: const ['production.cycle.a'],
          ),
        ],
      };

      for (final entry in cases.entries) {
        expect(
          () => compiler.compileKnowledgeCorpus(
            entry.value,
            masteryPolicyDocument: masteryPolicies,
          ),
          throwsA(
            isA<Exception>().having(
              (error) => error.toString(),
              'message',
              contains('[${entry.key}]'),
            ),
          ),
          reason: entry.key,
        );
      }
    });

    test('entry candidates receive precise structural quarantine reason codes',
        () {
      final sources = [
        _source('production.valid'),
        _source(
          'production.dangling',
          dependencies: const ['production.missing'],
        ),
        _source(
          'production.self',
          dependencies: const ['production.self'],
        ),
        _source(
          'production.duplicate',
          dependencies: const ['production.valid', 'production.valid'],
        ),
        _source(
          'production.cycle.a',
          dependencies: const ['production.cycle.b'],
        ),
        _source(
          'production.cycle.b',
          dependencies: const ['production.cycle.a'],
        ),
      ];
      final candidates = _candidates(sources);
      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: _acceptedReviews(candidates),
      );
      final codes = {
        for (final item in result.quarantined)
          item.candidate.entryId: item.code,
      };

      expect(result.eligible.map((candidate) => candidate.entryId),
          ['production.valid']);
      expect(codes['production.dangling'],
          EntryCandidateQuarantineCode.danglingDependency);
      expect(codes['production.self'],
          EntryCandidateQuarantineCode.selfDependency);
      expect(codes['production.duplicate'],
          EntryCandidateQuarantineCode.duplicateDependency);
      expect(codes['production.cycle.a'],
          EntryCandidateQuarantineCode.dependencyCycle);
      expect(codes['production.cycle.b'],
          EntryCandidateQuarantineCode.dependencyCycle);
    });

    test('quarantined prerequisite produces dependencyUnavailable downstream',
        () {
      final candidates = _candidates([
        _source('production.rejected'),
        _source(
          'production.blocked',
          dependencies: const ['production.rejected'],
        ),
        _source('production.independent'),
      ]);
      final reviews = _acceptedReviews(candidates);
      final rejected = candidates.firstWhere(
        (candidate) => candidate.entryId == 'production.rejected',
      );
      reviews[rejected.entryId] = _review(rejected, accepted: false);

      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: reviews,
      );
      final quarantined = {
        for (final item in result.quarantined) item.candidate.entryId: item,
      };

      expect(quarantined['production.rejected']!.code,
          EntryCandidateQuarantineCode.reviewRejected);
      expect(quarantined['production.blocked']!.code,
          EntryCandidateQuarantineCode.dependencyUnavailable);
      expect(
          quarantined['production.blocked']!.details, ['production.rejected']);
      expect(result.eligible.map((candidate) => candidate.entryId),
          ['production.independent']);
    });

    test('dependency declaration order cannot change RC or package digest', () {
      final ordered = [
        _source('production.base.a'),
        _source('production.base.b'),
        _source(
          'production.dependent',
          dependencies: const ['production.base.a', 'production.base.b'],
        ),
      ];
      final reversed = [
        ordered[0],
        ordered[1],
        _source(
          'production.dependent',
          dependencies: const ['production.base.b', 'production.base.a'],
        ),
      ];
      final orderedCandidates = _candidates(ordered);
      final reversedCandidates = _candidates(reversed);
      final orderedResult = const KnowledgeReleaseCandidateBuilder().build(
        candidates: orderedCandidates,
        reviewsByEntryId: _acceptedReviews(orderedCandidates),
      );
      final reversedResult = const KnowledgeReleaseCandidateBuilder().build(
        candidates: reversedCandidates,
        reviewsByEntryId: _acceptedReviews(reversedCandidates),
      );

      expect(reversedResult.releaseCandidate.contentDigest,
          orderedResult.releaseCandidate.contentDigest);
      expect(
        compiler.compileKnowledgeCorpus(
          reversed,
          masteryPolicyDocument: masteryPolicies,
        ),
        compiler.compileKnowledgeCorpus(
          ordered,
          masteryPolicyDocument: masteryPolicies,
        ),
      );
    });

    test('RC creation rejects a resolved dependency digest mismatch', () {
      final candidates = _candidates([
        _source('production.base'),
        _source(
          'production.dependent',
          dependencies: const ['production.base'],
        ),
      ]);
      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: _acceptedReviews(candidates),
      );
      final edge = result.releaseCandidate.resolvedDependencies.single;

      expect(
        () => ReleaseCandidateSnapshot.create(
          compilerVersion: result.releaseCandidate.compilerVersion,
          knowledgeVersion: result.releaseCandidate.knowledgeVersion,
          entries: result.releaseCandidate.entries,
          resolvedDependencies: [
            ResolvedKnowledgeDependency(
              entryId: edge.entryId,
              dependencyId: edge.dependencyId,
              resolvedDependencyContentDigest: 'mismatched-content-digest',
            ),
          ],
        ),
        throwsA(
          isA<KnowledgeGeneralizationException>().having(
            (error) => error.message,
            'message',
            contains('content digest mismatch'),
          ),
        ),
      );
    });

    test('isolated entries remain eligible because connectivity is optional',
        () {
      final candidates = _candidates([
        _source('production.isolated.a'),
        _source('production.isolated.b'),
      ]);
      final result = const KnowledgeReleaseCandidateBuilder().build(
        candidates: candidates,
        reviewsByEntryId: _acceptedReviews(candidates),
      );

      expect(result.eligible, hasLength(2));
      expect(result.quarantined, isEmpty);
    });
  });
}

List<KnowledgeEntryCandidate> _candidates(List<String> sources) => [
      for (final source in sources)
        KnowledgeEntryCandidate.fromCompiledSource(
          compiler.compileKnowledgeEntrySource(source),
        ),
    ];

Map<String, EntryCandidateReviewDecision> _acceptedReviews(
  List<KnowledgeEntryCandidate> candidates,
) =>
    {
      for (final candidate in candidates)
        candidate.entryId: _review(candidate, accepted: true),
    };

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
      reviewer: 'M2.2 Production Dependency Fixture',
      decidedAt: '2026-07-21T00:00:00.000Z',
      reason: accepted ? null : 'Production-style fixture rejection.',
    );

String _source(String id, {List<String> dependencies = const []}) {
  final relations = dependencies.isEmpty
      ? 'relations: []'
      : [
          'relations:',
          for (final dependency in dependencies) ...[
            '  - type: requires',
            '    targetId: $dependency',
          ],
        ].join('\n');
  return '''
---
schemaVersion: 1
id: $id
kind: concept
knowledgeVersion: production-dependency.1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: $id
summary: Production dependency fixture for $id.
capabilities: []
$relations
payload:
  explanation: Dependency validation for $id.
  keyPoints:
    - Deterministic dependency behavior.
---
Production-style dependency fixture for $id.
''';
}
