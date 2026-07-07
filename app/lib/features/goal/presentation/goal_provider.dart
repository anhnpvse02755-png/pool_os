import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/daily_goal.dart';

final goalTrackerProvider = StateNotifierProvider<GoalTrackerNotifier, GoalTrackerState>((ref) {
  return GoalTrackerNotifier();
});

class GoalTrackerState {
  final List<DailyGoal> goals;
  final List<DailyGoal> todayGoals;
  final bool isLoading;
  final String? error;

  const GoalTrackerState({
    this.goals = const [],
    this.todayGoals = const [],
    this.isLoading = false,
    this.error,
  });

  GoalTrackerState copyWith({
    List<DailyGoal>? goals,
    List<DailyGoal>? todayGoals,
    bool? isLoading,
    String? error,
  }) {
    return GoalTrackerState(
      goals: goals ?? this.goals,
      todayGoals: todayGoals ?? this.todayGoals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<DailyGoal> get activeGoals =>
      goals.where((g) => g.status == GoalStatus.active).toList();

  List<DailyGoal> get completedGoals =>
      goals.where((g) => g.status == GoalStatus.completed).toList();

  List<DailyGoal> get overdueGoals =>
      goals.where((g) => g.isOverdue && g.status == GoalStatus.active).toList();

  int get totalGoals => goals.length;
  int get completedToday => todayGoals.where((g) => g.isComplete).length;
  int get totalToday => todayGoals.length;

  double get todayProgress {
    if (totalToday == 0) return 0.0;
    return todayGoals.fold<double>(0.0, (sum, g) => sum + g.progress) / totalToday;
  }

  List<DailyGoal> getGoalsByCategory(GoalCategory category) {
    return goals.where((g) => g.category == category).toList();
  }

  List<DailyGoal> getGoalsByPriority(GoalPriority priority) {
    return goals.where((g) => g.priority == priority).toList();
  }
}

class GoalTrackerNotifier extends StateNotifier<GoalTrackerState> {
  GoalTrackerNotifier() : super(const GoalTrackerState()) {
    _loadDefaultGoals();
  }

  void _loadDefaultGoals() {
    final defaultGoals = [
      DailyGoal(
        id: 1,
        title: 'Practice Position Control',
        titleVi: 'Luyện điều bi',
        description: 'Complete position control drills',
        descriptionVi: 'Hoàn thành bài tập điều bi',
        category: GoalCategory.skill,
        priority: GoalPriority.high,
        targetValue: 1,
        currentValue: 0,
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrence: RecurrencePattern.daily,
      ),
      DailyGoal(
        id: 2,
        title: 'Complete 50 Shots',
        titleVi: 'Hoàn thành 50 cú đánh',
        description: 'Make 50 shots in practice',
        descriptionVi: 'Đánh trúng 50 cú trong buổi tập',
        category: GoalCategory.practice,
        priority: GoalPriority.medium,
        targetValue: 50,
        currentValue: 0,
        unit: 'shots',
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrence: RecurrencePattern.daily,
      ),
      DailyGoal(
        id: 3,
        title: 'Practice Break Shots',
        titleVi: 'Luyện phá bàn',
        description: 'Work on break technique',
        descriptionVi: 'Luyện kỹ thuật phá bàn',
        category: GoalCategory.skill,
        priority: GoalPriority.medium,
        targetValue: 10,
        currentValue: 0,
        unit: 'breaks',
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrence: RecurrencePattern.daily,
      ),
      DailyGoal(
        id: 4,
        title: 'Play 1 Match',
        titleVi: 'Chơi 1 trận',
        description: 'Complete at least one match session',
        descriptionVi: 'Hoàn thành ít nhất một buổi thi đấu',
        category: GoalCategory.practice,
        priority: GoalPriority.medium,
        targetValue: 1,
        currentValue: 0,
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrence: RecurrencePattern.weekly,
      ),
      DailyGoal(
        id: 5,
        title: 'Review Session Notes',
        titleVi: 'Xem lại ghi chú',
        description: 'Review and analyze previous session',
        descriptionVi: 'Xem lại và phân tích buổi tập trước',
        category: GoalCategory.mental,
        priority: GoalPriority.low,
        targetValue: 1,
        currentValue: 0,
        createdAt: DateTime.now(),
        isRecurring: true,
        recurrence: RecurrencePattern.weekly,
      ),
    ];

    state = state.copyWith(
      goals: defaultGoals,
      todayGoals: defaultGoals.where((g) => g.isRecurring).toList(),
    );
  }

  void addGoal(DailyGoal goal) {
    final newGoal = goal.copyWith(
      id: state.goals.isEmpty ? 1 : state.goals.map((g) => g.id ?? 0).reduce((a, b) => a > b ? a : b) + 1,
    );
    state = state.copyWith(
      goals: [...state.goals, newGoal],
      todayGoals: newGoal.isRecurring ? [...state.todayGoals, newGoal] : state.todayGoals,
    );
  }

  void updateGoal(DailyGoal goal) {
    final index = state.goals.indexWhere((g) => g.id == goal.id);
    if (index == -1) return;

    final updatedGoals = [...state.goals];
    updatedGoals[index] = goal;

    final todayIndex = state.todayGoals.indexWhere((g) => g.id == goal.id);
    List<DailyGoal> updatedTodayGoals = [...state.todayGoals];
    if (todayIndex != -1) {
      updatedTodayGoals[todayIndex] = goal;
    }

    state = state.copyWith(
      goals: updatedGoals,
      todayGoals: updatedTodayGoals,
    );
  }

  void removeGoal(int goalId) {
    state = state.copyWith(
      goals: state.goals.where((g) => g.id != goalId).toList(),
      todayGoals: state.todayGoals.where((g) => g.id != goalId).toList(),
    );
  }

  void updateProgress(int goalId, int newValue) {
    final index = state.goals.indexWhere((g) => g.id == goalId);
    if (index == -1) return;

    final goal = state.goals[index];
    final updatedGoal = goal.copyWith(
      currentValue: newValue,
      status: newValue >= goal.targetValue ? GoalStatus.completed : GoalStatus.active,
      completedAt: newValue >= goal.targetValue ? DateTime.now() : null,
    );

    updateGoal(updatedGoal);
  }

  void incrementProgress(int goalId, {int amount = 1}) {
    final goal = state.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );
    updateProgress(goalId, goal.currentValue + amount);
  }

  void decrementProgress(int goalId, {int amount = 1}) {
    final goal = state.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );
    updateProgress(goalId, (goal.currentValue - amount).clamp(0, goal.targetValue));
  }

  void completeGoal(int goalId) {
    final goal = state.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );
    updateProgress(goalId, goal.targetValue);
  }

  void uncompleteGoal(int goalId) {
    final goal = state.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );
    updateGoal(goal.copyWith(
      status: GoalStatus.active,
      completedAt: null,
    ));
  }

  void abandonGoal(int goalId) {
    final goal = state.goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => throw Exception('Goal not found'),
    );
    updateGoal(goal.copyWith(status: GoalStatus.abandoned));
  }

  void resetDailyGoals() {
    final resetGoals = state.goals.map((g) {
      if (g.isRecurring) {
        return g.copyWith(
          currentValue: 0,
          status: GoalStatus.active,
          completedAt: null,
        );
      }
      return g;
    }).toList();

    state = state.copyWith(
      goals: resetGoals,
      todayGoals: resetGoals.where((g) => g.isRecurring).toList(),
    );
  }

  List<DailyGoal> getGoalsForDate(DateTime date) {
    return state.goals.where((g) {
      if (g.targetDate == null) return false;
      final targetDate = DateTime.parse(g.targetDate!);
      return targetDate.year == date.year &&
          targetDate.month == date.month &&
          targetDate.day == date.day;
    }).toList();
  }
}
