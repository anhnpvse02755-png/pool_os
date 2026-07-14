import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/data_center/domain/models/data_center_models.dart';

final dataCenterServiceProvider = Provider<DataCenterService>((ref) {
  return DataCenterService(ref.watch(databaseProvider));
});

/// Task 12 — the Data Center service. It manages the *storage* of Pool OS data
/// (backup / restore / export / import / info / maintenance) without changing
/// the *meaning* of any of it. It reads rows out generically via [db.AppDatabase.allTables]
/// + raw SQL, and only writes rows back on an explicit, user-confirmed
/// restore/import — inside a single transaction. It never edits the Statistics
/// engine or the LOCKED RFC-301/302 recording pipeline logic, and never deletes
/// user data during maintenance. No AI.
///
/// File I/O uses path_provider only (no share_plus / file_picker in this
/// project): backups + exports are written to app-scoped directories the UI
/// then lists, and restore/import read a file by path.
class DataCenterService {
  final db.AppDatabase _db;

  DataCenterService(this._db);

  static const _backupDirName = 'backups';
  static const _exportDirName = 'exports';

  // --- Directories ---------------------------------------------------------

  Future<Directory> _backupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _backupDirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _exportDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, _exportDirName));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Every physical table name in the schema (generic — no hardcoded list, so a
  /// future table is backed up automatically once it exists in [allTables]).
  List<String> get _tableNames =>
      _db.allTables.map((t) => t.actualTableName).toList();

  // --- Backup (Phần 1) -----------------------------------------------------

  /// Build the full backup envelope from every table. Values are already JSON
  /// primitives (Drift stores ints/reals/text/blobs), so they serialize as-is;
  /// blobs (none in this schema) would need base64 but are absent here.
  Future<BackupEnvelope> buildBackup() async {
    final tables = <String, List<Map<String, Object?>>>{};
    for (final name in _tableNames) {
      final rows = await _db.customSelect('SELECT * FROM $name').get();
      tables[name] = rows.map((r) => r.data).toList();
    }
    return BackupEnvelope(
      formatVersion: kBackupFormatVersion,
      schemaVersion: _db.schemaVersion,
      createdAt: DateTime.now(),
      appLabel: 'Pool OS',
      tables: tables,
    );
  }

  /// Write a backup to the backups directory and return the created file.
  Future<File> createBackupFile() async {
    final envelope = await buildBackup();
    final dir = await _backupDir();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File(p.join(dir.path, 'pool_os_backup_$stamp.json'));
    await file.writeAsString(jsonEncode(envelope.toJson()));
    return file;
  }

  /// List existing backup files newest-first, with cheap header metadata.
  Future<List<BackupFileInfo>> listBackups() async {
    final dir = await _backupDir();
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    final infos = <BackupFileInfo>[];
    for (final f in files) {
      int? schema;
      int? rows;
      try {
        final json = jsonDecode(await f.readAsString()) as Map<String, Object?>;
        schema = (json['schemaVersion'] as num?)?.toInt();
        final tbls = json['tables'];
        if (tbls is Map) {
          rows = tbls.values
              .fold<int>(0, (s, v) => s + (v is List ? v.length : 0));
        }
      } catch (_) {
        // Unreadable / not a Pool OS backup — still list it, flagged null.
      }
      final stat = f.statSync();
      infos.add(BackupFileInfo(
        path: f.path,
        fileName: p.basename(f.path),
        sizeBytes: stat.size,
        modifiedAt: stat.modified,
        schemaVersion: schema,
        totalRows: rows,
      ));
    }
    infos.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return infos;
  }

  Future<void> deleteBackup(String path) async {
    final f = File(path);
    if (await f.exists()) await f.delete();
  }

  // --- Restore / Import (Phần 2 / 4) ---------------------------------------

  /// Parse a backup file's header without loading intent to restore — used to
  /// power the overwrite-confirmation dialog (Phần 2 — cảnh báo trước khi ghi đè).
  Future<BackupEnvelope> readBackup(String path) async {
    final json = jsonDecode(await File(path).readAsString())
        as Map<String, Object?>;
    return BackupEnvelope.fromJson(json);
  }

  /// Restore from a parsed envelope. Version-checked (Phần 2): a backup from a
  /// different schema version is refused rather than risking corruption. The
  /// whole operation runs in ONE transaction — delete-all + re-insert per table
  /// — so a failure rolls back and leaves the current data intact (no partial
  /// state, no duplicates). Only known tables are touched.
  Future<RestoreResult> restore(BackupEnvelope envelope) async {
    if (envelope.formatVersion > kBackupFormatVersion) {
      return const RestoreResult(ok: false, errorKey: 'dc_err_format');
    }
    if (envelope.schemaVersion != _db.schemaVersion) {
      return const RestoreResult(ok: false, errorKey: 'dc_err_schema');
    }

    final known = _tableNames.toSet();
    var tablesDone = 0;
    var rowsDone = 0;

    try {
      await _db.transaction(() async {
        // Defer FK checks to commit time so table + row order within the bulk
        // replace doesn't matter (a child row can be inserted before its
        // parent). Unlike `PRAGMA foreign_keys = OFF`, defer_foreign_keys DOES
        // take effect inside a transaction and auto-resets when it ends. If any
        // referential integrity is actually broken, the commit fails and the
        // whole restore rolls back — current data stays intact.
        await _db.customStatement('PRAGMA defer_foreign_keys = ON');
        for (final entry in envelope.tables.entries) {
          final table = entry.key;
          if (!known.contains(table)) continue; // ignore unknown/stale tables
          await _db.customStatement('DELETE FROM $table');
          for (final row in entry.value) {
            await _insertRow(table, row);
            rowsDone++;
          }
          tablesDone++;
        }
      });
    } catch (_) {
      return const RestoreResult(ok: false, errorKey: 'dc_err_restore');
    }

    return RestoreResult(
      ok: true,
      tablesRestored: tablesDone,
      rowsRestored: rowsDone,
    );
  }

  /// Restore straight from a file path (Phần 2/4).
  Future<RestoreResult> restoreFromFile(String path) async {
    try {
      final envelope = await readBackup(path);
      return restore(envelope);
    } catch (_) {
      return const RestoreResult(ok: false, errorKey: 'dc_err_parse');
    }
  }

  /// Insert one row map into [table] using a parameterised statement (values
  /// bound, never interpolated — no SQL injection through cell contents).
  Future<void> _insertRow(String table, Map<String, Object?> row) async {
    if (row.isEmpty) return;
    final cols = row.keys.toList();
    final placeholders = List.filled(cols.length, '?').join(', ');
    final colList = cols.map((c) => '"$c"').join(', ');
    final values = cols.map((c) => _toSqlValue(row[c])).toList();
    await _db.customStatement(
      'INSERT INTO $table ($colList) VALUES ($placeholders)',
      values,
    );
  }

  Object? _toSqlValue(Object? v) {
    // JSON round-trips bool as bool, but SQLite wants int for it.
    if (v is bool) return v ? 1 : 0;
    return v;
  }

  // --- Export (Phần 3) -----------------------------------------------------

  /// The source table(s) for an export module.
  List<String> _tablesForModule(ExportModule m) {
    switch (m) {
      case ExportModule.matches:
        return ['matches'];
      case ExportModule.training:
        return ['training_center_sessions', 'drill_runs'];
      case ExportModule.goals:
        return ['goals'];
      case ExportModule.equipment:
        return ['cues'];
      case ExportModule.shots:
        return ['shots'];
    }
  }

  /// Export one module to a file in the exports directory, returning the file.
  Future<File> exportModule(ExportModule module, ExportFormat format) async {
    final dir = await _exportDir();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final ext = format == ExportFormat.json ? 'json' : 'csv';
    final file =
        File(p.join(dir.path, 'pool_os_${module.code}_$stamp.$ext'));

    final tables = _tablesForModule(module);
    if (format == ExportFormat.json) {
      final out = <String, List<Map<String, Object?>>>{};
      for (final t in tables) {
        final rows = await _db.customSelect('SELECT * FROM $t').get();
        out[t] = rows.map((r) => r.data).toList();
      }
      await file.writeAsString(jsonEncode(out));
    } else {
      // CSV of the module's primary table (first). Spreadsheet-friendly.
      final primary = tables.first;
      final rows = await _db.customSelect('SELECT * FROM $primary').get();
      await file.writeAsString(_toCsv(rows.map((r) => r.data).toList()));
    }
    return file;
  }

  String _toCsv(List<Map<String, Object?>> rows) {
    if (rows.isEmpty) return '';
    final headers = rows.first.keys.toList();
    final buffer = StringBuffer()..writeln(headers.map(_csvCell).join(','));
    for (final row in rows) {
      buffer.writeln(headers.map((h) => _csvCell(row[h])).join(','));
    }
    return buffer.toString();
  }

  String _csvCell(Object? value) {
    final s = value?.toString() ?? '';
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  Future<List<BackupFileInfo>> listExports() async {
    final dir = await _exportDir();
    final files = dir.listSync().whereType<File>().toList();
    final infos = files.map((f) {
      final stat = f.statSync();
      return BackupFileInfo(
        path: f.path,
        fileName: p.basename(f.path),
        sizeBytes: stat.size,
        modifiedAt: stat.modified,
      );
    }).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return infos;
  }

  // --- Database info (Phần 5) ----------------------------------------------

  Future<DatabaseInfo> getInfo() async {
    final counts = <String, int>{};
    for (final name in _tableNames) {
      final row = await _db
          .customSelect('SELECT COUNT(*) AS c FROM $name')
          .getSingle();
      counts[name] = (row.data['c'] as num?)?.toInt() ?? 0;
    }

    int sizeBytes = 0;
    try {
      final docs = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(docs.path, 'pool_os.db'));
      if (await dbFile.exists()) sizeBytes = await dbFile.length();
    } catch (_) {}

    return DatabaseInfo(
      schemaVersion: _db.schemaVersion,
      backupFormatVersion: kBackupFormatVersion,
      sizeBytes: sizeBytes,
      players: counts['players'] ?? 0,
      matches: counts['matches'] ?? 0,
      racks: counts['racks'] ?? 0,
      shots: counts['shots'] ?? 0,
      trainingSessions: counts['training_center_sessions'] ?? 0,
      goals: counts['goals'] ?? 0,
      rowCounts: counts,
    );
  }

  // --- Maintenance (Phần 6) ------------------------------------------------

  /// Verify referential integrity + structural soundness. Non-destructive:
  /// runs SQLite's own checks and returns true when clean. Never edits data.
  Future<bool> verifyIntegrity() async {
    final fk = await _db.customSelect('PRAGMA foreign_key_check').get();
    if (fk.isNotEmpty) return false;
    final check = await _db.customSelect('PRAGMA integrity_check').getSingle();
    final result = check.data.values.first?.toString().toLowerCase();
    return result == 'ok';
  }

  /// Compact the database file (reclaim free pages). Non-destructive — VACUUM
  /// only reorganises storage, it never removes user rows.
  Future<void> compact() async {
    await _db.customStatement('VACUUM');
  }

  /// Clear temporary export files (Phần 6 — dọn dữ liệu tạm). Only touches the
  /// app-generated exports directory; never user data or backups.
  Future<int> clearExports() async {
    final dir = await _exportDir();
    var removed = 0;
    for (final f in dir.listSync().whereType<File>()) {
      await f.delete();
      removed++;
    }
    return removed;
  }
}
