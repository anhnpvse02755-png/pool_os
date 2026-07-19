import 'dart:async';

import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/settings/presentation/settings_provider.dart';

void main() {
  test('theme and locale survive SettingsNotifier recreation', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = PlayerRepository(database);
    await repository.createPlayer(
      Player(
        name: 'UAT Player',
        dominantHand: 'right',
        language: 'vi',
        measurementSystem: 'cm',
        theme: 'dark',
      ),
    );

    final first = SettingsNotifier(repository);
    addTearDown(first.dispose);
    await _waitUntil(() => first.state.themeMode == ThemeMode.dark);

    first.setThemeMode(ThemeMode.light);
    first.setLocale('en');
    await _waitUntil(() async {
      final player = await repository.getActivePlayer();
      return player?.theme == 'light' && player?.language == 'en';
    });

    final reloaded = SettingsNotifier(repository);
    addTearDown(reloaded.dispose);
    await _waitUntil(
      () =>
          reloaded.state.themeMode == ThemeMode.light &&
          reloaded.state.locale == 'en',
    );
  });
}

Future<void> _waitUntil(FutureOr<bool> Function() condition) async {
  for (var attempt = 0; attempt < 50; attempt++) {
    final result = condition();
    if (result is Future<bool> ? await result : result) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Condition was not met before timeout.');
}
