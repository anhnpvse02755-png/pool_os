import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final manifest = _json(
      '$workspace/architecture/milestones/m13_freeze/contract_manifest.json');
  final proof =
      _json('$workspace/architecture/milestones/m13_freeze/proof_record.json');

  test('M13 inventory symbols dependencies and cycles are frozen', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final symbols = contracts
        .expand((c) => (c['publicSymbols'] as List).cast<String>())
        .toList();
    final files = contracts.map((c) => c['file'] as String).toSet();
    final edges = contracts.expand((c) => (c['dependencies'] as List)).length;
    expect(manifest['milestone'], 'M13');
    expect(contracts, hasLength(8));
    expect(symbols, hasLength(66));
    expect(symbols.toSet(), hasLength(66));
    expect(edges, 7);
    expect(manifest['contractCount'], 8);
    expect(manifest['publicSymbols'], 66);
    expect(manifest['dependencyEdges'], 7);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(contracts), isFalse);
    for (final contract in contracts) {
      final source = File('$workspace/app/lib/application/${contract['file']}')
          .readAsStringSync();
      for (final symbol in (contract['publicSymbols'] as List).cast<String>()) {
        expect(
            source,
            matches(
                RegExp('(?:abstract interface class|class|enum) $symbol\\b')));
      }
      for (final dependency
          in (contract['dependencies'] as List).cast<String>()) {
        expect(files, contains(dependency));
        expect(source, contains('package:pool_os/application/$dependency'));
      }
    }
  });

  test('normalized hashes versions and contract set digest replay', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final canonical = contracts
        .map((c) => <String, dynamic>{
              'file': c['file'],
              'normalizedSha256': c['normalizedSha256'],
              'version': c['version'],
              'publicSymbols': c['publicSymbols'],
              'dependencies': c['dependencies'],
            })
        .toList();
    expect(_digest(canonical), manifest['contractSetDigest']);
    expect(_digest(canonical), proof['contractSetDigest']);
    for (final contract in contracts) {
      final source = File('$workspace/app/lib/application/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), contract['normalizedSha256']);
      expect(source, matches(RegExp(r'const \w+Version = 1;')));
    }
  });

  test('proof is canonical and runtime shells contain no concrete framework',
      () {
    for (final key in [
      'normalizedSha256Manifest',
      'publicSymbolUniqueness',
      'dependencyGraph',
      'canonicalJson',
      'replay',
      'hiddenMutableState',
      'contractVersions'
    ]) {
      expect(proof[key], 'pass');
    }
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
    for (final contract
        in (manifest['contracts'] as List).cast<Map<String, dynamic>>()) {
      final source = File('$workspace/app/lib/application/${contract['file']}')
          .readAsStringSync();
      for (final forbidden in [
        "import 'dart:io'",
        'package:http',
        'package:flutter',
        'package:provider',
        'runApp(',
        'WidgetsFlutterBinding',
        'GetIt.',
        'static ',
        'late '
      ]) {
        expect(source, isNot(contains(forbidden)));
      }
    }
  });

  test('protected M12 freeze artifacts remain unchanged', () {
    expect(proof['protectedM3M12'], 'unchanged');
    final protected =
        (proof['protectedArtifacts'] as Map).cast<String, String>();
    for (final entry in protected.entries) {
      final source = File('$workspace/architecture/milestones/${entry.key}')
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
  final visiting = <String>{}, visited = <String>{};
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
