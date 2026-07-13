import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/presentation/rack_summary_dialog.dart';
import 'package:pool_os/features/shot/presentation/shot_recording_screen.dart';
import 'package:pool_os/features/match/presentation/pre_match_context_screen.dart';
import 'package:pool_os/features/match/presentation/post_match_context_screen.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/player_state/domain/models/player_state_log.dart';
import 'package:pool_os/features/player_state/presentation/player_state_provider.dart';
import 'package:pool_os/features/player_state/presentation/widgets/fatigue_check_dialog.dart';
import 'package:pool_os/features/player_state/presentation/form_curve_provider.dart';
import 'package:pool_os/features/player_state/presentation/widgets/form_curve_card.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

final matchDetailProvider = StateNotifierProvider.family<MatchDetailNotifier, MatchDetailState, int>(
  (ref, matchId) {
    return MatchDetailNotifier(
      matchId: matchId,
      matchRepo: ref.watch(matchRepositoryProvider),
      rackRepo: ref.watch(rackRepositoryProvider),
    );
  },
);

class MatchDetailState {
  final Match? match;
  final List<Rack> racks;
  final int playerWins;
  final int opponentWins;
  final bool isLoading;
  final String? error;
  final bool matchFinished;

  const MatchDetailState({
    this.match,
    this.racks = const [],
    this.playerWins = 0,
    this.opponentWins = 0,
    this.isLoading = false,
    this.error,
    this.matchFinished = false,
  });

  MatchDetailState copyWith({
    Match? match,
    List<Rack>? racks,
    int? playerWins,
    int? opponentWins,
    bool? isLoading,
    String? error,
    bool? matchFinished,
  }) {
    return MatchDetailState(
      match: match ?? this.match,
      racks: racks ?? this.racks,
      playerWins: playerWins ?? this.playerWins,
      opponentWins: opponentWins ?? this.opponentWins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      matchFinished: matchFinished ?? this.matchFinished,
    );
  }
}

class MatchDetailNotifier extends StateNotifier<MatchDetailState> {
  final int matchId;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;

  MatchDetailNotifier({
    required this.matchId,
    required MatchRepository matchRepo,
    required RackRepository rackRepo,
  })  : _matchRepo = matchRepo,
        _rackRepo = rackRepo,
        super(const MatchDetailState()) {
    loadMatch();
  }

  Future<void> loadMatch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final match = await _matchRepo.getMatchById(matchId);
      final racks = await _rackRepo.getRacksByMatchId(matchId);
      
      int playerWins = 0;
      int opponentWins = 0;
      for (final rack in racks) {
        if (rack.result) {
          playerWins++;
        } else {
          opponentWins++;
        }
      }

      bool matchFinished = false;
      Match? updatedMatch = match;
      if (match != null && match.raceTo != null && !match.isActive) {
        matchFinished = true;
      } else if (match != null && match.raceTo != null) {
        // FIX-002: Winner only when score == raceTo (exact match, no early finish)
        if (playerWins == match.raceTo!) {
          matchFinished = true;
          await finishMatch('Player');
          updatedMatch = await _matchRepo.getMatchById(matchId);
        } else if (opponentWins == match.raceTo!) {
          matchFinished = true;
          await finishMatch('Opponent');
          updatedMatch = await _matchRepo.getMatchById(matchId);
        }
      }

