import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_publication.dart';

void main() {
  late Directory temporary;
  late Directory store;
  late String compiled;

  setUp(() {
    temporary = Directory.systemTemp.createTempSync(
      'pool_os_knowledge_publication_',
    );
    store = Directory('${temporary.path}${Platform.pathSeparator}store');
    compiled = compileCurrentCorpus(Directory.current);
  });

  tearDown(() {
    if (temporary.existsSync()) temporary.deleteSync(recursive: true);
  });

  group('KnowledgePublicationPipeline', () {
    test('compiler input matches the frozen generated asset', () {
      expect(
        compiled,
        _normalizeNewlines(
          File('assets/executable_pack_v0_6.json').readAsStringSync(),
        ),
      );
    });

    test('publishes one deterministic immutable artifact idempotently', () {
      final pipeline = KnowledgePublicationPipeline(store);

      final first = _publishAccepted(pipeline, compiled);
      final second = _publishAccepted(pipeline, compiled);

      expect(second.digest, first.digest);
      expect(pipeline.current().contentDigest, first.contentDigest);
      final artifacts =
          Directory('${store.path}${Platform.pathSeparator}objects')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('package.json'));
      expect(artifacts, hasLength(1));
    });

    test('serializes concurrent publishers into one current artifact',
        () async {
      final storePath = store.path;
      final publications = await Future.wait([
        for (var index = 0; index < 3; index++)
          Isolate.run(
            () => KnowledgePublicationPipeline(Directory(storePath))
                .submitCandidate(
                  candidateId: 'concurrent-candidate',
                  compile: () => compiled,
                  review: _acceptedReview(compiled),
                )
                .publication!
                .contentDigest,
          ),
      ]);

      expect(publications.toSet(), hasLength(1));
      expect(
        KnowledgePublicationPipeline(store).current().contentDigest,
        publications.first,
      );
    });

    test('validation failure cannot replace the current publication', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final current = _publishAccepted(pipeline, compiled);
      final tampered = compiled.replaceFirst('Ghost Ball', 'Tampered Ball');

      final result = pipeline.submitCandidate(
        candidateId: 'tampered-candidate',
        compile: () => tampered,
        review: _acceptedReview(compiled),
      );
      expect(result.status, PublicationCandidateStatus.quarantined);
      expect(
        result.quarantine!.issues.single.code,
        PublicationValidationCode.artifactInvalid,
      );
      expect(pipeline.current().contentDigest, current.contentDigest);
    });

    test('recovers when publication stops after backing up current', () {
      final stable = _publishAccepted(
        KnowledgePublicationPipeline(store),
        compiled,
      );
      final next = _variant(compiled, knowledgeVersion: '0.6.0-failure-test');
      final failing = KnowledgePublicationPipeline(
        store,
        faultInjector: (checkpoint) {
          if (checkpoint == PublicationCheckpoint.currentBackedUp) {
            throw StateError('simulated process termination');
          }
        },
      );

      expect(() => _publishAccepted(failing, next), throwsStateError);

      final recovered = KnowledgePublicationPipeline(store).current();
      expect(recovered.contentDigest, stable.contentDigest);
    });

    test('rollback atomically selects the previous immutable publication', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final first = _publishAccepted(pipeline, compiled);
      final second = _publishAccepted(
        pipeline,
        _variant(compiled, knowledgeVersion: '0.6.0-next'),
      );
      expect(second.contentDigest, isNot(first.contentDigest));

      final rolledBack = pipeline.rollback();

      expect(rolledBack.contentDigest, first.contentDigest);
      expect(pipeline.current().contentDigest, first.contentDigest);
    });

    test('corrupted current pointer falls back to the previous publication',
        () {
      final pipeline = KnowledgePublicationPipeline(store);
      final first = _publishAccepted(pipeline, compiled);
      _publishAccepted(
        pipeline,
        _variant(compiled, knowledgeVersion: '0.6.0-next'),
      );
      File('${store.path}${Platform.pathSeparator}current.json')
          .writeAsStringSync('{"truncated":', flush: true);

      final recovered = pipeline.current();

      expect(recovered.contentDigest, first.contentDigest);
      expect(
        jsonDecode(
          File('${store.path}${Platform.pathSeparator}current.json')
              .readAsStringSync(),
        ),
        isA<Map<String, dynamic>>(),
      );
    });

    test('rejects a modified immutable artifact', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final publication = _publishAccepted(pipeline, compiled);
      final artifact = File(
        '${store.path}${Platform.pathSeparator}'
        '${publication.artifactPath.replaceAll('/', Platform.pathSeparator)}',
      );
      artifact.writeAsStringSync(
        '${artifact.readAsStringSync()}\n',
        flush: true,
      );

      expect(
        pipeline.current,
        throwsA(isA<KnowledgePublicationException>()),
      );
    });

    test('verifyCurrent detects compiler/publication drift', () {
      final pipeline = KnowledgePublicationPipeline(store);
      _publishAccepted(pipeline, compiled);

      expect(
        () => pipeline.verifyCurrent(
          _variant(compiled, knowledgeVersion: '0.6.0-drift'),
        ),
        throwsA(isA<KnowledgePublicationException>()),
      );
    });

    test('quarantines a valid candidate when review is missing', () {
      final pipeline = KnowledgePublicationPipeline(store);

      final result = pipeline.submitCandidate(
        candidateId: 'missing-review',
        compile: () => compiled,
        review: null,
      );

      expect(result.status, PublicationCandidateStatus.quarantined);
      expect(
        result.quarantine!.issues.single.code,
        PublicationValidationCode.reviewMissing,
      );
      expect(pipeline.quarantineRecords('missing-review'), hasLength(1));
      expect(
        pipeline.current,
        throwsA(isA<KnowledgePublicationException>()),
      );
    });

    test('quarantines a rejected review with its reason and decision', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final pack = ExecutableKnowledgePack.fromJsonString(compiled);
      final review = PublicationReviewDecision.create(
        outcome: PublicationReviewOutcome.rejected,
        candidateContentDigest: pack.contentDigest,
        compilerVersion: pack.compilerVersion,
        reviewer: 'Product Owner',
        decidedAt: '2026-07-20T00:00:00.000Z',
        reason: 'Domain evidence is incomplete.',
      );

      final result = pipeline.submitCandidate(
        candidateId: 'rejected-review',
        compile: () => compiled,
        review: review,
      );

      expect(
        result.quarantine!.issues.single.code,
        PublicationValidationCode.reviewRejected,
      );
      expect(result.quarantine!.reviewDecision!.digest, review.digest);
    });

    test('quarantines a review scoped to a different candidate', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final review = PublicationReviewDecision.create(
        outcome: PublicationReviewOutcome.accepted,
        candidateContentDigest: 'different-content-digest',
        compilerVersion:
            ExecutableKnowledgePack.fromJsonString(compiled).compilerVersion,
        reviewer: 'Product Owner',
        decidedAt: '2026-07-20T00:00:00.000Z',
      );

      final result = pipeline.submitCandidate(
        candidateId: 'review-scope-mismatch',
        compile: () => compiled,
        review: review,
      );

      expect(
        result.quarantine!.issues.single.code,
        PublicationValidationCode.reviewScopeMismatch,
      );
    });

    test('quarantines a review scoped to a different release candidate', () {
      final pipeline = KnowledgePublicationPipeline(store);
      final pack = ExecutableKnowledgePack.fromJsonString(compiled);
      final review = PublicationReviewDecision.create(
        outcome: PublicationReviewOutcome.accepted,
        candidateContentDigest: pack.contentDigest,
        compilerVersion: pack.compilerVersion,
        releaseCandidateContentDigest: 'reviewed-rc-digest',
        reviewer: 'Product Owner',
        decidedAt: '2026-07-20T00:00:00.000Z',
      );

      final result = pipeline.submitCandidate(
        candidateId: 'release-candidate-scope-mismatch',
        compile: () => compiled,
        review: review,
        releaseCandidateContentDigest: 'submitted-rc-digest',
      );

      expect(
        result.quarantine!.issues.single.code,
        PublicationValidationCode.reviewScopeMismatch,
      );
    });

    test('quarantines a typed compiler validation failure', () {
      final pipeline = KnowledgePublicationPipeline(store);

      final result = pipeline.submitCandidate(
        candidateId: 'compiler-failure',
        compile: () => throw const ExecutableKnowledgeException(
          'Duplicate knowledge ID.',
        ),
        review: null,
      );

      expect(
        result.quarantine!.issues.single,
        isA<PublicationValidationIssue>()
            .having(
              (issue) => issue.code,
              'code',
              PublicationValidationCode.compilationFailed,
            )
            .having(
              (issue) => issue.phase,
              'phase',
              PublicationValidationPhase.compile,
            ),
      );
    });

    test('creates distinct Publication Records for distinct accepted reviews',
        () {
      final pipeline = KnowledgePublicationPipeline(store);
      final pack = ExecutableKnowledgePack.fromJsonString(compiled);
      final firstReview = _acceptedReview(compiled);
      final first = pipeline.submitCandidate(
        candidateId: 'first-accepted-review',
        compile: () => compiled,
        review: firstReview,
      );
      final secondReview = PublicationReviewDecision.create(
        outcome: PublicationReviewOutcome.accepted,
        candidateContentDigest: pack.contentDigest,
        compilerVersion: pack.compilerVersion,
        reviewer: 'Independent Reviewer',
        decidedAt: '2026-07-21T00:00:00.000Z',
      );
      final second = pipeline.submitCandidate(
        candidateId: 'second-accepted-review',
        compile: () => compiled,
        review: secondReview,
      );

      expect(
          second.publication!.contentDigest, first.publication!.contentDigest);
      expect(second.publication!.digest, isNot(first.publication!.digest));
      expect(second.publication!.reviewDecision.digest, secondReview.digest);
      expect(pipeline.current().digest, second.publication!.digest);
      expect(
        Directory('${store.path}${Platform.pathSeparator}objects')
            .listSync(recursive: true)
            .whereType<File>()
            .where((file) => file.path.endsWith('package.json')),
        hasLength(1),
      );
      expect(
        Directory('${store.path}${Platform.pathSeparator}manifests')
            .listSync()
            .whereType<File>(),
        hasLength(2),
      );
    });

    test('detects tampering in an immutable quarantine record', () {
      final pipeline = KnowledgePublicationPipeline(store);
      pipeline.submitCandidate(
        candidateId: 'tampered-quarantine',
        compile: () => compiled,
        review: null,
      );
      final recordFile = Directory(
        '${store.path}${Platform.pathSeparator}quarantine'
        '${Platform.pathSeparator}tampered-quarantine',
      ).listSync().whereType<File>().single;
      recordFile.writeAsStringSync(
        recordFile
            .readAsStringSync()
            .replaceFirst('reviewMissing', 'reviewRejected'),
        flush: true,
      );

      expect(
        () => pipeline.quarantineRecords('tampered-quarantine'),
        throwsA(isA<KnowledgePublicationException>()),
      );
    });
  });
}

