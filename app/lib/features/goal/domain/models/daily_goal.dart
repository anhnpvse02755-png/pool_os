import 'dart:ui';

class DailyGoal {
  final int? id;
  final String title;
  final String titleVi;
  final String? description;
  final String? descriptionVi;
  final GoalCategory category;
  final GoalPriority priority;
  final GoalStatus status;
  final int targetValue;
  final int currentValue;
  final String unit;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? targetDate;
  final bool isRecurring;
  final RecurrencePattern? recurrence;

  DailyGoal({
    this.id,
    required this.title,
    required this.titleVi,
    this.description,
    this.descriptionVi,
    required this.category,
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.active,
    this.targetValue = 1,
    this.currentValue = 0,
    this.unit = '',
    required this.createdAt,
    this.completedAt,
    this.targetDate,
    this.isRecurring = false,
    this.recurrence,
  });

  DailyGoal copyWith({
    int? id,
    String? title,
    String? titleVi,
    String? description,
    String? descriptionVi,
    GoalCategory? category,
    GoalPriority? priority,
    GoalStatus? status,
    int? targetValue,
    int? currentValue,
    String? unit,
    DateTime? createdAt,
    DateTime? completedAt,
    String? targetDate,
    bool? isRecurring,
    RecurrencePattern? recurrence,
  }) {
    return DailyGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      titleVi: titleVi ?? this.titleVi,
      description: description ?? this.description,
      descriptionVi: descriptionVi ?? this.descriptionVi,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      targetDate: targetDate ?? this.targetDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  double get progress =>
      targetValue == 0 ? 0.0 : (currentValue / targetValue).clamp(0.0, 1.0);

  bool get isComplete => currentValue >= targetValue;

  bool get isOverdue {
    if (targetDate == null) return false;
    if (isComplete) return false;
    return DateTime.now().isAfter(DateTime.parse(targetDate!));
  }

  int get daysRemaining {
    if (targetDate == null) return -1;
    return DateTime.parse(targetDate!).difference(DateTime.now()).inDays;
  }
}

enum GoalCategory {
  practice,
  skill,
  fitness,
  mental,
  equipment,
  tournament,
  social,
  other,
}

extension GoalCategoryExtension on GoalCategory {
  String get name {
    return switch (this) {
      GoalCategory.practice => 'practice',
      GoalCategory.skill => 'skill',
      GoalCategory.fitness => 'fitness',
      GoalCategory.mental => 'mental',
      GoalCategory.equipment => 'equipment',
      GoalCategory.tournament => 'tournament',
      GoalCategory.social => 'social',
      GoalCategory.other => 'other',
    };
  }

  String getDisplayName() {
    return switch (this) {
      GoalCategory.practice => 'Practice',
      GoalCategory.skill => 'Skill Development',
      GoalCategory.fitness => 'Fitness',
      GoalCategory.mental => 'Mental Training',
      GoalCategory.equipment => 'Equipment',
      GoalCategory.tournament => 'Tournament',
      GoalCategory.social => 'Social/Competition',
      GoalCategory.other => 'Other',
    };
  }

  String getDisplayNameVi() {
    return switch (this) {
      GoalCategory.practice => 'Luyện tập',
      GoalCategory.skill => 'Phát triển kỹ năng',
      GoalCategory.fitness => 'Thể lực',
      GoalCategory.mental => 'Tâm lý',
      GoalCategory.equipment => 'Dụng cụ',
      GoalCategory.tournament => 'Giải đấu',
      GoalCategory.social => 'Xã hội/Thi đấu',
      GoalCategory.other => 'Khác',
    };
  }
}

enum GoalPriority {
  low,
  medium,
  high,
  urgent,
}

extension GoalPriorityExtension on GoalPriority {
  String get name {
    return switch (this) {
      GoalPriority.low => 'low',
      GoalPriority.medium => 'medium',
      GoalPriority.high => 'high',
      GoalPriority.urgent => 'urgent',
    };
  }

  String getDisplayName() {
    return switch (this) {
      GoalPriority.low => 'Low',
      GoalPriority.medium => 'Medium',
      GoalPriority.high => 'High',
      GoalPriority.urgent => 'Urgent',
    };
  }

  Color getColor() {
    return switch (this) {
      GoalPriority.low => GoalColors.grey,
      GoalPriority.medium => GoalColors.blue,
      GoalPriority.high => GoalColors.orange,
      GoalPriority.urgent => GoalColors.red,
    };
  }
}

enum GoalStatus {
  active,
  completed,
  abandoned,
  onHold,
}

extension GoalStatusExtension on GoalStatus {
  String get name {
    return switch (this) {
      GoalStatus.active => 'active',
      GoalStatus.completed => 'completed',
      GoalStatus.abandoned => 'abandoned',
      GoalStatus.onHold => 'on_hold',
    };
  }
}

enum RecurrencePattern {
  daily,
  weekly,
  monthly,
}

extension RecurrencePatternExtension on RecurrencePattern {
  String get name {
    return switch (this) {
      RecurrencePattern.daily => 'daily',
      RecurrencePattern.weekly => 'weekly',
      RecurrencePattern.monthly => 'monthly',
    };
  }

  String getDisplayName() {
    return switch (this) {
      RecurrencePattern.daily => 'Daily',
      RecurrencePattern.weekly => 'Weekly',
      RecurrencePattern.monthly => 'Monthly',
    };
  }
}

class GoalColors {
  static const Color grey = Color(0xFF9E9E9E);
  static const Color blue = Color(0xFF2196F3);
  static const Color orange = Color(0xFFFF9800);
  static const Color red = Color(0xFFF44336);
  static const Color green = Color(0xFF4CAF50);
}
