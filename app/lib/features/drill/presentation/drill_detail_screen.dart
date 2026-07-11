import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/drill/presentation/drill_provider.dart';
import 'package:pool_os/features/drill/presentation/drill_library_screen.dart';

class DrillDetailScreen extends ConsumerWidget {
  final Drill drill;

  const DrillDetailScreen({super.key, required this.drill});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context).languageCode;
    final isVi = locale == 'vi';
    final name = isVi ? drill.nameVi : drill.name;
    final description = isVi ? drill.descriptionVi : drill.description;
    final practiceCounts = ref.watch(drillPracticeCountProvider);
    final practiceCount = practiceCounts[drill.id] ?? 0;
    final isFavorite = ref.watch(favoriteDrillsProvider).contains(drill.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getSkillLevelColor(drill.skillLevel),
                      _getSkillLevelColor(drill.skillLevel).withAlpha(179),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getCategoryIcon(drill.category),
                    size: 80,
                    color: Colors.white.withAlpha(76),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  ref.read(favoriteDrillsProvider.notifier).toggleFavorite(drill.id!);
                },
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Info Row
                  _buildHeaderInfo(context, locale),

                  const SizedBox(height: 24),

                  // Description
                  _buildSection(
                    context,
                    'Mô tả',
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),

                  // Purpose
                  if (drill.purpose != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Mục đích',
                      Text(
                        drill.purpose!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],

                  // Table Layout
                  if (drill.tableLayout != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Sơ đồ bàn',
                      _buildInfoRow(
                        Icons.table_restaurant,
                        drill.tableLayout!,
                        context,
                      ),
                    ),
                  ],

                  // Ball Setup
                  if (drill.ballSetup != null) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Xếp bi',
                      _buildInfoRow(
                        Icons.sports_tennis,
                        drill.ballSetup!,
                        context,
                      ),
                    ),
                  ],

                  // Execution Steps
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'Các bước thực hiện',
                    _buildStepsList(context, isVi),
                  ),

                  // Success Criteria
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    'Tiêu chuẩn thành công',
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(76),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.flag,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mục tiêu',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${drill.targetScore} điểm',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (drill.recommendedRepetitions != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Lặp lại',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${drill.recommendedRepetitions}',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Common Mistakes
                  if (drill.commonMistakes != null && drill.commonMistakes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Lỗi thường gặp',
                      _buildMistakesList(context, isVi),
                    ),
                  ],

                  // Expected Improvement
                  if (drill.expectedImprovement != null && drill.expectedImprovement!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Cải thiện mong đợi',
                                      _buildImprovementList(context, isVi),
                    ),
                  ],

                  // Related Skills
                  if (drill.relatedSkills != null && drill.relatedSkills!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Kỹ năng liên quan',
                      _buildSkillsChips(context, locale),
                    ),
                  ],

                  // Focus Skills
                  if (drill.focusSkills.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(
                      context,
                      'Trọng tâm kỹ năng',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: drill.focusSkills.map((skill) {
                          return Chip(
                            avatar: Icon(
                              _getSkillIcon(skill),
                              size: 18,
                            ),
                            label: Text(_getSkillName(skill, locale)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  // Practice Stats
                  const SizedBox(height: 24),
                  _buildPracticeStats(context, practiceCount, locale),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startDrill(context, ref),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Bắt đầu tập'),
      ),
    );
  }

  Widget _buildHeaderInfo(BuildContext context, String locale) {
    return Row(
      children: [
        // Difficulty Stars
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Độ khó',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < drill.difficultyStars ? Icons.star : Icons.star_border,
                    size: 20,
                    color: index < drill.difficultyStars ? Colors.amber : Colors.grey,
                  );
                }),
              ),
            ],
          ),
        ),

        // Skill Level Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSkillLevelColor(drill.skillLevel).withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getSkillLevelColor(drill.skillLevel),
            ),
          ),
          child: Text(
            DrillSkillLevel.getName(drill.skillLevel, 'vi'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _getSkillLevelColor(drill.skillLevel),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Time
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${drill.timeLimitMinutes} phút',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }

  Widget _buildStepsList(BuildContext context, bool isVietnamese) {
    final instructions = isVietnamese ? drill.instructionsVi : drill.instructions;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: instructions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${entry.key + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMistakesList(BuildContext context, bool isVietnamese) {
    return Card(
      color: Colors.orange.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: drill.commonMistakes!.map((mistake) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber,
                    size: 20,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(mistake)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildImprovementList(BuildContext context, bool isVietnamese) {
    return Card(
      color: Colors.green.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: drill.expectedImprovement!.map((improvement) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(improvement)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSkillsChips(BuildContext context, String locale) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: drill.relatedSkills!.map((skill) {
        return Chip(
          avatar: const Icon(Icons.trending_up, size: 18),
          label: Text(skill),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        );
      }).toList(),
    );
  }

  Widget _buildPracticeStats(BuildContext context, int practiceCount, String locale) {
    final completionPercent = _calculateCompletionPercent(practiceCount);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê luyện tập',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.replay,
                    'Số lần tập',
                    practiceCount.toString(),
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.percent,
                    'Hoàn thành',
                    '$completionPercent%',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.calendar_today,
                    'Mã bài tập',
                    drill.code,
                  ),
                ),
              ],
            ),
            if (practiceCount > 0) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionPercent / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.withAlpha(51),
                  valueColor: AlwaysStoppedAnimation(_getCompletionColor(completionPercent)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
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
                color: Theme.of(context).colorScheme.outline,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int _calculateCompletionPercent(int practiceCount) {
    if (practiceCount == 0) return 0;
    if (drill.recommendedRepetitions != null && drill.recommendedRepetitions! > 0) {
      return (practiceCount / drill.recommendedRepetitions! * 100).clamp(0, 100).toInt();
    }
    return (practiceCount * 10).clamp(0, 100).toInt();
  }

  Color _getCompletionColor(int percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    if (percent > 0) return Colors.blue;
    return Colors.grey;
  }

  Color _getSkillLevelColor(String skillLevel) {
    switch (skillLevel) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.blue;
      case 'advanced':
        return Colors.orange;
      case 'professional':
        return Colors.red;
      case 'coachCustom':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'warmup':
        return Icons.accessibility_new;
      case 'straightShot':
        return Icons.straighten;
      case 'thinCut':
        return Icons.content_cut;
      case 'thickCut':
        return Icons.crop;
      case 'longPot':
        return Icons.arrow_forward;
      case 'position':
        return Icons.adjust;
      case 'cueBallControl':
        return Icons.sports_tennis;
      case 'break':
        return Icons.flash_on;
      case 'safety':
        return Icons.shield;
      case 'kick':
        return Icons.turn_right;
      case 'bank':
        return Icons.change_history;
      case 'jump':
        return Icons.keyboard_arrow_up;
      case 'patternPlay':
        return Icons.timeline;
      case 'pressure':
        return Icons.whatshot;
      case 'tournament':
        return Icons.emoji_events;
      case 'mental':
        return Icons.psychology;
      case 'recovery':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  IconData _getSkillIcon(String skill) {
    switch (skill) {
      case 'stroke':
        return Icons.sports_martial_arts;
      case 'aiming':
        return Icons.gps_fixed;
      case 'position':
        return Icons.adjust;
      case 'control':
        return Icons.tune;
      case 'pattern':
        return Icons.timeline;
      case 'break':
        return Icons.flash_on;
      case 'safety':
        return Icons.shield;
      case 'mental':
        return Icons.psychology;
      case 'kick':
        return Icons.turn_right;
      case 'bank':
        return Icons.change_history;
      case 'power':
        return Icons.bolt;
      case 'consistency':
        return Icons.trending_flat;
      default:
        return Icons.star;
    }
  }

  String _getSkillName(String skill, String locale) {
    final isVietnamese = locale == 'vi';
    final names = {
      'stroke': isVietnamese ? 'Đánh cơ' : 'Stroke',
      'aiming': isVietnamese ? 'Ngắm' : 'Aiming',
      'position': isVietnamese ? 'Điều bi' : 'Position',
      'control': isVietnamese ? 'Kiểm soát' : 'Control',
      'pattern': isVietnamese ? 'Quỹ đạo' : 'Pattern',
      'break': isVietnamese ? 'Phá bàn' : 'Break',
      'safety': isVietnamese ? 'An toàn' : 'Safety',
      'mental': isVietnamese ? 'Tâm lý' : 'Mental',
      'kick': isVietnamese ? 'Đá bi' : 'Kick',
      'bank': isVietnamese ? 'Ghiên' : 'Bank',
      'power': isVietnamese ? 'Lực' : 'Power',
      'consistency': isVietnamese ? 'Ổn định' : 'Consistency',
    };
    return names[skill] ?? skill;
  }

  Future<void> _startDrill(BuildContext context, WidgetRef ref) async {
    // RFC-302 Task E: startDrill now provisions the recording pipeline
    // (Session → Match → Rack) and is async. Await, surface failure, then open.
    await ref.read(activeDrillProvider.notifier).startDrill(drill);
    if (!context.mounted) return;
    final error = ref.read(activeDrillProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActiveDrillScreen(drill: drill),
      ),
    );
  }
}
