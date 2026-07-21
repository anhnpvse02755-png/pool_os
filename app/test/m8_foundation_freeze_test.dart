import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workspace = Directory.current.parent.path;
  final manifestFile = File(
      '$workspace/architecture/milestones/m8_freeze/contract_manifest.json');
  final proofFile =
      File('$workspace/architecture/milestones/m8_freeze/proof_record.json');

  test('M8 manifest freezes six contracts with unique symbols and no cycles',
      () {
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    expect(manifest['contractCount'], 6);
    expect(manifest['publicSymbols'], 22);
    expect(manifest['dependencyEdges'], 7);
    expect(manifest['cycles'], 0);
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    final symbols = contracts
        .expand(
            (contract) => (contract['publicSymbols'] as List).cast<String>())
        .toList();
    expect(contracts, hasLength(6));
    expect(symbols.toSet(), hasLength(22));
    for (final contract in contracts) {
      expect(
          File('$workspace/app/lib/contracts/${contract['file']}').existsSync(),
          isTrue);
    }
  });

  test('M8 normalized contract hashes and versions are stable', () {
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    for (final contract in contracts) {
      final normalized =
          File('$workspace/app/lib/contracts/${contract['file']}')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');
      expect(sha256.convert(utf8.encode(normalized)).toString(),
          contract['normalizedSha256']);
      expect(normalized, contains('ContractVersion'));
    }
  });

  test('M8 proof records canonical replay and protected baseline', () {
    final proof =
        jsonDecode(proofFile.readAsStringSync()) as Map<String, dynamic>;
    expect(proof['status'], 'pass');
    expect(proof['normalizedSha256Manifest'], 'pass');
    expect(proof['publicSymbolUniqueness'], 'pass');
    expect(proof['dependencyGraph'], 'pass');
    expect(proof['canonicalJson'], 'pass');
    expect(proof['replay'], 'pass');
    expect(proof['hiddenMutableState'], 'pass');
    expect(proof['contractVersions'], 'pass');
    expect(proof['protectedM3M7'], 'unchanged');
  });

  test('M8 contracts contain no runtime or mutable execution mechanisms', () {
    final manifest =
        jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
    final contracts =
        (manifest['contracts'] as List).cast<Map<String, dynamic>>();
    for (final contract in contracts) {
      final source = File('$workspace/app/lib/contracts/${contract['file']}')
          .readAsStringSync();
      expect(source, isNot(contains('Future<')));
      expect(source, isNot(contains('Timer')));
      expect(source, isNot(contains('http')));
      expect(source, isNot(contains('static ')));
      expect(source, isNot(contains('late ')));
    }
  });
}
