import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/settings/presentation/settings_provider.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('settings')),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, l10n.get('localization')),
          const SizedBox(height: 8),
          _buildLanguageSelector(context, ref, settings, l10n),
          const SizedBox(height: 8),
          _buildMeasurementSelector(context, ref, settings, l10n),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.get('appearance')),
          const SizedBox(height: 8),
          _buildThemeSelector(context, ref, settings, l10n),
          const SizedBox(height: 24),
          _buildSectionHeader(context, l10n.get('statistics')),
          const SizedBox(height: 8),
          _buildAboutSection(context, l10n),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(l10n.get('vietnamese')),
            subtitle: const Text('Tiếng Việt'),
            value: 'vi',
            groupValue: settings.locale,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setLocale(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Text(l10n.get('english')),
            subtitle: const Text('English'),
            value: 'en',
            groupValue: settings.locale,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setLocale(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: Text(l10n.get('measurement_cm')),
            value: 'cm',
            groupValue: settings.measurementSystem,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setMeasurementSystem(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<String>(
            title: Text(l10n.get('measurement_inch')),
            value: 'in',
            groupValue: settings.measurementSystem,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setMeasurementSystem(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    WidgetRef ref,
    SettingsState settings,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.get('system_default')),
            secondary: const Icon(Icons.settings_suggest),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: Text(l10n.get('light_mode')),
            secondary: const Icon(Icons.light_mode),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setThemeMode(value);
              }
            },
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: Text(l10n.get('dark_mode')),
            secondary: const Icon(Icons.dark_mode),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (value) {
              if (value != null) {
                ref.read(settingsProvider.notifier).setThemeMode(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_bar,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.get('app_name'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Version 2.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pool OS - Billiards Performance Tracker',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
