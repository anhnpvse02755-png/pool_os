import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/features/equipment/application/equipment_performance_calculator.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/presentation/equipment_provider.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/player/presentation/career_timeline_section.dart';
import 'package:pool_os/features/player/presentation/player_profile_provider.dart';
import 'package:pool_os/features/player/presentation/player_provider.dart';
import 'package:pool_os/features/player_model/application/player_progress_calculator.dart';
import 'package:pool_os/features/player_model/domain/player_progress_projection.dart';
import 'package:pool_os/features/player_model/presentation/player_progress_provider.dart';
import 'package:pool_os/features/statistics/application/statistics_analytics_service.dart';

void main() {
  testWidgets(
    'committed handoff never renders mixed Player identities and failures invalidate nothing',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final players = PlayerRepository(database);
      final equipment = EquipmentRepository(database);
      final first = await players.createPlayer(_player('First'));
      final second = await players.createPlayer(_player('Second'));
      await _seedProjectionData(players, equipment, first);
      await _seedProjectionData(players, equipment, second);

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          careerTimelineProvider.overrideWith((ref) async {
            ref.watch(
              playerNotifierProvider.select((state) => state.revision),
            );
            await Future<void>.delayed(const Duration(milliseconds: 20));
            final playerId = (await players.getActivePlayer())?.id;
            return playerId == null
                ? null
                : CareerTimelineProjection.create(
                    playerId: playerId,
                    sourceDigest: 'career-source-$playerId',
                    events: const [],
                  );
          }),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);
      await container.read(playerNotifierProvider.notifier).loadPlayers();

      final snapshots = <List<int?>>[];
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: _IdentityProbe(snapshots: snapshots)),
        ),
      );
      await _pumpUntilIdentity(tester, first);

      final dashboardBefore = container.read(dashboardProvider.notifier);
      final statisticsBefore =
          container.read(matchStatisticsSnapshotProvider);

      final target = await players.getPlayerById(second);
      final switched =
          container.read(playerNotifierProvider.notifier).selectPlayer(target!);
      await _pumpUntilIdentity(tester, second);
      expect(await switched, isTrue);

      expect(
        identical(dashboardBefore, container.read(dashboardProvider.notifier)),
        isFalse,
      );
      expect(
        identical(
          statisticsBefore,
          container.read(matchStatisticsSnapshotProvider),
        ),
        isFalse,
      );
      expect(
        snapshots.where(
          (snapshot) => snapshot.whereType<int>().toSet().length > 1,
        ),
        isEmpty,
      );

      final dashboardAfter = container.read(dashboardProvider.notifier);
      final statisticsAfter =
          container.read(matchStatisticsSnapshotProvider);
      final failed = await container
          .read(playerNotifierProvider.notifier)
          .selectPlayer(_player('Missing').copyWith(id: 9999));
      await tester.pump();

      expect(failed, isFalse);
      expect(
        identical(dashboardAfter, container.read(dashboardProvider.notifier)),
        isTrue,
      );
      expect(
        identical(
          statisticsAfter,
          container.read(matchStatisticsSnapshotProvider),
        ),
        isTrue,
      );
      expect(find.text(_identityLabel(second)), findsOneWidget);
      expect((await players.getActivePlayer())?.id, second);

      final deleted =
          container.read(playerNotifierProvider.notifier).deletePlayer(second);
      await _pumpUntilIdentity(tester, first);
      expect(await deleted, isTrue);
      expect(
        identical(dashboardAfter, container.read(dashboardProvider.notifier)),
        isFalse,
      );
      expect(
        identical(
          statisticsAfter,
          container.read(matchStatisticsSnapshotProvider),
        ),
        isFalse,
      );
      expect(
        snapshots.where(
          (snapshot) => snapshot.whereType<int>().toSet().length > 1,
        ),
        isEmpty,
      );
      expect((await players.getActivePlayer())?.id, first);
    },
  );
}

class _IdentityProbe extends ConsumerWidget {
  const _IdentityProbe({required this.snapshots});

