import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';

final dailyReadinessProvider =
    StateNotifierProvider<DailyReadinessNotifier, DailyReadinessState>((ref) {
  return DailyReadinessNotifier(
      ref.watch(dailyReadinessRepositoryProvider), ref);
});

class DailyReadinessState {
  final DailyReadinessModel? today;
  final List<DailyReadinessModel> recentDays;
  final bool isLoading;
  final String? error;

  const DailyReadinessState({
    this.today,
    this.recentDays = const [],
    this.isLoading = false,
    this.error,
  });

  DailyReadinessState copyWith({
    DailyReadinessModel? today,
    List<DailyReadinessModel>? recentDays,
    bool? isLoading,
    String? error,
    bool clearToday = false,
  }) {
    return DailyReadinessState(
      today: clearToday ? null : (today ?? this.today),
      recentDays: recentDays ?? this.recentDays,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class DailyReadinessNotifier extends StateNotifier<DailyReadinessState> {
  final DailyReadinessRepository _repository;
  final Ref _ref;

  // FIX-007A: Track pending saves for debouncing
  Timer? _saveTimer;

  DailyReadinessNotifier(this._repository, this._ref)
      : super(const DailyReadinessState());

  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _triggerCascadingUpdates() {
    _ref.read(dashboardProvider.notifier).refresh();
    _ref.invalidate(coachContextProvider);
    _ref.invalidate(coachOutputProvider);
  }

  Future<void> loadToday() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final today = await _repository.getByDate(_getTodayDate());
      state = state.copyWith(
        today: today,
        clearToday: today == null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadRecentDays() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final recentDays = await _repository.getRecentDays(7);
      state = state.copyWith(recentDays: recentDays, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _scheduleSave(DailyReadinessModel readiness) {
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 500),
      () => saveNow(readiness),
    );
  }

  Future<bool> saveNow([DailyReadinessModel? readiness]) async {
    _saveTimer?.cancel();
    final toSave = readiness ?? state.today;
    if (toSave == null) return false;

    try {
      await _repository.upsert(toSave);
      final recentDays = await _repository.getRecentDays(7);
      if (!mounted) return true;
      state = state.copyWith(
        today: toSave,
        recentDays: recentDays,
        isLoading: false,
        error: null,
      );
      _triggerCascadingUpdates();
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
      return false;
    }
  }

  // FIX-007A: Update UI immediately, debounce DB save
  void updateFieldImmediate(String field, dynamic value) {
    final current = state.today ?? DailyReadinessModel(date: _getTodayDate());
    DailyReadinessModel updated;

    switch (field) {
      case 'sleepHours':
        updated = current.copyWith(sleepHours: value as double?);
        break;
      case 'energyLevel':
        updated = current.copyWith(energyLevel: value as int?);
        break;
      case 'focusLevel':
        updated = current.copyWith(focusLevel: value as int?);
        break;
      case 'confidenceLevel':
        updated = current.copyWith(confidenceLevel: value as int?);
        break;
      case 'mood':
        updated = current.copyWith(mood: value as String?);
        break;
      case 'stressLevel':
        updated = current.copyWith(stressLevel: value as int?);
        break;
      case 'shoulderCondition':
        updated = current.copyWith(shoulderCondition: value as int?);
        break;
      case 'wristCondition':
        updated = current.copyWith(wristCondition: value as int?);
        break;
      case 'backCondition':
        updated = current.copyWith(backCondition: value as int?);
        break;
      case 'equipment':
        updated = current.copyWith(equipment: value as String?);
        break;
      case 'playingLocation':
        updated = current.copyWith(playingLocation: value as String?);
        break;
      case 'tableSpeed':
        updated = current.copyWith(tableSpeed: value as String?);
        break;
      case 'todayGoal':
        updated = current.copyWith(todayGoal: value as String?);
        break;
      case 'notes':
        updated = current.copyWith(notes: value as String?);
        break;
      default:
        return;
    }

    // Update UI immediately
    state = state.copyWith(today: updated);

    // Debounce save to DB
    _scheduleSave(updated);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}
