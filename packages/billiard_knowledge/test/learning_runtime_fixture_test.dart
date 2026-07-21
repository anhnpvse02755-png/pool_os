import 'dart:io';

import 'package:billiard_knowledge/billiard_knowledge.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/learning_runtime_fixture.dart';

void main() {
  final packageRoot = Directory.current.absolute;

  group('LR-1 published candidate fixture', () {
    test('compiles, receives scoped reviews, and publishes in isolation', () {
      final build = buildLearningRuntimeFixture(packageRoot);
      final pack = ExecutableKnowledgePack.fromJsonString(
        build.artifacts['published_candidate.json']!,
      );

      expect(build.proof['status'], 'PASS');
      expect(build.proof['entryReviews'], 'accepted');
      expect(build.proof['isolatedCandidatePublication'], 'PASS');
      expect(build.proof['productionActivation'], isFalse);
      expect(pack.entries, hasLength(5));
      expect(
        (pack.byId('technique.bank_shot')!.payload as TechniquePayload)
            .masteryCategory,
        MasteryCategory.advanced,
      );
    });

    test('source order cannot change RC, candidate pack, or proof', () {
      final normal = buildLearningRuntimeFixture(packageRoot);
      final reversed = buildLearningRuntimeFixture(
        packageRoot,
        reverseSourceOrder: true,
      );

      expect(reversed.artifacts, normal.artifacts);
      expect(reversed.proof, normal.proof);
    });
  });
}
