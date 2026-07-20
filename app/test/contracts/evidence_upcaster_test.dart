import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/contracts/evidence_upcaster.dart';

void main() {
  group('EvidenceUpcasterChain', () {
    test('composes every registered step in deterministic order', () {
      final visited = <String>[];
      final chain = EvidenceUpcasterChain(
        currentVersion: 3,
        steps: [
          _step(0, 1, visited),
          _step(1, 2, visited),
          _step(2, 3, visited),
        ],
      );
      final source = <String, dynamic>{
        'events': [
          {'type': 'legacy'},
        ],
      };

      final result = chain.upcast(source, sourceVersion: 0);

      expect(result['batchSchemaVersion'], 3);
      expect(result['visited'], ['0->1', '1->2', '2->3']);
      expect(visited, ['0->1', '1->2', '2->3']);
      expect(source, {
        'events': [
          {'type': 'legacy'},
        ],
      });
    });

    test('returns a defensive copy when input is already current', () {
      final chain = EvidenceUpcasterChain(currentVersion: 1, steps: const []);
      final source = <String, dynamic>{
        'batchSchemaVersion': 1,
        'nested': {'value': 1},
      };

      final result = chain.upcast(source, sourceVersion: 1);
      (result['nested'] as Map<String, dynamic>)['value'] = 2;

      expect((source['nested'] as Map<String, dynamic>)['value'], 1);
    });

    test('fails when a required intermediate version is missing', () {
      final chain = EvidenceUpcasterChain(
        currentVersion: 3,
        steps: [_step(0, 1, <String>[])],
      );

      expect(
        () => chain.upcast(const {}, sourceVersion: 0),
        throwsA(isA<EvidenceUpcastException>()),
      );
    });

    test('rejects duplicate source versions at registration', () {
      expect(
        () => EvidenceUpcasterChain(
          currentVersion: 2,
          steps: [
            _step(0, 1, <String>[]),
            _step(0, 2, <String>[]),
          ],
        ),
        throwsA(isA<EvidenceUpcastException>()),
      );
    });

    test('rejects future source versions', () {
      final chain = EvidenceUpcasterChain(currentVersion: 1, steps: const []);

      expect(
        () => chain.upcast(
          const {'batchSchemaVersion': 2},
          sourceVersion: 2,
        ),
        throwsA(isA<EvidenceUpcastException>()),
      );
    });

    test('rejects source metadata that contradicts the payload', () {
      final chain = EvidenceUpcasterChain(currentVersion: 1, steps: const []);

      expect(
        () => chain.upcast(
          const {'batchSchemaVersion': 0},
          sourceVersion: 1,
        ),
        throwsA(isA<EvidenceUpcastException>()),
      );
    });

    test('rejects a step that emits an unexpected version', () {
      final chain = EvidenceUpcasterChain(
        currentVersion: 1,
        steps: [
          EvidenceUpcasterStep(
            fromVersion: 0,
            toVersion: 1,
            transform: (source) => {
              ...source,
              'batchSchemaVersion': 99,
            },
          ),
        ],
      );

      expect(
        () => chain.upcast(const {}, sourceVersion: 0),
        throwsA(isA<EvidenceUpcastException>()),
      );
    });
  });
}

EvidenceUpcasterStep _step(
  int from,
  int to,
  List<String> visited,
) =>
    EvidenceUpcasterStep(
      fromVersion: from,
      toVersion: to,
      transform: (source) {
        final marker = '$from->$to';
        visited.add(marker);
        return {
          ...source,
          'batchSchemaVersion': to,
          'visited': [...?source['visited'] as List<dynamic>?, marker],
        };
      },
    );
