import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/data_center/data/data_center_service.dart';
import 'package:pool_os/features/data_center/domain/models/data_center_models.dart';

// Task 12 — Data Center providers. Read paths (info, backup/export listings) are
// FutureProviders; write paths (create backup, restore, export, maintenance) go
// through the controller so the UI can await + refresh. No AI.

/// Database information (Phần 5), recomputed on refresh.
final databaseInfoProvider = FutureProvider<DatabaseInfo>((ref) async {
  final service = ref.watch(dataCenterServiceProvider);
  return service.getInfo();
});

/// Existing backup files (Phần 2 — restore picker), newest-first.
final backupListProvider = FutureProvider<List<BackupFileInfo>>((ref) async {
  final service = ref.watch(dataCenterServiceProvider);
  return service.listBackups();
});

/// Existing export files (Phần 3), newest-first.
final exportListProvider = FutureProvider<List<BackupFileInfo>>((ref) async {
  final service = ref.watch(dataCenterServiceProvider);
  return service.listExports();
});

/// Thin controller over the service that invalidates the read providers after a
/// mutation so the UI reflects the new state from the source of truth.
class DataCenterController {
  final Ref _ref;
  DataCenterController(this._ref);

  DataCenterService get _service => _ref.read(dataCenterServiceProvider);

  Future<String> createBackup() async {
    final file = await _service.createBackupFile();
    _ref.invalidate(backupListProvider);
    return file.path;
  }

  Future<void> deleteBackup(String path) async {
    await _service.deleteBackup(path);
    _ref.invalidate(backupListProvider);
  }

  /// Read a backup header for the overwrite-confirmation dialog (Phần 2).
  Future<BackupEnvelope> readBackup(String path) => _service.readBackup(path);

  Future<RestoreResult> restore(String path) async {
    final result = await _service.restoreFromFile(path);
    if (result.ok) {
      // Everything downstream changed — invalidate broadly.
      _ref.invalidate(databaseInfoProvider);
    }
    return result;
  }

  Future<String> export(ExportModule module, ExportFormat format) async {
    final file = await _service.exportModule(module, format);
    _ref.invalidate(exportListProvider);
    return file.path;
  }

  Future<RestoreResult> importFile(String path) async {
    final result = await _service.restoreFromFile(path);
    if (result.ok) _ref.invalidate(databaseInfoProvider);
    return result;
  }

  Future<bool> verifyIntegrity() => _service.verifyIntegrity();

  Future<void> compact() async {
    await _service.compact();
    _ref.invalidate(databaseInfoProvider);
  }

  Future<int> clearExports() async {
    final n = await _service.clearExports();
    _ref.invalidate(exportListProvider);
    return n;
  }
}

final dataCenterControllerProvider = Provider<DataCenterController>((ref) {
  return DataCenterController(ref);
});
