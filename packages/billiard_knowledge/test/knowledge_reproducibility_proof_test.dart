import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/knowledge_reproducibility_proof.dart';

void main() {
  final packageRoot = Directory.current.absolute;

  group('M2.4 reproducibility proof', () {
    test('reproduces M2.3 identity and publication semantics', () {
      final proof = verifyM24Reproducibility(packageRoot);

      expect(proof['status'], 'PASS');
      expect(
        proof['releaseCandidateDigest'],
        expectedM23ReleaseCandidateDigest,
      );
      expect(proof['candidatePackDigest'], expectedM23CandidatePackDigest);
      expect(proof['candidateRuntimeLoad'], 'PASS');
      expect(proof['productionCurrentUnchanged'], 'PASS');
      expect(proof['productionActivation'], isFalse);
    });

    test('rejects RC or Candidate Pack identity drift', () {
      expect(
        () => verifyM24Reproducibility(
          packageRoot,
          expectedReleaseCandidate: 'wrong-rc-digest',
        ),
        throwsA(isA<M24ReproducibilityException>()),
      );
      expect(
        () => verifyM24Reproducibility(
          packageRoot,
          expectedCandidatePack: 'wrong-candidate-digest',
        ),
        throwsA(isA<M24ReproducibilityException>()),
      );
    });

    test('rejects production pointer or publication semantics drift', () {
      expect(
        () => verifyM24Reproducibility(
          packageRoot,
          expectedCurrentPointer: 'wrong-current-digest',
        ),
        throwsA(isA<M24ReproducibilityException>()),
      );

      final drifted = Map<String, dynamic>.from(
        expectedPublicationSemantics,
      )..['knowledgeVersion'] = 'unexpected';
      expect(
        () => verifyPublicationSemantics(
          drifted,
          expectedPublicationSemantics,
        ),
        throwsA(isA<M24ReproducibilityException>()),
      );
    });
  });
}
