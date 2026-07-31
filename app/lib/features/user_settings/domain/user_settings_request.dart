// EPIC 09 — User Settings request shapes (Track A — mobile app).

import 'package:pool_os/features/user_settings/domain/models/user_settings_models.dart';

class UserSettingsRequest {
  final String playerId;
  final DateTime asOf;
  const UserSettingsRequest({required this.playerId, required this.asOf});
}

class SettingsUpdateRequest extends UserSettingsRequest {
  final ThemeMode? theme;
  final String? language;
  final String? currency;
  final String? units;
  const SettingsUpdateRequest({
    required super.playerId,
    required super.asOf,
    this.theme,
    this.language,
    this.currency,
    this.units,
  });
}

class BackupRequest extends UserSettingsRequest {
  const BackupRequest({required super.playerId, required super.asOf});
}

class RestoreRequest extends UserSettingsRequest {
  final String backupId;
  const RestoreRequest({
    required super.playerId,
    required super.asOf,
    required this.backupId,
  });
}

class ExportRequest extends UserSettingsRequest {
  final ExportScope scope;
  final ExportFormat format;
  const ExportRequest({
    required super.playerId,
    required super.asOf,
    required this.scope,
    required this.format,
  });
}

class ImportRequest extends UserSettingsRequest {
  final ImportFormat format;
  final String? validationOnly;
  const ImportRequest({
    required super.playerId,
    required super.asOf,
    required this.format,
    this.validationOnly,
  });
}