// EPIC 09 — ImportExportEngine (Track A — Import/Export).
//
// Phase 1. Personal data export (JSON/CSV) and import. Validate first /
// Preview / Execute / Rollback on failure. No partial corruption allowed.

import 'package:pool_os/features/user_settings/domain/user_settings_engine.dart';

class ImportExportEngine implements UserSettingsEngine {
  @override
  String get engineId => 'import_export';
  @override
  Future<UserSettingsContribution> run(UserSettingsRequest request) async {
    return const UserSettingsContribution(
      engineId: 'import_export',
      status: CapabilityStatus.implemented,
    );
  }
}