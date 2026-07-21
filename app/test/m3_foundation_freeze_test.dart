import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/m3_foundation_freeze.dart';

void main() {
  late Directory repositoryRoot;
  late M3FoundationFreezeResult result;

  setUpAll(() {
    repositoryRoot = Directory('..').absolute;
    result = validateM3FoundationFreeze(repositoryRoot);
  });

  test('freezes every public M3 contract by normalized content digest', () {
    expect(result.contractCount, 14);
    expect(result.publicSymbolCount, greaterThan(40));
    expect(result.manifestDigest, hasLength(64));
    expect(result.contractSetDigest, hasLength(64));
  });

  test('freezes the complete M3.1-M3.13 foundation suite inventory', () {
    expect(result.foundationTestCount, 13);
  });

  test('frozen contract dependency graph is deterministic and acyclic', () {
    final repeated = validateM3FoundationFreeze(repositoryRoot);
    expect(repeated.dependencyEdges, result.dependencyEdges);
    expect(repeated.toJson(), result.toJson());
  });

  test('freeze proof records no forbidden imports or live AI integration', () {
    expect(result.toJson()['forbiddenImports'], 'PASS');
    expect(result.toJson()['duplicatePublicSymbols'], 'PASS');
    expect(result.toJson()['deterministicStubBoundary'], 'PASS');
    expect(result.toJson()['dependencyCycles'], isEmpty);
  });
}
