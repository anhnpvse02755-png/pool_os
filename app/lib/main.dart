import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/app/theme/app_theme.dart';
import 'package:pool_os/shared/localization/app_localizations.dart';
import 'package:pool_os/app/router.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = AppDatabase();
  runApp(ProviderScope(overrides: [databaseProvider.overrideWithValue(database)], child: const PoolOSApp()));
}

class PoolOSApp extends ConsumerWidget {
  const PoolOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Pool OS',
      theme: AppTheme.darkTheme,
      locale: const Locale('vi'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      routerConfig: appRouter,
    );
  }
}
