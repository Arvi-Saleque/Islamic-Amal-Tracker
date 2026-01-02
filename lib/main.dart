import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'data/services/firestore_sync_service.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - app works without it)
  try {
    await Firebase.initializeApp();
    // Initialize Firestore Sync Service
    await firestoreSyncService.init();
  } catch (e) {
    print('Firebase initialization failed: $e');
    // App will work in offline mode
  }
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
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
    return MaterialApp(
      title: 'আমল ট্র্যাকার',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
