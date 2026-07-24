import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';

final sessionMatchRepositoryProvider = Provider<MatchRepository>((ref) {
  return ref.watch(matchRepositoryProvider);
});

final sessionHistoryRepositoryProvider = Provider<SessionRepository>((ref) {
  return ref.watch(sessionRepositoryProvider);
});

final sessionRackHistoryRepositoryProvider = Provider<RackRepository>((ref) {
  return ref.watch(rackRepositoryProvider);
});
