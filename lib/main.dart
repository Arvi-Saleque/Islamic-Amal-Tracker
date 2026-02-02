import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'data/services/firestore_sync_service.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'services/daily_reminder_service.dart';
import 'services/permission_service.dart';
import 'presentation/providers/prayer_times_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (optional - app works without it)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
  
  // Initialize Daily Reminder Service (Android only)
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await DailyReminderService.initialize();

      // ✅ NEW: Auto-schedule always-on default reminders at app startup
      final granted = await PermissionService.areAllPermissionsGranted();
      if (granted) {
        await DailyReminderService.scheduleDefaultDailyAmalReminder(); 
        await DailyReminderService.scheduleDefaultRollingWindowFromApi();
      }
    } catch (e) {
      print('DailyReminderService initialization failed: $e');
    }
  }

  
  // Set preferred orientations (only for mobile platforms)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  
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
    ref.listen<PrayerTimesState>(prayerTimesProvider, (previous, next) async {
      if (next.isLoading) return;
      if (next.error != null) return;
      if (next.prayerTimes.isEmpty) return;

      // Only schedule defaults if permissions are granted
      final granted = await PermissionService.areAllPermissionsGranted();
      if (!granted) return;

      // ✅ Schedule default prayer reminders using today's computed times
      await DailyReminderService.scheduleDefaultPrayerReminders(
        prayerTimes: next.prayerTimes,
      );

      final fajr = next.prayerTimes['fajr'];
      final maghrib = next.prayerTimes['maghrib'];

      if (fajr != null && maghrib != null) {
        await DailyReminderService.scheduleDefaultDhikrReminders(
          fajrTime: fajr,
          maghribTime: maghrib,
        );
      }
    });


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
