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

final sessionSummaryProvider = StateNotifierProvider.family<SessionSummaryNotifier, SessionSummaryState, int>(
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
      final analysis = _analyzeSession(matches, allRacks, allShots);
      final achievements = _checkAchievements(matches, allRacks, allShots, stats);
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

  Map<String, dynamic> _calculateStats(List<Match> matches, List<Rack> racks, List<Shot> shots) {
    final totalRacks = racks.length;
    final wins = racks.where((r) => r.result).length;
    final totalShots = shots.length;
    final madeShots = shots.where((s) => s.isMade).length;

    int breakAndRuns = 0;
    final positionQuality = <String, int>{};
    final shotTypes = <String, int>{};

    for (final shot in shots) {
      if (shot.positionQuality != null) {
        positionQuality[shot.positionQuality!] = (positionQuality[shot.positionQuality!] ?? 0) + 1;
      }
    }

    for (final rack in racks) {
      if (rack.result && shots.where((s) => s.rackId == rack.id).length >= 3) {
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
  ) {
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations = <String>[];

    final winRate = racks.isNotEmpty ? racks.where((r) => r.result).length / racks.length : 0.0;
    final accuracy = shots.isNotEmpty ? shots.where((s) => s.isMade).length / shots.length : 0.0;

    if (winRate >= 0.7) {
      strengths.add('Excellent win rate this session!');
    } else if (winRate < 0.4) {
      weaknesses.add('Win rate needs improvement');
      recommendations.add('Focus on position play to create more opportunities');
    }

    if (accuracy >= 0.85) {
      strengths.add('Outstanding shot making!');
    } else if (accuracy < 0.6) {
      weaknesses.add('Shot accuracy could be better');
      recommendations.add('Practice fundamental shots and focus on alignment');
    }

    final positionQuality = state.stats['positionQuality'] as Map<String, int>? ?? {};
    final perfectCount = positionQuality['perfect'] ?? 0;
    final badCount = positionQuality['bad'] ?? 0;

    if (perfectCount > shots.length * 0.3) {
      strengths.add('Great position play!');
    }
    if (badCount > shots.length * 0.2) {
      weaknesses.add('Position play needs work');
      recommendations.add('Work on speed control and cue ball spin');
    }

    final breakAndRuns = state.stats['breakAndRuns'] as int? ?? 0;
    if (breakAndRuns > 0) {
      strengths.add('$breakAndRuns break and run(s)!');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Keep up the good work and stay consistent!');
    }

    return (strengths, weaknesses, recommendations);
  }

  List<String> _checkAchievements(List<Match> matches, List<Rack> racks, List<Shot> shots, Map<String, dynamic> stats) {
    final achievements = <String>[];
    final wins = stats['wins'] as int? ?? 0;
    final accuracy = stats['accuracy'] as double? ?? 0.0;
    final breakAndRuns = stats['breakAndRuns'] as int? ?? 0;

    if (wins >= 1) {
      achievements.add('First Win - You won at least one rack!');
    }
    if (accuracy >= 0.9) {
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
    final breakAndRuns = stats['breakAndRuns'] as int? ?? 0;

    final summary = StringBuffer();

    if (winRate >= 70) {
      summary.writeln('Outstanding performance today! Your win rate of ${winRate.toStringAsFixed(1)}% shows excellent game control.');
    } else if (winRate >= 50) {
      summary.writeln('Good session overall. Your ${winRate.toStringAsFixed(1)}% win rate indicates solid performance.');
    } else {
      summary.writeln('Keep working at it! Focus on the fundamentals to improve your win rate.');
    }

    if (accuracy >= 80) {
      summary.writeln('Your shot making was excellent at ${accuracy.toStringAsFixed(1)}% accuracy.');
    } else if (accuracy >= 60) {
      summary.writeln('Shot accuracy of ${accuracy.toStringAsFixed(1)}% is a good foundation to build on.');
    } else {
      summary.writeln('Consider spending more time on basic shot practice to improve your ${accuracy.toStringAsFixed(1)}% accuracy.');
    }

    if (breakAndRuns > 0) {
      summary.writeln('Impressive break and run(s) today - great ball control!');
    }

    if (totalRacks >= 10) {
      summary.writeln('You completed $totalRacks racks today - great dedication to practice!');
    }

    return summary.toString().trim();
  }

  String _getRecommendedDrill(Map<String, dynamic> stats) {
    final accuracy = stats['accuracy'] as double? ?? 0.0;
    final positionQuality = stats['positionQuality'] as Map<String, int>? ?? {};
    final badCount = positionQuality['bad'] ?? 0;
    final goodCount = positionQuality['good'] ?? 0;

    if (accuracy < 0.6) {
      return 'Straight Shot Drill - Practice hitting straight shots at different distances to improve accuracy and alignment.';
    } else if (badCount > goodCount) {
      return 'Position Play Drill - Practice getting the cue ball to specific positions after each shot to improve control.';
    } else if (accuracy >= 0.8) {
      return 'Advanced Combination Drill - Work on combination shots and carom shots to expand your offensive arsenal.';
    } else {
      return '3-Ball Drill - Practice pocketing three balls in sequence, focusing on position for the next shot.';
    }
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

  Widget _buildContent(BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
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
          _buildStrengthsWeaknesses(context, state, l10n),
          const SizedBox(height: 24),
          _buildCoachSummary(context, state, l10n),
          const SizedBox(height: 24),
          _buildRecommendedDrill(context, state, l10n),
          const SizedBox(height: 24),
          _buildRecommendations(context, state, l10n),
          const SizedBox(height: 32),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
    final stats = state.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('session_stats'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatRow(context, l10n.get('sessions'), '${stats['totalMatches'] ?? 0}'),
                const Divider(),
                _buildStatRow(context, l10n.get('rack_count'), '${stats['totalRacks'] ?? 0}'),
                const Divider(),
                _buildStatRow(
                  context,
                  l10n.get('rack_win'),
                  '${stats['wins'] ?? 0}',
                  suffix: '/${stats['totalRacks'] ?? 0}',
                ),
                const Divider(),
                _buildStatRow(context, l10n.get('shot_count'), '${stats['totalShots'] ?? 0}'),
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

  Widget _buildStatRow(BuildContext context, String label, String value, {String suffix = ''}) {
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

  Widget _buildAchievements(BuildContext context, SessionSummaryState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('achievements'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          Expanded(child: Text(achievement)),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            Expanded(child: Text(s)),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            Expanded(child: Text(w)),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          Expanded(child: Text(line.trim())),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 16, color: Colors.purple),
                          SizedBox(width: 4),
                          Text(
                            l10n.get('suggested'),
                            style: TextStyle(color: Colors.purple, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  state.recommendedDrill,
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          Expanded(child: Text(r)),
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
