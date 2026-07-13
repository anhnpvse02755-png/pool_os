import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';
import 'package:pool_os/features/match/data/repositories/match_context_repository.dart';

/// Task 06: loads/saves the pre- and post-match context for a single Match.
/// Family-keyed by matchId so each match has its own state. Data-only.
final matchContextProvider = StateNotifierProvider.family<MatchContextNotifier,
    MatchContextState, int>((ref, matchId) {
  return MatchContextNotifier(ref.watch(matchContextRepositoryProvider), matchId);
});

class MatchContextState {
  final MatchContext? context;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const MatchContextState({
    this.context,
    this.isLoading = true,
    this.isSaving = false,
    this.error,
  });

  MatchContextState copyWith({
    MatchContext? context,
    bool? isLoading,
    bool? isSaving,
    String? error,
  }) {
    return MatchContextState(
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

class MatchContextNotifier extends StateNotifier<MatchContextState> {
  final MatchContextRepository _repo;
  final int matchId;

  MatchContextNotifier(this._repo, this.matchId)
      : super(const MatchContextState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ctx = await _repo.getByMatchId(matchId);
      state = MatchContextState(context: ctx, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> savePre(MatchContext ctx) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repo.savePreMatch(ctx);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> savePost(MatchContext ctx) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      await _repo.savePostMatch(ctx);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}
