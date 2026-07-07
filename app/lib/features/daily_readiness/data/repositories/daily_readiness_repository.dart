import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';

final dailyReadinessRepositoryProvider = Provider<DailyReadinessRepository>((ref) {
  return DailyReadinessRepository();
});

class DailyReadinessRepository {
  final Map<String, DailyReadinessModel> _storage = {};

  Future<DailyReadinessModel?> getByDate(String date) async {
    return _storage[date];
  }

  Future<List<DailyReadinessModel>> getByDateRange(String startDate, String endDate) async {
    return _storage.values
        .where((d) => d.date.compareTo(startDate) >= 0 && d.date.compareTo(endDate) <= 0)
        .toList();
  }

  Future<List<DailyReadinessModel>> getRecentDays(int days) async {
    final sorted = _storage.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(days).toList();
  }

  Future<int> upsert(DailyReadinessModel readiness) async {
    final id = _storage.length + 1;
    _storage[readiness.date] = readiness.copyWith(id: id);
    return id;
  }

  Future<int> delete(int id) async {
    final key = _storage.keys.firstWhere(
      (k) => _storage[k]?.id == id,
      orElse: () => '',
    );
    if (key.isNotEmpty) {
      _storage.remove(key);
      return 1;
    }
    return 0;
  }
}
