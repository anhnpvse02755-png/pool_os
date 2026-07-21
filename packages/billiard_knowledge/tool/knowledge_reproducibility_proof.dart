import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

import 'knowledge_migration_v1_4.dart';
import 'knowledge_publication.dart';

const expectedM23ReleaseCandidateDigest =
    'fbe07edcaa9db94326db2d204ac2a9753d50ea32163a52995cd875251fba26ac';
const expectedM23CandidatePackDigest =
    '22f60cdcaab064c07f1feaf600d9f9f9ea2b892db23fcc490304c9024e4e5e02';
const expectedProductionCurrentPointerDigest =
    '0e757d4af0eca29fd085ab0c0c5b806415b63dd651bd3000ab23023eb158c8ba';

void main(List<String> args) {
  final packageRoot = Directory.current.absolute;
  final output = _outputFile(args, packageRoot);
  try {
    final proof = verifyM24Reproducibility(packageRoot);
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(_pretty(proof));
    stdout.writeln(
      'M2.4 Reproducibility PASS: '
      '${proof['releaseCandidateDigest']} / '
      '${proof['candidatePackDigest']}.',
    );
    stdout.writeln('Proof report -> ${output.path}');
  } on M24ReproducibilityException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

class M24ReproducibilityException implements Exception {
  const M24ReproducibilityException(this.message);

  final String message;

  @override
  String toString() => 'M24ReproducibilityException: $message';
}

Map<String, dynamic> verifyM24Reproducibility(
  Directory packageRoot, {
  String expectedReleaseCandidate = expectedM23ReleaseCandidateDigest,
  String expectedCandidatePack = expectedM23CandidatePackDigest,
  String expectedCurrentPointer = expectedProductionCurrentPointerDigest,
}) {
  final currentFile = File(
    _joinMany(packageRoot.path, ['publication', 'current.json']),
  );
  final currentBefore = _fileDigest(currentFile);
  if (currentBefore != expectedCurrentPointer) {
    throw M24ReproducibilityException(
      'Production current pointer drift: $currentBefore.',
    );
  }

  final build = buildM23Migration(packageRoot);
  final rcDigest = '${build.report['releaseCandidateDigest']}';
  final candidateDigest = '${build.report['candidatePackDigest']}';
  if (rcDigest != expectedReleaseCandidate) {
    throw M24ReproducibilityException(
      'RC Content Digest drift: $rcDigest.',
    );
  }
  if (candidateDigest != expectedCandidatePack) {
    throw M24ReproducibilityException(
      'Candidate Pack Digest drift: $candidateDigest.',
    );
  }

  _verifyCommittedArtifact(
    packageRoot,
    'release_candidate.json',
    build.artifacts['release_candidate.json']!,
  );
  _verifyCommittedArtifact(
    packageRoot,
    'candidate_pack.json',
    build.artifacts['candidate_pack.json']!,
  );
  _verifyCommittedArtifact(
    packageRoot,
    'publication_review.json',
    build.artifacts['publication_review.json']!,
  );

  final candidatePack = build.artifacts['candidate_pack.json']!;
  final identity = readM23KnowledgeArtifact(candidatePack);
  if (identity.contentDigest != candidateDigest ||
      identity.compilerVersion != migrationCompilerVersion ||
      identity.knowledgeVersion != migrationKnowledgeVersion) {
    throw const M24ReproducibilityException(
      'Candidate runtime identity does not match M2.3.',
    );
  }

  final review = PublicationReviewDecision.fromJson(
    jsonDecode(build.artifacts['publication_review.json']!)
        as Map<String, dynamic>,
  );
  final store = Directory.systemTemp.createTempSync('pool_os_m2_4_publish_');
  late final KnowledgePublicationMetadata publication;
  try {
    final pipeline = KnowledgePublicationPipeline(
      store,
      artifactReader: readM23KnowledgeArtifact,
    );
    final result = pipeline.submitCandidate(
      candidateId: 'm2-4-reproducibility-proof',
      compile: () => candidatePack,
      review: review,
      releaseCandidateContentDigest: rcDigest,
    );
    if (result.status != PublicationCandidateStatus.published ||
        result.publication == null) {
      throw const M24ReproducibilityException(
        'Reviewed candidate did not pass isolated publication.',
      );
    }
    publication = result.publication!;
    if (pipeline.current().digest != publication.digest) {
      throw const M24ReproducibilityException(
        'Isolated publication pointer does not resolve to its record.',
      );
    }
  } finally {
    if (store.existsSync()) store.deleteSync(recursive: true);
  }

  final semantics = publicationSemantics(publication);
  verifyPublicationSemantics(semantics, expectedPublicationSemantics);

  final currentAfter = _fileDigest(currentFile);
  if (currentAfter != currentBefore) {
    throw const M24ReproducibilityException(
      'M2.4 changed the production current pointer.',
    );
  }

  return {
    'schemaVersion': 1,
    'milestone': 'M2.4',
    'status': 'PASS',
    'releaseCandidateDigest': rcDigest,
    'candidatePackDigest': candidateDigest,
    'publicationSemantics': semantics,
    'candidateRuntimeLoad': 'PASS',
    'productionCurrentPointer': currentAfter,
    'productionCurrentUnchanged': 'PASS',
    'productionActivation': false,
  };
}

const expectedPublicationSemantics = <String, dynamic>{
  'schemaVersion': publicationSchemaVersion,
  'compilerVersion': migrationCompilerVersion,
  'knowledgeVersion': migrationKnowledgeVersion,
  'contentDigest': expectedM23CandidatePackDigest,
  'artifactPath': 'objects/$expectedM23CandidatePackDigest/package.json',
  'releaseCandidateContentDigest': expectedM23ReleaseCandidateDigest,
  'reviewOutcome': 'accepted',
  'reviewCandidateContentDigest': expectedM23CandidatePackDigest,
  'reviewCompilerVersion': migrationCompilerVersion,
  'reviewReleaseCandidateContentDigest': expectedM23ReleaseCandidateDigest,
};

Map<String, dynamic> publicationSemantics(
  KnowledgePublicationMetadata publication,
) =>
    {
      'schemaVersion': publicationSchemaVersion,
      'compilerVersion': publication.compilerVersion,
      'knowledgeVersion': publication.knowledgeVersion,
      'contentDigest': publication.contentDigest,
      'artifactPath': publication.artifactPath,
      'releaseCandidateContentDigest':
          publication.releaseCandidateContentDigest,
      'reviewOutcome': publication.reviewDecision.outcome.name,
      'reviewCandidateContentDigest':
          publication.reviewDecision.candidateContentDigest,
      'reviewCompilerVersion': publication.reviewDecision.compilerVersion,
      'reviewReleaseCandidateContentDigest':
          publication.reviewDecision.releaseCandidateContentDigest,
    };

void verifyPublicationSemantics(
  Map<String, dynamic> actual,
  Map<String, dynamic> expected,
) {
  if (jsonEncode(actual) != jsonEncode(expected)) {
    throw M24ReproducibilityException(
      'Publication semantics drift. Expected ${jsonEncode(expected)}, '
      'found ${jsonEncode(actual)}.',
    );
  }
}

void _verifyCommittedArtifact(
  Directory packageRoot,
  String name,
  String expected,
) {
  final file = File(
    _joinMany(packageRoot.path, ['migration', 'm2_3', name]),
  );
  if (!file.existsSync() ||
      _normalizeNewlines(file.readAsStringSync()) != expected) {
    throw M24ReproducibilityException(
      'Committed M2.3 artifact drift: $name.',
    );
  }
}

File _outputFile(List<String> args, Directory packageRoot) {
  final index = args.indexOf('--output');
  if (index < 0) {
    return File(
      _joinMany(packageRoot.path, ['build', 'm2_4', 'proof.json']),
    );
  }
  if (index + 1 >= args.length) {
    throw const M24ReproducibilityException(
      '--output requires a file path.',
    );
  }
  return File(args[index + 1]).absolute;
}

String _fileDigest(File file) => sha256
    .convert(utf8.encode(_normalizeNewlines(file.readAsStringSync())))
    .toString();

String _normalizeNewlines(String value) =>
    value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

String _pretty(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';

String _join(String first, String second) =>
    '$first${Platform.pathSeparator}$second';

String _joinMany(String first, Iterable<String> rest) =>
    rest.fold(first, (path, segment) => _join(path, segment));
