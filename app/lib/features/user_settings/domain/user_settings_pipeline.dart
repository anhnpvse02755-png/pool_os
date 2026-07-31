// EPIC 09 — UserSettingsPipeline (Track A — 3 engines).

import 'package:pool_os/features/user_settings/domain/user_settings_engine.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_request.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_response.dart';
import 'package:pool_os/features/user_settings/domain/capability.dart';
import 'package:pool_os/features/user_settings/domain/engines/settings_engine.dart';
import 'package:pool_os/features/user_settings/domain/engines/backup_engine.dart';
import 'package:pool_os/features/user_settings/domain/engines/import_export_engine.dart';

class UserSettingsPipeline {
  final List<UserSettingsEngine> _engines;
  const UserSettingsPipeline(this._engines);

  UserSettingsEngine? _byId(String id) {
    for (final e in _engines) {
      if (e.engineId == id) return e;
    }
    return null;
  }

  Future<UserSettingsResponse> _run(
    String playerId,
    DateTime now,
    UserSettingsRequest request,
    List<String> ids,
  ) async {
    final contributions = <UserSettingsContribution>[];
    for (final id in ids) {
      final engine = _byId(id);
      if (engine == null) {
        contributions.add(UserSettingsContribution(
          engineId: id,
          status: CapabilityStatus.planned,
          reason: const CapabilityReason(
            code: 'engine_not_registered',
            message: 'Not yet registered in the pipeline.',
          ),
        ));
        continue;
      }
      contributions.add(await engine.run(request));
    }
    return UserSettingsResponse(
      playerId: playerId,
      generatedAt: now,
      contributions: contributions,
    );
  }

  Future<UserSettingsResponse> settings(SettingsUpdateRequest req) =>
      _run(req.playerId, req.asOf, req, const ['settings']);

  Future<UserSettingsResponse> backup(BackupRequest req) =>
      _run(req.playerId, req.asOf, req, const ['backup']);

  Future<UserSettingsResponse> restore(RestoreRequest req) =>
      _run(req.playerId, req.asOf, req, const ['backup']);

  Future<UserSettingsResponse> export(ExportRequest req) =>
      _run(req.playerId, req.asOf, req, const ['import_export']);

  Future<UserSettingsResponse> import(ImportRequest req) =>
      _run(req.playerId, req.asOf, req, const ['import_export']);

  Future<UserSettingsResponse> dashboard(UserSettingsRequest req) =>
      _run(req.playerId, req.asOf, req, const ['settings', 'backup', 'import_export']);
}

UserSettingsPipeline defaultUserSettingsPipeline() {
  return UserSettingsPipeline(<UserSettingsEngine>[
    SettingsEngine(),
    BackupEngine(),
    ImportExportEngine(),
  ]);
}