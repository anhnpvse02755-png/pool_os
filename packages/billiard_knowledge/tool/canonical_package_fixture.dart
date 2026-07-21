import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';

import 'knowledge_publication.dart';

const canonicalPackageReviewer = 'LR-5 Conformance Reviewer';
const canonicalPackageDecidedAt = '2026-07-21T00:00:00.000Z';

void main(List<String> args) {
  final root = Directory.current.absolute;
  final build = buildCanonicalPackageFixture(root);
  final output = Directory(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}'
    'fixtures${Platform.pathSeparator}lr_5${Platform.pathSeparator}generated',
  )..createSync(recursive: true);
  final check = args.contains('--check');
  for (final entry in build.entries.entries) {
    final file = File('${output.path}${Platform.pathSeparator}${entry.key}');
    if (check) {
      if (!file.existsSync() ||
          file.readAsStringSync().replaceAll('\r\n', '\n') != entry.value) {
        throw StateError('LR-5 artifact drift: ${entry.key}.');
      }
    } else {
      file.writeAsStringSync(entry.value);
    }
  }
  stdout.writeln(
    'LR-5 ${check ? 'Check PASS' : 'fixture generated'}: '
    '${build.proof['manifestDigest']}.',
  );
}

class CanonicalPackageFixtureBuild {
  const CanonicalPackageFixtureBuild(this.entries, this.proof);
  final Map<String, String> entries;
  final Map<String, dynamic> proof;
}

CanonicalPackageFixtureBuild buildCanonicalPackageFixture(Directory root) {
  final packageRoot = Directory(
    '${root.path}${Platform.pathSeparator}test${Platform.pathSeparator}'
    'fixtures${Platform.pathSeparator}lr_4${Platform.pathSeparator}generated',
  );
  final artifact = File(
          '${packageRoot.path}${Platform.pathSeparator}published_candidate.json')
      .readAsStringSync()
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n');
  final rc = Map<String, dynamic>.from(jsonDecode(
    File('${packageRoot.path}${Platform.pathSeparator}release_candidate.json')
        .readAsStringSync(),
  ) as Map);
  final pack = ExecutableKnowledgePack.fromJsonString(artifact);
  final dependencyDigest = sha256
      .convert(utf8.encode(jsonEncode(rc['resolvedDependencies'])))
      .toString();
  final contracts = <String, String>{
    'knowledge.entry.polymorphism': '1.0.0',
    if (pack.entries.any((entry) => entry.dependencies.isNotEmpty))
      'learning.dependencies.direct': '1.0.0',
    if (pack.entries.any((entry) => entry.unlockExpression != null))
      'learning.unlock.all_of': '1.0.0',
  };
  final manifest = CanonicalKnowledgePackageManifest.create(
    packageVersion: '1.0.0',
    pack: pack,
    artifact: artifact,
    releaseCandidateDigest: rc['contentDigest'] as String,
    dependencyManifestDigest: dependencyDigest,
    minimumRuntimeVersion: '0.6.0',
    requiredRuntimeContracts: contracts,
  );
  final store = Directory.systemTemp.createTempSync('pool_os_lr_5_');
  late final KnowledgePublicationMetadata publication;
  try {
    final pipeline = KnowledgePublicationPipeline(store);
    final review = PublicationReviewDecision.create(
      outcome: PublicationReviewOutcome.accepted,
      candidateContentDigest: pack.contentDigest,
      compilerVersion: pack.compilerVersion,
      releaseCandidateContentDigest: rc['contentDigest'] as String,
      reviewer: canonicalPackageReviewer,
      decidedAt: canonicalPackageDecidedAt,
    );
    final result = pipeline.submitCandidate(
      candidateId: 'lr-5-canonical-package-v1',
      compile: () => artifact,
      review: review,
      releaseCandidateContentDigest: rc['contentDigest'] as String,
      packageManifestDigest: manifest.manifestDigest,
      activate: false,
    );
    if (result.publication == null) {
      throw StateError('LR-5 publication failed.');
    }
    publication = result.publication!;
    if (File('${store.path}${Platform.pathSeparator}current.json')
        .existsSync()) {
      throw StateError('LR-5 changed current pointer.');
    }
  } finally {
    store.deleteSync(recursive: true);
  }
  final proof = <String, dynamic>{
    'schemaVersion': 1,
    'status': 'PASS',
    'manifestDigest': manifest.manifestDigest,
    'candidatePackDigest': pack.contentDigest,
    'releaseCandidateDigest': rc['contentDigest'],
    'publicationRecordDigest': publication.digest,
    'publicationReferencesManifest':
        publication.packageManifestDigest == manifest.manifestDigest,
    'publishedCandidatePackage': true,
    'productionActivation': false,
  };
  return CanonicalPackageFixtureBuild(
    {
      'manifest.json': _pretty(manifest.toJson()),
      'package.json': artifact,
      'publication_record.json': _pretty(publication.toJson()),
      'proof.json': _pretty(proof),
    },
    proof,
  );
}

String _pretty(Object value) =>
    '${const JsonEncoder.withIndent('  ').convert(value)}\n';
