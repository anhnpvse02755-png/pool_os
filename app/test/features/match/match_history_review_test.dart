import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/presentation/match_history_view.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';

void main() {
  late AppDatabase database;
  late SessionRepository sessions;
  late MatchRepository matches;
  late RackRepository racks;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    sessions = SessionRepository(database);
    matches = MatchRepository(database);
    racks = RackRepository(database);
  });

  tearDown(() => database.close());

  testWidgets('shows only completed matches with score and session linkage',
      (tester) async {
    final sessionId = await sessions.createSession(
      Session(
        sessionType: SessionTypes.match,
        startedAt: DateTime(2026, 7, 24, 9),
        finishedAt: DateTime(2026, 7, 24, 10),
      ),
    );
    final completedId = await matches.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 1,
        gameType: GameTypes.raceTo,
        opponent: 'Lan',
        raceTo: 2,
        startTime: DateTime(2026, 7, 24, 9),
        endTime: DateTime(2026, 7, 24, 10),
      ),
    );
    await matches.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 2,
        gameType: GameTypes.raceTo,
        opponent: 'Active opponent',
        raceTo: 2,
        startTime: DateTime(2026, 7, 24, 10),
      ),
    );
    for (final result in [true, false, true]) {
      await racks.createRack(
        Rack(
          matchId: completedId,
          rackNumber: await racks.getNextRackNumber(completedId),
          result: result,
        ),
      );
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          home:
              Scaffold(body: SingleChildScrollView(child: MatchHistoryView())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final historyTile = find.byKey(ValueKey('match-history-$completedId'));
    expect(find.text('Match history'), findsOneWidget);
    expect(find.descendant(of: historyTile, matching: find.text('Lan')),
        findsOneWidget);
    expect(find.descendant(of: historyTile, matching: find.text('2-1')),
        findsOneWidget);
    expect(
      find.descendant(
        of: historyTile,
        matching: find.textContaining('Session #$sessionId'),
      ),
      findsOneWidget,
    );
    expect(find.text('Active opponent'), findsNothing);

    await tester.tap(historyTile);
    await tester.pumpAndSettle();

    expect(find.text('#$sessionId'), findsOneWidget);
    expect(find.text('1 - 0'), findsOneWidget);
    expect(find.text('1 - 1'), findsOneWidget);
    expect(find.text('2 - 1'), findsOneWidget);
  });

  test('existing repositories preserve chronological rack history', () async {
    final sessionId = await sessions.createSession(
      Session(sessionType: SessionTypes.match, startedAt: DateTime.now()),
    );
    final matchId = await matches.createMatch(
      Match(
        sessionId: sessionId,
        matchNumber: 1,
        gameType: GameTypes.raceTo,
        endTime: DateTime.now(),
      ),
    );
    await racks
        .createRack(Rack(matchId: matchId, rackNumber: 2, result: false));
    await racks.createRack(Rack(matchId: matchId, rackNumber: 1, result: true));

    final history = await racks.getRacksByMatchId(matchId);

    expect(history.map((rack) => rack.rackNumber), [1, 2]);
    expect(history.map((rack) => rack.result), [true, false]);
    expect((await matches.getMatchById(matchId))!.sessionId, sessionId);
  });
}
