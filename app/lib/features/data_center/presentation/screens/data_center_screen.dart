import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/data_center/domain/models/data_center_models.dart';
import 'package:pool_os/features/data_center/presentation/providers/data_center_providers.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

/// Task 12 — Data Center screen. One place to back up, restore, export, import,
/// inspect and maintain the Pool OS database. Every destructive action (restore,
/// import) is gated behind an explicit confirmation dialog. No AI, no cloud sync.
class DataCenterScreen extends ConsumerWidget {
  const DataCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final infoAsync = ref.watch(databaseInfoProvider);
    final backupsAsync = ref.watch(backupListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.get('dc_title')), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(context, l10n.get('dc_section_backup'), Icons.backup),
          const SizedBox(height: 8),
          _backupActions(context, ref, l10n),
          const SizedBox(height: 8),
          backupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorCard(context, l10n),
            data: (backups) => _backupList(context, ref, l10n, backups),
          ),
          const SizedBox(height: 24),
          _section(context, l10n.get('dc_section_export'), Icons.file_download),
          const SizedBox(height: 8),
          _exportActions(context, ref, l10n),
          const SizedBox(height: 24),
          _section(context, l10n.get('dc_section_info'), Icons.info_outline),
          const SizedBox(height: 8),
          infoAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _errorCard(context, l10n),
            data: (info) => _infoCard(context, l10n, info),
          ),
          const SizedBox(height: 24),
          _section(
              context, l10n.get('dc_section_maintenance'), Icons.build_circle),
          const SizedBox(height: 8),
          _maintenanceActions(context, ref, l10n),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Backup (Phần 1/2) ---------------------------------------------------

  Widget _backupActions(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('dc_backup_desc'),
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(l10n.get('dc_create_backup')),
              onPressed: () async {
                final path =
                    await ref.read(dataCenterControllerProvider).createBackup();
                if (context.mounted) {
                  _toast(context, l10n.get('dc_backup_created'), detail: path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _backupList(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      List<BackupFileInfo> backups) {
    if (backups.isEmpty) {
      return _emptyHint(context, l10n.get('dc_no_backups'));
    }
    return Column(
      children: backups.map((b) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: Text(b.fileName, style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              '${_formatSize(b.sizeBytes)} · '
              '${b.totalRows ?? '?'} ${l10n.get('dc_rows')} · '
              'v${b.schemaVersion ?? '?'}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.restore, color: Colors.orange),
                  tooltip: l10n.get('dc_restore'),
                  onPressed: () => _confirmRestore(context, ref, l10n, b),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: l10n.get('delete'),
                  onPressed: () => ref
                      .read(dataCenterControllerProvider)
                      .deleteBackup(b.path),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, BackupFileInfo backup) async {
    // Phần 2 — cảnh báo trước khi ghi đè: show what will be overwritten.
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.get('dc_restore_confirm_title')),
        content: Text(
          l10n
              .get('dc_restore_confirm_body')
              .replaceAll('{rows}', '${backup.totalRows ?? '?'}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.get('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.get('dc_restore')),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final result =
        await ref.read(dataCenterControllerProvider).restore(backup.path);
    if (!context.mounted) return;
    if (result.ok) {
      _toast(
        context,
        l10n
            .get('dc_restore_ok')
            .replaceAll('{rows}', '${result.rowsRestored}'),
      );
    } else {
      _toast(context, l10n.get(result.errorKey ?? 'dc_err_restore'),
          error: true);
    }
  }

  // --- Export (Phần 3) -----------------------------------------------------

  Widget _exportActions(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.get('dc_export_desc'),
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ExportModule.values.map((m) {
                return ActionChip(
                  avatar: const Icon(Icons.file_download, size: 18),
                  label: Text(l10n.get(m.labelKey)),
                  onPressed: () => _pickFormatAndExport(context, ref, l10n, m),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFormatAndExport(BuildContext context, WidgetRef ref,
      AppLocalizations l10n, ExportModule module) async {
    final format = await showModalBottomSheet<ExportFormat>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.data_object),
              title: const Text('JSON'),
              onTap: () => Navigator.of(ctx).pop(ExportFormat.json),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('CSV'),
              onTap: () => Navigator.of(ctx).pop(ExportFormat.csv),
            ),
          ],
        ),
      ),
    );
    if (format == null) return;
    final path = await ref
        .read(dataCenterControllerProvider)
        .export(module, format);
    if (context.mounted) {
      _toast(context, l10n.get('dc_export_ok'), detail: path);
    }
  }

  // --- Database info (Phần 5) ----------------------------------------------

  Widget _infoCard(
      BuildContext context, AppLocalizations l10n, DatabaseInfo info) {
    final rows = <(String, String)>[
      (l10n.get('dc_db_version'), 'v${info.schemaVersion}'),
      (l10n.get('dc_backup_format'), 'v${info.backupFormatVersion}'),
      (l10n.get('dc_db_size'), _formatSize(info.sizeBytes)),
      (l10n.get('player'), '${info.players}'),
      (l10n.get('gc_metric_total_matches'), '${info.matches}'),
      (l10n.get('gc_metric_total_racks'), '${info.racks}'),
      (l10n.get('gc_metric_total_shots'), '${info.shots}'),
      (l10n.get('career_filter_training'), '${info.trainingSessions}'),
      (l10n.get('gc_section_goals'), '${info.goals}'),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: rows.map((r) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.$1,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey)),
                  Text(r.$2,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- Maintenance (Phần 6) ------------------------------------------------

  Widget _maintenanceActions(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.verified_outlined, color: Colors.green),
            title: Text(l10n.get('dc_verify')),
            subtitle: Text(l10n.get('dc_verify_desc')),
            onTap: () async {
              final ok =
                  await ref.read(dataCenterControllerProvider).verifyIntegrity();
              if (context.mounted) {
                _toast(
                  context,
                  ok ? l10n.get('dc_verify_ok') : l10n.get('dc_verify_fail'),
                  error: !ok,
                );
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.compress, color: Colors.blue),
            title: Text(l10n.get('dc_compact')),
            subtitle: Text(l10n.get('dc_compact_desc')),
            onTap: () async {
              await ref.read(dataCenterControllerProvider).compact();
              if (context.mounted) _toast(context, l10n.get('dc_compact_ok'));
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cleaning_services, color: Colors.brown),
            title: Text(l10n.get('dc_clear_temp')),
            subtitle: Text(l10n.get('dc_clear_temp_desc')),
            onTap: () async {
              final n =
                  await ref.read(dataCenterControllerProvider).clearExports();
              if (context.mounted) {
                _toast(
                  context,
                  l10n.get('dc_clear_temp_ok').replaceAll('{n}', '$n'),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // --- Shared bits ---------------------------------------------------------

  Widget _section(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _emptyHint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _errorCard(BuildContext context, AppLocalizations l10n) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.get('error_loading_data'))),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String message,
      {String? detail, bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(detail == null ? message : '$message\n$detail'),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
