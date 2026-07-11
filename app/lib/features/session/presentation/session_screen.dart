import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/presentation/session_provider.dart';
import 'package:pool_os/features/session/presentation/session_state.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/session/presentation/session_summary_screen.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/presentation/match_detail_screen.dart';
import 'package:pool_os/features/shot/presentation/shot_recording_screen.dart';
import 'package:pool_os/features/event/presentation/event_recording_screen.dart';
import 'package:pool_os/features/drill/presentation/drill_library_screen.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SessionScreen extends ConsumerStatefulWidget {
  const SessionScreen({super.key});

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionNotifierProvider.notifier).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sessionNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('session')),
        actions: [
          if (state.activeSession != null && state.activeSession!.sessionType != SessionTypes.practice)
            IconButton(
              icon: const Icon(Icons.flag),
              onPressed: () => _showAddMatchDialog(context, l10n),
              tooltip: l10n.get('new_match'),
            )
          else if (state.activeSession == null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => _showSelectSessionDialog(context, l10n),
              tooltip: l10n.get('recent_sessions'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.activeSession == null
              ? _buildEmptyState(context, l10n)
              : _buildSessionView(context, state, l10n),
      floatingActionButton: state.activeSession == null
          ? FloatingActionButton(
              onPressed: () => _showAddSessionDialog(context, l10n),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showSelectSessionDialog(BuildContext context, AppLocalizations l10n) {
    final state = ref.read(sessionNotifierProvider);
    final finishedSessions = state.sessions.where((s) => s.finishedAt != null).toList();

    if (finishedSessions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.get('no_sessions_to_continue'))),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.get('continue_match'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: finishedSessions.length,
                itemBuilder: (context, index) {
                  final session = finishedSessions[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.sports_bar),
                    ),
                    title: Text(session.sessionType.toUpperCase()),
                    subtitle: Text(_formatDateTime(session.startedAt)),
                    trailing: session.finishedAt != null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.play_circle, color: Colors.orange),
                    onTap: () {
                      Navigator.pop(ctx);
                      _continueSession(context, session, l10n);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _continueSession(BuildContext context, dynamic session, AppLocalizations l10n) {
    ref.read(sessionNotifierProvider.notifier).continueSession(session.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.get('continue_session')}: ${session.sessionType}'),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(dt.year, dt.month, dt.day);

    String dateStr;
    if (sessionDate == today) {
      dateStr = 'Hôm nay';
    } else if (sessionDate == yesterday) {
      dateStr = 'Hôm qua';
    } else {
      dateStr = '${dt.day}/${dt.month}/${dt.year}';
    }

    return '$dateStr ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_bar_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(l10n.get('empty_state'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.get('tap_to_add'), style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSessionView(BuildContext context, SessionState state, AppLocalizations l10n) {
    final session = state.activeSession!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        session.sessionType.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop),
                        onPressed: () => _finishSession(session.id!),
                        tooltip: l10n.get('finish_session'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 16),
                      const SizedBox(width: 8),
                      Text(_formatDuration(session.duration)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Practice Session: Show Shot/Event/Drill buttons (no Win/Lose)
          if (session.sessionType == SessionTypes.practice) ...[
            _buildPracticeActions(context, l10n),
            const SizedBox(height: 16),
          ],
          if (state.matches.isNotEmpty) ...[
            Text(l10n.get('matches'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: state.matches.length,
                itemBuilder: (context, index) {
                  final match = state.matches[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${match.matchNumber}'),
                      ),
                      title: Text(_getGameTypeLabel(match.gameType, l10n)),
                      subtitle: match.isActive
                          ? Text(l10n.get('active'))
                          : Text(_formatDuration(match.duration ?? Duration.zero)),
                      trailing: match.isActive
                          ? const Icon(Icons.play_circle, color: Colors.green)
                          : null,
                      onTap: () => _selectMatch(context, match.id!),
                      onLongPress: () => _showMatchOptions(context, match),
                    ),
                  );
                },
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Icon(Icons.flag_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(l10n.get('no_matches_yet'), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddMatchDialog(context, l10n),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.get('new_match')),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPracticeActions(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Colors.blue.withAlpha(13),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('practice_mode'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSmallAction(
                    context,
                    Icons.gps_fixed,
                    l10n.get('add_shot'),
                    () => _openShotRecording(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallAction(
                    context,
                    Icons.event,
                    l10n.get('add_event'),
                    () => _openEventRecording(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSmallAction(
                    context,
                    Icons.fitness_center,
                    l10n.get('drill'),
                    () => _openDrillLibrary(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallAction(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  String _getGameTypeLabel(String gameType, AppLocalizations l10n) {
    switch (gameType) {
      case 'warm_up':
        return l10n.get('warm_up');
      case 'race_to':
        return l10n.get('race_to');
      case 'race_to_5':
        return l10n.get('race_to_5');
      case 'race_to_7':
        return l10n.get('race_to_7');
      case 'ghost_challenge':
        return l10n.get('ghost_challenge');
      case 'challenge_match':
        return l10n.get('challenge_match');
      case 'league_match':
        return l10n.get('league_match');
      case 'tournament_match':
        return l10n.get('tournament_match');
      case 'practice_match':
        return l10n.get('practice_match');
      case 'drill':
        return l10n.get('drill');
      default:
        return gameType;
    }
  }

  void _showAddSessionDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('start_session')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: Text(l10n.get('practice')),
              onTap: () {
                Navigator.pop(context);
                ref.read(sessionNotifierProvider.notifier).createPracticeSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events),
              title: Text(l10n.get('match')),
              onTap: () {
                Navigator.pop(context);
                ref.read(sessionNotifierProvider.notifier).createMatchSession();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMatchDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.get('new_match')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: Text(l10n.get('warm_up')),
              onTap: () {
                Navigator.pop(context);
                ref.read(sessionNotifierProvider.notifier).createMatch(GameTypes.warmUp);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports_bar),
              title: Text(l10n.get('race_to')),
              // RFC-302 Task D: pick any race-to value instead of the two
              // hardcoded 5/7 options.
              onTap: () {
                Navigator.pop(context);
                _showRaceToPicker(context, l10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(l10n.get('ghost_challenge')),
              onTap: () {
                Navigator.pop(context);
                ref.read(sessionNotifierProvider.notifier).createMatch(GameTypes.ghostChallenge);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectMatch(BuildContext context, int matchId) {
    ref.read(sessionNotifierProvider.notifier).selectMatch(matchId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchDetailScreen(matchId: matchId),
      ),
    );
  }

  // RFC-302 Task D: let the user pick any race-to target instead of only 5/7.
  void _showRaceToPicker(BuildContext context, AppLocalizations l10n) {
    const presets = [3, 5, 7, 9, 11, 13, 15, 21];
    void create(int raceTo) {
      ref.read(sessionNotifierProvider.notifier).createMatch(
            GameTypes.raceTo,
            raceTo: raceTo,
          );
    }

    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.get('race_to'),
                  style: Theme.of(sheetCtx).textTheme.titleMedium,
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final v in presets)
                    ChoiceChip(
                      label: Text('$v'),
                      selected: false,
                      onSelected: (_) {
                        Navigator.pop(sheetCtx);
                        create(v);
                      },
                    ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.tune),
                title: Text(l10n.get('race_to_custom')),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showRaceToCustomDialog(context, l10n, create);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRaceToCustomDialog(
    BuildContext context,
    AppLocalizations l10n,
    void Function(int raceTo) onPick,
  ) {
    final controller = TextEditingController();
    // RFC-302: dispose the controller once the dialog closes (any exit path:
    // Confirm, Cancel, or barrier/back dismiss) so it is not leaked.
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.get('race_to_custom')),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.get('race_to'),
            hintText: 'e.g. 10',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              // Guard: only accept a positive race target.
              if (value == null || value < 1) return;
              Navigator.pop(dialogCtx);
              onPick(value);
            },
            child: Text(l10n.get('confirm')),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  void _showMatchOptions(BuildContext context, Match match) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: Text(l10n.get('view_details')),
              onTap: () {
                Navigator.pop(ctx);
                _selectMatch(context, match.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.get('delete'), style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteMatch(context, match, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteMatch(BuildContext context, Match match, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('delete_match')),
        content: Text(l10n.get('are_you_sure')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(sessionNotifierProvider.notifier).deleteMatch(match.id!);
            },
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }

  void _finishSession(int sessionId) {
    final l10n = AppLocalizations.of(context);
    ref.read(sessionNotifierProvider.notifier).finishSession(sessionId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('session_finished')),
        action: SnackBarAction(
          label: l10n.get('view_summary'),
          onPressed: () => _showSessionSummary(context, sessionId),
        ),
      ),
    );
  }

  void _showSessionSummary(BuildContext context, int sessionId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionSummaryScreen(sessionId: sessionId),
      ),
    );
  }

  // RFC-301 Rule #3/#4: the Practice flow uses the SAME Match → Rack → Shot →
  // Event pipeline as a match. Before opening the shot recorder we ensure a
  // practice Match and an open Rack exist, so the Shot always has a real parent.
  Future<void> _openShotRecording(BuildContext context) async {
    final session = ref.read(sessionNotifierProvider).activeSession;
    if (session?.id == null) return;
    final coordinator = ref.read(recordingCoordinatorProvider);
    final l10n = AppLocalizations.of(context);
    try {
      final matchId = await coordinator.ensurePracticeMatch(sessionId: session!.id!);
      final rackId = await coordinator.ensureCurrentRack(matchId: matchId);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShotRecordingScreen(
            rackId: rackId,
            sessionId: session.id,
            matchId: matchId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.get('error')}: $e')),
      );
    }
  }

  // RFC-301 Rule #2/#3: an Event MUST attach to a real, persisted Shot. Open the
  // event recorder against the most recent Shot in the current practice Rack;
  // if none exists yet, tell the user to record a shot first.
  Future<void> _openEventRecording(BuildContext context) async {
    final session = ref.read(sessionNotifierProvider).activeSession;
    if (session?.id == null) return;
    final coordinator = ref.read(recordingCoordinatorProvider);
    final shotRepo = ref.read(shotRepositoryProvider);
    final l10n = AppLocalizations.of(context);
    try {
      final matchId = await coordinator.ensurePracticeMatch(sessionId: session!.id!);
      final rackId = await coordinator.ensureCurrentRack(matchId: matchId);
      final shots = await shotRepo.getShotsByRackId(rackId);
      if (!context.mounted) return;
      if (shots.isEmpty || shots.last.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('record_shot_first'))),
        );
        return;
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EventRecordingScreen(
            shotId: shots.last.id!,
            rackId: rackId,
            sessionId: session.id,
            matchId: matchId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.get('error')}: $e')),
      );
    }
  }

  void _openDrillLibrary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DrillLibraryScreen(),
      ),
    );
  }
}
