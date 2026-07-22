import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final milestoneRoot = '$workspace/architecture/milestones';
  final manifest = _json('$milestoneRoot/m15_freeze/contract_manifest.json');
  final proof = _json('$milestoneRoot/m15_freeze/proof_record.json');

  test('M15 planning contract inventory and dependencies are frozen', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final files = contracts.map((c) => c['file'] as String).toSet();
    final sections = contracts
        .expand((c) => (c['semanticSections'] as List).cast<String>())
        .toList();
    final symbols = contracts
        .expand((c) => (c['publicSymbols'] as List).cast<String>())
        .toList();
    final edges = contracts.expand((c) => (c['dependencies'] as List)).length;

    expect(manifest['milestone'], 'M15');
    expect(contracts, hasLength(8));
    expect(files, hasLength(8));
    expect(symbols, isEmpty);
    expect(sections, hasLength(121));
    expect(edges, 13);
    expect(manifest['contractCount'], 8);
    expect(manifest['publicSymbols'], 0);
    expect(manifest['semanticSections'], 121);
    expect(manifest['dependencyEdges'], 13);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(contracts), isFalse);

    for (final contract in contracts) {
      final source = File('$milestoneRoot/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(source, contains('**Status:** Accepted; Closed'));
      for (final section
          in (contract['semanticSections'] as List).cast<String>()) {
        expect(source, contains('## $section'));
      }
      for (final dependency
          in (contract['dependencies'] as List).cast<String>()) {
        expect(files, contains(dependency));
      }
    }
  });

  test('normalized hashes and canonical contract set digest replay', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final canonical = contracts
        .map((c) => <String, dynamic>{
              'file': c['file'],
              'normalizedSha256': c['normalizedSha256'],
              'version': c['version'],
              'publicSymbols': c['publicSymbols'],
              'semanticSections': c['semanticSections'],
              'dependencies': c['dependencies'],
            })
        .toList();
    expect(_digest(canonical), manifest['contractSetDigest']);
    expect(_digest(canonical), proof['contractSetDigest']);
    for (final contract in contracts) {
      final source = File('$milestoneRoot/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), contract['normalizedSha256']);
      expect(contract['version'], 1);
    }
  });

  test('M15 freeze proof is canonical and deterministic', () {
    for (final key in [
      'normalizedSha256Manifest',
      'semanticSectionInventory',
      'dependencyGraph',
      'canonicalJson',
      'replay',
      'acceptedStatus'
    ]) {
      expect(proof[key], 'pass');
    }
    expect(proof['publicSymbolInventory'], 'notApplicable');
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
  });

  test('accepted M14 and frozen M3-M13 remain unchanged transitively', () {
    expect(proof['protectedM3M14'], 'unchanged');
    final protected =
        (proof['protectedArtifacts'] as Map).cast<String, String>();
    expect(protected, hasLength(12));
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

bool _hasCycle(List<Map<String, dynamic>> contracts) {
  final graph = {
    for (final c in contracts)
      c['file'] as String: (c['dependencies'] as List).cast<String>()
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
