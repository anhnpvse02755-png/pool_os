import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/learning_dependency_fixture.dart';

void main() {
  final packageRoot = Directory.current.absolute;

  group('LR-2 dependency-aware learning fixture', () {
    test('compiles typed dependencies and publishes in isolation', () {
      final build = buildLearningDependencyFixture(packageRoot);
      final pack = ExecutableKnowledgePack.fromJsonString(
        build.artifacts['published_candidate.json']!,
      );

      expect(build.proof['status'], 'PASS');
      expect(build.proof['directDependencyCount'], 4);
      expect(build.proof['isolatedCandidatePublication'], 'PASS');
      expect(build.proof['productionActivation'], isFalse);
      expect(pack.entries, hasLength(4));
      expect(
        pack.byId('technique.stop_control')!.dependencies,
        ['technique.straight_stroke'],
      );
      expect(
        pack.byId('technique.position_control')!.dependencies,
        ['technique.follow_control', 'technique.stop_control'],
      );
    });

    test('hard dependencies remain distinct from semantic relations', () {
      final raw = jsonDecode(
        buildLearningDependencyFixture(
          packageRoot,
        ).artifacts['published_candidate.json']!,
      ) as Map<String, dynamic>;
      final entries = (raw['entries'] as List).cast<Map<String, dynamic>>();
      final position = entries.singleWhere(
        (entry) => entry['id'] == 'technique.position_control',
      );

      expect(position['relations'], [
        'technique.follow_control',
        'technique.stop_control',
      ]);
      expect(position['dependencies'], [
        'technique.follow_control',
        'technique.stop_control',
      ]);
    });

    test('source order cannot change RC, candidate pack, or proof', () {
      final normal = buildLearningDependencyFixture(packageRoot);
      final reversed = buildLearningDependencyFixture(
        packageRoot,
        reverseSourceOrder: true,
      );

      expect(reversed.artifacts, normal.artifacts);
      expect(reversed.proof, normal.proof);
    });

    test('runtime loader defensively rejects dangling and cyclic graphs', () {
      final compiled = buildLearningDependencyFixture(
        packageRoot,
      ).artifacts['published_candidate.json']!;

      expect(
        () => ExecutableKnowledgePack.fromJsonString(
          _mutate(compiled, (entries) {
            entries.firstWhere(
              (entry) => entry['id'] == 'technique.stop_control',
            )['dependencies'] = ['technique.missing'];
          }),
        ),
        throwsA(
          isA<ExecutableKnowledgeException>().having(
            (error) => error.message,
            'message',
            contains('Dangling dependency'),
          ),
        ),
      );

      expect(
        () => ExecutableKnowledgePack.fromJsonString(
          _mutate(compiled, (entries) {
            entries.firstWhere(
              (entry) => entry['id'] == 'technique.straight_stroke',
            )['dependencies'] = ['technique.stop_control'];
          }),
        ),
        throwsA(
          isA<ExecutableKnowledgeException>().having(
            (error) => error.message,
            'message',
            contains('Dependency cycle'),
          ),
        ),
      );
    });
  });
}

String _mutate(
  String compiled,
  void Function(List<Map<String, dynamic>> entries) mutate,
) {
  final payload = Map<String, dynamic>.from(
    jsonDecode(compiled) as Map,
  )..remove('contentDigest');
  final entries = (payload['entries'] as List)
      .map((entry) => Map<String, dynamic>.from(entry as Map))
      .toList(growable: false);
  payload['entries'] = entries;
  mutate(entries);
  final digest = sha256.convert(utf8.encode(jsonEncode(payload))).toString();
  return jsonEncode({...payload, 'contentDigest': digest});
}
