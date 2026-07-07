import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_provider.dart';
import 'package:pool_os/features/statistics/presentation/statistics_provider.dart';

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref.watch(playerRepositoryProvider), ref);
});

class PlayerState {
  final List<Player> players;
  final Player? activePlayer;
  final Player? editingPlayer;
  final bool isLoading;
  final String? error;
  final bool isEditing;
  final bool isCreating;

  const PlayerState({
    this.players = const [],
    this.activePlayer,
    this.editingPlayer,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.isCreating = false,
  });

  PlayerState copyWith({
    List<Player>? players,
    Player? activePlayer,
    Player? editingPlayer,
    bool? isLoading,
    String? error,
    bool? isEditing,
    bool? isCreating,
    bool clearActivePlayer = false,
    bool clearEditingPlayer = false,
  }) {
    return PlayerState(
      players: players ?? this.players,
      activePlayer: clearActivePlayer ? null : (activePlayer ?? this.activePlayer),
      editingPlayer: clearEditingPlayer ? null : (editingPlayer ?? this.editingPlayer),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      isCreating: isCreating ?? this.isCreating,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _repository;
  final Ref _ref;

  PlayerNotifier(this._repository, this._ref) : super(const PlayerState());

  void _triggerCascadingUpdates() {
    _ref.read(dashboardProvider.notifier).refresh();
    _ref.read(statisticsNotifierProvider.notifier).refreshStatistics();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setEditing(bool editing, {Player? player}) {
    state = state.copyWith(
      isEditing: editing,
      editingPlayer: player,
      isCreating: player == null && editing,
    );
  }

  void setCreating(bool creating) {
    state = state.copyWith(isCreating: creating, isEditing: creating);
  }

  void setActivePlayer(Player player) {
    state = state.copyWith(activePlayer: player);
  }

  void setPlayers(List<Player> players) {
    state = state.copyWith(players: players, isLoading: false);
  }

  Future<void> loadPlayers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final players = await _repository.getAllPlayers();
      final active = players.isNotEmpty
          ? (await _repository.getActivePlayer()) ?? players.first
          : null;
      state = state.copyWith(
        players: players,
        activePlayer: active,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadActivePlayer() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final active = await _repository.getActivePlayer();
      state = state.copyWith(activePlayer: active, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectPlayer(Player player) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setActivePlayer(player.id!);
      state = state.copyWith(activePlayer: player, isLoading: false);
      _triggerCascadingUpdates();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePlayer(Player player) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePlayer(player);
      await loadPlayers();
      _triggerCascadingUpdates();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createPlayer(Player player) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final id = await _repository.createPlayer(player);
      final newPlayer = player.copyWith(id: id);
      await loadPlayers();
      if (state.players.length == 1) {
        await _repository.setActivePlayer(id);
        state = state.copyWith(activePlayer: newPlayer);
      }
      _triggerCascadingUpdates();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deletePlayer(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deletePlayer(id);
      await loadPlayers();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void startEditing(Player player) {
    state = state.copyWith(
      isEditing: true,
      isCreating: false,
      editingPlayer: player,
    );
  }

  void startCreating() {
    state = state.copyWith(
      isEditing: true,
      isCreating: true,
      editingPlayer: null,
    );
  }

  void cancelEditing() {
    state = state.copyWith(
      isEditing: false,
      isCreating: false,
      clearEditingPlayer: true,
    );
  }
}
