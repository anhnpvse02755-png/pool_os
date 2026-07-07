import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
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
  SettingsNotifier() : super(const SettingsState());

  void setLocale(String locale) {
    state = state.copyWith(locale: locale);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  void setMeasurementSystem(String system) {
    state = state.copyWith(measurementSystem: system);
  }
}
