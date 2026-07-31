// EPIC 09 — SettingsEngine (Track A — User Settings).
//
// Phase 1. Personal user preferences: Theme / Language / Currency / Units.

import 'package:pool_os/features/user_settings/domain/user_settings_engine.dart';

class SettingsEngine implements UserSettingsEngine {
  @override
  String get engineId => 'settings';
  @override
  Future<UserSettingsContribution> run(UserSettingsRequest request) async {
    return const UserSettingsContribution(
      engineId: 'settings',
      status: CapabilityStatus.implemented,
    );
  }
}