import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/player_progress_service.dart';
import '../domain/player_progress_projection.dart';
import '../../player/presentation/player_provider.dart';

final playerProgressProvider =
    FutureProvider.autoDispose<PlayerProgressProjection?>((ref) {
  ref.watch(playerNotifierProvider.select((state) => state.revision));
  return ref.watch(playerProgressServiceProvider).loadOrRefreshActivePlayer();
});
