import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/m5_foundation_freeze.dart';

void main() {
  late Map<String, dynamic> proof;

  setUpAll(() {
    proof = validateM5FoundationFreeze(Directory('..').absolute);
  });

  test('freezes the complete M5 public contract and suite inventory', () {
    expect(proof['contractCount'], 12);
    expect(proof['foundationTestCount'], 11);
    expect(proof['publicSymbolCount'], greaterThan(30));
  });

  test('dependency graph is deterministic and acyclic', () {
    expect(proof['dependencyEdges'], isNotEmpty);
    expect(proof['dependencyCycles'], isEmpty);
    expect(proof['contractSetDigest'], hasLength(64));
  });

  test('version, hidden state, and protected artifact checks pass', () {
    expect(proof['versionBindings'], 'PASS');
    expect(proof['hiddenState'], 'PASS');
    expect(proof['protectedArtifactsChanged'], false);
  });

  test('repeated freeze validation produces the same proof', () {
    expect(validateM5FoundationFreeze(Directory('..').absolute), proof);
  });
}
