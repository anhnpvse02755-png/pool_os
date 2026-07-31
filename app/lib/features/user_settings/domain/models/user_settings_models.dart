// EPIC 09 — User Settings data models (Track A — mobile app).

class UserSettings {
  final String playerId;
  final ThemeMode theme;
  final String language;
  final String currency;
  final String units;
  final DateTime updatedAt;

  const UserSettings({
    required this.playerId,
    this.theme = ThemeMode.system,
    this.language = 'en',
    this.currency = 'USD',
    this.units = 'metric',
    required this.updatedAt,
  });
}

enum ThemeMode { light, dark, system }

class BackupMetadata {
  final String id;
  final String playerId;
  final DateTime createdAt;
  final String version;
  final int schemaVersion;
  final String buildVersion;
  final String checksum;

  const BackupMetadata({
    required this.id,
    required this.playerId,
    required this.createdAt,
    required this.version,
    required this.schemaVersion,
    required this.buildVersion,
    required this.checksum,
  });
}

class ImportJob {
  final String id;
  final String playerId;
  final ImportFormat format;
  final ImportState state;
  final String? error;
  final DateTime createdAt;

  const ImportJob({
    required this.id,
    required this.playerId,
    required this.format,
    required this.state,
    this.error,
    required this.createdAt,
  });
}

enum ImportFormat { json, csv }
enum ImportState { pending, validating, preview, executing, completed, failed, rolledBack }

class ExportJob {
  final String id;
  final String playerId;
  final ExportScope scope;
  final ExportFormat format;
  final ExportState state;
  final String? filePath;
  final DateTime createdAt;

  const ExportJob({
    required this.id,
    required this.playerId,
    required this.scope,
    required this.format,
    required this.state,
    this.filePath,
    required this.createdAt,
  });
}

enum ExportScope { equipment, knowledge, training, statistics, all }
enum ExportFormat { json, csv }
enum ExportState { pending, executing, completed, failed }