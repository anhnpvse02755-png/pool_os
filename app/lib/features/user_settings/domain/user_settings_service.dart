// EPIC 09 — UserSettingsService. THE sole entry point (Track A — mobile app).
//
// PO 2026-07-31: Admin features stay in Pool OS Admin Portal (web).
// Mobile app has User Settings only: Theme / Language / Currency / Units /
// Backup / Restore / Import / Export. No admin permissions.

import 'package:pool_os/features/user_settings/domain/user_settings_pipeline.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_request.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_response.dart';

class UserSettingsService {
  final UserSettingsPipeline _pipeline;
  const UserSettingsService(this._pipeline);

  Future<UserSettingsResponse> settings(SettingsUpdateRequest req) =>
      _pipeline.settings(req);

  Future<UserSettingsResponse> backup(BackupRequest req) =>
      _pipeline.backup(req);

  Future<UserSettingsResponse> restore(RestoreRequest req) =>
      _pipeline.restore(req);

  Future<UserSettingsResponse> export(ExportRequest req) =>
      _pipeline.export(req);

  Future<UserSettingsResponse> import_(ImportRequest req) =>
      _pipeline.import(req);

  Future<UserSettingsResponse> dashboard(UserSettingsRequest req) =>
      _pipeline.dashboard(req);
}