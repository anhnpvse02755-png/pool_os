// Task 12 — Data Center domain models.
//
// Pure Dart, no persistence. The Data Center is a NON-AI data-management layer:
// full backup / restore, per-module export, import, database information and
// maintenance. It never edits the meaning of recorded data and never touches
// the Statistics engine or the LOCKED RFC-301/302 recording pipeline logic — it
// only reads rows out (backup/export/info) and, on an explicit user-confirmed
// restore/import, writes rows back inside a transaction.

/// The on-disk backup format version. Bumped only if the envelope shape (not the
/// table schema) changes. Restore checks this + the DB schema version so a
/// backup from an incompatible build is rejected instead of corrupting data.
const int kBackupFormatVersion = 1;

/// A parsed backup envelope (Phần 1/2). [tables] maps a table name to its list
/// of row maps (JSON-primitive values). Kept generic so every table is backed
/// up without per-table code — see BackupService.
class BackupEnvelope {
  final int formatVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final String appLabel;
  final Map<String, List<Map<String, Object?>>> tables;

  const BackupEnvelope({
    required this.formatVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.appLabel,
    required this.tables,
  });

  /// Total row count across every table (shown in the restore confirmation).
  int get totalRows =>
      tables.values.fold(0, (sum, rows) => sum + rows.length);

  Map<String, Object?> toJson() => {
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'appLabel': appLabel,
        'tables': tables,
      };

  factory BackupEnvelope.fromJson(Map<String, Object?> json) {
    final rawTables = (json['tables'] as Map).cast<String, Object?>();
    final tables = <String, List<Map<String, Object?>>>{};
    rawTables.forEach((table, rows) {
      tables[table] = (rows as List)
          .map((r) => (r as Map).cast<String, Object?>())
          .toList();
    });
    return BackupEnvelope(
      formatVersion: (json['formatVersion'] as num?)?.toInt() ?? 0,
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      appLabel: json['appLabel'] as String? ?? 'Pool OS',
      tables: tables,
    );
  }
}

/// Metadata about a backup file sitting in the backups directory (Phần 2 — the
/// restore picker lists these). Cheap to build — read from the file's header +
/// filesystem stat, without loading the whole payload.
class BackupFileInfo {
  final String path;
  final String fileName;
  final int sizeBytes;
  final DateTime modifiedAt;
  final int? schemaVersion; // parsed from the envelope header, null if unreadable
  final int? totalRows;

  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.sizeBytes,
    required this.modifiedAt,
    this.schemaVersion,
    this.totalRows,
  });
}

/// Phần 5 — a read-only snapshot of database information.
class DatabaseInfo {
  final int schemaVersion;
  final int backupFormatVersion;
  final int sizeBytes;
  final int players;
  final int matches;
  final int racks;
  final int shots;
  final int trainingSessions;
  final int goals;
  final Map<String, int> rowCounts; // every table -> row count

  const DatabaseInfo({
    required this.schemaVersion,
    required this.backupFormatVersion,
    required this.sizeBytes,
    required this.players,
    required this.matches,
    required this.racks,
    required this.shots,
    required this.trainingSessions,
    required this.goals,
    required this.rowCounts,
  });
}

/// The outcome of a restore or import (Phần 2/4), surfaced to the UI.
class RestoreResult {
  final bool ok;
  final int tablesRestored;
  final int rowsRestored;
  final String? errorKey; // l10n key when !ok

  const RestoreResult({
    required this.ok,
    this.tablesRestored = 0,
    this.rowsRestored = 0,
    this.errorKey,
  });
}

/// A module the player can export on its own (Phần 3). Each maps to one or more
/// source tables the export service reads read-only.
enum ExportModule { matches, training, goals, equipment, shots }

extension ExportModuleInfo on ExportModule {
  String get code {
    switch (this) {
      case ExportModule.matches:
        return 'matches';
      case ExportModule.training:
        return 'training';
      case ExportModule.goals:
        return 'goals';
      case ExportModule.equipment:
        return 'equipment';
      case ExportModule.shots:
        return 'shots';
    }
  }

  String get labelKey => 'dc_export_$code';
}

/// Chosen export encoding (Phần 3). JSON preserves types; CSV is spreadsheet-
/// friendly.
enum ExportFormat { json, csv }
