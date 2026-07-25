import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/player_profile_service.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/player/presentation/player_provider.dart';

typedef SavePlayerProfile = Future<bool> Function(Player player);

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfileState>((ref) {
  ref.watch(playerNotifierProvider.select((state) => state.revision));
  return PlayerProfileNotifier(
    ref.watch(playerRepositoryProvider),
    ref.watch(playerProfileServiceProvider),
    ref.watch(equipmentRepositoryProvider),
    (player) {
      final notifier = ref.read(playerNotifierProvider.notifier);
      return player.id == null
          ? notifier.createPlayer(player)
          : notifier.updatePlayer(player);
    },
  );
});

class PlayerProfileState {
  final Player? player;
  final ProfileAchievements? achievements;
  final List<TimelineEntry> timeline;
  // Read-only equipment display (§6): the cues currently used per role.
  final Cue? playingCue;
  final Cue? breakCue;
  final Cue? jumpCue;
  final bool isLoading;
  final String? error;

  const PlayerProfileState({
    this.player,
    this.achievements,
    this.timeline = const [],
    this.playingCue,
    this.breakCue,
    this.jumpCue,
    this.isLoading = false,
    this.error,
  });

  PlayerProfileState copyWith({
    Player? player,
    ProfileAchievements? achievements,
    List<TimelineEntry>? timeline,
    Cue? playingCue,
    Cue? breakCue,
    Cue? jumpCue,
    bool? isLoading,
    String? error,
    bool clearPlaying = false,
    bool clearBreak = false,
    bool clearJump = false,
  }) {
    return PlayerProfileState(
      player: player ?? this.player,
      achievements: achievements ?? this.achievements,
      timeline: timeline ?? this.timeline,
      playingCue: clearPlaying ? null : (playingCue ?? this.playingCue),
      breakCue: clearBreak ? null : (breakCue ?? this.breakCue),
      jumpCue: clearJump ? null : (jumpCue ?? this.jumpCue),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlayerProfileNotifier extends StateNotifier<PlayerProfileState> {
  final PlayerRepository _playerRepo;
  final PlayerProfileService _profileService;
  final EquipmentRepository _equipmentRepo;
  final SavePlayerProfile _savePlayer;

  PlayerProfileNotifier(
    this._playerRepo,
    this._profileService,
    this._equipmentRepo,
    this._savePlayer,
  ) : super(const PlayerProfileState(isLoading: true)) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final player = await _playerRepo.getActivePlayer();
      final achievements = await _profileService.computeAchievements();
      final timeline = await _profileService.buildTimeline();
      final playingCue = await _equipmentRepo.getActiveCueByType(
        'playing',
        playerId: player?.id,
      );
      final breakCue = await _equipmentRepo.getActiveCueByType(
        'break',
        playerId: player?.id,
      );
      final jumpCue = await _equipmentRepo.getActiveCueByType(
        'jump',
        playerId: player?.id,
      );
      if (!mounted) return;
      state = PlayerProfileState(
        player: player,
        achievements: achievements,
        timeline: timeline,
        playingCue: playingCue,
        breakCue: breakCue,
        jumpCue: jumpCue,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Persist an edited profile. Creates the player row if none exists yet.
  Future<void> saveProfile(Player updated) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final saved = await _savePlayer(updated);
      if (!saved) {
        throw StateError(
          'player-profile-save-failed',
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
