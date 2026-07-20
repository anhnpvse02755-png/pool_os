import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(playerRepositoryProvider));
});

class SettingsState {
  final String locale;
  final ThemeMode themeMode;
  final String measurementSystem;

  const SettingsState({
    this.locale = 'vi',
    this.themeMode = ThemeMode.system,
    this.measurementSystem = 'cm',
  });

  SettingsState copyWith({
    String? locale,
    ThemeMode? themeMode,
    String? measurementSystem,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      measurementSystem: measurementSystem ?? this.measurementSystem,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final PlayerRepository _playerRepository;
  bool _changedSinceStart = false;
  Future<void> _pendingWrite = Future.value();

  SettingsNotifier(this._playerRepository) : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final player = await _playerRepository.getActivePlayer();
    if (_changedSinceStart) return;
    if (player == null) return;
    state = SettingsState(
      locale: player.language,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == player.theme,
        orElse: () => ThemeMode.system,
      ),
      measurementSystem: player.measurementSystem,
    );
  }

  void setLocale(String locale) {
    _changedSinceStart = true;
    state = state.copyWith(locale: locale);
    _schedulePersist();
  }

  void setThemeMode(ThemeMode mode) {
    _changedSinceStart = true;
    state = state.copyWith(themeMode: mode);
    _schedulePersist();
  }

  void setMeasurementSystem(String system) {
    _changedSinceStart = true;
    state = state.copyWith(measurementSystem: system);
    _schedulePersist();
  }

  void _schedulePersist() {
    final snapshot = state;
    _pendingWrite = _pendingWrite.then((_) async {
      final player = await _playerRepository.getActivePlayer();
      if (player == null) return;
      await _playerRepository.updatePlayer(
        player.copyWith(
          language: snapshot.locale,
          theme: snapshot.themeMode.name,
          measurementSystem: snapshot.measurementSystem,
        ),
      );
    });
  }
}