KnowledgePublicationMetadata _publishAccepted(
  KnowledgePublicationPipeline pipeline,
  String compiled,
) {
  final result = pipeline.submitCandidate(
    candidateId: 'accepted-${_contentDigest(compiled).substring(0, 12)}',
    compile: () => compiled,
    review: _acceptedReview(compiled),
  );
  if (result.status != PublicationCandidateStatus.published) {
    throw StateError('Expected an accepted publication candidate.');
  }
  return result.publication!;
}

PublicationReviewDecision _acceptedReview(String compiled) {
  final pack = ExecutableKnowledgePack.fromJsonString(compiled);
  return PublicationReviewDecision.create(
    outcome: PublicationReviewOutcome.accepted,
    candidateContentDigest: pack.contentDigest,
    compilerVersion: pack.compilerVersion,
    reviewer: 'Product Owner',
    decidedAt: '2026-07-20T00:00:00.000Z',
  );
}

String _contentDigest(String compiled) =>
    ExecutableKnowledgePack.fromJsonString(compiled).contentDigest;

String _variant(String compiled, {required String knowledgeVersion}) {
  final payload = Map<String, dynamic>.from(
    jsonDecode(compiled) as Map,
  )
    ..remove('contentDigest')
    ..['knowledgeVersion'] = knowledgeVersion;
  final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  return '${const JsonEncoder.withIndent(' ').convert({
        ...payload,
        'contentDigest': digest,
      })}\n';
}

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
