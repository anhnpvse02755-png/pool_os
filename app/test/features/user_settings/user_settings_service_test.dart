// EPIC 09 — User Settings Service tests (Track A — mobile app).

import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_engine.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_pipeline.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_service.dart';
import 'package:pool_os/features/user_settings/domain/user_settings_request.dart';
import 'package:pool_os/features/user_settings/domain/models/user_settings_models.dart';

UserSettingsService _service() => UserSettingsService(defaultUserSettingsPipeline());

void main() {
  group('UserSettingsService — 5 surfaces (Track A mobile app)', () {
    test('settings returns implemented contribution', () async {
      final r = await _service().settings(SettingsUpdateRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        theme: ThemeMode.dark,
      ));
      expect(r.contributions.any((c) => c.engineId == 'settings'), isTrue);
    });

    test('backup returns implemented contribution', () async {
      final r = await _service().backup(BackupRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      expect(r.contributions.any((c) => c.engineId == 'backup'), isTrue);
    });

    test('restore returns implemented contribution', () async {
      final r = await _service().restore(RestoreRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        backupId: 'b1',
      ));
      expect(r.contributions.any((c) => c.engineId == 'backup'), isTrue);
    });

    test('export returns implemented contribution', () async {
      final r = await _service().export(ExportRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        scope: ExportScope.all,
        format: ExportFormat.json,
      ));
      expect(r.contributions.any((c) => c.engineId == 'import_export'), isTrue);
    });

    test('import returns implemented contribution', () async {
      final r = await _service().import_(ImportRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
        format: ImportFormat.json,
      ));
      expect(r.contributions.any((c) => c.engineId == 'import_export'), isTrue);
    });

    test('dashboard aggregates all 3 engines', () async {
      final r = await _service().dashboard(UserSettingsRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      final ids = r.contributions.map((c) => c.engineId).toList();
      expect(ids, containsAll(['settings', 'backup', 'import_export']));
    });

    test('all contributions are implemented', () async {
      final r = await _service().dashboard(UserSettingsRequest(
        playerId: 'p1',
        asOf: DateTime.utc(2026, 7, 31),
      ));
      for (final c in r.contributions) {
        expect(c.isImplemented, isTrue, reason: '${c.engineId} should be implemented');
      }
    });
  });
}
