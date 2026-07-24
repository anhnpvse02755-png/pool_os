import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/player_progress_service.dart';
import '../domain/player_progress_projection.dart';

final playerProgressProvider =
    FutureProvider.autoDispose<PlayerProgressProjection?>((ref) {
  return ref.watch(playerProgressServiceProvider).loadOrRefreshActivePlayer();
});
