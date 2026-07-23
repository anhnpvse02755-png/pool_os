import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/app/theme/app_theme.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/app/router.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/settings/presentation/settings_provider.dart';
import 'package:pool_os/core/runtime/core_runtime.dart';
import 'package:pool_os/core/runtime/runtime_configuration.dart';
import 'package:pool_os/shared/foundation/result.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final coreBootstrap = CoreRuntimeComposition(
    configuration: ImmutableRuntimeConfiguration(const {
      'runtime.environment': 'product',
      'runtime.version': '1',
    }),
  ).bootstrap();
  if (coreBootstrap case FailureResult<CoreRuntimeState>(:final failure)) {
    throw StateError('Core runtime bootstrap failed: ${failure.code}');
  }
  final database = AppDatabase();
  runApp(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const PoolOSApp()));
}

class PoolOSApp extends ConsumerWidget {
  const PoolOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: 'Pool OS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: Locale(settings.locale),
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      routerConfig: appRouter,
    );
  }
}
