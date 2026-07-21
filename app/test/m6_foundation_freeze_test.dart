import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final root = Directory.current.parent.path;
  test('M6 freeze manifest has six contracts and no cycles', () {
    final json = jsonDecode(File('$root/architecture/milestones/m6_freeze/contract_manifest.json').readAsStringSync()) as Map<String, dynamic>;
    expect(json['contractCount'], 6);
    expect(json['cycles'], 0);
    expect((json['contracts'] as List), hasLength(6));
  });
  test('M6 machine proof is passing and protected baseline unchanged', () {
    final json = jsonDecode(File('$root/architecture/milestones/m6_freeze/proof_record.json').readAsStringSync()) as Map<String, dynamic>;
    expect(json['status'], 'pass');
    expect(json['protectedM3M5'], 'unchanged');
    expect(json['replay'], 'pass');
  });
}
