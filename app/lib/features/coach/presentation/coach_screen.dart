import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/coach/presentation/coach_provider.dart';
import 'package:pool_os/features/coach/domain/coach_rule_engine.dart';
import 'package:pool_os/features/coach/domain/coach_recommendation_engine.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(coachProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('coach')),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.get('overview')),
            Tab(text: l10n.get('training')),
            Tab(text: l10n.get('insights')),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, state, l10n, locale),
                _buildTrainingTab(context, state, l10n, locale),
                _buildInsightsTab(context, state, l10n, locale),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(coachProvider.notifier).refreshData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildKPISection(context, state, l10n),
            const SizedBox(height: 24),
            _buildTrainingFocus(context, state, l10n, locale),
            const SizedBox(height: 24),
            _buildStrengthsWeaknesses(context, state, l10n, locale),
            const SizedBox(height: 24),
            _buildRecommendations(context, state, l10n, locale),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildKPISection(
      BuildContext context, CoachState state, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.get('coach_score'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                context,
                Icons.fitness_center,
                '${state.coachScore}',
                l10n.get('coach'),
                _getScoreColor(state.coachScore),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildKPICard(
                context,
                Icons.psychology,
                '${state.skillScore}',
                l10n.get('skill_radar'),
                _getScoreColor(state.skillScore),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildKPICard(
                context,
                Icons.trending_up,
                '${state.trendScore}',
                l10n.get('trend'),
                _getScoreColor(state.trendScore),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildKPICard(
                context,
                Icons.check_circle,
                '${state.readinessScore}',
                l10n.get('ready_score'),
                _getScoreColor(state.readinessScore),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
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

  Widget _buildTrainingFocus(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    final plan = state.trainingPlan;
    final recommendations = state.coachRecommendations;

    // If no training plan and no recommendations, show empty
    if ((plan == null || plan.isEmpty) && recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.flag, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              l10n.get('coach_todays_focus'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Primary Focus - First recommendation highlighted
        if (recommendations.isNotEmpty) ...[
          _buildPrimaryFocusCard(context, recommendations.first, l10n),
          const SizedBox(height: 8),
        ],
        // Secondary Focus - Intensity badge if available
        if (plan != null && !plan.isEmpty) ...[
          Card(
            color: _getIntensityColor(plan.intensity).withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getIntensityColor(plan.intensity),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getIntensityLabel(plan.intensity, l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${plan.totalDurationMinutes} ${l10n.get('minutes_short')}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (plan.hasMainDrills) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.fitness_center, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.mainDrills.length} ${l10n.get('drills_short')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        // Secondary recommendations
        if (recommendations.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            l10n.get('coach_secondary_focus'),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          ...recommendations.skip(1).take(2).map(
                (rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildSecondaryFocusCard(context, rec, l10n),
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildPrimaryFocusCard(
      BuildContext context, CoachRecommendation rec, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'vi' ? rec.observationVi : rec.observation;
    final evidence = locale == 'vi' ? rec.evidenceVi : rec.evidence;

    return Card(
      color: Colors.blue.withAlpha(13),
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
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l10n.get('coach_primary_focus'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(rec.category).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getCategoryLabel(rec.category, l10n),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(rec.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              evidence,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            if (rec.drills.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.fitness_center, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rec.drills.first.drillId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryFocusCard(
      BuildContext context, CoachRecommendation rec, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'vi' ? rec.observationVi : rec.observation;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: _getCategoryColor(rec.category),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getCategoryLabel(rec.category, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  String _getIntensityLabel(TrainingIntensity intensity, AppLocalizations l10n) {
    switch (intensity) {
      case TrainingIntensity.heavy:
        return l10n.get('intensity_heavy');
      case TrainingIntensity.normal:
        return l10n.get('intensity_normal');
      case TrainingIntensity.light:
        return l10n.get('intensity_light');
      case TrainingIntensity.recovery:
        return l10n.get('intensity_recovery');
    }
  }

  Color _getIntensityColor(TrainingIntensity intensity) {
    switch (intensity) {
      case TrainingIntensity.heavy:
        return Colors.red;
      case TrainingIntensity.normal:
        return Colors.blue;
      case TrainingIntensity.light:
        return Colors.amber;
      case TrainingIntensity.recovery:
        return Colors.green;
    }
  }

  Widget _buildStrengthsWeaknesses(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              l10n.get('analysis'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.strengths.isNotEmpty) ...[
          Card(
            color: Colors.green.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.get('strengths'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.strengths.map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.green)),
                          Expanded(child: Text(s)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.weaknesses.isNotEmpty)
          Card(
            color: Colors.orange.withAlpha(13),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_down,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l10n.get('weaknesses'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...state.weaknesses.map(
                    (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ',
                              style: TextStyle(color: Colors.orange)),
                          Expanded(child: Text(w)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecommendations(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    if (state.coachRecommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.info_outline,
                    size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  l10n.get('coach_not_enough_data'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show remaining recommendations (skip first as it's in Primary Focus)
    final remainingRecs = state.coachRecommendations.skip(1).toList();
    if (remainingRecs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              l10n.get('coach_recommendation_history'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...remainingRecs.map((rec) {
          return _buildRecommendationCard(context, rec, l10n);
        }),
      ],
    );
  }

  Widget _buildRecommendationCard(
      BuildContext context, CoachRecommendation rec, AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final observation =
        locale == 'vi' ? rec.observationVi : rec.observation;
    final evidence = locale == 'vi' ? rec.evidenceVi : rec.evidence;
    final expected =
        locale == 'vi' ? rec.expectedImprovementVi : rec.expectedImprovement;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(rec.category).withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getCategoryLabel(rec.category, l10n),
                    style: TextStyle(
                      fontSize: 10,
                      color: _getCategoryColor(rec.category),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.visibility, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('coach_observation'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        observation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.analytics, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.get('coach_evidence'),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        evidence,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (rec.drills.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('coach_recommended_drill'),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        ...rec.drills.map((drill) {
                          final drillName = drill.drillId.isNotEmpty ? drill.drillId : 'Drill';
                          final drillText = '$drillName (${drill.durationMinutes} ${l10n.get('minutes_short')})';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(Icons.sports, size: 14, color: Colors.green[600]),
                                const SizedBox(width: 6),
                                Expanded(child: Text(drillText, style: Theme.of(context).textTheme.bodySmall)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(13),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trending_up,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.get('coach_expected_improvement'),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          expected,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'health':
        return Colors.red;
      case 'readiness':
        return Colors.blue;
      case 'mental':
        return Colors.purple;
      case 'skill_weakness':
        return Colors.orange;
      case 'training_plan':
        return Colors.green;
      case 'equipment':
        return Colors.brown;
      case 'recovery':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    final labels = {
      'health': l10n.get('category_health'),
      'readiness': l10n.get('category_readiness'),
      'mental': l10n.get('category_mental'),
      'skill_weakness': l10n.get('category_skill_weakness'),
      'training_plan': l10n.get('category_training_plan'),
      'equipment': l10n.get('category_equipment'),
      'recovery': l10n.get('category_recovery'),
      'general': l10n.get('category_general'),
    };
    return labels[category] ?? category;
  }

  Widget _buildTrainingTab(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    final plan = state.trainingPlan;

    if (plan == null || plan.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                l10n.get('coach_no_training_plan'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.get('coach_complete_sessions_for_plan'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(coachProvider.notifier).refreshData();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTrainingPlanHeader(context, plan, l10n),
          const SizedBox(height: 24),
          if (plan.warmup.isNotEmpty) ...[
            _buildDrillSection(
                context, l10n.get('warmup'), Icons.play_arrow, plan.warmup, l10n),
            const SizedBox(height: 16),
          ],
          if (plan.mainDrills.isNotEmpty) ...[
            _buildDrillSection(
                context, l10n.get('coach_recommended_drill'), Icons.fitness_center, plan.mainDrills, l10n),
            const SizedBox(height: 16),
          ],
          if (plan.cooldown.isNotEmpty) ...[
            _buildDrillSection(
                context, l10n.get('cooldown'), Icons.self_improvement, plan.cooldown, l10n),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.go('/drills');
            },
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.get('coach_start_training')),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingPlanHeader(
      BuildContext context, DailyTrainingPlan plan, AppLocalizations l10n) {
    return Card(
      color: _getIntensityColor(plan.intensity).withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.get('coach_todays_plan'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIntensityColor(plan.intensity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getIntensityLabel(plan.intensity, l10n),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.coachMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${plan.totalDurationMinutes} ${l10n.get('minutes_short')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.fitness_center, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${plan.totalDrills} ${l10n.get('drills_short')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrillSection(BuildContext context, String title, IconData icon,
      List<dynamic> drills, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...drills.map((drill) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withAlpha(26),
                child: const Icon(Icons.sports, color: Colors.blue),
              ),
              title: Text(drill.drillId.isNotEmpty ? drill.drillId : 'Drill'),
              subtitle: Text(
                '${drill.durationMinutes} ${l10n.get('minutes_short')} - ${drill.difficulty}',
              ),
              trailing: Text(
                l10n.get('coach_start_drill'),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInsightsTab(
      BuildContext context, CoachState state, AppLocalizations l10n, String locale) {
    if (state.insights.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                l10n.get('no_insights'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.get('play_sessions_for_insights'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.insights.length,
      itemBuilder: (context, index) {
        final insight = state.insights[index];
        final title = locale == 'vi' ? insight.titleVi : insight.title;
        final description =
            locale == 'vi' ? insight.descriptionVi : insight.description;

        Color color;
        switch (insight.type) {
          case 'success':
            color = Colors.green;
            break;
          case 'warning':
            color = Colors.orange;
            break;
          case 'error':
            color = Colors.red;
            break;
          default:
            color = Colors.blue;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(insight.icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