      state = state.copyWith(
        match: updatedMatch,
        racks: racks,
        playerWins: playerWins,
        opponentWins: opponentWins,
        isLoading: false,
        matchFinished: matchFinished,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateMatch(Match match) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _matchRepo.updateMatch(match);
      await loadMatch();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteMatch() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _matchRepo.deleteMatch(matchId);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> finishMatch(String winner) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _matchRepo.finishMatch(matchId, winner);
      await loadMatch();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recordRackResult(bool playerWon) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRackNumber = state.racks.length + 1;

      final newRack = Rack(
        matchId: matchId,
        rackNumber: newRackNumber,
        result: playerWon,
        createdAt: DateTime.now(),
      );

      await _rackRepo.createRack(newRack);
      // RFC-302 Task: loadMatch() re-counts wins from DB (incl. this new rack)
      // and finishes the match itself when a side reaches raceTo exactly.
      // The old post-check below re-added +1 on top of that fresh count,
      // declaring a winner one rack early (race-to 7 won at 6). Removed.
      await loadMatch();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recordRackResultWithSummary(
    bool playerWon, {
    int ballsPotted = 0,
    int largestRun = 0,
    bool breakSuccess = false,
    bool breakScratch = false,
    bool breakFoul = false,
    int easyMissCount = 0,
    int hardMissCount = 0,
    int scratchErrorCount = 0,
    int positionErrorCount = 0,
    int safetyErrorCount = 0,
    int kickErrorCount = 0,
    int jumpErrorCount = 0,
    List<String>? bestStrengths,
    List<String>? biggestMistakes,
    int confidence = 5,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRackNumber = state.racks.length + 1;

      final newRack = Rack(
        matchId: matchId,
        rackNumber: newRackNumber,
        result: playerWon,
        createdAt: DateTime.now(),
        ballsPotted: ballsPotted,
        largestRun: largestRun,
        breakSuccess: breakSuccess,
        breakScratch: breakScratch,
        breakFoul: breakFoul,
        easyMissCount: easyMissCount,
        hardMissCount: hardMissCount,
        scratchErrorCount: scratchErrorCount,
        positionErrorCount: positionErrorCount,
        safetyErrorCount: safetyErrorCount,
        kickErrorCount: kickErrorCount,
        jumpErrorCount: jumpErrorCount,
        bestStrengths: bestStrengths ?? [],
        biggestMistakes: biggestMistakes ?? [],
        confidence: confidence,
        notes: notes,
        // Backward compatibility
        biggestMistake: biggestMistakes?.isNotEmpty == true ? biggestMistakes!.first : null,
        biggestStrength: bestStrengths?.isNotEmpty == true ? bestStrengths!.first : null,
      );

      await _rackRepo.createRack(newRack);
      // RFC-302 Task: same double-count fix as recordRackResult — loadMatch()
      // re-counts from DB and finishes at exactly raceTo. The old +1 post-check
      // ended the match one rack early. Removed.
      await loadMatch();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // FIX-002: Winner only at exact raceTo, not early finish (>=)
  bool checkRaceToWinner() {
    final match = state.match;
    if (match == null || match.raceTo == null) return false;
    
    // Only winner when score equals raceTo exactly
    if (state.playerWins == match.raceTo!) {
      return true;
    } else if (state.opponentWins == match.raceTo!) {
      return true;
    }
    return false;
  }

  // FIX-002: Generate Match Summary from all racks automatically
  // FIX-003: Extended to include break, errors, and multi-select strengths/mistakes
  MatchSummaryData generateMatchSummary() {
    final racks = state.racks;
    if (racks.isEmpty) {
      return const MatchSummaryData();
    }

    int totalBallsPotted = 0;
    int largestRun = 0;
    int totalConfidence = 0;
    int confidenceCount = 0;
    
    // Break stats
    int breakSuccessCount = 0;
    int breakScratchCount = 0;
    int breakFoulCount = 0;
    int breakAttempts = 0;
    
    // Error counts
    int totalEasyMiss = 0;
    int totalHardMiss = 0;
    int totalScratchError = 0;
    int totalPositionError = 0;
    int totalSafetyError = 0;
    int totalKickError = 0;
    int totalJumpError = 0;
    
    // Strength and mistake counts (multi-select)
    Map<String, int> strengthCounts = {};
    Map<String, int> mistakeCounts = {};

    for (final rack in racks) {
      // FIX-003: New fields
      totalBallsPotted += rack.ballsPotted;
      if (rack.largestRun > largestRun) {
        largestRun = rack.largestRun;
      }
      
      // Break stats
      breakAttempts++;
      if (rack.breakSuccess) breakSuccessCount++;
      if (rack.breakScratch) breakScratchCount++;
      if (rack.breakFoul) breakFoulCount++;
      
      // Error counts
      totalEasyMiss += rack.easyMissCount;
      totalHardMiss += rack.hardMissCount;
      totalScratchError += rack.scratchErrorCount;
      totalPositionError += rack.positionErrorCount;
      totalSafetyError += rack.safetyErrorCount;
      totalKickError += rack.kickErrorCount;
      totalJumpError += rack.jumpErrorCount;
      
      // Confidence
      totalConfidence += rack.confidence ?? 5;
      confidenceCount++;

      // Multi-select strengths
      for (final strength in rack.bestStrengths) {
        strengthCounts[strength] = (strengthCounts[strength] ?? 0) + 1;
      }
      
      // Multi-select mistakes
      for (final mistake in rack.biggestMistakes) {
        mistakeCounts[mistake] = (mistakeCounts[mistake] ?? 0) + 1;
      }
      
      // Backward compatibility
      if (rack.biggestMistake != null) {
        mistakeCounts[rack.biggestMistake!] = (mistakeCounts[rack.biggestMistake!] ?? 0) + 1;
      }
      if (rack.biggestStrength != null) {
        strengthCounts[rack.biggestStrength!] = (strengthCounts[rack.biggestStrength!] ?? 0) + 1;
      }
    }

    // Find most common mistake and strength
    String? mostCommonMistake;
    int maxMistakeCount = 0;
    mistakeCounts.forEach((key, value) {
      if (value > maxMistakeCount) {
        maxMistakeCount = value;
        mostCommonMistake = key;
      }
    });

    String? mostCommonStrength;
    int maxStrengthCount = 0;
    strengthCounts.forEach((key, value) {
      if (value > maxStrengthCount) {
        maxStrengthCount = value;
        mostCommonStrength = key;
      }
    });

    // FIX-003: Calculate break success rate
    final breakSuccessRate = breakAttempts > 0 
        ? (breakSuccessCount / breakAttempts * 100).round() 
        : 0;

    return MatchSummaryData(
      matchScore: '${state.playerWins} - ${state.opponentWins}',
      totalRacks: racks.length,
      playerWins: state.playerWins,
      opponentWins: state.opponentWins,
      win: state.playerWins > state.opponentWins,
      largestRun: largestRun,
      totalBallsPotted: totalBallsPotted,
      commonMistake: mostCommonMistake,
      commonStrength: mostCommonStrength,
      averageConfidence: confidenceCount > 0 ? (totalConfidence / confidenceCount).round() : 0,
      // FIX-003: New fields
      breakSuccessRate: breakSuccessRate,
      breakSuccessCount: breakSuccessCount,
      breakScratchCount: breakScratchCount,
      breakFoulCount: breakFoulCount,
      totalEasyMiss: totalEasyMiss,
      totalHardMiss: totalHardMiss,
      totalScratchError: totalScratchError,
      totalPositionError: totalPositionError,
      totalSafetyError: totalSafetyError,
      totalKickError: totalKickError,
      totalJumpError: totalJumpError,
      commonStrengths: strengthCounts,
      commonMistakes: mistakeCounts,
    );
  }
}

// FIX-002: Match Summary data class - auto-generated from rack data
// FIX-003: Extended with break stats, errors, and multi-select strengths/mistakes
class MatchSummaryData {
  final String matchScore;
  final int totalRacks;
  final int playerWins;
  final int opponentWins;
  final bool win;
  final int largestRun;
  final int totalBallsPotted;
  final String? commonMistake;
  final String? commonStrength;
  final int averageConfidence;
  
  // FIX-003: Break stats
  final int breakSuccessRate;
  final int breakSuccessCount;
  final int breakScratchCount;
  final int breakFoulCount;
  
  // FIX-003: Error counts
  final int totalEasyMiss;
  final int totalHardMiss;
  final int totalScratchError;
  final int totalPositionError;
  final int totalSafetyError;
  final int totalKickError;
  final int totalJumpError;
  
  // FIX-003: Multi-select strengths and mistakes
  final Map<String, int> commonStrengths;
  final Map<String, int> commonMistakes;

  const MatchSummaryData({
    this.matchScore = '0 - 0',
    this.totalRacks = 0,
    this.playerWins = 0,
    this.opponentWins = 0,
    this.win = false,
    this.largestRun = 0,
    this.totalBallsPotted = 0,
    this.commonMistake,
    this.commonStrength,
    this.averageConfidence = 5,
    this.breakSuccessRate = 0,
    this.breakSuccessCount = 0,
    this.breakScratchCount = 0,
    this.breakFoulCount = 0,
    this.totalEasyMiss = 0,
    this.totalHardMiss = 0,
    this.totalScratchError = 0,
    this.totalPositionError = 0,
    this.totalSafetyError = 0,
    this.totalKickError = 0,
    this.totalJumpError = 0,
    this.commonStrengths = const {},
    this.commonMistakes = const {},
  });
}

class MatchDetailScreen extends ConsumerWidget {
  final int matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(matchDetailProvider(matchId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('match_details')),
        centerTitle: true,
        actions: [
          if (state.match != null && state.match!.isActive && !state.matchFinished)
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: () => _undoLastRack(context, ref, l10n),
              tooltip: l10n.get('undo_rack'),
            ),
          if (state.match != null && state.match!.isActive && !state.matchFinished)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _showFinishDialog(context, ref, l10n, state),
              tooltip: l10n.get('finish_match'),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDialog(context, ref, state.match!, l10n);
              } else if (value == 'delete') {
                _showDeleteDialog(context, ref, l10n);
              } else if (value == 'pre_context') {
                // Task 06: pre-match context. Entered before play; never during
                // Rack/Shot recording.
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PreMatchContextScreen(matchId: matchId),
                ));
              } else if (value == 'post_context') {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PostMatchContextScreen(matchId: matchId),
                ));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pre_context',
                child: Row(
                  children: [
                    const Icon(Icons.flag_outlined),
                    const SizedBox(width: 8),
                    Text(l10n.get('pre_match_context')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'post_context',
                child: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in_outlined),
                    const SizedBox(width: 8),
                    Text(l10n.get('post_match_context')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit),
                    const SizedBox(width: 8),
                    Text(l10n.get('edit')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(l10n.get('delete'), style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : state.match == null
                  ? Center(child: Text(l10n.get('no_data')))
                  : _buildContent(context, state, l10n, ref),
    );
  }

  Widget _buildContent(BuildContext context, MatchDetailState state, AppLocalizations l10n, WidgetRef ref) {
    final match = state.match!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchHeader(context, match, state, l10n),
          const SizedBox(height: 24),
          if (state.matchFinished || !match.isActive)
            _buildWinnerAnnouncement(context, match, l10n),
          const SizedBox(height: 24),
          _buildMatchInfo(context, match, l10n),
          const SizedBox(height: 24),
          if (match.raceTo != null)
            _buildRaceProgress(context, match, state, l10n),
          const SizedBox(height: 24),
          _buildRackTimeline(context, state, l10n),
          const SizedBox(height: 24),
          // Task 07: Warm-up Intelligence — form curve computed on demand from
          // this match's real racks/shots (nothing stored). The card renders its
          // own "not enough data" state when there are too few racks.
          _buildFormCurve(ref),
          if (match.notes != null && match.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildNotes(context, match, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchHeader(
    BuildContext context,
    Match match,
    MatchDetailState state,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreBox(context, state.playerWins, Colors.green, l10n.get('rack_win')),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'vs',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey),
                  ),
                ),
                _buildScoreBox(context, state.opponentWins, Colors.red, l10n.get('rack_loss')),
              ],
            ),
            const SizedBox(height: 16),
            if (match.raceTo != null && match.isActive && !state.matchFinished)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${l10n.get('race_to')}: ${match.raceTo}',
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              )
            else if (match.isActive)
              Chip(
                label: Text(l10n.get('active')),
                backgroundColor: Colors.green.withAlpha(26),
                labelStyle: const TextStyle(color: Colors.green),
              )
            else
              Chip(
                label: Text(match.winner != null ? '${match.winner} ${l10n.get('won')}' : l10n.get('finished')),
                backgroundColor: Colors.blue.withAlpha(26),
                labelStyle: const TextStyle(color: Colors.blue),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBox(BuildContext context, int score, Color color, String label) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(26),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWinnerAnnouncement(BuildContext context, Match match, AppLocalizations l10n) {
    return Card(
      color: Colors.amber.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get('match_winner'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  Text(
                    match.winner ?? 'Unknown',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaceProgress(
    BuildContext context,
    Match match,
    MatchDetailState state,
    AppLocalizations l10n,
  ) {
    final raceTo = match.raceTo!;
    final playerProgress = state.playerWins / raceTo;
    final opponentProgress = state.opponentWins / raceTo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('race_to_progress').replaceAll('{raceTo}', '$raceTo'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(l10n.get('you')),
                    const Spacer(),
                    Text(
                      '${state.playerWins} / $raceTo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: playerProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withAlpha(51),
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(match.opponent ?? l10n.get('opponent')),
                    const Spacer(),
                    Text(
                      '${state.opponentWins} / $raceTo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: opponentProgress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withAlpha(51),
                    valueColor: const AlwaysStoppedAnimation(Colors.red),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchInfo(BuildContext context, Match match, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('match_info'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
                _buildInfoRow(context, l10n.get('session_type'), _getGameTypeLabel(match.gameType, l10n)),
              if (match.raceTo != null) ...[
                const Divider(height: 1),
                _buildInfoRow(context, l10n.get('race_to'), '${match.raceTo}'),
              ],
              if (match.opponent != null) ...[
                const Divider(height: 1),
                _buildInfoRow(context, l10n.get('opponent'), match.opponent!),
              ],
              if (match.startTime != null) ...[
                const Divider(height: 1),
                _buildInfoRow(context, l10n.get('started'), _formatDateTime(match.startTime!)),
              ],
              if (match.endTime != null) ...[
                const Divider(height: 1),
                _buildInfoRow(context, l10n.get('ended'), _formatDateTime(match.endTime!)),
              ],
              if (match.duration != null) ...[
                const Divider(height: 1),
                _buildInfoRow(context, l10n.get('session_duration'), _formatDuration(match.duration!)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRackTimeline(BuildContext context, MatchDetailState state, AppLocalizations l10n) {
    final match = state.match;
    final isActive = match?.isActive == true && !state.matchFinished;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.get('rack_timeline'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${state.racks.length} ${l10n.get('racks')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isActive)
          Card(
            color: Colors.blue.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.get('record_rack_result'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.get('tap_to_record_rack'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Consumer(
                    builder: (context, ref, child) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showRackSummaryDialog(context, ref, true),
                                  icon: const Icon(Icons.emoji_events),
                                  label: Text(l10n.get('rack_win')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showRackSummaryDialog(context, ref, false),
                                  icon: const Icon(Icons.close),
                                  label: Text(l10n.get('rack_loss')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openShotRecording(context, ref),
                                  icon: const Icon(Icons.gps_fixed),
                                  label: Text(l10n.get('add_shot')),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              // Task 02: standalone "Add Event" removed from the
                              // shot flow — a miss reason now lives on the Shot
                              // itself (see intent/missReason). EventRecordingScreen
                              // is no longer surfaced here.
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        if (state.racks.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.grid_view_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.get('no_racks'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.racks.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final rack = state.racks[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rack.result ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                    child: Icon(
                      rack.result ? Icons.check : Icons.close,
                      color: rack.result ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text('${l10n.get('rack_count')} ${rack.rackNumber}'),
                  subtitle: Text(_formatDateTime(rack.createdAt)),
                  trailing: Icon(
                    rack.result ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: rack.result ? Colors.amber : Colors.grey,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildFormCurve(WidgetRef ref) {
    final curveAsync = ref.watch(matchFormCurveProvider(matchId));
    return curveAsync.when(
      // Silent while loading / on error — the form curve is a secondary insight,
      // it must never block or clutter the match detail if data isn't ready.
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (curve) => FormCurveCard(curve: curve),
    );
  }

  Widget _buildNotes(BuildContext context, Match match, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('notes'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(match.notes!),
          ),
        ),
      ],
    );
  }

  String _getGameTypeLabel(String gameType, AppLocalizations l10n) {
    switch (gameType) {
      case 'warm_up':
        return l10n.get('warm_up');
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

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  void _showFinishDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, MatchDetailState state) {
    if (state.match?.raceTo != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.get('finish_match')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.get('select_winner')),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text('${l10n.get('you')} - ${state.playerWins} wins'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(matchDetailProvider(matchId).notifier).finishMatch('Player');
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.grey),
                title: Text('${state.match?.opponent ?? 'Opponent'} - ${state.opponentWins} wins'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(matchDetailProvider(matchId).notifier).finishMatch('Opponent');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.get('cancel')),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.get('finish_match')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.emoji_events, color: Colors.amber),
                title: Text(l10n.get('rack_win')),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(matchDetailProvider(matchId).notifier).finishMatch('Player');
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: Text(l10n.get('rack_loss')),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(matchDetailProvider(matchId).notifier).finishMatch('Opponent');
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Match match, AppLocalizations l10n) {
    final opponentController = TextEditingController(text: match.opponent);
    final notesController = TextEditingController(text: match.notes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('edit_match')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: opponentController,
                decoration: InputDecoration(
                  labelText: l10n.get('opponent'),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: l10n.get('notes'),
                  prefixIcon: const Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              final updatedMatch = match.copyWith(
                opponent: opponentController.text.isEmpty ? null : opponentController.text,
                notes: notesController.text.isEmpty ? null : notesController.text,
              );
              ref.read(matchDetailProvider(matchId).notifier).updateMatch(updatedMatch);
            },
            child: Text(l10n.get('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
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
              ref.read(matchDetailProvider(matchId).notifier).deleteMatch();
              context.pop();
            },
            child: Text(l10n.get('delete')),
          ),
        ],
      ),
    );
  }

  void _undoLastRack(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final state = ref.read(matchDetailProvider(matchId));
    if (state.racks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.get('no_racks_to_undo')),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('undo_rack_confirm')),
        content: Text(l10n.get('undo_rack_message').replaceAll('{number}', '${state.racks.last.rackNumber}')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final lastRack = state.racks.last;
              await ref.read(rackRepositoryProvider).deleteRack(lastRack.id!);
              await ref.read(matchDetailProvider(matchId).notifier).loadMatch();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.get('rack_undone').replaceAll('{number}', '${lastRack.rackNumber}')),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(l10n.get('undo_rack_action')),
          ),
        ],
      ),
    );
  }

  // FIX-002: Show Rack Summary Dialog after each rack Win/Lose
  // FIX-007A: Fixed context issue - close dialog first, then show feedback
  void _showRackSummaryDialog(BuildContext context, WidgetRef ref, bool won) {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(matchDetailProvider(matchId));
    final nextRackNumber = state.racks.length + 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => RackSummaryDialog(
        won: won,
        rackNumber: nextRackNumber,
        onSave: (summaryData) async {
          // FIX-007A: Close dialog immediately before async operations
          Navigator.of(dialogCtx).pop();

          await ref.read(matchDetailProvider(matchId).notifier).recordRackResultWithSummary(
            won,
            ballsPotted: summaryData.ballsPotted,
            largestRun: summaryData.largestRun,
            breakSuccess: summaryData.breakSuccess,
            breakScratch: summaryData.breakScratch,
            breakFoul: summaryData.breakFoul,
            easyMissCount: summaryData.easyMissCount,
            hardMissCount: summaryData.hardMissCount,
            scratchErrorCount: summaryData.scratchErrorCount,
            positionErrorCount: summaryData.positionErrorCount,
            safetyErrorCount: summaryData.safetyErrorCount,
            kickErrorCount: summaryData.kickErrorCount,
            jumpErrorCount: summaryData.jumpErrorCount,
            bestStrengths: summaryData.bestStrengths,
            biggestMistakes: summaryData.biggestMistakes,
            confidence: summaryData.confidence,
            notes: summaryData.notes,
          );

          // RFC-302 Task 2: the await above may outlive this screen (finishing
          // the match pops MatchDetailScreen). Guard on context.mounted before
          // touching ref/context — the old addPostFrameCallback ran a frame
          // later, after dispose, throwing "Cannot use ref after the widget
          // was disposed". The await already defers us past the navigator lock.
          if (!context.mounted) return;
          final newState = ref.read(matchDetailProvider(matchId));
          if (newState.matchFinished) {
            _showMatchSummaryDialog(context, ref);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(won ? l10n.get('rack_win') : l10n.get('rack_loss')),
                backgroundColor: won ? Colors.green : Colors.red,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }

  // FIX-002: Show auto-generated Match Summary when match ends
  void _showMatchSummaryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.read(matchDetailProvider(matchId));
    final summary = ref.read(matchDetailProvider(matchId).notifier).generateMatchSummary();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              summary.win ? Icons.emoji_events : Icons.sports,
              color: summary.win ? Colors.amber : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(l10n.get('match_finished')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match Result
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: summary.win ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${l10n.get('you')} ${summary.matchScore} ${state.match?.opponent ?? l10n.get('opponent')}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: summary.win ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Match Statistics Summary
              _buildSummaryRow(l10n.get('total_racks'), '${summary.totalRacks}'),
              _buildSummaryRow(l10n.get('result'), summary.win ? l10n.get('win') : l10n.get('loss')),
              _buildSummaryRow(l10n.get('win'), '${summary.playerWins}'),
              _buildSummaryRow(l10n.get('loss'), '${summary.opponentWins}'),
              _buildSummaryRow(l10n.get('average_confidence'), '${summary.averageConfidence}/10'),

              if (summary.commonMistake != null) ...[
                const SizedBox(height: 16),
                _buildSummaryRow(l10n.get('common_mistake'), _getLocalizedMistake(summary.commonMistake!, l10n)),
              ],
              if (summary.commonStrength != null) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(l10n.get('common_strength'), _getLocalizedStrength(summary.commonStrength!, l10n)),
              ],
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(summary.win ? l10n.get('congratulations_win') : l10n.get('better_luck_next_time')),
                  backgroundColor: summary.win ? Colors.amber : Colors.blue,
                  duration: const Duration(seconds: 2),
                ),
              );
              // Player State §5: quick post-match fatigue note after the summary
              // is dismissed. Optional (Skip closes it). Captures the match's
              // sessionId so the log attaches to the right session/match.
              final match = ref.read(matchDetailProvider(matchId)).match;
              if (match != null && context.mounted) {
                _showFatigueCheck(context, ref, match.sessionId, matchId);
              }
            },
            child: Text(l10n.get('continue')),
          ),
        ],
      ),
    );
  }

  // Player State §5: post-match fatigue prompt. Optional; Skip closes without
  // saving. Persists a post_match log tied to the session + match.
  void _showFatigueCheck(
      BuildContext context, WidgetRef ref, int sessionId, int matchId) {
    showDialog(
      context: context,
      builder: (dialogCtx) => FatigueCheckDialog(
        onPick: (fatigueLevel) async {
          Navigator.of(dialogCtx).pop();
          await ref.read(playerStateProvider.notifier).addLog(
                PlayerStateLog(
                  sessionId: sessionId,
                  matchId: matchId,
                  kind: PlayerStateKind.postMatch,
                  fatigueLevel: fatigueLevel,
                ),
              );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getLocalizedMistake(String key, AppLocalizations l10n) {
    switch (key) {
      case 'alignment':
        return 'Alignment';
      case 'stance':
        return 'Stance';
      case 'stroke':
        return 'Stroke';
      case 'speed_control':
        return 'Speed Control';
      case 'position_play':
        return 'Position Play';
      case 'shot_selection':
        return 'Shot Selection';
      case 'safety_play':
        return 'Safety Play';
      case 'mental':
        return 'Mental';
      case 'break':
        return 'Break';
      case 'scratch':
        return 'Scratch';
      case 'foul':
        return 'Foul';
      default:
        return key;
    }
  }

  String _getLocalizedStrength(String key, AppLocalizations l10n) {
    switch (key) {
      case 'break_effective':
        return 'Effective Break';
      case 'shot_making':
        return 'Shot Making';
      case 'position_play':
        return 'Position Play';
      case 'safety_play':
        return 'Safety Play';
      case 'mental_toughness':
        return 'Mental Toughness';
      case 'consistency':
        return 'Consistency';
      case 'pattern_play':
        return 'Pattern Play';
      case 'long_pots':
        return 'Long Pots';
      case 'bank_shots':
        return 'Bank Shots';
      case 'control':
        return 'Control';
      default:
        return key;
    }
  }

  // RFC-301 Rule #1/#3: ensure an open Rack exists for this match, then open
  // the shot recorder with the real rackId so the Shot always has a parent.
  Future<void> _openShotRecording(BuildContext context, WidgetRef ref) async {
    final coordinator = ref.read(recordingCoordinatorProvider);
    final l10n = AppLocalizations.of(context);
    try {
      final rackId = await coordinator.ensureCurrentRack(matchId: matchId);
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShotRecordingScreen(
            rackId: rackId,
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

}
