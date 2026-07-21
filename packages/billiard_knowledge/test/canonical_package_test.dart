import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/canonical_package_fixture.dart';

void main() {
  final root = Directory.current.absolute;

  test('Manifest-first load verifies compatibility, artifact, and replay pack',
      () {
    final build = buildCanonicalPackageFixture(root);
    final manifest = build.entries['manifest.json']!;
    final artifact = build.entries['package.json']!;
    final pack = const CanonicalPackageRuntimeLoader(
      RuntimeCompatibility(
        runtimeVersion: '0.6.0',
        supportedContracts: {
          'knowledge.entry.polymorphism': '1.0.0',
          'learning.dependencies.direct': '1.0.0',
          'learning.unlock.all_of': '1.0.0',
        },
      ),
    ).load(manifest, artifact);

    expect(pack.contentDigest, build.proof['candidatePackDigest']);
    expect(build.proof['productionActivation'], isFalse);
  });

  test('Manifest digest ignores Publication Record reviewer and time', () {
    final first = buildCanonicalPackageFixture(root);
    final manifest = CanonicalKnowledgePackageManifest.fromJson(
      jsonDecode(first.entries['manifest.json']!) as Map<String, dynamic>,
    );
    final publication = jsonDecode(first.entries['publication_record.json']!)
        as Map<String, dynamic>;
    final changed = Map<String, dynamic>.from(publication)
      ..['reviewDecision'] = {
        ...Map<String, dynamic>.from(publication['reviewDecision'] as Map),
        'reviewer': 'Another Reviewer',
        'decidedAt': '2026-07-22T00:00:00.000Z',
      };

    expect(
      changed['reviewDecision']['reviewer'],
      isNot(publication['reviewDecision']['reviewer']),
    );
    expect(manifest.manifestDigest, first.proof['manifestDigest']);
  });

  test('older runtime and missing contract fail before artifact load', () {
    final build = buildCanonicalPackageFixture(root);
    expect(
      () => const CanonicalPackageRuntimeLoader(
        RuntimeCompatibility(
          runtimeVersion: '0.5.0',
          supportedContracts: {},
        ),
      ).load(build.entries['manifest.json']!, build.entries['package.json']!),
      throwsA(isA<CanonicalPackageException>()),
    );
  });
}
