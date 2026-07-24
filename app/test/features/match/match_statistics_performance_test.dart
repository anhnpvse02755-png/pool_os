import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/application/match_statistics_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/presentation/match_statistics_panel.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';

void main() {
  late AppDatabase database;
  late MatchRepository matches;
  late RackRepository racks;
  late SessionRepository sessions;
  late MatchStatisticsService statistics;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    matches = MatchRepository(database);
    racks = RackRepository(database);
    sessions = SessionRepository(database);
    statistics = MatchStatisticsService(matches: matches, racks: racks);
  });
  tearDown(() => database.close());

  test('aggregates completed match performance from persisted racks', () async {
    final sessionId = await _createSession(sessions);
    final first = await _createMatch(
      matches,
      sessionId: sessionId,
      matchNumber: 1,
      opponent: 'Lan',
      start: DateTime(2026, 7, 24, 8),
      end: DateTime(2026, 7, 24, 9),
    );
    final second = await _createMatch(
      matches,
      sessionId: sessionId,
      matchNumber: 2,
      opponent: 'Minh',
      start: DateTime(2026, 7, 24, 10),
      end: DateTime(2026, 7, 24, 10, 30),
    );
    await _record(racks, first, [true, false, true]);
    await _record(racks, second, [false, true]);
    await _createMatch(
      matches,
      sessionId: sessionId,
      matchNumber: 3,
      opponent: 'Active',
      start: DateTime(2026, 7, 24, 11),
    );

    final result = await statistics.load();

    expect(result.matchCount, 2);
    expect(result.rackCount, 5);
    expect(result.wins, 3);
    expect(result.losses, 2);
    expect(result.duration, const Duration(minutes: 90));
    expect(result.performance.map((entry) => entry.match.opponent),
        ['Minh', 'Lan']);
  });

  testWidgets('renders persisted match metrics and recent performance',
      (tester) async {
    final sessionId = await _createSession(sessions);
    final matchId = await _createMatch(
      matches,
      sessionId: sessionId,
      matchNumber: 1,
      opponent: 'Lan',
      start: DateTime(2026, 7, 24, 8),
      end: DateTime(2026, 7, 24, 9),
    );
    await _record(racks, matchId, [true, false, true, true]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          home: Scaffold(
              body: SingleChildScrollView(child: MatchStatisticsPanel())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Match performance'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Racks'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('1h 0m'), findsNWidgets(2));
    expect(find.text('Lan'), findsOneWidget);
    expect(find.text('3-1'), findsOneWidget);
  });
}

Future<int> _createSession(SessionRepository repository) {
  final now = DateTime(2026, 7, 24, 8);
  return repository.createSession(
    Session(
      sessionType: SessionTypes.match,
      startedAt: now,
      finishedAt: now.add(const Duration(hours: 3)),
    ),
  );
}

Future<int> _createMatch(
  MatchRepository repository, {
  required int sessionId,
  required int matchNumber,
  required String opponent,
  required DateTime start,
  DateTime? end,
}) {
  return repository.createMatch(
    Match(
      sessionId: sessionId,
      matchNumber: matchNumber,
      gameType: GameTypes.raceTo,
      opponent: opponent,
      startTime: start,
      endTime: end,
    ),
  );
}

Future<void> _record(
  RackRepository repository,
  int matchId,
  List<bool> results,
) async {
  for (var index = 0; index < results.length; index++) {
    await repository.createRack(
      Rack(
        matchId: matchId,
        rackNumber: index + 1,
        result: results[index],
      ),
    );
  }
}
