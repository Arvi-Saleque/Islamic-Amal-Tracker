import 'dart:ui';
import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../services/permission_service.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/prayer_tracking_provider.dart';
import '../../providers/daily_amal_provider.dart';
import '../../providers/dhikr_counter_provider.dart';
import '../../providers/reading_tracker_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/sin_tracker_provider.dart';
import '../prayer/prayer_tracker_screen.dart';
import '../daily_amal/daily_amal_screen.dart';
import '../reading/reading_tracker_screen.dart';
import '../sin_tracker/sin_tracker_screen.dart';
import '../dhikr/dhikr_counter_screen.dart';
import '../../providers/main_shell_tab_provider.dart';
import '../../../services/daily_reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:timezone/data/latest.dart' as tz;
import '../../../data/services/firestore_sync_service.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Start heavy init in background (doesn't block UI)
      unawaited(_bootstrapApp());

      // Permissions + your existing init flow
      PermissionService.checkAndRequestPermissions(context);
      _afterAuthInit();
    });
  }

  Future<void> _bootstrapApp() async {
    // Timezone
    try {
      tz.initializeTimeZones();
    } catch (_) {}

    // Hive already initialized in main.dart, skip re-initialization

    // Firebase + Firestore sync init (optional)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await firestoreSyncService.init();
    } catch (e) {
      debugPrint('Firebase init failed: $e');
    }

    // Cloud restore (DO NOT block navigation/splash)
    try {
      await firestoreSyncService.restoreAllData();
    } catch (e) {
      debugPrint('Cloud restore failed: $e');
    }

    // Reminder init (don’t schedule heavy rolling window here unless you want)
    if (!kIsWeb && Platform.isAndroid) {
      try {
        await DailyReminderService.initialize();
      } catch (e) {
        debugPrint('DailyReminderService init failed: $e');
      }
    }
  }

  Future<void> _afterAuthInit() async {
    // small delay so UI is ready (optional)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // Check if user already has a saved location
    final prefs = await SharedPreferences.getInstance();
    final hasSavedLocation =
        prefs.getDouble('saved_lat') != null &&
        prefs.getDouble('saved_lon') != null;

    if (!hasSavedLocation) {
      // No saved location — check location service and request permission
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show friendly dialog asking user to enable location
        final shouldOpenSettings = await _showLocationServiceDialog();
        if (shouldOpenSettings == true) {
          await Geolocator.openLocationSettings();
          // Wait a bit and check again
          await Future.delayed(const Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
      }

      // If location service is now enabled, request permission
      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      }
    }

    // Always fetch prayer times (provider handles saved/live/default internally)
    ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();

    // Show notification popup (your existing behavior)
    PermissionService.showNotificationPermissionPopup(context);

    // Always schedule default rolling window (uses real coords or fallback)
    await DailyReminderService.scheduleDefaultRollingWindowFromApi();
  }

  Future<bool?> _showLocationServiceDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('home_location_enable_title'.tr()),
        content: Text('home_location_enable_body'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('home_later'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('home_enable_location'.tr()),
          ),
        ],
      ),
    );
  }

  /// Refresh — uses saved location if available, otherwise asks to enable location
  Future<void> _refreshAll() async {
    final cs = Theme.of(context).colorScheme;

    // Check if user has a saved location
    final prefs = await SharedPreferences.getInstance();
    final hasSavedLocation =
        prefs.getDouble('saved_lat') != null &&
        prefs.getDouble('saved_lon') != null;

    if (!hasSavedLocation) {
      // No saved location — show dialog if location service is off
      var serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final shouldOpenSettings = await _showLocationServiceDialog();
        if (shouldOpenSettings == true) {
          await Geolocator.openLocationSettings();
          await Future.delayed(const Duration(seconds: 2));
          serviceEnabled = await Geolocator.isLocationServiceEnabled();
        }
      }

      if (serviceEnabled) {
        var permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
      }
    }

    ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
    ref.read(prayerTrackingProvider.notifier).loadTodayData();
    ref.read(dailyAmalProvider.notifier).loadTodayData();
    ref.read(dhikrCounterProvider.notifier).loadTodayData();
    ref.read(readingTrackerProvider.notifier).loadTodayData();
    ref.read(statisticsProvider.notifier).updateTodayStats();
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final locationOn = await Geolocator.isLocationServiceEnabled();
    final hasAnySavedLocation = prefs.getDouble('saved_lat') != null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          (locationOn || hasAnySavedLocation)
              ? 'home_data_updated'.tr()
              : 'home_location_off'.tr(),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: cs.primary,
      ),
    );
  }

  // -------------------------------------------------
  // Premium UI Helpers (Golden + Dark)
  // -------------------------------------------------

  static const Color _gold = Color(0xFFD4AF37);

  Widget _buildHomeBackground(BuildContext context) {
    final theme = Theme.of(context);
    final gradients = theme.extension<GradientColors>()!;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradients.backgroundGradient,
            ),
          ),
        ),

        Positioned(
          top: -140,
          right: -120,
          child: _glowBlob(
            size: 280,
            opacity: theme.brightness == Brightness.dark ? 0.14 : 0.07,
          ),
        ),
        Positioned(
          bottom: -160,
          left: -140,
          child: _glowBlob(
            size: 320,
            opacity: theme.brightness == Brightness.dark ? 0.10 : 0.05,
          ),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(
                      theme.brightness == Brightness.dark ? 0.35 : 0.06,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _glowBlob({required double size, required double opacity}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [_gold.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  Widget _premiumInkCard({
    required BuildContext context,
    required VoidCallback onTap,
    EdgeInsets margin = EdgeInsets.zero,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 18,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final accent = isDark ? _gold : cs.primary;
    final cardA = cs.surface;
    final cardB = cs.surfaceContainerLow;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [cardA, cardB],
                ),
                border: Border.all(color: accent.withOpacity(0.18), width: 1),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.onSurface.withOpacity(0.06),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: padding, child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconPill(BuildContext context, IconData icon) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final accent = cs.primary;

    final pillBg = cs.surfaceContainerHighest;

    final pillBorder = accent.withOpacity(0.18);

    final iconColor = accent;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pillBorder),
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }

  Widget _sunChip({
    required BuildContext context,
    required String label,
    required String time,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradients = theme.extension<GradientColors>()!;
    final cardStyle = theme.extension<PremiumCardStyle>()!;

    final accent = cs.primary;
    final textColor = cs.onSurface.withOpacity(0.80);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(
                color: accent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
            Text(label, style: TextStyle(color: textColor, fontSize: 10)),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients.innerCardGradient,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: cardStyle.borderColor.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesState = ref.watch(prayerTimesProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final titleColor = cs.primary;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[0],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[1],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'app_title'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: cs.primary),
            tooltip: 'refresh'.tr(),
            onPressed: () => _refreshAll(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildHomeBackground(context)),
          RefreshIndicator(
            onRefresh: () => _refreshAll(),
            color: cs.primary,
            backgroundColor: cs.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSunCard(context, prayerTimesState),
                  const SizedBox(height: 16),
                  _buildPrayerTimesCard(context, prayerTimesState),
                  const SizedBox(height: 16),
                  _buildTodayProgress(context, ref),
                  const SizedBox(height: 20),
                  _buildAmalCards(context, ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSunCard(BuildContext context, PrayerTimesState state) {
    final now = DateTime.now();
    final locale = context.locale;
    final isBangla = locale.languageCode == 'bn';

    // Hijri date (adjust by -1 day for correct date)
    final yesterday = now.subtract(const Duration(days: 1));
    final hijri = HijriCalendar.fromDate(yesterday);
    final hijriMonthKey = _getHijriMonthKey(hijri.hMonth);
    final hijriMonth = hijriMonthKey.tr();
    final hijriDayStr = isBangla
        ? _toBengaliNumber(hijri.hDay)
        : hijri.hDay.toString();

    // Bengali calendar-style date (approximate, but now using i18n keys)
    final bengaliDate = _getBengaliDate(context, now);

    // Localized Gregorian date line (weekday + day + month)
    final weekdayKey = _getWeekdayKey(now.weekday);
    final weekdayLabel = weekdayKey.tr();
    final monthKey = _getMonthKey(now.month);
    final monthLabel = monthKey.tr();
    final dayNumStr = isBangla ? _toBengaliNumber(now.day) : now.day.toString();

    // Prayer times for sunrise/sunset
    String? sunriseTime;
    String? sunsetTime;
    if (state.prayerTimes.isNotEmpty) {
      final sunrise = state.prayerTimes['sunrise'];
      final maghrib = state.prayerTimes['maghrib'];
      if (sunrise != null) {
        sunriseTime = _formatTimeShort(context, sunrise);
      }
      if (maghrib != null) {
        sunsetTime = _formatTimeShort(context, maghrib);
      }
    }

    return buildPremiumCard(
      context: context,
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.zero,
      radius: 22,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final cs = Theme.of(context).colorScheme;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$hijriDayStr $hijriMonth',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$weekdayLabel, $dayNumStr $monthLabel',
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.65),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bengaliDate,
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.55),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final cs = Theme.of(context).colorScheme;
                    return Container(
                      height: 76,
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            cs.primary.withOpacity(0.25),
                            cs.primary.withOpacity(0.55),
                            cs.primary.withOpacity(0.25),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _sunChip(
                      context: context,
                      label: 'home_sunrise'.tr(),
                      time: sunriseTime ?? '--:--',
                      icon: Icons.wb_sunny_rounded,
                    ),
                    const SizedBox(height: 12),
                    _sunChip(
                      context: context,
                      label: 'home_sunset'.tr(),
                      time: sunsetTime ?? '--:--',
                      icon: Icons.nights_stay_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (state.locationName != null) ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.7),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.locationName!,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeShort(BuildContext context, DateTime time) {
    final isBangla = context.locale.languageCode == 'bn';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    var timeStr = '$hour:$minute';
    if (isBangla) {
      timeStr = _toBengaliString(timeStr);
    }
    return timeStr;
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number
        .toString()
        .split('')
        .map((d) => bengaliDigits[int.parse(d)])
        .join();
  }

  // Convert any string containing English digits to Bengali digits
  String _toBengaliString(String str) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return str.split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? bengaliDigits[digit] : char;
    }).join();
  }

  String _getHijriMonthKey(int month) {
    switch (month) {
      case 1:
        return 'hijri_muharram';
      case 2:
        return 'hijri_safar';
      case 3:
        return 'hijri_rabi_al_awwal';
      case 4:
        return 'hijri_rabi_al_thani';
      case 5:
        return 'hijri_jumada_al_ula';
      case 6:
        return 'hijri_jumada_al_akhirah';
      case 7:
        return 'hijri_rajab';
      case 8:
        return 'hijri_shaban';
      case 9:
        return 'hijri_ramadan';
      case 10:
        return 'hijri_shawwal';
      case 11:
        return 'hijri_dhul_qadah';
      case 12:
      default:
        return 'hijri_dhul_hijjah';
    }
  }

  String _getWeekdayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'weekday_mon';
      case DateTime.tuesday:
        return 'weekday_tue';
      case DateTime.wednesday:
        return 'weekday_wed';
      case DateTime.thursday:
        return 'weekday_thu';
      case DateTime.friday:
        return 'weekday_fri';
      case DateTime.saturday:
        return 'weekday_sat';
      case DateTime.sunday:
      default:
        return 'weekday_sun';
    }
  }

  String _getMonthKey(int month) {
    switch (month) {
      case 1:
        return 'month_jan';
      case 2:
        return 'month_feb';
      case 3:
        return 'month_mar';
      case 4:
        return 'month_apr';
      case 5:
        return 'month_may';
      case 6:
        return 'month_jun';
      case 7:
        return 'month_jul';
      case 8:
        return 'month_aug';
      case 9:
        return 'month_sep';
      case 10:
        return 'month_oct';
      case 11:
        return 'month_nov';
      case 12:
      default:
        return 'month_dec';
    }
  }

  String _getBengaliDate(BuildContext context, DateTime date) {
    // Approximate Bengali calendar calculation
    // Bengali year starts around April 14
    int bengaliMonth;
    int bengaliDay;

    const bengaliMonthKeys = [
      'bengali_poush',
      'bengali_magh',
      'bengali_falgun',
      'bengali_chaitra',
      'bengali_baishakh',
      'bengali_jaishtha',
      'bengali_ashar',
      'bengali_shrabon',
      'bengali_bhadro',
      'bengali_ashwin',
      'bengali_kartik',
      'bengali_agrahayon',
    ];

    // Find current Bengali month based on Gregorian date
    if (date.month == 1) {
      if (date.day >= 15) {
        bengaliMonth = 1; // Magh (starts Jan 15)
        bengaliDay = date.day - 14;
      } else {
        bengaliMonth = 0; // Poush
        bengaliDay = date.day + 16;
      }
    } else if (date.month == 2) {
      if (date.day >= 13) {
        bengaliMonth = 2; // Falgun
        bengaliDay = date.day - 12;
      } else {
        bengaliMonth = 1; // Magh
        bengaliDay = date.day + 18;
      }
    } else {
      // Simplified for other months
      bengaliMonth = (date.month + 8) % 12;
      bengaliDay = (date.day + 15) % 30 + 1;
    }

    final isBangla = context.locale.languageCode == 'bn';
    final dayStr = isBangla
        ? _toBengaliNumber(bengaliDay)
        : bengaliDay.toString();
    final monthKey = bengaliMonthKeys[bengaliMonth];
    final monthLabel = monthKey.tr();

    return '$dayStr $monthLabel';
  }

  Widget _buildPrayerTimesCard(BuildContext context, PrayerTimesState state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return buildPremiumCard(
      context: context,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.zero,
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.isLoading && state.error == null)
            _buildCurrentPrayerSection(state),

          if (!state.isLoading && state.error == null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    (cs.primary).withOpacity(0.25),
                    (cs.primary).withOpacity(0.55),
                    (cs.primary).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: cs.primary),
                    ),
                  )
                else if (state.error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'home_error'.tr(),
                        style: TextStyle(color: cs.error, fontSize: 14),
                      ),
                    ),
                  )
                else ...[
                  if (state.prayerTimes['fajr'] != null)
                    _buildPrayerTimeRow(
                      context,
                      'fajr'.tr(),
                      _formatTime(context, state.prayerTimes['fajr']!),
                      state.currentPrayer == 'fajr',
                    ),
                  const SizedBox(height: 8),
                  if (state.prayerTimes['dhuhr'] != null)
                    _buildPrayerTimeRow(
                      context,
                      _getPrayerDisplayName('dhuhr'),
                      _formatTime(context, state.prayerTimes['dhuhr']!),
                      state.currentPrayer == 'dhuhr',
                    ),
                  const SizedBox(height: 8),
                  if (state.prayerTimes['asr'] != null)
                    _buildPrayerTimeRow(
                      context,
                      'asr'.tr(),
                      _formatTime(context, state.prayerTimes['asr']!),
                      state.currentPrayer == 'asr',
                    ),
                  const SizedBox(height: 8),
                  if (state.prayerTimes['maghrib'] != null)
                    _buildPrayerTimeRow(
                      context,
                      'maghrib'.tr(),
                      _formatTime(context, state.prayerTimes['maghrib']!),
                      state.currentPrayer == 'maghrib',
                    ),
                  const SizedBox(height: 8),
                  if (state.prayerTimes['isha'] != null)
                    _buildPrayerTimeRow(
                      context,
                      'isha'.tr(),
                      _formatTime(context, state.prayerTimes['isha']!),
                      state.currentPrayer == 'isha',
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPrayerSection(PrayerTimesState state) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine status and colors
    Color statusColor;
    String statusText;
    String mainText;
    String? subtitleText;

    if (state.isForbiddenTime) {
      statusColor = cs.error;
      statusText = 'prayer_forbidden_time'.tr();
      mainText = 'prayer_forbidden_msg'.tr();
      subtitleText = null;
    } else if (state.isNaflTime) {
      statusColor = isDark ? _gold : cs.primary;
      statusText = 'prayer_now'.tr();
      mainText = 'prayer_nafl'.tr();
      subtitleText = null;
    } else if (state.currentPrayer != null) {
      statusColor = isDark ? _gold : cs.primary;
      statusText = 'prayer_now'.tr();
      mainText = _getPrayerDisplayName(state.currentPrayer!);
      subtitleText = 'prayer_next_time'.tr();
    } else {
      return const SizedBox.shrink();
    }

    // Calculate progress
    double progress = 0.0;
    String? currentPrayerTimeStr;
    String? prayerEndTimeStr;
    String? nextPrayerTimeStr;
    String? nextPrayerName;

    if (state.currentPrayer != null && state.prayerTimes.isNotEmpty) {
      var currentPrayerTime = state.prayerTimes[state.currentPrayer!];
      var prayerEndTime = state.waqtEndTimes[state.currentPrayer!];

      if (currentPrayerTime != null && prayerEndTime != null) {
        final now = DateTime.now();

        // For Isha after midnight: adjust times
        // If current time is before Fajr and we're in Isha,
        // isha started yesterday, ends today at Fajr
        if (state.currentPrayer == 'isha' && now.hour < 6) {
          // Isha started yesterday
          currentPrayerTime = currentPrayerTime.subtract(
            const Duration(days: 1),
          );
          // Isha ends today at Fajr (prayerEndTime is already set to fajr + 1 day,
          // but we need today's fajr)
          final todayFajr = state.prayerTimes['fajr'];
          if (todayFajr != null) {
            prayerEndTime = todayFajr;
          }
        }

        final totalDuration = prayerEndTime
            .difference(currentPrayerTime)
            .inSeconds;
        final elapsedDuration = now.difference(currentPrayerTime).inSeconds;
        if (totalDuration > 0 && elapsedDuration > 0) {
          progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        }
        currentPrayerTimeStr = _formatTimeShort2(context, currentPrayerTime);
        prayerEndTimeStr = _formatTimeShort2(context, prayerEndTime);
      }

      // Get next prayer
      final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      final currentIndex = prayers.indexOf(state.currentPrayer!);
      if (currentIndex < prayers.length - 1) {
        final nextPrayer = prayers[currentIndex + 1];
        final nextTime = state.prayerTimes[nextPrayer];
        if (nextTime != null) {
          nextPrayerName = _getPrayerDisplayName(nextPrayer);
          nextPrayerTimeStr = _formatTime(context, nextTime);
        }
      } else {
        // If it's Isha (last prayer), show tomorrow's Fajr
        nextPrayerName = _getPrayerDisplayName('fajr');
        nextPrayerTimeStr = null;
      }
    } else if (state.isNaflTime && state.prayerTimes.isNotEmpty) {
      // For Nafl time, calculate progress from sunrise to dhuhr
      final sunrise = state.prayerTimes['sunrise'];
      final dhuhr = state.prayerTimes['dhuhr'];

      if (sunrise != null && dhuhr != null) {
        final now = DateTime.now();
        final totalDuration = dhuhr.difference(sunrise).inSeconds;
        final elapsedDuration = now.difference(sunrise).inSeconds;
        if (totalDuration > 0 && elapsedDuration > 0) {
          progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        }
        currentPrayerTimeStr = _formatTimeShort2(context, sunrise);
        prayerEndTimeStr = _formatTimeShort2(context, dhuhr);
      }

      // Next prayer after nafl is dhuhr
      nextPrayerName = _getPrayerDisplayName(
        DateTime.now().weekday == DateTime.friday ? 'jumuah' : 'dhuhr',
      );
      final dhuhrTime = state.prayerTimes['dhuhr'];
      if (dhuhrTime != null) {
        nextPrayerTimeStr = _formatTime(context, dhuhrTime);
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.surfaceContainerHighest, cs.surfaceContainer],
        ),
        border: Border(
          bottom: BorderSide(color: cs.primary.withOpacity(0.5), width: 1),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main prayer name
          Text(
            mainText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? _gold : cs.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Countdown timer (if current prayer or nafl time)
          if ((state.currentPrayer != null &&
                  state.timeToCurrentPrayerEnd != null) ||
              (state.isNaflTime && state.timeToNextPrayer != null)) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final raw = state.isNaflTime
                    ? state.timeToNextPrayer!
                    : state.timeToCurrentPrayerEnd!;
                final isBangla = context.locale.languageCode == 'bn';

                String countdownText;
                if (isBangla) {
                  // Bengali locale: Bengali digits + Bengali units
                  countdownText = _toBengaliString(raw);
                } else {
                  // English (or other) locale: keep ASCII digits, map Bengali units to English
                  countdownText = raw
                      .replaceAll('ঘ', 'h')
                      .replaceAll('মি', 'm');
                }

                return Text(
                  countdownText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? _gold : cs.primary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              state.isNaflTime
                  ? 'prayer_next_time'.tr()
                  : (subtitleText ?? 'prayer_next_time'.tr()),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ] else if (subtitleText != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: statusColor.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],

          // Progress bar
          if (state.currentPrayer != null || state.isNaflTime) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  currentPrayerTimeStr ?? '',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontSize: 11,

                    fontFamily: 'AlinurBanglaborno',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: cs.surfaceContainerHighest.withOpacity(0.5),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final goldenWidth = totalWidth * progress;
                        return Stack(
                          children: [
                            // Gray background (full width)
                            Container(
                              width: totalWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHighest.withOpacity(
                                  0.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Golden part (elapsed time)
                            Container(
                              width: goldenWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isDark ? _gold : cs.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  prayerEndTimeStr ?? '',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.5),
                    fontSize: 11,
                    fontFamily: 'AlinurBanglaborno',
                  ),
                ),
              ],
            ),

            // Next prayer info
            if (nextPrayerName != null && nextPrayerTimeStr != null) ...[
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final cs = Theme.of(context).colorScheme;

                  final bg = cs.surfaceContainerHighest;
                  final textColor = cs.onSurface.withOpacity(0.85);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, color: textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${'home_next_prayer'.tr(namedArgs: {'name': nextPrayerName!})} - $nextPrayerTimeStr',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontFamily: 'AlinurBanglaborno',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ] else if (nextPrayerName != null) ...[
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final cs = theme.colorScheme;

                  final bg = cs.surfaceContainerHighest;
                  final textColor = cs.onSurface.withOpacity(0.7);

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, color: textColor, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${'home_next_prayer'.tr(namedArgs: {'name': nextPrayerName!})} (${'common_tomorrow'.tr()})',
                          style: TextStyle(color: textColor, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _getPrayerDisplayName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'fajr'.tr();
      case 'dhuhr':
        // Check if Friday
        if (DateTime.now().weekday == DateTime.friday) {
          return 'jumuah'.tr();
        }
        return 'dhuhr'.tr();
      case 'jumuah':
        return 'jumuah'.tr();
      case 'asr':
        return 'asr'.tr();
      case 'maghrib':
        return 'maghrib'.tr();
      case 'isha':
        return 'isha'.tr();
      default:
        return prayerName;
    }
  }

  String _formatTimeShort2(BuildContext context, DateTime time) {
    final isBangla = context.locale.languageCode == 'bn';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    var timeStr = '$hour:$minute';
    if (isBangla) {
      timeStr = _toBengaliString(timeStr);
    }
    return timeStr;
  }

  // _getPrayerNameInBangla is no longer needed because prayer names
  // are now fully localized via translation keys.

  String _formatTime(BuildContext context, DateTime time) {
    final isBangla = context.locale.languageCode == 'bn';
    final hour = time.hour > 12
        ? time.hour - 12
        : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    var timeStr = '$hour:$minute';
    if (isBangla) {
      timeStr = _toBengaliString(timeStr);
    }
    return '$timeStr $period';
  }

  // Replace your existing _buildPrayerTimeRow with this one
  Widget _buildPrayerTimeRow(
    BuildContext context,
    String name,
    String time,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // soft depth (always)
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 10),
            spreadRadius: -10,
          ),
          // golden glow only for active
          if (isActive)
            BoxShadow(
              color: cs.primary.withOpacity(0.28),
              blurRadius: 22,
              offset: const Offset(0, 10),
              spreadRadius: -12,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Glass blur layer (premium feel)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: const SizedBox.shrink(),
              ),
            ),

            // Main surface
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [cs.primary, cs.primary]
                      : [cs.surface, cs.surfaceContainerLow],
                ),
                border: Border.all(
                  color: isActive
                      ? cs.onSurface.withOpacity(0.10)
                      : cs.primary.withOpacity(0.16),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Left indicator dot (same content, just premium look)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? cs.onPrimary
                          : cs.primary.withOpacity(0.35),
                      boxShadow: [
                        if (isActive)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        color: isActive
                            ? cs.onPrimary
                            : cs.onSurface.withOpacity(0.88),
                        fontSize: 16,
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                    ),
                  ),

                  // Time (tabular figures => premium alignment)
                  Text(
                    time,
                    style: TextStyle(
                      color: isActive
                          ? cs.onPrimary
                          : cs.onSurface.withOpacity(0.88),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            // Subtle top highlight line (premium sheen)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                height: 1,
                color: cs.onSurface.withOpacity(isActive ? 0.18 : 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgress(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final prayerTrackingState = ref.watch(prayerTrackingProvider);
    final dailyAmalState = ref.watch(dailyAmalProvider);
    final dhikrState = ref.watch(dhikrCounterProvider);
    final readingState = ref.watch(readingTrackerProvider);

    final completedPrayers =
        prayerTrackingState.todayData.completedPrayersCount;
    final completedAmal = dailyAmalState.todayData.completedCount;
    final totalAmal = dailyAmalState.todayData.totalCount;
    final dhikrCount = dhikrState.todayData.totalCount;
    final dhikrTarget = dhikrState.todayData.totalTarget;
    final readingMinutes = readingState.todayData.totalMinutes;
    final readingTarget = readingState.todayData.goal.totalMinutes;

    final prayerProgress = completedPrayers / 5;
    final amalProgress = totalAmal > 0 ? completedAmal / totalAmal : 0.0;
    final dhikrProgress = dhikrTarget > 0
        ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0)
        : 0.0;
    final readingProgress = readingTarget > 0
        ? (readingMinutes / readingTarget).clamp(0.0, 1.0)
        : 0.0;

    final overallProgress =
        (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
    final overallPercentage = (overallProgress * 100).toInt();

    return buildPremiumCard(
      context: context,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(22),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (cs.primary).withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (cs.primary).withOpacity(0.18)),
                ),
                child: Icon(
                  Icons.trending_up_rounded,
                  color: cs.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'today_progress'.tr(),
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.primary.withOpacity(0.25)),
                ),
                child: Text(
                  '$overallPercentage%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'overall_progress'.tr(),
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _getProgressMessage(overallProgress),
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeInOut,
                    height: 12,
                    width:
                        (MediaQuery.of(context).size.width - 80) *
                        overallProgress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          _getProgressColor(overallProgress),
                          _getProgressColor(overallProgress),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor(
                            overallProgress,
                          ).withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressCircle(
                context,
                completedPrayers,
                5,
                'prayer_section'.tr(),
              ),
              _buildProgressCircle(
                context,
                completedAmal,
                totalAmal,
                'daily_section'.tr(),
              ),
              _buildProgressCircle(
                context,
                dhikrCount,
                dhikrTarget,
                'dhikr_section'.tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (progress >= 0.8) {
      return cs.primary; // Green for excellent
    } else if (progress >= 0.5) {
      return cs.primary.withOpacity(0.8); // Gold for good
    } else if (progress >= 0.25) {
      return cs.primary.withOpacity(0.5); // Orange for moderate
    } else {
      return cs.primary.withOpacity(0.2); // Light red for needs improvement
    }
  }

  String _getProgressMessage(double progress) {
    if (progress >= 0.8) {
      return 'progress_excellent'.tr();
    } else if (progress >= 0.5) {
      return 'progress_good'.tr();
    } else if (progress >= 0.25) {
      return 'progress_keep_going'.tr();
    } else {
      return 'progress_start'.tr();
    }
  }

  Widget _buildProgressCircle(
    BuildContext context,
    int current,
    int total,
    String label,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final percentage = current / total;
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 6,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/$total',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.50),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.65),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmalCards(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final prayerTrackingState = ref.watch(prayerTrackingProvider);
    final dailyAmalState = ref.watch(dailyAmalProvider);
    final dhikrState = ref.watch(dhikrCounterProvider);
    final readingState = ref.watch(readingTrackerProvider);
    final sinTrackerState = ref.watch(sinTrackerProvider);
    final completedPrayers =
        prayerTrackingState.todayData.completedPrayersCount;
    final completedAmal = dailyAmalState.todayData.completedCount;
    final totalAmal = dailyAmalState.todayData.totalCount;
    final dhikrCount = dhikrState.todayData.totalCount;
    final dhikrTarget = dhikrState.todayData.totalTarget;
    final readingMinutes = readingState.todayData.totalMinutes;
    final readingGoal = readingState.todayData.goal.totalMinutes;
    final totalSins = sinTrackerState.todayRecord.totalSinCount;
    final pendingKaffara = sinTrackerState.todayRecord.pendingKaffaraCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'todays_amal'.tr(),
              style: TextStyle(
                color: cs.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildAmalCard(
            context,
            title: 'prayer_section'.tr(),
            subtitle: 'prayer_five_times'.tr(),
            icon: Icons.mosque,
            current: completedPrayers,
            total: 5,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerTrackerScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildAmalCard(
            context,
            title: 'daily_amal_title'.tr(),
            subtitle: 'daily_amal_subtitle'.tr(),
            icon: Icons.check_circle_outline,
            current: completedAmal,
            total: totalAmal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyAmalScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildAmalCard(
            context,
            title: 'dhikr_section'.tr(),
            subtitle: 'dhikr_subtitle'.tr(),
            icon: Icons.favorite_outline,
            current: dhikrCount,
            total: dhikrTarget,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DhikrCounterScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildAmalCard(
            context,
            title: 'reading_section'.tr(),
            subtitle: 'reading_subtitle'.tr(),
            icon: Icons.book_outlined,
            current: readingMinutes,
            total: readingGoal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReadingTrackerScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildSinTrackerCard(
            context,
            totalSins: totalSins,
            pendingKaffara: pendingKaffara,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SinTrackerScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSinTrackerCard(
    BuildContext context, {
    required int totalSins,
    required int pendingKaffara,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return _premiumInkCard(
      context: context,
      onTap: onTap,
      radius: 18,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _iconPill(context, Icons.auto_fix_high_rounded),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sin_tracker_title'.tr(),
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  totalSins == 0
                      ? 'home_sin_no_sins'.tr()
                      : pendingKaffara == 0
                      ? 'home_sin_all_kaffara'.tr()
                      : 'home_sin_pending'.tr(
                          namedArgs: {'count': pendingKaffara.toString()},
                        ),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12.8,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: cs.onSurface.withOpacity(0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildAmalCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required int current,
    required int total,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final safeTotal = total <= 0 ? 1 : total;
    final percentage = (current / safeTotal).clamp(0.0, 1.0);

    return _premiumInkCard(
      context: context,
      onTap: onTap,
      radius: 18,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _iconPill(context, icon),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12.8,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    '$current/$total',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: cs.onSurface.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest.withOpacity(0.4),
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
