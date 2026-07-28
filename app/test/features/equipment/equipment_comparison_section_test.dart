import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_comparison_section.dart';

Cue _cue({
  required int id,
  required int playerId,
  String name = 'Cue',
  bool isActive = true,
}) {
  final now = DateTime(2026, 1, 1);
  return Cue(
    id: id,
    playerId: playerId,
    name: name,
    shaftMaterial: 'Carbon Fiber',
    shaftDiameter: 12.75,
    tipBrand: 'Kamui',
    tipHardness: 'Medium',
    weight: 19.0,
    balance: 'Center',
    joint: 'Uni-Loc',
    isActive: isActive,
    createdAt: now,
    updatedAt: now,
  );
}

EquipmentPerformanceProjection _projection({
  required int playerId,
  required int equipmentId,
  int totalMatches = 10,
  double matchWinRate = 50,
  int totalTrainingSessions = 10,
  double trainingSuccessRate = 50,
  DateTime? lastUsed,
}) {
  return EquipmentPerformanceProjection.create(
    playerId: playerId,
    equipmentId: equipmentId,
    totalMatches: totalMatches,
    matchWinRate: matchWinRate,
    totalTrainingSessions: totalTrainingSessions,
    trainingSuccessRate: trainingSuccessRate,
    recordedDurationSeconds: 0,
    lastUsed: lastUsed,
    sourceDigest: 'digest-$playerId-$equipmentId',
  );
}

EquipmentComparisonEntry _entry({
  required int id,
  required int playerId,
  String name = 'Cue',
  bool isActive = true,
  int totalMatches = 10,
  double matchWinRate = 50,
  int totalTrainingSessions = 10,
  double trainingSuccessRate = 50,
  DateTime? lastUsed = null,
}) {
  return EquipmentComparisonEntry(
    cue: _cue(id: id, playerId: playerId, name: name, isActive: isActive),
    projection: _projection(
      playerId: playerId,
      equipmentId: id,
      totalMatches: totalMatches,
      matchWinRate: matchWinRate,
      totalTrainingSessions: totalTrainingSessions,
      trainingSuccessRate: trainingSuccessRate,
      lastUsed: lastUsed,
    ),
  );
}

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  final now = DateTime(2026, 7, 28, 12);

  group('FEATURE_012 Equipment Comparison', () {
    test('Less than 2 selections → buildComparisonEntries returns null', () {
      final empty = buildComparisonEntries(
        selected: [],
        activePlayerId: 100,
      );
      expect(empty, isNull);
      final one = buildComparisonEntries(
        selected: [_entry(id: 1, playerId: 100)],
        activePlayerId: 100,
      );
      expect(one, isNull);
    });

    test('Exactly 2 selections → returns the two entries', () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100, name: 'A'),
          _entry(id: 2, playerId: 100, name: 'B'),
        ],
        activePlayerId: 100,
      );
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0].cue.name, 'A');
      expect(result[1].cue.name, 'B');
    });

    test('More than 2 selections → capped at 2 (Rule 2)', () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100),
          _entry(id: 2, playerId: 100),
          _entry(id: 3, playerId: 100),
        ],
        activePlayerId: 100,
      );
      expect(result, isNotNull);
      expect(result!.length, 2);
      expect(result[0].cue.id, 1);
      expect(result[1].cue.id, 2);
    });

    test('Output list is unmodifiable', () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100),
          _entry(id: 2, playerId: 100),
        ],
        activePlayerId: 100,
      );
      expect(() => result!.add(_entry(id: 99, playerId: 100)),
          throwsUnsupportedError);
    });

    // PO amendment 2026-07-28 — Rule 8 visibility gate.

    test('Rule 8: Comparison hidden with one selected cue', () {
      final result = buildComparisonEntries(
        selected: [_entry(id: 1, playerId: 100)],
        activePlayerId: 100,
      );
      expect(result, isNull);
    });

    test('Rule 8: Comparison hidden with zero selected cues', () {
      final result = buildComparisonEntries(
        selected: const [],
        activePlayerId: 100,
      );
      expect(result, isNull);
    });

    test('Rule 8: Comparison hidden when one selected cue becomes inactive',
        () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100, isActive: true),
          _entry(id: 2, playerId: 100, isActive: false),
        ],
        activePlayerId: 100,
      );
      expect(result, isNull);
    });

    test(
        'Rule 8: Comparison hidden when one selected cue belongs to a'
        ' different player', () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100, isActive: true),
          _entry(id: 2, playerId: 999, isActive: true),
        ],
        activePlayerId: 100,
      );
      expect(result, isNull);
    });

    test('Rule 8: Comparison hidden when no active player', () {
      final result = buildComparisonEntries(
        selected: [
          _entry(id: 1, playerId: 100, isActive: true),
          _entry(id: 2, playerId: 100, isActive: true),
        ],
        activePlayerId: null,
      );
      expect(result, isNull);
    });

    testWidgets('Empty selection → widget renders hidden (Rule 8)',
        (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonSection(
        selected: const [],
        now: now,
        locale: 'en',
        activePlayerId: 100,
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-hidden')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-section')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-table')),
        findsNothing,
      );
    });

    testWidgets('Two valid selections → table rendered', (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonSection(
        selected: [
          _entry(id: 1, playerId: 100, name: 'Revo'),
          _entry(id: 2, playerId: 100, name: 'Ignite'),
        ],
        activePlayerId: 100,
        now: now,
        locale: 'en',
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-table')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-header-left')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-header-right')),
        findsOneWidget,
      );
      expect(find.text('Revo'), findsOneWidget);
      expect(find.text('Ignite'), findsOneWidget);
    });

    testWidgets('Insufficient data → "Chưa đủ dữ liệu." message rendered',
        (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonSection(
        selected: [
          _entry(id: 1, playerId: 100, totalMatches: 2),
          _entry(id: 2, playerId: 100, totalMatches: 2),
        ],
        activePlayerId: 100,
        now: now,
        locale: 'en',
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-insufficient')),
        findsOneWidget,
      );
      expect(find.text('Chưa đủ dữ liệu.'), findsOneWidget);
    });

    testWidgets('No winner highlight in DOM (no colour coding in widget)',
        (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonSection(
        selected: [
          _entry(id: 1, playerId: 100, matchWinRate: 80),
          _entry(id: 2, playerId: 100, matchWinRate: 30),
        ],
        activePlayerId: 100,
        now: now,
        locale: 'en',
      )));
      // Spec Rule 6: no green/red winner. Verify at least one cell exists
      // per side and there is no recommendation widget key from FEATURE_010.
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-left-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-right-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-recommendation-section')),
        findsNothing,
      );
    });

    testWidgets('VI locale renders Vietnamese labels', (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonSection(
        selected: [
          _entry(id: 1, playerId: 100),
          _entry(id: 2, playerId: 100),
        ],
        activePlayerId: 100,
        now: now,
        locale: 'vi',
      )));
      expect(find.text('Tỷ lệ thắng'), findsOneWidget);
      expect(find.text('Trận'), findsOneWidget);
      expect(find.text('Buổi tập'), findsOneWidget);
    });
  });
}
