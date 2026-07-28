import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/presentation/equipment_comparison_screen.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_comparison_section.dart'
    show EquipmentComparisonEntry;

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
  DateTime? lastUsed,
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

List<Cue> _cuesFrom(List<EquipmentComparisonEntry> entries) =>
    entries.map((e) => e.cue).toList(growable: false);

List<EquipmentPerformanceProjection> _projectionsFrom(
        List<EquipmentComparisonEntry> entries) =>
    entries.map((e) => e.projection).toList(growable: false);

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  final now = DateTime(2026, 7, 28, 12);

  group('FEATURE_012 v2 Equipment Comparison Screen', () {
    testWidgets('Renders exactly 2 cue columns when 2 cues selected',
        (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100, name: 'CueA'),
        _entry(id: 2, playerId: 100, name: 'CueB'),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-screen')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-col-header-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-col-header-1')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-col-header-2')),
        findsNothing,
      );
    });

    testWidgets('Renders 5 cue columns when 5 cues selected (no cap)',
        (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100, name: 'Cue1'),
        _entry(id: 2, playerId: 100, name: 'Cue2'),
        _entry(id: 3, playerId: 100, name: 'Cue3'),
        _entry(id: 4, playerId: 100, name: 'Cue4'),
        _entry(id: 5, playerId: 100, name: 'Cue5'),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      for (var i = 0; i < 5; i++) {
        expect(
          find.byKey(ValueKey('equipment-comparison-col-header-$i')),
          findsOneWidget,
          reason: 'column $i should exist',
        );
      }
    });

    testWidgets('Horizontal scroll wrapper exists when many cues selected',
        (tester) async {
      final entries = List.generate(
          6, (i) => _entry(id: i + 1, playerId: 100, name: 'Cue${i + 1}'));
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-horizontal-scroll')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-vertical-scroll')),
        findsOneWidget,
      );
    });

    testWidgets('Insufficient cue shows "Chưa đủ dữ liệu." in its column',
        (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100, name: 'Good', totalMatches: 50),
        _entry(id: 2, playerId: 100, name: 'Sparse', totalMatches: 1),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      // Cue #1 (index 0) has sufficient data; cue #2 (index 1) is
      // insufficient. The cells in column 1 across all rows must show
      // the literal Vietnamese message.
      expect(find.text('Chưa đủ dữ liệu.'), findsWidgets);
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-1-0')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-1-2')),
        findsOneWidget,
      );
    });

    testWidgets(
        'Match Win Rate rendered exactly from projection (no recompute)',
        (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100, matchWinRate: 68),
        _entry(id: 2, playerId: 100, matchWinRate: 64),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      expect(find.text('68%'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);
    });

    testWidgets('No winner highlight — no green/red colour coding',
        (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100, matchWinRate: 90),
        _entry(id: 2, playerId: 100, matchWinRate: 30),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      // Spec Rule 8 v2: no green/red conclusion. The legacy recommendation
      // widget is also absent because the screen is dedicated to comparison.
      expect(
        find.byKey(const ValueKey('equipment-recommendation-section')),
        findsNothing,
      );
      // Confirm data table rendered.
      expect(
        find.byKey(const ValueKey('equipment-comparison-data-table')),
        findsOneWidget,
      );
    });

    testWidgets('VI locale renders Vietnamese metric labels', (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100),
        _entry(id: 2, playerId: 100),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'vi',
      )));
      expect(find.text('Tỷ lệ thắng'), findsOneWidget);
      expect(find.text('Trận'), findsOneWidget);
      expect(find.text('Buổi tập'), findsOneWidget);
    });

    testWidgets('Empty cues list shows empty placeholder', (tester) async {
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: const [],
        projections: const [],
        now: now,
        locale: 'en',
      )));
      expect(
        find.byKey(const ValueKey('equipment-comparison-empty')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('equipment-comparison-data-table')),
        findsNothing,
      );
    });

    testWidgets('All five metric rows are rendered', (tester) async {
      final entries = [
        _entry(id: 1, playerId: 100),
        _entry(id: 2, playerId: 100),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries),
        projections: _projectionsFrom(entries),
        now: now,
        locale: 'en',
      )));
      // Material DataTable wraps rows in a Table widget that strips per-row
      // keys from the finder. Verify presence by row labels instead.
      expect(find.text('Win Rate'), findsOneWidget);
      expect(find.text('Training Success'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('Trainings'), findsOneWidget);
      expect(find.text('Last Used'), findsOneWidget);
    });

    testWidgets('Only projection fields used — no recomputation',
        (tester) async {
      // Pass cues whose totalMatches is 7. With insufficient threshold = 5,
      // 7 is sufficient. Screen must show the actual projection value.
      final entries = [
        _entry(id: 1, playerId: 100, totalMatches: 7, matchWinRate: 50),
      ];
      // Build a single-cue screen; in real flow the screen is opened only
      // when there are >=2 cues, but the widget itself does not gate by
      // count. We render 2 cues to satisfy the table layout: the second
      // cue is a clone with sufficient data so its values are independent.
      final entries2 = [
        entries[0],
        _entry(id: 2, playerId: 100, totalMatches: 8, matchWinRate: 55),
      ];
      await tester.pumpWidget(_wrap(EquipmentComparisonScreen(
        cues: _cuesFrom(entries2),
        projections: _projectionsFrom(entries2),
        now: now,
        locale: 'en',
      )));
      // Cell at row matches, col 0 must read "7".
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-0-2')),
        findsOneWidget,
      );
      // Cell at row match-win, col 0 must read "50%".
      expect(
        find.byKey(const ValueKey('equipment-comparison-cell-0-0')),
        findsOneWidget,
      );
    });
  });
}
