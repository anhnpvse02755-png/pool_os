import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';
import 'package:pool_os/features/statistics/presentation/widgets/win_rate_detail_widget.dart';
import 'package:pool_os/features/statistics/presentation/widgets/rack_detail_widget.dart';
import 'package:pool_os/features/statistics/presentation/widgets/shot_statistics_widget.dart';
import 'package:pool_os/features/statistics/presentation/widgets/error_statistics_widget.dart';
import 'package:pool_os/features/statistics/presentation/widgets/break_statistics_widget.dart';
import 'package:pool_os/features/statistics/domain/models/statistics.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statisticsNotifierProvider.notifier).loadStats();
      ref.read(statisticsNotifierProvider.notifier).loadCareerStats();
      ref.read(statisticsNotifierProvider.notifier).loadEventStats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(statisticsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('statistics')),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.get('career')),
            Tab(text: l10n.get('skill_dashboard')),
            Tab(text: l10n.get('trend_dashboard')),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCareerTab(context, state, l10n),
                _buildSkillTab(context, state, l10n),
                _buildTrendTab(context, state, l10n),
              ],
            ),
    );
  }

  Widget _buildCareerTab(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('career_dashboard'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildOverallStats(context, state, l10n),
          const SizedBox(height: 24),
          _buildDetailedStats(context, state, l10n),
          const SizedBox(height: 24),
          _buildEventStats(context, state, l10n),
          const SizedBox(height: 24),
          _buildStatisticsCategories(context, state, l10n),
        ],
      ),
    );
  }

  Widget _buildOverallStats(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverallStat(
                  context,
                  state.totalSessions.toString(),
                  l10n.get('sessions'),
                  Icons.sports_bar,
                  Colors.blue,
                  l10n,
                  StatDefinition(
                    name: l10n.get('sessions'),
                    definition: l10n.get('stat_sessions_definition'),
                    calculation: l10n.get('stat_sessions_calculation'),
                    trend: _getPerformanceTrend(state.totalSessions > 0 ? 0.6 : 0.0),
                    target: l10n.get('stat_sessions_target'),
                    advice: l10n.get('stat_sessions_advice'),
                  ),
                ),
                _buildOverallStat(
                  context,
                  state.totalRacks.toString(),
                  l10n.get('rack_count'),
                  Icons.grid_view,
                  Colors.green,
                  l10n,
                  StatDefinition(
                    name: l10n.get('rack_count'),
                    definition: 'Total number of racks (frames) completed',
                    calculation: 'Sum of all rack records across sessions',
                    trend: 'Stable',
                    target: 'Complete at least 50 racks per practice session',
                    advice: 'Focus on completing racks rather than just shooting. Each completed rack builds mental stamina.',
                  ),
                ),
                _buildOverallStat(
                  context,
                  '${(state.rackWinRate * 100).toInt()}%',
                  l10n.get('rack_win'),
                  Icons.emoji_events,
                  Colors.amber,
                  l10n,
                  StatDefinition(
                    name: l10n.get('rack_win'),
                    definition: 'Percentage of racks won out of total completed',
                    calculation: '(Wins / Total Racks) x 100',
                    trend: 'Stable',
                    target: 'Aim for 60%+ win rate in practice',
                    advice: 'Work on position play and shot selection to improve your win rate.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOverallStat(
                  context,
                  state.totalShots.toString(),
                  l10n.get('shot_count'),
                  Icons.gps_fixed,
                  Colors.purple,
                  l10n,
                  StatDefinition(
                    name: l10n.get('shot_count'),
                    definition: 'Total number of shots attempted across all racks',
                    calculation: 'Sum of all shot records',
                    trend: 'Stable',
                    target: 'Quality over quantity - focus on making each shot count',
                    advice: 'Track both made and missed shots to identify patterns in your game.',
                  ),
                ),
                _buildOverallStat(
                  context,
                  '${(state.careerAccuracy * 100).toInt()}%',
                  l10n.get('shot_made'),
                  Icons.check_circle,
                  Colors.teal,
                  l10n,
                  StatDefinition(
                    name: l10n.get('shot_made'),
                    definition: 'Percentage of shots successfully made',
                    calculation: '(Made Shots / Total Shots) x 100',
                    trend: 'Stable',
                    target: 'Elite players achieve 70%+ accuracy',
                    advice: 'Practice fundamental shots until they become automatic. Focus on alignment and follow-through.',
                  ),
                ),
                _buildOverallStat(
                  context,
                  state.totalEvents.toString(),
                  l10n.get('event_count'),
                  Icons.event,
                  Colors.orange,
                  l10n,
                  StatDefinition(
                    name: l10n.get('event_count'),
                    definition: 'Number of notable events (great shots, mistakes, mental moments)',
                    calculation: 'Count of recorded events across sessions',
                    trend: 'Stable',
                    target: 'Learn from every event - positive or negative',
                    advice: 'Review your events to understand what triggers great shots or mistakes.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    AppLocalizations l10n,
    StatDefinition definition,
  ) {
    return GestureDetector(
      onTap: () => _showStatDetailDialog(context, definition, l10n),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(26),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  void _showStatDetailDialog(
      BuildContext context, StatDefinition definition, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(definition.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow(ctx, l10n.get('definition'), definition.definition),
              const SizedBox(height: 12),
              _buildDetailRow(ctx, l10n.get('calculation'), definition.calculation),
              const SizedBox(height: 12),
              _buildDetailRow(ctx, l10n.get('trend'), definition.getTrendText(l10n)),
              const SizedBox(height: 12),
              _buildDetailRow(ctx, l10n.get('target'), definition.target),
              const SizedBox(height: 12),
              _buildDetailRow(ctx, l10n.get('advice'), definition.advice),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext ctx, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }

  Widget _buildDetailedStats(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    final commonMiss = _guessCommonMiss(state, l10n);
    final recommendation = _guessRecommendation(state, commonMiss, l10n);

    final stats = [
      _buildStatBlock(
        l10n,
        category: l10n.get('stat_category'),
        metric: l10n.get('total_wins'),
        detail: l10n.get('stat_match_won'),
        recommendation: recommendation,
        value: state.totalWins.toString(),
        color: Colors.green,
      ),
      _buildStatBlock(
        l10n,
        category: l10n.get('stat_category'),
        metric: l10n.get('total_losses'),
        detail: l10n.get('stat_common_mistakes'),
        recommendation: recommendation,
        value: state.totalLosses.toString(),
        color: Colors.red,
      ),
      _buildStatBlock(
        l10n,
        category: l10n.get('stat_category'),
        metric: l10n.get('win_rate'),
        detail: l10n.get('stat_accuracy_trend'),
        recommendation: recommendation,
        value: '${(state.rackWinRate * 100).toStringAsFixed(1)}%',
        color: Colors.blue,
      ),
      _buildStatBlock(
        l10n,
        category: l10n.get('stat_category'),
        metric: l10n.get('shot_accuracy'),
        detail: l10n.get('stat_main_reason'),
        recommendation: recommendation,
        value: '${(state.careerAccuracy * 100).toStringAsFixed(1)}%',
        color: Colors.teal,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('detailed_stats'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildStatRow(
                context,
                l10n.get('total_wins'),
                state.totalWins.toString(),
                Colors.green,
                stats[0],
                l10n,
              ),
              const Divider(height: 1),
              _buildStatRow(
                context,
                l10n.get('total_losses'),
                state.totalLosses.toString(),
                Colors.red,
                stats[1],
                l10n,
              ),
              const Divider(height: 1),
              _buildStatRow(
                context,
                l10n.get('win_rate'),
                '${(state.rackWinRate * 100).toStringAsFixed(1)}%',
                Colors.blue,
                stats[2],
                l10n,
              ),
              const Divider(height: 1),
              _buildStatRow(
                context,
                l10n.get('shot_accuracy'),
                '${(state.careerAccuracy * 100).toStringAsFixed(1)}%',
                Colors.teal,
                stats[3],
                l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    StatDefinition definition,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => _showStatDetailDialog(context, definition, l10n),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventStats(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    if (state.totalEvents == 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('event_analysis'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.get('total_events')}: ${state.totalEvents}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                if (state.eventCategoryStats.isNotEmpty) ...[
                  Text(
                    l10n.get('by_category'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.eventCategoryStats.entries.map((e) {
                      return Chip(
                        label: Text('${e.key}: ${e.value}'),
                        backgroundColor: _getCategoryColor(e.key).withAlpha(26),
                        labelStyle: TextStyle(
                          color: _getCategoryColor(e.key),
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'stroke':
        return Colors.blue;
      case 'position':
        return Colors.green;
      case 'decision':
        return Colors.orange;
      case 'mental':
        return Colors.purple;
      case 'break':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildSkillTab(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('skill_dashboard'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          if (state.skillStats.isEmpty)
            _buildEmptySkillsState(context, l10n)
          else
            ...state.skillStats.map((s) => _buildSkillCard(context, s, l10n)),
        ],
      ),
    );
  }

  Widget _buildEmptySkillsState(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.psychology_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.get('no_skills_yet'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.get('play_more_sessions_skills'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkillCard(
      BuildContext context, SkillStat skill, AppLocalizations l10n) {
    final color = _getSkillColor(skill.value);
    final label = _getSkillLabel(skill.value, l10n);
    final definition = _getSkillDefinition(skill.skill, l10n);
    final trend = _getSkillTrend(skill, l10n);
    final target = _getSkillTarget(skill.skill);
    final advice = _getSkillAdvice(skill.skill, skill.value);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showSkillDetailDialog(context, skill, definition, trend,
            target, advice, color, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      skill.skill,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: skill.value,
                        backgroundColor: Colors.grey.withAlpha(51),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(skill.value * 100).toInt()}%',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTrendBadge(context, trend, l10n),
                  const SizedBox(width: 8),
                  if (skill.sampleSize != null)
                    Text(
                      '${skill.sampleSize} ${l10n.get('data_points')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  const Spacer(),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendBadge(
      BuildContext context, String trend, AppLocalizations l10n) {
    Color trendColor;
    IconData trendIcon;

    if (trend.contains('up') || trend.contains('Improving')) {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (trend.contains('down') || trend.contains('Declining')) {
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
    } else {
      trendColor = Colors.grey;
      trendIcon = Icons.trending_flat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: trendColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trendIcon, size: 12, color: trendColor),
          const SizedBox(width: 4),
          Text(
            trend,
            style: TextStyle(fontSize: 10, color: trendColor),
          ),
        ],
      ),
    );
  }

  void _showSkillDetailDialog(
    BuildContext context,
    SkillStat skill,
    String definition,
    String trend,
    String target,
    String advice,
    Color color,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(skill.skill)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailSection(l10n.get('definition'), definition),
              const SizedBox(height: 12),
              _buildDetailSection(l10n.get('current_value'),
                  '${(skill.value * 100).toInt()}%'),
              const SizedBox(height: 12),
              _buildDetailSection(l10n.get('calculation'),
                  _getSkillCalculation(skill.skill, l10n)),
              const SizedBox(height: 12),
              _buildDetailSection(l10n.get('trend'), trend),
              const SizedBox(height: 12),
              _buildDetailSection(l10n.get('target'), target),
              const SizedBox(height: 12),
              _buildDetailSection(l10n.get('advice'), advice),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.get('close')),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(content),
      ],
    );
  }

  String _getSkillDefinition(String skill, AppLocalizations l10n) {
    switch (skill.toLowerCase()) {
      case 'stroke':
        return l10n.get('skill_stroke_desc');
      case 'position':
        return l10n.get('skill_position_desc');
      case 'decision':
        return l10n.get('skill_decision_desc');
      case 'pattern':
        return l10n.get('skill_pattern_desc');
      case 'break':
        return l10n.get('skill_break_desc');
      case 'safety':
        return l10n.get('skill_safety_desc');
      case 'mental':
        return l10n.get('skill_mental_desc');
      case 'consistency':
        return l10n.get('skill_consistency_desc');
      case 'equipment':
        return l10n.get('skill_equipment_desc');
      case 'recovery':
        return l10n.get('skill_recovery_desc');
      default:
        return 'Skill in $skill';
    }
  }

  String _getSkillCalculation(String skill, AppLocalizations l10n) {
    return 'Based on shot analysis and performance metrics from recent sessions';
  }

  String _getSkillTrend(SkillStat skill, AppLocalizations l10n) {
    if (skill.trend == null) {
      return l10n.get('skill_stable');
    }
    if (skill.trend! > 0.05) {
      return l10n.get('skill_improving');
    } else if (skill.trend! < -0.05) {
      return l10n.get('skill_declining');
    }
    return l10n.get('skill_stable');
  }

  String _getSkillTarget(String skill) {
    switch (skill.toLowerCase()) {
      case 'stroke':
        return '80%+ accuracy on all shot types';
      case 'position':
        return 'Get cue ball to ideal position 70%+ of the time';
      case 'decision':
        return 'Make optimal shot selection 75%+ of the time';
      case 'pattern':
        return 'Complete patterns without misses 60%+ of the time';
      case 'break':
        return 'Pocket a ball and have a makeable 2nd shot 60%+ of the time';
      case 'safety':
        return 'Win safety exchanges 55%+ of the time';
      case 'mental':
        return 'Maintain focus and composure throughout sessions';
      case 'consistency':
        return 'Keep performance variance below 15% across sessions';
      case 'equipment':
        return 'Adapt quickly to different cues and table conditions';
      case 'recovery':
        return 'Recover from mistakes without major momentum loss';
      default:
        return 'Improve to 75%+ level';
    }
  }

  String _getSkillAdvice(String skill, double value) {
    if (value >= 0.8) {
      return 'Excellent! Focus on maintaining this level and pushing for mastery.';
    } else if (value >= 0.6) {
      return 'Good progress. Continue practicing to reach the next level.';
    } else if (value >= 0.4) {
      return 'Room for improvement. Dedicate focused practice time to this area.';
    }
    return 'Needs attention. Start with fundamentals and build gradually.';
  }

  Color _getSkillColor(double value) {
    if (value >= 0.8) return Colors.green;
    if (value >= 0.6) return Colors.lightGreen;
    if (value >= 0.4) return Colors.amber;
    if (value >= 0.2) return Colors.orange;
    return Colors.red;
  }

  String _getSkillLabel(double value, AppLocalizations l10n) {
    if (value >= 0.8) return l10n.get('skill_excellent');
    if (value >= 0.6) return l10n.get('skill_advanced');
    if (value >= 0.4) return l10n.get('skill_intermediate');
    if (value >= 0.2) return l10n.get('skill_developing');
    return l10n.get('skill_needs_improvement');
  }

  Widget _buildTrendTab(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.get('trend_dashboard'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildTrendCard(
            context,
            l10n.get('weekly_performance'),
            Icons.calendar_view_week,
            Colors.blue,
            [
              '${l10n.get('sessions')}: ${state.totalSessions}',
              '${l10n.get('rack_count')}: ${state.totalRacks}',
              '${l10n.get('win_rate')}: ${(state.rackWinRate * 100).toStringAsFixed(1)}%',
            ],
            StatDefinition(
              name: l10n.get('weekly_performance'),
              definition: 'Your performance metrics over the tracked period',
              calculation: 'Aggregated from all sessions and racks',
              trend: _getPerformanceTrend(state.rackWinRate),
              target: 'Improve by 5% each week',
              advice: 'Review what worked and what didn\'t. Adjust practice focus accordingly.',
            ),
            l10n,
          ),
          const SizedBox(height: 12),
          _buildTrendCard(
            context,
            l10n.get('accuracy_trend'),
            Icons.trending_up,
            Colors.green,
            [
              '${l10n.get('career_accuracy')}: ${(state.careerAccuracy * 100).toStringAsFixed(1)}%',
              '${l10n.get('recent_performance')}: ${_getPerformanceTrend(state.careerAccuracy)}',
            ],
            StatDefinition(
              name: l10n.get('accuracy_trend'),
              definition: 'How your shot-making accuracy has changed over time',
              calculation: 'Rolling average of shot success rate',
              trend: _getAccuracyTrend(state.careerAccuracy),
              target: 'Reach and maintain 70%+ accuracy',
              advice: 'Focus on alignment and cue delivery. Record your practice sessions to review.',
            ),
            l10n,
          ),
          const SizedBox(height: 24),
          _buildImprovementTips(context, state, l10n),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<String> details,
    StatDefinition definition,
    AppLocalizations l10n,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showStatDetailDialog(context, definition, l10n),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Icon(Icons.info_outline, size: 16, color: Colors.grey.shade400),
                ],
              ),
              const SizedBox(height: 12),
              ...details.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Text('• '),
                      Expanded(child: Text(d)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPerformanceTrend(double accuracy) {
    if (accuracy >= 0.75) return 'Excellent';
    if (accuracy >= 0.6) return 'Good';
    if (accuracy >= 0.45) return 'Average';
    return 'Needs Improvement';
  }

  String _getAccuracyTrend(double accuracy) {
    if (accuracy >= 0.7) return 'Improving';
    if (accuracy >= 0.5) return 'Stable';
    return 'Needs Focus';
  }

  Widget _buildImprovementTips(
      BuildContext context, StatisticsState state, AppLocalizations l10n) {
    final tips = <String>[];
    final vi = Localizations.localeOf(context).languageCode == 'vi';

    if (state.rackWinRate < 0.5) {
      tips.add(vi
          ? 'Tập trung điều bi để tạo thêm cơ hội ghi điểm'
          : 'Focus on position play to create more scoring opportunities');
    }
    if (state.careerAccuracy < 0.7) {
      tips.add(vi
          ? 'Luyện các cú đánh cơ bản và kỹ thuật căn chỉnh'
          : 'Practice fundamental shots and alignment techniques');
    }
    if (state.totalSessions < 10) {
      tips.add(vi
          ? 'Chơi thêm buổi để xây dựng dữ liệu ổn định'
          : 'Play more sessions to build consistent data');
    }

    if (tips.isEmpty) {
      tips.add(vi
          ? 'Tiếp tục duy trì, phong độ của bạn đang rất tốt.'
          : 'Keep up the great work! Your performance is excellent.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.get('improvement_tips'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips
                  .map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• '),
                          Expanded(child: Text(tip)),
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

  String _guessCommonMiss(StatisticsState state, AppLocalizations l10n) {
    if (state.careerAccuracy < 0.5) return l10n.get('stat_most_frequent_error');
    if (state.rackWinRate < 0.5) return l10n.get('stat_common_miss_type');
    return l10n.get('stat_most_frequent_error');
  }

  // ignore: unused_element - Reserved for future Statistics UI enhancement
  String _guessCommonStrength(StatisticsState state, AppLocalizations l10n) {
    if (state.rackWinRate >= 0.6) return l10n.get('stat_common_strengths');
    if (state.careerAccuracy >= 0.7) return l10n.get('stat_common_strengths');
    return l10n.get('stat_coach_insight');
  }

  String _guessRecommendation(StatisticsState state, String commonMiss, AppLocalizations l10n) {
    if (state.rackWinRate < 0.5) {
      return l10n.get('focus_position_play');
    }
    if (state.careerAccuracy < 0.7) {
      return l10n.get('practice_fundamentals');
    }
    if (state.totalSessions < 10) {
      return l10n.get('play_more_sessions');
    }
    return l10n.get('keep_up_great_work');
  }

  StatDefinition _buildStatBlock(
    AppLocalizations l10n, {
    required String category,
    required String metric,
    required String detail,
    required String recommendation,
    required String value,
    required Color color,
  }) {
    return StatDefinition(
      name: metric,
      definition: '$category: $metric',
      calculation: detail,
      trend: _getPerformanceTrend(
        double.tryParse(value.replaceAll('%', '')) ?? 0.0,
      ),
      target: recommendation,
      advice: l10n.get('stat_insight_benefit'),
    );
  }

  // FIX-009B: Statistics category cards for drill-down navigation
  Widget _buildStatisticsCategories(BuildContext context, StatisticsState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('detailed_statistics'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildCategoryTile(
                context,
                l10n.get('win_rate_detail'),
                Icons.sports_score,
                Colors.blue,
                () => _navigateToDetail(context, l10n.get('win_rate_detail'), const WinRateDetailWidget()),
                l10n,
              ),
              const Divider(height: 1),
              _buildCategoryTile(
                context,
                l10n.get('rack_detail'),
                Icons.grid_view,
                Colors.green,
                () => _navigateToDetail(context, l10n.get('rack_detail'), const RackDetailWidget()),
                l10n,
              ),
              const Divider(height: 1),
              _buildCategoryTile(
                context,
                l10n.get('shot_statistics'),
                Icons.gps_fixed,
                Colors.purple,
                () => _navigateToDetail(context, l10n.get('shot_statistics'), const ShotStatisticsWidget()),
                l10n,
              ),
              const Divider(height: 1),
              _buildCategoryTile(
                context,
                l10n.get('error_statistics'),
                Icons.error_outline,
                Colors.orange,
                () => _navigateToDetail(context, l10n.get('error_statistics'), const ErrorStatisticsWidget()),
                l10n,
              ),
              const Divider(height: 1),
              _buildCategoryTile(
                context,
                l10n.get('break_statistics'),
                Icons.sports_bar,
                Colors.teal,
                () => _navigateToDetail(context, l10n.get('break_statistics'), const BreakStatisticsWidget()),
                l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    AppLocalizations l10n,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _navigateToDetail(BuildContext context, String title, Widget child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: child,
        ),
      ),
    );
  }
}

class StatDefinition {
  final String name;
  final String definition;
  final String calculation;
  final String trend;
  final String target;
  final String advice;

  const StatDefinition({
    required this.name,
    required this.definition,
    required this.calculation,
    required this.trend,
    required this.target,
    required this.advice,
  });

  String getTrendText(AppLocalizations l10n) {
    if (trend.isEmpty) return l10n.get('skill_stable');
    return trend;
  }
}