  final List<List<int?>> snapshots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerId = ref.watch(playerNotifierProvider).activePlayer?.id;
    final profileId = ref.watch(playerProfileProvider).player?.id;
    final progress = ref.watch(playerProgressProvider);
    final progressId =
        progress.isLoading ? null : progress.valueOrNull?.playerId;
    final equipmentIds = ref
        .watch(equipmentNotifierProvider)
        .performanceProjections
        .map((projection) => projection.playerId)
        .toSet();
    final equipmentId = equipmentIds.length == 1 ? equipmentIds.single : null;
    final career = ref.watch(careerTimelineProvider);
    final careerId = career.isLoading ? null : career.valueOrNull?.playerId;
    ref.watch(dashboardProvider);
    ref.watch(matchStatisticsSnapshotProvider);

    final rendered = <int?>[
      playerId,
      profileId,
      progressId,
      equipmentId,
      careerId,
    ];
    snapshots.add(rendered);
    return Scaffold(
      body: Text(
        'identity:${playerId ?? '-'}|${profileId ?? '-'}|'
        '${progressId ?? '-'}|${equipmentId ?? '-'}|${careerId ?? '-'}',
      ),
    );
  }
}

Future<void> _pumpUntilIdentity(WidgetTester tester, int playerId) async {
  for (var attempt = 0; attempt < 150; attempt++) {
    await tester.pump(const Duration(milliseconds: 20));
    if (find.text(_identityLabel(playerId)).evaluate().isNotEmpty) return;
  }
  fail('All Player-bound providers did not converge on Player $playerId.');
}

String _identityLabel(int playerId) =>
    'identity:$playerId|$playerId|$playerId|$playerId|$playerId';

Future<void> _seedProjectionData(
  PlayerRepository players,
  EquipmentRepository equipment,
  int playerId,
) async {
  await players.saveProgressProjection(_progressProjection(playerId));
  final cueId = await equipment.createCue(_cue(playerId));
  await equipment.replacePerformanceProjections(
    playerId,
    [_equipmentProjection(playerId, cueId)],
  );
}

domain.Player _player(String name) => domain.Player(
      name: name,
      dominantHand: 'right',
      language: 'en',
      measurementSystem: 'metric',
      theme: 'dark',
    );

Cue _cue(int playerId) => Cue(
      playerId: playerId,
      name: 'Cue $playerId',
      shaftMaterial: 'Carbon',
      shaftDiameter: 12.5,
      tipBrand: 'Kamui',
      tipHardness: 'Medium',
      weight: 19,
      balance: 'Center',
      joint: 'Radial',
      createdAt: DateTime.utc(2026, 7, 25),
      updatedAt: DateTime.utc(2026, 7, 25),
    );

PlayerProgressProjection _progressProjection(int playerId) =>
    const PlayerProgressCalculator().calculate(
      playerId: playerId,
      activities: [
        PlayerProgressActivity(
          kind: PlayerProgressActivityKind.training,
          sourceId: 'training:handoff',
          occurredAt: DateTime.utc(2026, 7, 25),
          rackCount: 1,
          wins: 0,
          attempts: 10,
          successes: 8,
          breakAttempts: 0,
          breakSuccesses: 0,
          scratches: 0,
          positionErrors: 1,
          safetyErrors: 0,
          kickErrors: 0,
          jumpErrors: 0,
          confidenceValues: [80],
        ),
      ],
      mastery: const [],
      fallbackUpdatedAt: DateTime.utc(2026, 7, 25),
    );

EquipmentPerformanceProjection _equipmentProjection(
  int playerId,
  int cueId,
) =>
    const EquipmentPerformanceCalculator().calculate(
      playerId: playerId,
      equipmentId: cueId,
      activities: [
        EquipmentPerformanceActivity(
          kind: EquipmentActivityKind.training,
          sourceId: 'training:handoff',
          sessionId: 1,
          endedAt: DateTime.utc(2026, 7, 25),
          durationSeconds: 600,
          won: false,
          attempts: 10,
          successes: 8,
        ),
      ],
    );
