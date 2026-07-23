import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = '${Directory.current.parent.path}/architecture/milestones';
  final manifest = _json('$root/m22_freeze/contract_manifest.json');
  final proof = _json('$root/m22_freeze/proof_record.json');

  test('M22 accepted planning inventory sections and graph are frozen', () {
    final artifacts =
        (manifest['artifacts'] as List).cast<Map<String, dynamic>>();
    final files = artifacts.map((a) => a['file'] as String).toSet();
    final sections = artifacts
        .expand((a) => (a['requiredSections'] as List).cast<String>())
        .toList();
    final edges = artifacts.expand((a) => a['dependencies'] as List).length;
    expect(manifest['milestone'], 'M22');
    expect(artifacts, hasLength(8));
    expect(files, hasLength(8));
    expect(sections, hasLength(40));
    expect(edges, 17);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(artifacts), isFalse);
    for (final artifact in artifacts) {
      final source = File('$root/${artifact['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(source, contains('**Status:** Accepted; Closed'));
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

  test('normalized hashes and artifact set digest replay', () {
    final artifacts =
        (manifest['artifacts'] as List).cast<Map<String, dynamic>>();
    final canonical = artifacts
        .map((a) => <String, dynamic>{
              'file': a['file'],
              'normalizedSha256': a['normalizedSha256'],
              'status': a['status'],
              'requiredSections': a['requiredSections'],
              'dependencies': a['dependencies'],
            })
        .toList();
    expect(_digest(canonical), manifest['artifactSetDigest']);
    expect(_digest(canonical), proof['artifactSetDigest']);
    for (final artifact in artifacts) {
      final source = File('$root/${artifact['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), artifact['normalizedSha256']);
    }
  });

  test('M22 proof is canonical and records replay metadata', () {
    for (final key in [
      'normalizedSha256Manifest',
      'requiredSectionInventory',
      'acceptedStatus',
      'dependencyGraph',
      'canonicalJson',
      'replay',
      'acceptedM22'
    ]) {
      expect(proof[key], 'pass');
    }
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
  });

  test('M21 freeze and transitive M3-M21 chain remain unchanged', () {
    expect(proof['protectedM3M21'], 'unchanged');
    final protected =
        (proof['protectedArtifacts'] as Map).cast<String, String>();
    expect(protected, hasLength(2));
    for (final entry in protected.entries) {
      final source = File('$root/${entry.key}')
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
    for (final a in artifacts)
      a['file'] as String: (a['dependencies'] as List).cast<String>()
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
