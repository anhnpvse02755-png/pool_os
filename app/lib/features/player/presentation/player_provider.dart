import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart';

final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier(ref.watch(playerRepositoryProvider));
});

class PlayerState {
  final List<Player> players;
  final Player? activePlayer;
  final Player? editingPlayer;
  final bool isLoading;
  final String? error;
  final bool isEditing;
  final bool isCreating;
  final int revision;

  const PlayerState({
    this.players = const [],
    this.activePlayer,
    this.editingPlayer,
    this.isLoading = false,
    this.error,
    this.isEditing = false,
    this.isCreating = false,
    this.revision = 0,
  });

  PlayerState copyWith({
    List<Player>? players,
    Player? activePlayer,
    Player? editingPlayer,
    bool? isLoading,
    String? error,
    bool? isEditing,
    bool? isCreating,
    int? revision,
    bool clearActivePlayer = false,
    bool clearEditingPlayer = false,
  }) {
    return PlayerState(
      players: players ?? this.players,
      activePlayer:
          clearActivePlayer ? null : (activePlayer ?? this.activePlayer),
      editingPlayer:
          clearEditingPlayer ? null : (editingPlayer ?? this.editingPlayer),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isEditing: isEditing ?? this.isEditing,
      isCreating: isCreating ?? this.isCreating,
      revision: revision ?? this.revision,
    );
  }
}

class PlayerNotifier extends StateNotifier<PlayerState> {
  final PlayerRepository _repository;

  PlayerNotifier(this._repository) : super(const PlayerState());

  Future<void> _publishCommittedSnapshot() async {
    final snapshot = await _repository.getPlayerSnapshot();
    state = state.copyWith(
      players: snapshot.players,
      activePlayer: snapshot.activePlayer,
      clearActivePlayer: snapshot.activePlayer == null,
      isLoading: false,
      revision: state.revision + 1,
    );
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

  Future<void> loadPlayers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _publishCommittedSnapshot();
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<void> loadActivePlayer() => loadPlayers();

  Future<bool> selectPlayer(Player player) async {
    final previousActivePlayerId = state.activePlayer?.id;
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.switchActivePlayer(player.id!);
      if (previousActivePlayerId == player.id) {
        state = state.copyWith(isLoading: false);
      } else {
        await _publishCommittedSnapshot();
      }
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> updatePlayer(Player player) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updatePlayer(player);
      await _publishCommittedSnapshot();
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> createPlayer(Player player) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.createPlayer(player);
      await _publishCommittedSnapshot();
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
    }
  }

  Future<bool> deletePlayer(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deletePlayer(id);
      await _publishCommittedSnapshot();
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      return false;
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
