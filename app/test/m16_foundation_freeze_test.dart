import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final milestoneRoot = '$workspace/architecture/milestones';
  final sourceRoot = '$workspace/app/lib/infrastructure/production';
  final manifest = _json('$milestoneRoot/m16_freeze/contract_manifest.json');
  final proof = _json('$milestoneRoot/m16_freeze/proof_record.json');

  test('M16 runtime inventory, symbols, versions, and dependencies are frozen',
      () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final files =
        contracts.map((contract) => contract['file'] as String).toSet();
    final symbols = contracts
        .expand(
            (contract) => (contract['publicSymbols'] as List).cast<String>())
        .toList();
    final edges =
        contracts.expand((contract) => contract['dependencies'] as List).length;

    expect(manifest['milestone'], 'M16');
    expect(manifest['sourceRoot'], 'app/lib/infrastructure/production');
    expect(contracts, hasLength(8));
    expect(files, hasLength(8));
    expect(symbols, hasLength(92));
    expect(symbols.toSet(), hasLength(92));
    expect(edges, 7);
    expect(manifest['contractCount'], 8);
    expect(manifest['publicSymbols'], 92);
    expect(manifest['dependencyEdges'], 7);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(contracts), isFalse);

    for (final contract in contracts) {
      final source = File('$sourceRoot/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(
        source,
        contains(
          'const ${contract['versionMarker']} = ${contract['version']};',
        ),
      );
      for (final symbol in (contract['publicSymbols'] as List).cast<String>()) {
        expect(source, contains(symbol));
      }
      for (final dependency
          in (contract['dependencies'] as List).cast<String>()) {
        expect(files, contains(dependency));
        expect(source, contains(dependency));
      }
    }
  });

  test('normalized hashes and canonical contract set digest replay', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final canonical = contracts
        .map((contract) => <String, dynamic>{
              'file': contract['file'],
              'normalizedSha256': contract['normalizedSha256'],
              'versionMarker': contract['versionMarker'],
              'version': contract['version'],
              'publicSymbols': contract['publicSymbols'],
              'dependencies': contract['dependencies'],
            })
        .toList();
    expect(_digest(canonical), manifest['contractSetDigest']);
    expect(_digest(canonical), proof['contractSetDigest']);
    for (final contract in contracts) {
      final source = File('$sourceRoot/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), contract['normalizedSha256']);
    }
  });

  test('M16 freeze proof is canonical and deterministic', () {
    for (final key in [
      'normalizedSha256Manifest',
      'publicSymbolInventory',
      'versionMarkers',
      'dependencyGraph',
      'canonicalJson',
      'replay',
      'acceptedM16',
    ]) {
      expect(proof[key], 'pass');
    }
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
  });

  test('accepted M15 freeze and transitive M3-M15 chain remain unchanged', () {
    expect(proof['protectedM3M15'], 'unchanged');
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

bool _hasCycle(List<Map<String, dynamic>> contracts) {
  final graph = {
    for (final contract in contracts)
      contract['file'] as String:
          (contract['dependencies'] as List).cast<String>(),
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
