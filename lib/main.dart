import 'package:amal_tracker/core/theme/theme_mode_provider.dart';
import 'package:amal_tracker/data/local/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  await HiveService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('bn'),
      child: const ProviderScope(
        child: AmalTrackerApp(),
      ),
    ),
  );
}


class AmalTrackerApp extends ConsumerWidget {
  const AmalTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    return MaterialApp(
      title: 'আমল ট্র্যাকার',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      home: const SplashScreen(),
    );
  }
}
