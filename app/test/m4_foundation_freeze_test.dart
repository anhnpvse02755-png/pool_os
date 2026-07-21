import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> manifest;
  late Directory repository;

  setUpAll(() {
    repository = Directory.current.parent;
    manifest = jsonDecode(File(
      '${repository.path}/architecture/milestones/m4_freeze/contract_manifest.json',
    ).readAsStringSync()) as Map<String, dynamic>;
  });

  test('M4 contract hashes and contract-set digest match the manifest', () {
    final unsigned = Map<String, dynamic>.from(manifest)
      ..['manifestDigest'] = '';
    expect(
      sha256.convert(utf8.encode(jsonEncode(unsigned))).toString(),
      manifest['manifestDigest'],
    );
    final contracts =
        (manifest['contractFiles'] as List).cast<Map<String, dynamic>>();
    final bindings = <String>[];
    for (final contract in contracts) {
      final path = contract['path'] as String;
      final normalized = File('${repository.path}/$path')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      final digest = sha256.convert(utf8.encode(normalized)).toString();
      expect(digest, contract['sha256'], reason: path);
      bindings.add('$path:$digest');
    }
    bindings.sort();
    expect(
      sha256.convert(utf8.encode(bindings.join('\n'))).toString(),
      '54629ce61fd50b31b8f8d628292bac4768cc0700bdfca90f91dfc9ce4546f79e',
    );
  });

  test('M4 public symbols are unique and version bindings are present', () {
    final contracts =
        (manifest['contractFiles'] as List).cast<Map<String, dynamic>>();
    final symbols = <String>[];
    final pattern = RegExp(r'^(?:abstract )?(?:class|enum|typedef)\s+(\w+)',
        multiLine: true);
    for (final contract in contracts) {
      expect((contract['versions'] as Map).isNotEmpty, isTrue);
      final source =
          File('${repository.path}/${contract['path']}').readAsStringSync();
      symbols
          .addAll(pattern.allMatches(source).map((match) => match.group(1)!));
    }
    expect(symbols.toSet().length, symbols.length);
  });

  test('M4 dependency graph is acyclic and M3 has no M4 imports', () {
    final edges = (manifest['dependencyEdges'] as List).cast<String>();
    final graph = <String, Set<String>>{};
    for (final edge in edges) {
      final parts = edge.split('->');
      graph.putIfAbsent(parts[0], () => <String>{}).add(parts[1]);
    }
    final visiting = <String>{};
    final visited = <String>{};
    bool cycle(String node) {
      if (visiting.contains(node)) return true;
      if (!visited.add(node)) return false;
      visiting.add(node);
      for (final target in graph[node] ?? const <String>{}) {
        if (cycle(target)) return true;
      }
      visiting.remove(node);
      return false;
    }

    expect(graph.keys.any(cycle), isFalse);

    final m3 = jsonDecode(File(
      '${repository.path}/architecture/milestones/m3_freeze/contract_manifest.json',
    ).readAsStringSync()) as Map<String, dynamic>;
    final m4Names = (manifest['contractFiles'] as List)
        .cast<Map<String, dynamic>>()
        .map((entry) => (entry['path'] as String).split('/').last)
        .toSet();
    for (final entry
        in (m3['contractFiles'] as List).cast<Map<String, dynamic>>()) {
      final source =
          File('${repository.path}/${entry['path']}').readAsStringSync();
      expect(m4Names.any(source.contains), isFalse,
          reason: entry['path'] as String);
    }
  });

  test('M4 inventory contains eight contracts and eight foundation suites', () {
    expect((manifest['contractFiles'] as List).length, 8);
    expect((manifest['foundationTests'] as List).length, 8);
    for (final path in (manifest['foundationTests'] as List).cast<String>()) {
      expect(File('${repository.path}/$path').existsSync(), isTrue,
          reason: path);
    }
    final activation = File(
      '${repository.path}/app/lib/contracts/ai_runtime_activation_gate_contracts.dart',
    ).readAsStringSync();
    expect(activation, isNot(contains('learning_runtime')));
    expect(activation, isNot(contains('provider')));
  });
}
