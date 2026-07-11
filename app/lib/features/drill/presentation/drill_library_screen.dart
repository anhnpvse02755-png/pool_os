import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/drill/presentation/drill_provider.dart';
import 'package:pool_os/features/drill/presentation/drill_detail_screen.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class DrillLibraryScreen extends ConsumerStatefulWidget {
  const DrillLibraryScreen({super.key});

  @override
  ConsumerState<DrillLibraryScreen> createState() => _DrillLibraryScreenState();
}

class _DrillLibraryScreenState extends ConsumerState<DrillLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _skillLevelTabs = [
    DrillSkillLevel.beginner,
    DrillSkillLevel.intermediate,
    DrillSkillLevel.advanced,
    DrillSkillLevel.professional,
    DrillSkillLevel.coachCustom,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _skillLevelTabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final selectedSkillLevel = _skillLevelTabs[_tabController.index];
      ref.read(drillSkillLevelFilterProvider.notifier).state = selectedSkillLevel;
      ref.read(drillViewModeProvider.notifier).state = DrillViewMode.bySkillLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final viewMode = ref.watch(drillViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getViewTitle(viewMode, l10n, locale)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortSheet(context, locale),
            tooltip: l10n.get('sort'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, locale),
            tooltip: l10n.get('filter_drills'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(locale),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(l10n, locale),
          if (_hasActiveFilters()) _buildActiveFilters(l10n, locale),
          Expanded(
            child: _buildBody(viewMode, locale),
          ),
        ],
      ),
      bottomNavigationBar: _buildQuickAccessBar(l10n, locale),
    );
  }

  String _getViewTitle(DrillViewMode viewMode, AppLocalizations l10n, String locale) {
    switch (viewMode) {
      case DrillViewMode.bySkillLevel:
        return l10n.get('drill_library');
      case DrillViewMode.byCategory:
        return l10n.get('category');
      case DrillViewMode.favorites:
        return 'Yêu thích';
      case DrillViewMode.recent:
        return 'Gần đây';
      case DrillViewMode.mostUsed:
        return 'Nhiều luyện nhất';
    }
  }

  Widget _buildTabBar(String locale) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: _skillLevelTabs.map((level) {
        return Tab(
          text: DrillSkillLevel.getName(level, locale),
        );
      }).toList(),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n, String locale) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài tập theo tên, kỹ năng, danh mục, độ khó...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(drillSearchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          ref.read(drillSearchQueryProvider.notifier).state = value;
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    final skillLevel = ref.read(drillSkillLevelFilterProvider);
    final category = ref.read(drillCategoryFilterProvider);
    final difficulty = ref.read(drillDifficultyFilterProvider);
    final search = ref.read(drillSearchQueryProvider);

    return skillLevel != null ||
        category != null ||
        difficulty != null ||
        search.isNotEmpty;
  }

  Widget _buildActiveFilters(AppLocalizations l10n, String locale) {
    final skillLevel = ref.watch(drillSkillLevelFilterProvider);
    final category = ref.watch(drillCategoryFilterProvider);
    final difficulty = ref.watch(drillDifficultyFilterProvider);
    final search = ref.watch(drillSearchQueryProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (skillLevel != null)
              _buildFilterChip(
                DrillSkillLevel.getName(skillLevel, locale),
                () => ref.read(drillSkillLevelFilterProvider.notifier).state = null,
              ),
            if (category != null)
              _buildFilterChip(
                DrillCategory.getName(category, locale),
                () => ref.read(drillCategoryFilterProvider.notifier).state = null,
              ),
            if (difficulty != null)
              _buildFilterChip(
                _getDifficultyLabel(difficulty, locale),
                () => ref.read(drillDifficultyFilterProvider.notifier).state = null,
              ),
            if (search.isNotEmpty)
              _buildFilterChip(
                '"$search"',
                () {
                  _searchController.clear();
                  ref.read(drillSearchQueryProvider.notifier).state = '';
                },
              ),
            TextButton(
              onPressed: _clearAllFilters,
              child: Text(l10n.get('clear_filters')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        onDeleted: onRemove,
        deleteIconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(drillSearchQueryProvider.notifier).state = '';
    ref.read(drillSkillLevelFilterProvider.notifier).state = null;
    ref.read(drillCategoryFilterProvider.notifier).state = null;
    ref.read(drillDifficultyFilterProvider.notifier).state = null;
  }

  Widget _buildBody(DrillViewMode viewMode, String locale) {
    switch (viewMode) {
      case DrillViewMode.bySkillLevel:
        return _buildBySkillLevelView(locale);
      case DrillViewMode.byCategory:
        return _buildByCategoryView(locale);
      case DrillViewMode.favorites:
        return _buildFavoritesView(locale);
      case DrillViewMode.recent:
        return _buildRecentView(locale);
      case DrillViewMode.mostUsed:
        return _buildMostUsedView(locale);
    }
  }

  Widget _buildBySkillLevelView(String locale) {
    final drills = ref.watch(filteredDrillsProvider);

    if (drills.isEmpty) {
      return _buildEmptyState(locale);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drills.length,
      itemBuilder: (context, index) {
        return _buildDrillCard(drills[index], locale);
      },
    );
  }

  Widget _buildByCategoryView(String locale) {
    final groupedDrills = ref.watch(drillsByCategoryProvider);
    final categories = groupedDrills.keys.toList();

    if (categories.isEmpty) {
      return _buildEmptyState(locale);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final drills = groupedDrills[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DrillCategory.getName(category, locale),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${drills.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...drills.map((drill) => _buildDrillCard(drill, locale)),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildFavoritesView(String locale) {
    final favoriteIds = ref.watch(favoriteDrillsProvider);
    final allDrills = ref.watch(drillLibraryProvider);
    final favoriteDrills = allDrills.where((d) => favoriteIds.contains(d.id)).toList();

    if (favoriteDrills.isEmpty) {
      return _buildEmptyStateWithMessage(
        'Chưa có bài tập yêu thích',
        'Bấm biểu tượng trái tim để thêm vào yêu thích',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteDrills.length,
      itemBuilder: (context, index) {
        return _buildDrillCard(favoriteDrills[index], locale);
      },
    );
  }

  Widget _buildRecentView(String locale) {
    final recentDrills = ref.watch(recentDrillsProvider);

    if (recentDrills.isEmpty) {
      return _buildEmptyStateWithMessage(
        'Chưa có bài tập gần đây',
        'Bắt đầu tập để xem lịch sử',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentDrills.length,
      itemBuilder: (context, index) {
        return _buildDrillCard(recentDrills[index], locale);
      },
    );
  }

  Widget _buildMostUsedView(String locale) {
    final practiceCounts = ref.watch(drillPracticeCountProvider);
    final allDrills = ref.watch(drillLibraryProvider);

    // Sort drills by practice count
    final sortedDrills = List<Drill>.from(allDrills);
    sortedDrills.sort((a, b) {
      final aCount = practiceCounts[a.id] ?? 0;
      final bCount = practiceCounts[b.id] ?? 0;
      return bCount.compareTo(aCount);
    });

    // Filter out drills with 0 practice
    final mostUsedDrills = sortedDrills.where((d) => (practiceCounts[d.id] ?? 0) > 0).toList();

    if (mostUsedDrills.isEmpty) {
      return _buildEmptyStateWithMessage(
        'Chưa có dữ liệu luyện tập',
        'Bắt đầu tập để xem thống kê',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: mostUsedDrills.length,
      itemBuilder: (context, index) {
        return _buildDrillCard(mostUsedDrills[index], locale, showPracticeCount: true);
      },
    );
  }

  Widget _buildEmptyState(String locale) {
    return _buildEmptyStateWithMessage(
      'Không tìm thấy bài tập',
      'Thử điều chỉnh bộ lọc',
    );
  }

  Widget _buildEmptyStateWithMessage(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrillCard(Drill drill, String locale, {bool showPracticeCount = false}) {
    final isVietnamese = locale == 'vi';
    final name = isVietnamese ? drill.nameVi : drill.name;
    final description = isVietnamese ? drill.descriptionVi : drill.description;
    final practiceCounts = ref.watch(drillPracticeCountProvider);
    final practiceCount = practiceCounts[drill.id] ?? 0;
    final completionPercent = _calculateCompletionPercent(drill, practiceCount);
    final isFavorite = ref.watch(favoriteDrillsProvider).contains(drill.id);
    final isCoachCustom = drill.skillLevel == DrillSkillLevel.coachCustom;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDrillDetail(drill),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildDifficultyStars(drill.difficultyStars),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSkillLevelColor(drill.skillLevel).withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                DrillSkillLevel.getName(drill.skillLevel, locale),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getSkillLevelColor(drill.skillLevel),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Coach recommendation badge
                  if (isCoachCustom)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: Colors.amber),
                          SizedBox(width: 4),
                          Text(
                            'Đề xuất',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Favorite button
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      ref.read(favoriteDrillsProvider.notifier).toggleFavorite(drill.id!);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Info Row
              Row(
                children: [
                  _buildInfoChip(Icons.gps_fixed, '${drill.targetScore}'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.timer, '${drill.timeLimitMinutes} ${locale == 'vi' ? 'phút' : 'min'}'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.category, DrillCategory.getName(drill.category, locale)),
                ],
              ),

              const SizedBox(height: 12),

              // Progress and Stats Row
              Row(
                children: [
                  // Completion Progress
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hoàn thành',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$completionPercent%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getCompletionColor(completionPercent),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completionPercent / 100,
                            minHeight: 6,
                            backgroundColor: Colors.grey.withAlpha(51),
                            valueColor: AlwaysStoppedAnimation(_getCompletionColor(completionPercent)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showPracticeCount) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '$practiceCount lần',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _startDrill(drill),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Bắt đầu tập'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyStars(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < stars ? Icons.star : Icons.star_border,
          size: 16,
          color: index < stars ? Colors.amber : Colors.grey,
        );
      }),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  int _calculateCompletionPercent(Drill drill, int practiceCount) {
    if (practiceCount == 0) return 0;
    // Simple calculation: based on practice count relative to recommended repetitions
    if (drill.recommendedRepetitions != null && drill.recommendedRepetitions! > 0) {
      final percent = (practiceCount / drill.recommendedRepetitions! * 100).clamp(0, 100);
      return percent.toInt();
    }
    // Fallback: based on target score achievement
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

  void _showSortSheet(BuildContext context, String locale) {
    final currentSort = ref.read(drillSortProvider);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sắp xếp theo',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...DrillSortOption.values.map((option) {
              return ListTile(
                leading: Icon(
                  _getSortIcon(option),
                  color: currentSort == option
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(option.getName(locale)),
                trailing: currentSort == option
                    ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  ref.read(drillSortProvider.notifier).state = option;
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getSortIcon(DrillSortOption option) {
    switch (option) {
      case DrillSortOption.newest:
        return Icons.schedule;
      case DrillSortOption.alphabetical:
        return Icons.sort_by_alpha;
      case DrillSortOption.difficulty:
        return Icons.star;
      case DrillSortOption.coachRecommended:
        return Icons.auto_awesome;
      case DrillSortOption.recentlyUsed:
        return Icons.history;
      case DrillSortOption.mostPracticed:
        return Icons.trending_up;
    }
  }

  void _showFilterSheet(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _DrillFilterSheet(locale: locale),
    );
  }

  void _openDrillDetail(Drill drill) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DrillDetailScreen(drill: drill),
      ),
    );
  }

  Future<void> _startDrill(Drill drill) async {
    // RFC-302 Task E: startDrill now creates the Session/Match/Rack in the
    // recording pipeline, so it is async. Await it, surface a failure, and only
    // open the active-drill screen once the run is really recording.
    final notifier = ref.read(activeDrillProvider.notifier);
    await notifier.startDrill(drill);
    if (!mounted) return;
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

  String _getDifficultyLabel(String difficulty, String locale) {
    return switch (difficulty) {
      'beginner' => 'Người mới',
      'intermediate' => 'Trung bình',
      'advanced' => 'Nâng cao',
      'expert' => 'Chuyên gia',
      _ => difficulty,
    };
  }

  Widget _buildQuickAccessBar(AppLocalizations l10n, String locale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickAccessButton(
            Icons.category,
            'Danh mục',
            DrillViewMode.byCategory,
          ),
          _buildQuickAccessButton(
            Icons.favorite,
            'Yêu thích',
            DrillViewMode.favorites,
          ),
          _buildQuickAccessButton(
            Icons.history,
            'Gần đây',
            DrillViewMode.recent,
          ),
          _buildQuickAccessButton(
            Icons.trending_up,
            'Nhiều luyện',
            DrillViewMode.mostUsed,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, DrillViewMode viewMode) {
    final currentViewMode = ref.watch(drillViewModeProvider);
    final isSelected = currentViewMode == viewMode;

    return InkWell(
      onTap: () {
        ref.read(drillViewModeProvider.notifier).state = viewMode;
        if (viewMode == DrillViewMode.bySkillLevel) {
          // Reset to first tab
          _tabController.animateTo(0);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrillFilterSheet extends ConsumerWidget {
  final String locale;

  const _DrillFilterSheet({required this.locale});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(drillCategoryFilterProvider);
    final selectedDifficulty = ref.watch(drillDifficultyFilterProvider);
    final selectedTime = ref.watch(drillTimeFilterProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ lọc',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(drillCategoryFilterProvider.notifier).state = null;
                      ref.read(drillDifficultyFilterProvider.notifier).state = null;
                      ref.read(drillTimeFilterProvider.notifier).state = null;
                      ref.read(drillSkillFilterProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                    child: const Text('Xóa tất cả'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Category Filter (Shot Type)
              Text(
                'Loại cú đánh',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    'Tất cả',
                    null,
                    selectedCategory,
                    () => ref.read(drillCategoryFilterProvider.notifier).state = null,
                  ),
                  ...DrillCategory.all.map((category) {
                    return _buildFilterChip(
                      context,
                      ref,
                      DrillCategory.getName(category, 'vi'),
                      category,
                      selectedCategory,
                      () => ref.read(drillCategoryFilterProvider.notifier).state = category,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Difficulty Filter
              Text(
                'Độ khó',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    'Tất cả',
                    null,
                    selectedDifficulty,
                    () => ref.read(drillDifficultyFilterProvider.notifier).state = null,
                  ),
                  ...DrillDifficulty.all.map((difficulty) {
                    return _buildFilterChip(
                      context,
                      ref,
                      _getDifficultyLabel(difficulty, locale),
                      difficulty,
                      selectedDifficulty,
                      () => ref.read(drillDifficultyFilterProvider.notifier).state = difficulty,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Target Skill Filter
              Text(
                'Kỹ năng mục tiêu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    'Tất cả',
                    null,
                    ref.watch(drillSkillFilterProvider),
                    () => ref.read(drillSkillFilterProvider.notifier).state = null,
                  ),
                  ..._targetSkills.map((skill) {
                    return _buildFilterChip(
                      context,
                      ref,
                      skill['name']!,
                      skill['id'],
                      ref.watch(drillSkillFilterProvider),
                      () => ref.read(drillSkillFilterProvider.notifier).state = skill['id'],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),

              // Estimated Time Filter
              Text(
                'Thời gian ước tính',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(
                    context,
                    ref,
                    'Tất cả',
                    null,
                    selectedTime,
                    () => ref.read(drillTimeFilterProvider.notifier).state = null,
                  ),
                  _buildFilterChip(
                    context,
                    ref,
                    'Dưới 10 phút',
                    'short',
                    selectedTime,
                    () => ref.read(drillTimeFilterProvider.notifier).state = 'short',
                  ),
                  _buildFilterChip(
                    context,
                    ref,
                    '10-20 phút',
                    'medium',
                    selectedTime,
                    () => ref.read(drillTimeFilterProvider.notifier).state = 'medium',
                  ),
                  _buildFilterChip(
                    context,
                    ref,
                    'Trên 20 phút',
                    'long',
                    selectedTime,
                    () => ref.read(drillTimeFilterProvider.notifier).state = 'long',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Apply Button
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Áp dụng'),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Map<String, String>> get _targetSkills => [
        {'id': 'stroke', 'name': 'Đánh cơ'},
        {'id': 'aiming', 'name': 'Ngắm'},
        {'id': 'position', 'name': 'Điều bi'},
        {'id': 'control', 'name': 'Kiểm soát'},
        {'id': 'pattern', 'name': 'Quỹ đạo'},
        {'id': 'break', 'name': 'Phá bàn'},
        {'id': 'safety', 'name': 'An toàn'},
        {'id': 'mental', 'name': 'Tâm lý'},
        {'id': 'kick', 'name': 'Đá bi'},
        {'id': 'bank', 'name': 'Ghiên'},
        {'id': 'power', 'name': 'Lực'},
      ];

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref,
    String label,
    String? value,
    String? selectedValue,
    VoidCallback onSelect,
  ) {
    final isSelected = selectedValue == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(),
    );
  }

  String _getDifficultyLabel(String difficulty, String locale) {
    return switch (difficulty) {
      'beginner' => 'Người mới',
      'intermediate' => 'Trung bình',
      'advanced' => 'Nâng cao',
      'expert' => 'Chuyên gia',
      _ => difficulty,
    };
  }
}

// ===== ACTIVE DRILL SCREEN =====

class ActiveDrillScreen extends ConsumerStatefulWidget {
  final Drill drill;

  const ActiveDrillScreen({super.key, required this.drill});

  @override
  ConsumerState<ActiveDrillScreen> createState() => _ActiveDrillScreenState();
}

class _ActiveDrillScreenState extends ConsumerState<ActiveDrillScreen> {
  bool _showInstructions = true;
  // RFC-302 Task E: guards against a double-tap firing recordAttempt twice.
  // Each attempt persists a Shot; two fast taps would persist two Shots but the
  // in-memory counter/summary would advance once, permanently desyncing shot
  // data from the drill summary. Buttons are disabled while a record is in
  // flight.
  bool _recording = false;

  Future<void> _recordAttempt(bool success) async {
    if (_recording) return;
    setState(() => _recording = true);
    try {
      await ref.read(activeDrillProvider.notifier).recordAttempt(success: success);
    } finally {
      if (mounted) setState(() => _recording = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(activeDrillProvider);
    final session = state.session;
    final locale = Localizations.localeOf(context).languageCode;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.drill.nameVi)),
        body: Center(
          child: Text(l10n.get('error')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drill.nameVi),
        actions: [
          IconButton(
            icon: Icon(_showInstructions ? Icons.list : Icons.list_alt),
            onPressed: () => setState(() => _showInstructions = !_showInstructions),
            tooltip: 'Hướng dẫn',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              // RFC-302 Task E: reset/cancel now flush the recording match
              // (finish it so recorded shots stay valid history), so they are
              // async. Cancel then leaves the screen.
              final notifier = ref.read(activeDrillProvider.notifier);
              if (value == 'reset') {
                await notifier.resetDrill();
              } else if (value == 'cancel') {
                await notifier.cancelDrill();
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Bắt đầu lại'),
              ),
              const PopupMenuItem(
                value: 'cancel',
                child: Text('Hủy bài tập'),
              ),
            ],
          ),
        ],
      ),
      body: _showInstructions
          ? _buildInstructions(context, session, l10n, locale)
          : _buildActiveDrill(context, session, l10n, locale),
      bottomNavigationBar: session.isComplete
          ? _buildCompletionBanner(context, session, l10n, locale)
          : _buildActionBar(context, session, l10n, locale),
    );
  }

  Widget _buildInstructions(
    BuildContext context,
    DrillSession session,
    AppLocalizations l10n,
    String locale,
  ) {
    final isVietnamese = locale == 'vi';
    final instructions = isVietnamese
        ? widget.drill.instructionsVi
        : widget.drill.instructions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(context, session, locale),
          const SizedBox(height: 16),

          // Drill Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mục đích',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.drill.purpose ?? 'Phát triển kỹ năng',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (widget.drill.tableLayout != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Sơ đồ bàn',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.drill.tableLayout!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (widget.drill.ballSetup != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Xếp bi',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.drill.ballSetup!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn thực hiện',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...instructions.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  '${e.key + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(e.value)),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          // Common Mistakes
          if (widget.drill.commonMistakes != null && widget.drill.commonMistakes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.withAlpha(26),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Lỗi thường gặp',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.drill.commonMistakes!.map((mistake) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.error_outline, size: 18, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(mistake)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],

          // Expected Improvement
          if (widget.drill.expectedImprovement != null && widget.drill.expectedImprovement!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.green.withAlpha(26),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.trending_up, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Cải thiện mong đợi',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...widget.drill.expectedImprovement!.map((improvement) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(improvement)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, DrillSession session, String locale) {
    final progress = (session.currentScore / session.targetScore).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tiến độ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${session.currentScore} / ${session.targetScore}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Lần', session.attempts.toString()),
                _buildStat('Trúng', session.successfulAttempts.toString()),
                _buildStat(
                  'Tỷ lệ',
                  '${(session.successRate * 100).toInt()}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActiveDrill(
    BuildContext context,
    DrillSession session,
    AppLocalizations l10n,
    String locale,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Điểm hiện tại',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '${session.currentScore}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'của ${session.targetScore}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          if (!session.isComplete)
            Text(
              'Tiếp tục luyện tập!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        ],
      ),
    );
  }

  Widget _buildActionBar(
    BuildContext context,
    DrillSession session,
    AppLocalizations l10n,
    String locale,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _recording ? null : () => _recordAttempt(false),
                icon: const Icon(Icons.close, color: Colors.red),
                label: const Text(
                  'Trượt',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _recording ? null : () => _recordAttempt(true),
                icon: const Icon(Icons.check),
                label: const Text('Trúng'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionBanner(
    BuildContext context,
    DrillSession session,
    AppLocalizations l10n,
    String locale,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.green.withAlpha(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Hoàn thành bài tập!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tỷ lệ thành công: ${(session.successRate * 100).toInt()}%',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(activeDrillProvider.notifier).resetDrill();
                  setState(() => _showInstructions = true);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
              FilledButton.icon(
                onPressed: () {
                  ref.read(drillHistoryProvider.notifier).addSession(session);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.get('done')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
