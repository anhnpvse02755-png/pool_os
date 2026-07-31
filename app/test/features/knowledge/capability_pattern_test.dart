// EPIC 05 R2 — Capability Pattern tests (replacing the throw-based
// closure with [CapabilityResult.notAvailable]).
//
// PO 2026-07-31 — Pattern follows EPIC 04:
//   Implemented   → CapabilityResult.withValue(value)
//   NotAvailable  → CapabilityResult.notAvailable(reason)
//   Planned       → CapabilityResult.planned(reason)
// No exceptions thrown from capability-closed entry points.

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/knowledge/domain/knowledge_capability.dart';
import 'package:pool_os/features/knowledge/domain/services/recommendation_loader_service.dart';
import 'package:pool_os/features/knowledge/domain/services/recommendation_service.dart';

void main() {
  group('CapabilityResult — discriminant shape', () {
    test('withValue produces an Implemented result', () {
      const r = CapabilityResult<int>.withValue(7);
      expect(r.isImplemented, isTrue);
      expect(r.isNotAvailable, isFalse);
      expect(r.isPlanned, isFalse);
      expect(r.value, 7);
      expect(r.reason, isNull);
    });

    test('notAvailable produces a closed result', () {
      const r = CapabilityResult<int>.notAvailable(
        CapabilityReason(code: 'c1', message: 'm1'),
      );
      expect(r.isImplemented, isFalse);
      expect(r.isNotAvailable, isTrue);
      expect(r.value, isNull);
      expect(r.reason?.code, 'c1');
    });

    test('planned produces a roadmap result', () {
      const r = CapabilityResult<int>.planned(
        CapabilityReason(code: 'p1', message: 'm2'),
      );
      expect(r.isPlanned, isTrue);
    });

    test('getOrThrow throws StateError when not implemented', () {
      const r = CapabilityResult<int>.notAvailable(
        CapabilityReason(code: 'c1', message: 'm1'),
      );
      expect(() => r.getOrThrow(), throwsStateError);
    });

    test('getOrThrow returns value when implemented', () {
      const r = CapabilityResult<int>.withValue(42);
      expect(r.getOrThrow(), 42);
    });
  });

  group('RecommendationCapability — closure constants', () {
    test('unavailable is true', () {
      expect(RecommendationCapability.unavailable, isTrue);
    });

    test('reason code matches the Beta spec', () {
      expect(
        RecommendationCapability.reason.code,
        'recommendation_closed_beta',
      );
      expect(RecommendationCapability.reason.message, contains('Beta'));
    });
  });

  group('RecommendationLoaderService — capability-closed entry points', () {
    final loader = RecommendationLoaderService();

    test('getRecommended returns NotAvailable', () async {
      final r = await loader.getRecommended(null);
      expect(r.isNotAvailable, isTrue);
    });

    test('getRecommendedForSkill returns NotAvailable', () async {
      final r = await loader.getRecommendedForSkill('s1', 'beginner');
      expect(r.isNotAvailable, isTrue);
    });

    test('getRelatedRecommendations returns NotAvailable', () async {
      final r = await loader.getRelatedRecommendations(null);
      expect(r.isNotAvailable, isTrue);
    });

    test('getBasedOnMistakes returns NotAvailable', () async {
      final r = await loader.getBasedOnMistakes(const <String>['m1']);
      expect(r.isNotAvailable, isTrue);
    });

    test('getMetadata returns NotAvailable', () async {
      final r = await loader.getMetadata();
      expect(r.isNotAvailable, isTrue);
    });
  });
}