import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';

final sessionMatchRepositoryProvider = Provider<MatchRepository>((ref) {
  return ref.watch(matchRepositoryProvider);
});
