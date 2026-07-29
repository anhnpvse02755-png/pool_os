// EPIC 01 — Match Engine — Phase 7: Match Recording Screen.
//
// Live recording surface. The screen is intentionally minimal: it
// shows the current score (rack wins per participant), the active
// turn / shot count, an Undo / Redo pair, and buttons to record a
// shot, end a turn, end a rack, and complete the match. Foul /
// safety calls are surfaced as text buttons; full rule-driven
// classifications are deferred to EPIC Rule System.

import 'package:flutter/material.dart';

import '../../domain/engine/match_aggregate.dart';
import '../../domain/engine/states.dart';
import '../../domain/engine/value_objects.dart';
import '../../domain/rule/placeholder_rule.dart';
import 'match_engine_view_model.dart';

class MatchRecordingScreen extends StatefulWidget {
  const MatchRecordingScreen({
    super.key,
    required this.viewModel,
    required this.ruleRegistry,
  });

  final MatchEngineViewModel viewModel;
  final GameRuleRegistry ruleRegistry;

  @override
  State<MatchRecordingScreen> createState() => _MatchRecordingScreenState();
}

class _MatchRecordingScreenState extends State<MatchRecordingScreen> {
  late MatchEngineViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = widget.viewModel;
  }

  Future<void> _ensureMatchStarted() async {
    if (_vm.match.state == MatchState.created) {
      final next = await _vm.startMatch();
      if (mounted) setState(() => _vm = next);
    }
  }

  Future<void> _startNextRack() async {
    await _ensureMatchStarted();
    final breaking = _vm.ruleRegistry.breakStrategy().participantForBreak(
          gameNumber: _vm.match.racks.length + 1,
          participants: _vm.match.participants,
          previousWins: _vm.match.rackWinsByParticipant,
        );
    final rackId = RackId('rack-${_vm.match.racks.length + 1}');
    final next = await _vm.beginRack(rackId, breaking);
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _beginTurnFor(String participant) async {
    final rack = _vm.match.activeRack;
    if (rack == null) return;
    final turnId = TurnId(
        'turn-${rack.id.value}-${rack.turns.length + 1}-${DateTime.now().microsecondsSinceEpoch}');
    final next = await _vm.beginTurn(turnId, rack.id, participant);
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _recordShot() async {
    final rack = _vm.match.activeRack;
    final turn = rack?.activeTurn;
    if (rack == null || turn == null) return;
    final shotId = ShotId(
        'shot-${rack.id.value}-${turn.id.value}-${turn.shots.length + 1}-${DateTime.now().microsecondsSinceEpoch}');
    final next = await _vm.recordShot(
      shotId: shotId,
      turnId: turn.id,
      rackId: rack.id,
      participant: turn.participantId,
    );
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _endTurn(String resolution) async {
    final rack = _vm.match.activeRack;
    final turn = rack?.activeTurn;
    if (rack == null || turn == null) return;
    final next = await _vm.endTurn(
      turnId: turn.id,
      rackId: rack.id,
      resolution: resolution,
    );
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _endRack(String winner) async {
    final rack = _vm.match.activeRack;
    if (rack == null) return;
    final next = await _vm.endRack(rack.id, winner);
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _completeMatch() async {
    final winner = _vm.ruleRegistry.winCondition().determineWinner(
          rackWins: _vm.match.rackWinsByParticipant,
          raceLength: _vm.match.raceLength,
        );
    if (winner == null) return;
    final next = await _vm.completeMatch(winner);
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _undo() async {
    final next = await _vm.undo();
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _redo() async {
    final next = await _vm.redo();
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _recordFoul() async {
    final rack = _vm.match.activeRack;
    final turn = rack?.activeTurn;
    if (rack == null || turn == null) return;
    final next = await _vm.recordFoul(
      turnId: turn.id,
      rackId: rack.id,
      participant: turn.participantId,
      reason: 'placeholder-foul',
    );
    if (mounted) setState(() => _vm = next);
  }

  Future<void> _recordSafety() async {
    final rack = _vm.match.activeRack;
    final turn = rack?.activeTurn;
    if (rack == null || turn == null) return;
    final next = await _vm.recordSafety(
      turnId: turn.id,
      rackId: rack.id,
      participant: turn.participantId,
      reason: 'placeholder-safety',
    );
    if (mounted) setState(() => _vm = next);
  }

  @override
  Widget build(BuildContext context) {
    final match = _vm.match;
    final activeRack = match.activeRack;
    final activeTurn = activeRack?.activeTurn;

    return Scaffold(
      appBar: AppBar(
        title: Text('Match · ${match.gameType.label}'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: match.state.isTerminal ? null : _undo,
          ),
          IconButton(
            tooltip: 'Redo',
            icon: const Icon(Icons.redo),
            onPressed: match.state.isTerminal ? null : _redo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Scoreboard(match: match),
            const SizedBox(height: 16),
            _RackHeader(rack: activeRack),
            const SizedBox(height: 8),
            _TurnHeader(turn: activeTurn),
            const SizedBox(height: 16),
            _ShotHistory(turn: activeTurn),
            const Spacer(),
            _ActionBar(
              vm: _vm,
              onStartRack: _startNextRack,
              onBeginTurn: _beginTurnFor,
              onRecordShot: _recordShot,
              onEndTurn: _endTurn,
              onEndRack: _endRack,
              onCompleteMatch: _completeMatch,
              onRecordFoul: _recordFoul,
              onRecordSafety: _recordSafety,
            ),
            if (match.state.isTerminal) ...[
              const SizedBox(height: 8),
              _MatchSummary(match: match),
            ],
          ],
        ),
      ),
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final p in match.participants)
              Expanded(
                child: Column(
                  children: [
                    Text(p, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      'Rack wins: ${match.rackWinsFor(p)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Race to ${match.raceLength}',
                    style: Theme.of(context).textTheme.titleSmall),
                Text('State: ${match.state.name}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RackHeader extends StatelessWidget {
  const _RackHeader({required this.rack});
  final Rack? rack;

  @override
  Widget build(BuildContext context) {
    if (rack == null) {
      return const Text('No active rack.');
    }
    return Text(
        'Rack ${rack!.rackNumber} · breaking: ${rack!.breakingParticipantId}');
  }
}

class _TurnHeader extends StatelessWidget {
  const _TurnHeader({required this.turn});
  final Turn? turn;

  @override
  Widget build(BuildContext context) {
    if (turn == null) {
      return const Text('No active turn.');
    }
    return Text('Turn: ${turn!.participantId} · shots: ${turn!.shots.length}');
  }
}

class _ShotHistory extends StatelessWidget {
  const _ShotHistory({required this.turn});
  final Turn? turn;

  @override
  Widget build(BuildContext context) {
    if (turn == null || turn!.shots.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 96,
      child: ListView.builder(
        itemCount: turn!.shots.length,
        itemBuilder: (context, index) {
          final shot = turn!.shots[index];
          return ListTile(
            dense: true,
            title: Text('Shot #${shot.shotIndex}'),
            subtitle: Text('By ${shot.shootingParticipantId}'),
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.vm,
    required this.onStartRack,
    required this.onBeginTurn,
    required this.onRecordShot,
    required this.onEndTurn,
    required this.onEndRack,
    required this.onCompleteMatch,
    required this.onRecordFoul,
    required this.onRecordSafety,
  });

  final MatchEngineViewModel vm;
  final Future<void> Function() onStartRack;
  final Future<void> Function(String) onBeginTurn;
  final Future<void> Function() onRecordShot;
  final Future<void> Function(String) onEndTurn;
  final Future<void> Function(String) onEndRack;
  final Future<void> Function() onCompleteMatch;
  final Future<void> Function() onRecordFoul;
  final Future<void> Function() onRecordSafety;

  @override
  Widget build(BuildContext context) {
    final match = vm.match;
    final rack = match.activeRack;
    final turn = rack?.activeTurn;

    if (match.state.isTerminal) {
      return const Text('Match finished.');
    }

    if (rack == null) {
      return ElevatedButton.icon(
        onPressed: onStartRack,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start next rack'),
      );
    }

    if (turn == null) {
      return Wrap(
        spacing: 8,
        children: [
          for (final p in match.participants)
            ElevatedButton(
              onPressed: () => onBeginTurn(p),
              child: Text('${p} to break'),
            ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          onPressed: onRecordShot,
          icon: const Icon(Icons.sports),
          label: Text('Record shot #${turn.shots.length + 1}'),
        ),
        OutlinedButton(
          onPressed: () => onEndTurn('normal'),
          child: const Text('End turn (normal)'),
        ),
        OutlinedButton(
          onPressed: onRecordFoul,
          child: const Text('Record foul'),
        ),
        OutlinedButton(
          onPressed: onRecordSafety,
          child: const Text('Record safety'),
        ),
        Wrap(
          spacing: 4,
          children: [
            for (final p in match.participants)
              ElevatedButton(
                onPressed: () => onEndRack(p),
                child: Text('End rack · $p wins'),
              ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: onCompleteMatch,
          icon: const Icon(Icons.flag),
          label: const Text('Complete match'),
        ),
      ],
    );
  }
}

class _MatchSummary extends StatelessWidget {
  const _MatchSummary({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final winner = match.winnerParticipantId;
    final closedRacks =
        match.racks.where((r) => r.state == RackState.closed).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              winner == null ? 'Match ${match.state.name}' : 'Winner: $winner',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Racks played: ${closedRacks.length}'),
            for (final r in closedRacks)
              Text(
                '  Rack ${r.rackNumber}: ${r.winnerParticipantId ?? '-'}',
              ),
          ],
        ),
      ),
    );
  }
}
