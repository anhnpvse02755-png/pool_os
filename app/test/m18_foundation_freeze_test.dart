import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final milestoneRoot = '$workspace/architecture/milestones';
  final manifest = _json('$milestoneRoot/m18_freeze/contract_manifest.json');
  final proof = _json('$milestoneRoot/m18_freeze/proof_record.json');

  test('M18 planning inventory, sections, status, and dependencies are frozen',
      () {
    final artifacts =
        (manifest['artifacts'] as List).cast<Map<String, dynamic>>();
    final files =
        artifacts.map((artifact) => artifact['file'] as String).toSet();
    final sections = artifacts
        .expand(
            (artifact) => (artifact['requiredSections'] as List).cast<String>())
        .toList();
    final edges =
        artifacts.expand((artifact) => artifact['dependencies'] as List).length;

    expect(manifest['milestone'], 'M18');
    expect(manifest['sourceRoot'], 'architecture/milestones');
    expect(artifacts, hasLength(8));
    expect(files, hasLength(8));
    expect(sections, hasLength(40));
    expect(edges, 24);
    expect(manifest['artifactCount'], 8);
    expect(manifest['requiredSections'], 40);
    expect(manifest['dependencyEdges'], 24);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(artifacts), isFalse);

    for (final artifact in artifacts) {
      final source = File('$milestoneRoot/${artifact['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(source, contains('**Status:** Accepted; Closed'));
      expect(artifact['status'], 'Accepted; Closed');
      for (final section
          in (artifact['requiredSections'] as List).cast<String>()) {
        expect(source, contains('## $section'));
      }
      for (final dependency
          in (artifact['dependencies'] as List).cast<String>()) {
        expect(files, contains(dependency));
      }
    }
  });

  test('normalized hashes and canonical artifact set digest replay', () {
    final artifacts =
        (manifest['artifacts'] as List).cast<Map<String, dynamic>>();
    final canonical = artifacts
        .map((artifact) => <String, dynamic>{
              'file': artifact['file'],
              'normalizedSha256': artifact['normalizedSha256'],
              'status': artifact['status'],
              'requiredSections': artifact['requiredSections'],
              'dependencies': artifact['dependencies'],
            })
        .toList();
    expect(_digest(canonical), manifest['artifactSetDigest']);
    expect(_digest(canonical), proof['artifactSetDigest']);
    for (final artifact in artifacts) {
      final source = File('$milestoneRoot/${artifact['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), artifact['normalizedSha256']);
    }
  });

  test('M18 freeze proof is canonical and deterministic', () {
    for (final key in [
      'normalizedSha256Manifest',
      'requiredSectionInventory',
      'acceptedStatus',
      'dependencyGraph',
      'canonicalJson',
      'replay',
      'acceptedM18',
    ]) {
      expect(proof[key], 'pass');
    }
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
  });

  test('accepted M17 freeze and transitive M3-M17 chain remain unchanged', () {
    expect(proof['protectedM3M17'], 'unchanged');
    final protected =
        (proof['protectedArtifacts'] as Map).cast<String, String>();
    expect(protected, hasLength(2));
    for (final entry in protected.entries) {
      final source = File('$milestoneRoot/${entry.key}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), entry.value);
    }
  });
}

Map<String, dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

String _digest(Object value) => sha256
    .convert(utf8.encode(value is String ? value : jsonEncode(value)))
    .toString();

bool _hasCycle(List<Map<String, dynamic>> artifacts) {
  final graph = {
    for (final artifact in artifacts)
      artifact['file'] as String:
          (artifact['dependencies'] as List).cast<String>(),
  };
  final visiting = <String>{};
  final visited = <String>{};

  bool visit(String node) {
    if (visiting.contains(node)) return true;
    if (!visited.add(node)) return false;
    visiting.add(node);
    for (final dependency in graph[node] ?? const <String>[]) {
      if (visit(dependency)) return true;
    }
    visiting.remove(node);
    return false;
  }

  return graph.keys.any(visit);
}
