import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.parent.path;
  test('M7 manifest freezes six contracts without cycles', () {
    final json = jsonDecode(File('$root/architecture/milestones/m7_freeze/contract_manifest.json').readAsStringSync()) as Map<String, dynamic>;
    expect(json['contractCount'], 6);
    expect(json['publicSymbols'], 18);
    expect(json['dependencyEdges'], 5);
    expect(json['cycles'], 0);
    expect(json['contracts'], hasLength(6));
  });
  test('M7 proof records deterministic protected baseline', () {
    final json = jsonDecode(File('$root/architecture/milestones/m7_freeze/proof_record.json').readAsStringSync()) as Map<String, dynamic>;
    expect(json['status'], 'pass');
    expect(json['canonicalJson'], 'pass');
    expect(json['replay'], 'pass');
    expect(json['protectedM3M6'], 'unchanged');
  });
}
