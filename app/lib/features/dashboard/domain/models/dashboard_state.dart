class DashboardState {
  final int todaySessionCount;
  final int todayRackCount;
  final int todayWinCount;
  final int todayShotCount;
  final int todayMadeCount;
  final bool isLoading;
  final String? error;

  const DashboardState({
    this.todaySessionCount = 0,
    this.todayRackCount = 0,
    this.todayWinCount = 0,
    this.todayShotCount = 0,
    this.todayMadeCount = 0,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    int? todaySessionCount,
    int? todayRackCount,
    int? todayWinCount,
    int? todayShotCount,
    int? todayMadeCount,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      todaySessionCount: todaySessionCount ?? this.todaySessionCount,
      todayRackCount: todayRackCount ?? this.todayRackCount,
      todayWinCount: todayWinCount ?? this.todayWinCount,
      todayShotCount: todayShotCount ?? this.todayShotCount,
      todayMadeCount: todayMadeCount ?? this.todayMadeCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
