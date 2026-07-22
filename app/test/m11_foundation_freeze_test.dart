import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final manifestFile = File(
    '$workspace/architecture/milestones/m11_freeze/contract_manifest.json',
  );
  final proofFile =
      File('$workspace/architecture/milestones/m11_freeze/proof_record.json');
  final manifest =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  final proof =
      jsonDecode(proofFile.readAsStringSync()) as Map<String, dynamic>;

  test('M11 inventory, symbols, dependencies, and cycles are frozen', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final symbols = contracts
        .expand(
          (contract) => (contract['publicSymbols'] as List).cast<String>(),
        )
        .toList();
    final files = contracts.map((contract) => contract['file']).toSet();
    final edges = contracts
        .expand(
          (contract) => (contract['dependencies'] as List).map(
            (dependency) => '${contract['file']}->$dependency',
          ),
        )
        .toList();
    expect(manifest['milestone'], 'M11');
    expect(contracts, hasLength(8));
    expect(symbols, hasLength(42));
    expect(symbols.toSet(), hasLength(42));
    expect(files, hasLength(8));
    expect(edges, hasLength(6));
    expect(manifest['contractCount'], 8);
    expect(manifest['publicSymbols'], 42);
    expect(manifest['dependencyEdges'], 6);
    expect(manifest['cycles'], 0);
    expect(_hasCycle(contracts), isFalse);
    for (final contract in contracts) {
      final sourceFile =
          File('$workspace/app/lib/application/${contract['file']}');
      expect(sourceFile.existsSync(), isTrue);
      final source = sourceFile.readAsStringSync();
      for (final symbol in (contract['publicSymbols'] as List).cast<String>()) {
        expect(source, matches(RegExp('(?:class|enum) $symbol\\b')));
      }
      for (final dependency
          in (contract['dependencies'] as List).cast<String>()) {
        expect(files, contains(dependency));
        expect(
          source,
          contains('package:pool_os/application/$dependency'),
        );
      }
    }
  });

  test('normalized source hashes, versions, and set digest replay', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final canonical = contracts
        .map(
          (contract) => <String, dynamic>{
            'file': contract['file'],
            'normalizedSha256': contract['normalizedSha256'],
            'version': contract['version'],
            'publicSymbols': contract['publicSymbols'],
            'dependencies': contract['dependencies'],
          },
        )
        .toList();
    final setDigest = _digest(canonical);
    expect(setDigest, manifest['contractSetDigest']);
    expect(setDigest, proof['contractSetDigest']);
    for (final contract in contracts) {
      final source = File('$workspace/app/lib/application/${contract['file']}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), contract['normalizedSha256']);
      expect(source, matches(RegExp(r'const \w+Version = 1;')));
    }
  });

  test('proof is canonical and records deterministic replay', () {
    expect(proof['status'], 'pass');
    expect(proof['normalizedSha256Manifest'], 'pass');
    expect(proof['publicSymbolUniqueness'], 'pass');
    expect(proof['dependencyGraph'], 'pass');
    expect(proof['canonicalJson'], 'pass');
    expect(proof['replay'], 'pass');
    expect(proof['hiddenMutableState'], 'pass');
    expect(proof['contractVersions'], 'pass');
    expect(jsonEncode(jsonDecode(jsonEncode(manifest))), jsonEncode(manifest));
    expect(jsonEncode(jsonDecode(jsonEncode(proof))), jsonEncode(proof));
  });

  test('frozen M11 foundations have no hidden runtime mechanisms', () {
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    for (final contract in contracts) {
      final source = File('$workspace/app/lib/application/${contract['file']}')
          .readAsStringSync();
      expect(source, isNot(contains('Future<')));
      expect(source, isNot(contains('Timer')));
      expect(source, isNot(contains("import 'dart:io'")));
      expect(source, isNot(contains('package:http')));
      expect(source, isNot(contains('package:flutter')));
      expect(source, isNot(contains('package:provider')));
      expect(source, isNot(contains('static ')));
      expect(source, isNot(contains('late ')));
    }
  });

  test('protected M3-M10 freeze artifacts remain unchanged', () {
    final protected =
        (proof['protectedArtifacts'] as Map).cast<String, String>();
    expect(proof['protectedM3M10'], 'unchanged');
    for (final entry in protected.entries) {
      final source = File('$workspace/architecture/milestones/${entry.key}')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(_digest(source), entry.value);
    }
  });
}

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
