import 'dart:convert';
import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_compiler_v0.dart' as compiler;
import '../tool/learning_dependency_fixture.dart';
import '../tool/learning_unlock_fixture.dart';

void main() {
  final packageRoot = Directory.current.absolute;

  group('LR-4 Unlock Expression Contract', () {
    test('compiles nested allOf through RC and isolated publication', () {
      final build = buildLearningDependencyFixture(
        packageRoot,
        spec: lr4FixtureSpec,
      );
      final pack = ExecutableKnowledgePack.fromJsonString(
        build.artifacts['published_candidate.json']!,
      );
      final position = pack.byId('technique.position_control')!;

      expect(build.proof['status'], 'PASS');
      expect(build.proof['directDependencyCount'], 3);
      expect(position.unlockExpression, isA<UnlockAllOfExpression>());
      expect(position.unlockExpression!.dependencyIds, [
        'technique.follow_control',
        'technique.stop_control',
        'technique.straight_stroke',
      ]);
      expect(position.dependencies, position.unlockExpression!.dependencyIds);
    });

    test('allOf operand order is canonical', () {
      final normal = compiler.compileKnowledgeEntrySource(
        _source('technique.target', unlockLines: const [
          '  allOf:',
          '    - technique.a',
          '    - technique.b',
        ]),
      );
      final reversed = compiler.compileKnowledgeEntrySource(
        _source('technique.target', unlockLines: const [
          '  allOf:',
          '    - technique.b',
          '    - technique.a',
        ]),
      );

      expect(jsonEncode(reversed.entry), jsonEncode(normal.entry));
      expect(reversed.dependencies, normal.dependencies);
    });

    test('unsupported operators, empty allOf, and mixed declarations fail', () {
      final invalid = [
        _source('technique.or', unlockLines: const [
          '  anyOf:',
          '    - technique.a',
        ]),
        _source('technique.not', unlockLines: const [
          '  not: technique.a',
        ]),
        _source('technique.empty', unlockLines: const [
          '  allOf: []',
        ]),
        _source(
          'technique.mixed',
          relationDependency: 'technique.a',
          unlockLines: const [
            '  allOf:',
            '    - technique.a',
          ],
        ),
      ];

      for (final source in invalid) {
        expect(
          () => compiler.compileKnowledgeEntrySource(source),
          throwsA(isA<ExecutableKnowledgeException>()),
        );
      }
    });

    test('unlock leaves participate in compiler cycle rejection', () {
      final policies = compiler.parseYamlObject(
        File('corpus/mastery_policies.yaml').readAsStringSync(),
      );
      final sources = [
        _source('technique.a', unlockLines: const [
          '  allOf:',
          '    - technique.b',
        ]),
        _source('technique.b', unlockLines: const [
          '  allOf:',
          '    - technique.a',
        ]),
      ];

      expect(
        () => compiler.compileKnowledgeCorpus(
          sources,
          masteryPolicyDocument: policies,
        ),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('[dependencyCycle]'),
          ),
        ),
      );
    });

    test('source order cannot change LR-4 RC, pack, or proof', () {
      final normal = buildLearningDependencyFixture(
        packageRoot,
        spec: lr4FixtureSpec,
      );
      final reversed = buildLearningDependencyFixture(
        packageRoot,
        reverseSourceOrder: true,
        spec: lr4FixtureSpec,
      );

      expect(reversed.artifacts, normal.artifacts);
      expect(reversed.proof, normal.proof);
    });
  });
}

String _source(
  String id, {
  List<String>? unlockLines,
  String? relationDependency,
}) {
  final relations = relationDependency == null
      ? 'relations: []'
      : 'relations:\n  - type: requires\n    targetId: $relationDependency';
  final unlock =
      unlockLines == null ? '' : 'unlock:\n${unlockLines.join('\n')}\n';
  return '''
---
schemaVersion: 1
id: $id
kind: technique
knowledgeVersion: lr-4-test.1.0.0
publishedAt: 2026-07-21T00:00:00.000Z
reviewState: verified
title: $id
summary: LR-4 compiler fixture.
capabilities: [measurable_outcome, mastery_policy]
$relations
$unlock${_payload(id)}
---
LR-4 compiler fixture.
''';
}

String _payload(String id) => '''payload:
  masteryCategory: advanced
  outcome:
    description: Complete the protocol.
    successRadiusCm: 10
    requiredSuccesses: 8
    requiredAttempts: 10
  measurement:
    id: measurement.$id
    drillId: LR4-TEST
    attempts: 10
    successDefinition: Complete the protocol.
  drill:
    id: LR4-TEST
    title: LR-4 Test
    instructions: [Complete ten attempts.]
  nextRecommendation:
    id: status.complete
    title: Complete
    targetType: placeholder''';
