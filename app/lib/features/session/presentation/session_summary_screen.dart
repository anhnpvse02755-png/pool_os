import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

final sessionSummaryProvider = StateNotifierProvider.family<
    SessionSummaryNotifier, SessionSummaryState, int>(
  (ref, sessionId) {
    return SessionSummaryNotifier(
      sessionId: sessionId,
      matchRepo: ref.watch(matchRepositoryProvider),
      rackRepo: ref.watch(rackRepositoryProvider),
      shotRepo: ref.watch(shotRepositoryProvider),
    );
  },
);

class SessionSummaryState {
  final Session? session;
  final List<Match> matches;
  final List<Rack> allRacks;
  final List<Shot> allShots;
  final Map<String, dynamic> stats;
  final List<PlayerSkill> skills;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<String> achievements;
  final String coachSummary;
  final String recommendedDrill;
  final bool isLoading;
  final String? error;

  const SessionSummaryState({
    this.session,
    this.matches = const [],
    this.allRacks = const [],
    this.allShots = const [],
    this.stats = const {},
    this.skills = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.recommendations = const [],
    this.achievements = const [],
    this.coachSummary = '',
    this.recommendedDrill = '',
    this.isLoading = false,
    this.error,
  });

  SessionSummaryState copyWith({
    Session? session,
    List<Match>? matches,
    List<Rack>? allRacks,
    List<Shot>? allShots,
    Map<String, dynamic>? stats,
    List<PlayerSkill>? skills,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? recommendations,
    List<String>? achievements,
    String? coachSummary,
    String? recommendedDrill,
    bool? isLoading,
    String? error,
  }) {
    return SessionSummaryState(
      session: session ?? this.session,
      matches: matches ?? this.matches,
      allRacks: allRacks ?? this.allRacks,
      allShots: allShots ?? this.allShots,
      stats: stats ?? this.stats,
      skills: skills ?? this.skills,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendations: recommendations ?? this.recommendations,
      achievements: achievements ?? this.achievements,
      coachSummary: coachSummary ?? this.coachSummary,
      recommendedDrill: recommendedDrill ?? this.recommendedDrill,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionSummaryNotifier extends StateNotifier<SessionSummaryState> {
  final int sessionId;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;

  SessionSummaryNotifier({
    required this.sessionId,
    required MatchRepository matchRepo,
    required RackRepository rackRepo,
    required ShotRepository shotRepo,
  })  : _matchRepo = matchRepo,
        _rackRepo = rackRepo,
        _shotRepo = shotRepo,
        super(const SessionSummaryState()) {
    loadSummary();
  }

  Future<void> loadSummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final matches = await _matchRepo.getMatchesBySessionId(sessionId);
      final allRacks = <Rack>[];
      final allShots = <Shot>[];

      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        allRacks.addAll(racks);

        for (final rack in racks) {
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          allShots.addAll(shots);
        }
      }

      final stats = _calculateStats(matches, allRacks, allShots);
      final analysis = _analyzeSession(matches, allRacks, allShots, stats);
      final achievements =
          _checkAchievements(matches, allRacks, allShots, stats);
      final coachSummary = _generateCoachSummary(stats);
      final recommendedDrill = _getRecommendedDrill(stats);

      state = state.copyWith(
        matches: matches,
        allRacks: allRacks,
        allShots: allShots,
        stats: stats,
        strengths: analysis.$1,
        weaknesses: analysis.$2,
        recommendations: analysis.$3,
        achievements: achievements,
        coachSummary: coachSummary,
        recommendedDrill: recommendedDrill,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Map<String, dynamic> _calculateStats(
      List<Match> matches, List<Rack> racks, List<Shot> shots) {
    final totalRacks = racks.length;
    final wins = racks.where((r) => r.result).length;
    final totalShots = shots.length;
    final madeShots = shots.where((s) => s.isMade).length;

    int breakAndRuns = 0;
    final positionQuality = <String, int>{};
    final shotTypes = <String, int>{};

    for (final shot in shots) {
      if (shot.positionQuality != null) {
        positionQuality[shot.positionQuality!] =
            (positionQuality[shot.positionQuality!] ?? 0) + 1;
      }
    }

    for (final rack in racks) {
      final rackShots = shots.where((shot) => shot.rackId == rack.id).toList();
      if (rack.result &&
          rackShots.length >= 3 &&
          rackShots.every((shot) => shot.isMade)) {
        breakAndRuns++;
      }
    }

    return {
      'totalMatches': matches.length,
      'totalRacks': totalRacks,
      'wins': wins,
      'losses': totalRacks - wins,
      'winRate': totalRacks > 0 ? wins / totalRacks : 0.0,
      'totalShots': totalShots,
      'madeShots': madeShots,
      'accuracy': totalShots > 0 ? madeShots / totalShots : 0.0,
      'breakAndRuns': breakAndRuns,
      'positionQuality': positionQuality,
      'shotTypes': shotTypes,
    };
  }

  (List<String>, List<String>, List<String>) _analyzeSession(
    List<Match> matches,
    List<Rack> racks,
    List<Shot> shots,
    Map<String, dynamic> stats,
  ) {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    final winRate = racks.isNotEmpty
        ? racks.where((r) => r.result).length / racks.length
        : 0.0;
    final accuracy = shots.isNotEmpty
        ? shots.where((s) => s.isMade).length / shots.length
        : 0.0;

    if (racks.length >= 3 && winRate >= 0.7) {
      strengths.add('Excellent win rate this session!');
    } else if (racks.length >= 3 && winRate < 0.4) {
      weaknesses.add('Win rate needs improvement');
      recommendations
          .add('Focus on position play to create more opportunities');
    }

    if (shots.length >= 10 && accuracy >= 0.85) {
      strengths.add('Outstanding shot making!');
    } else if (shots.length >= 10 && accuracy < 0.6) {
      weaknesses.add('Shot accuracy could be better');
      recommendations.add('Practice fundamental shots and focus on alignment');
    }

    final positionQuality = stats['positionQuality'] as Map<String, int>? ?? {};
    final perfectCount = positionQuality['perfect'] ?? 0;
    final badCount = positionQuality['bad'] ?? 0;

    if (shots.length >= 10 && perfectCount > shots.length * 0.3) {
      strengths.add('Great position play!');
    }
    if (shots.length >= 10 && badCount > shots.length * 0.2) {
      weaknesses.add('Position play needs work');
      recommendations.add('Work on speed control and cue ball spin');
    }

    final breakAndRuns = stats['breakAndRuns'] as int? ?? 0;
    if (breakAndRuns > 0) {
      strengths.add('$breakAndRuns break and run(s)!');
    }

    if (recommendations.isEmpty && (racks.length >= 3 || shots.length >= 10)) {
      recommendations.add('Keep up the good work and stay consistent!');
    }

    return (strengths, weaknesses, recommendations);
  }

  List<String> _checkAchievements(List<Match> matches, List<Rack> racks,
      List<Shot> shots, Map<String, dynamic> stats) {
    final achievements = <String>[];
    final wins = stats['wins'] as int? ?? 0;
    final accuracy = stats['accuracy'] as double? ?? 0.0;
    final breakAndRuns = stats['breakAndRuns'] as int? ?? 0;

    if (wins >= 1) {
      achievements.add('First Win - You won at least one rack!');
    }
    if (shots.length >= 10 && accuracy >= 0.9) {
      achievements.add('Sharp Shooter - 90%+ accuracy in a session!');
    }
    if (breakAndRuns >= 1) {
      achievements.add('Break & Run - Completed a rack without a miss!');
    }
    if (racks.length >= 10) {
      achievements.add('Iron Player - Completed 10+ racks in one session!');
    }
    if (wins >= 5) {
      achievements.add('Hot Streak - Won 5+ racks in one session!');
    }

    return achievements;
  }

  String _generateCoachSummary(Map<String, dynamic> stats) {
    final winRate = (stats['winRate'] as double? ?? 0.0) * 100;
    final accuracy = (stats['accuracy'] as double? ?? 0.0) * 100;
    final totalRacks = stats['totalRacks'] as int? ?? 0;
    final totalShots = stats['totalShots'] as int? ?? 0;
    final breakAndRuns = stats['breakAndRuns'] as int? ?? 0;

    final summary = StringBuffer();

    if (totalRacks >= 3 && winRate >= 70) {
      summary.writeln(
          'Outstanding performance today! Your win rate of ${winRate.toStringAsFixed(1)}% shows excellent game control.');
    } else if (totalRacks >= 3 && winRate >= 50) {
      summary.writeln(
          'Good session overall. Your ${winRate.toStringAsFixed(1)}% win rate indicates solid performance.');
    } else if (totalRacks >= 3) {
      summary.writeln(
          'Keep working at it! Focus on the fundamentals to improve your win rate.');
    }

    if (totalShots >= 10 && accuracy >= 80) {
      summary.writeln(
          'Your shot making was excellent at ${accuracy.toStringAsFixed(1)}% accuracy.');
    } else if (totalShots >= 10 && accuracy >= 60) {
      summary.writeln(
          'Shot accuracy of ${accuracy.toStringAsFixed(1)}% is a good foundation to build on.');
    } else if (totalShots >= 10) {
      summary.writeln(
          'Consider spending more time on basic shot practice to improve your ${accuracy.toStringAsFixed(1)}% accuracy.');
    }

    if (breakAndRuns > 0) {
      summary
          .writeln('Impressive break and run(s) today - great ball control!');
    }

    if (totalRacks >= 10) {
      summary.writeln(
          'You completed $totalRacks racks today - great dedication to practice!');
    }

    return summary.toString().trim();
  }

  String _getRecommendedDrill(Map<String, dynamic> stats) {
    final accuracy = stats['accuracy'] as double? ?? 0.0;
    final totalShots = stats['totalShots'] as int? ?? 0;
    final totalRacks = stats['totalRacks'] as int? ?? 0;
    final positionQuality = stats['positionQuality'] as Map<String, int>? ?? {};
    final badCount = positionQuality['bad'] ?? 0;
    final goodCount = positionQuality['good'] ?? 0;

    if (totalShots < 10 && totalRacks < 3) return '';
    if (accuracy < 0.6) {
      return 'Straight Shot Drill - Practice hitting straight shots at different distances to improve accuracy and alignment.';
    } else if (badCount > goodCount) {
      return 'Position Play Drill - Practice getting the cue ball to specific positions after each shot to improve control.';
    }
    return '3-Ball Drill - Practice pocketing three balls in sequence, focusing on position for the next shot.';
  }
}

class SessionSummaryScreen extends ConsumerWidget {
  final int sessionId;

  const SessionSummaryScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(sessionSummaryProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('session_summary')),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(child: Text(state.error!))
              : _buildContent(context, state, l10n),
    );
  }

  Widget _buildContent(
      BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
    final stats = state.stats;
    final winRate = stats['winRate'] as double? ?? 0.0;
    final accuracy = stats['accuracy'] as double? ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPerformanceScore(context, winRate, accuracy, l10n),
          const SizedBox(height: 24),
          _buildStatsGrid(context, state, l10n),
          const SizedBox(height: 24),
          if (state.achievements.isNotEmpty) ...[
            _buildAchievements(context, state, l10n),
            const SizedBox(height: 24),
          ],
          if (state.strengths.isNotEmpty || state.weaknesses.isNotEmpty) ...[
            _buildStrengthsWeaknesses(context, state, l10n),
            const SizedBox(height: 24),
          ],
          if (state.coachSummary.isNotEmpty) ...[
            _buildCoachSummary(context, state, l10n),
            const SizedBox(height: 24),
          ],
          if (state.recommendedDrill.isNotEmpty) ...[
            _buildRecommendedDrill(context, state, l10n),
            const SizedBox(height: 24),
          ],
          if (state.recommendations.isNotEmpty) ...[
            _buildRecommendations(context, state, l10n),
            const SizedBox(height: 32),
          ],
          _buildDoneButton(context, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPerformanceScore(
    BuildContext context,
    double winRate,
    double accuracy,
    AppLocalizations l10n,
  ) {
    final performanceScore = ((winRate * 0.4 + accuracy * 0.6) * 100).round();
    final color = _getScoreColor(performanceScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.get('performance_score'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(51),
                border: Border.all(color: color, width: 4),
              ),
              child: Center(
                child: Text(
                  '$performanceScore',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreDetail(
                  context,
                  '${(winRate * 100).toInt()}%',
                  l10n.get('rack_win'),
                  winRate >= 0.5 ? Colors.green : Colors.red,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withAlpha(51),
                ),
                _buildScoreDetail(
                  context,
                  '${(accuracy * 100).toInt()}%',
                  l10n.get('shot_made'),
                  accuracy >= 0.7 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreDetail(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(
      BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('session_stats'),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(context, l10n.get('sessions'),
                    '${stats['totalMatches'] ?? 0}'),
                const Divider(),
                _buildStatRow(context, l10n.get('rack_count'),
                    '${stats['totalRacks'] ?? 0}'),
                const Divider(),
                _buildStatRow(
                  context,
                  l10n.get('rack_win'),
                  '${stats['wins'] ?? 0}',
                  suffix: '/${stats['totalRacks'] ?? 0}',
                ),
                const Divider(),
                _buildStatRow(context, l10n.get('shot_count'),
                    '${stats['totalShots'] ?? 0}'),
                const Divider(),
                _buildStatRow(
                  context,
                  l10n.get('break_and_run'),
                  '${stats['breakAndRuns'] ?? 0}',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value,
      {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            '$value$suffix',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(
      BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('achievements'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          color: Colors.amber.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: state.achievements
                  .map(
                    (achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(
                                  _localizedNarrative(context, achievement))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrengthsWeaknesses(
    BuildContext context,
    SessionSummaryState state,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.strengths.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.thumb_up, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.get('strengths'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.strengths
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                            Expanded(
                                child: Text(_localizedNarrative(context, s))),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (state.weaknesses.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.trending_down, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.get('weaknesses'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.orange.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.weaknesses
                    .map(
                      (w) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                            Expanded(
                                child: Text(_localizedNarrative(context, w))),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCoachSummary(
    BuildContext context,
    SessionSummaryState state,
    AppLocalizations l10n,
  ) {
    if (state.coachSummary.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('coach_summary'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          color: Colors.blue.withAlpha(13),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.coachSummary
                  .split('\n')
                  .where((line) => line.trim().isNotEmpty)
                  .map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(
                              child: Text(
                                  _localizedNarrative(context, line.trim()))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedDrill(
    BuildContext context,
    SessionSummaryState state,
    AppLocalizations l10n,
  ) {
    if (state.recommendedDrill.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.fitness_center, color: Colors.purple, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('recommended_drill'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow,
                              size: 16, color: Colors.purple),
                          SizedBox(width: 4),
                          Text(
                            l10n.get('suggested'),
                            style:
                                TextStyle(color: Colors.purple, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _localizedNarrative(context, state.recommendedDrill),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(
    BuildContext context,
    SessionSummaryState state,
    AppLocalizations l10n,
  ) {
    if (state.recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('training_advice'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.recommendations
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(
                              child: Text(_localizedNarrative(context, r))),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _localizedNarrative(BuildContext context, String text) {
    if (Localizations.localeOf(context).languageCode != 'vi') return text;
    const translations = <String, String>{
      'Excellent win rate this session!': 'Tỷ lệ thắng trong buổi này rất tốt.',
      'Win rate needs improvement': 'Tỷ lệ thắng cần được cải thiện.',
      'Focus on position play to create more opportunities':
          'Tập trung điều bi để tạo thêm cơ hội.',
      'Outstanding shot making!': 'Khả năng thực hiện cú đánh rất tốt.',
      'Shot accuracy could be better':
          'Độ chính xác cú đánh cần được cải thiện.',
      'Practice fundamental shots and focus on alignment':
          'Luyện cú đánh cơ bản và tập trung căn chỉnh.',
      'Great position play!': 'Khả năng điều bi rất tốt.',
      'Position play needs work': 'Khả năng điều bi cần được cải thiện.',
      'Work on speed control and cue ball spin':
          'Luyện kiểm soát tốc độ và xoáy bi cái.',
      'Keep up the good work and stay consistent!':
          'Tiếp tục duy trì và giữ sự ổn định.',
      'First Win - You won at least one rack!':
          'Chiến thắng đầu tiên - Bạn đã thắng ít nhất một ván.',
      'Sharp Shooter - 90%+ accuracy in a session!':
          'Tay cơ chính xác - Đạt trên 90% trong một buổi.',
      'Break & Run - Completed a rack without a miss!':
          'Phá và dọn bàn - Hoàn thành một ván không đánh hỏng.',
      'Iron Player - Completed 10+ racks in one session!':
          'Bền bỉ - Hoàn thành ít nhất 10 ván trong một buổi.',
      'Hot Streak - Won 5+ racks in one session!':
          'Chuỗi thắng - Thắng ít nhất 5 ván trong một buổi.',
      'Straight Shot Drill - Practice hitting straight shots at different distances to improve accuracy and alignment.':
          'Bài tập cú thẳng - Luyện cú thẳng ở nhiều khoảng cách để cải thiện độ chính xác và căn chỉnh.',
      'Position Play Drill - Practice getting the cue ball to specific positions after each shot to improve control.':
          'Bài tập điều bi - Đưa bi cái đến vị trí xác định sau mỗi cú để cải thiện kiểm soát.',
      'Advanced Combination Drill - Work on combination shots and carom shots to expand your offensive arsenal.':
          'Bài tập phối hợp nâng cao - Luyện combo và carom để mở rộng phương án tấn công.',
      '3-Ball Drill - Practice pocketing three balls in sequence, focusing on position for the next shot.':
          'Bài tập 3 bi - Đánh ba bi liên tiếp và tập trung vị trí cho cú kế tiếp.',
    };
    final fixed = translations[text];
    if (fixed != null) return fixed;
    if (text.contains('break and run(s)!')) {
      return text.replaceAll('break and run(s)!', 'lần phá và dọn bàn.');
    }
    if (text.startsWith('Outstanding performance today!')) {
      return 'Phong độ hôm nay rất tốt; dữ liệu cho thấy bạn kiểm soát trận đấu hiệu quả.';
    }
    if (text.startsWith('Good session overall.')) {
      return 'Buổi chơi nhìn chung tốt và có phong độ ổn định.';
    }
    if (text.startsWith('Keep working at it!')) {
      return 'Tiếp tục luyện các yếu tố cơ bản để cải thiện tỷ lệ thắng.';
    }
    if (text.startsWith('Your shot making was excellent')) {
      return 'Khả năng thực hiện cú đánh trong buổi này rất tốt.';
    }
    if (text.startsWith('Shot accuracy of')) {
      return 'Độ chính xác là nền tảng tốt để tiếp tục phát triển.';
    }
    if (text.startsWith('Consider spending more time')) {
      return 'Nên dành thêm thời gian luyện cú cơ bản để cải thiện độ chính xác.';
    }
    if (text.startsWith('Impressive break and run')) {
      return 'Khả năng kiểm soát bi trong các ván phá và dọn bàn rất tốt.';
    }
    if (text.startsWith('You completed')) {
      return 'Bạn đã hoàn thành nhiều ván trong buổi này, cho thấy khối lượng luyện tập tốt.';
    }
    return text;
  }

  Widget _buildDoneButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.get('done')),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }
}
