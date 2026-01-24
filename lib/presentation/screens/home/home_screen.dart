import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hijri/hijri_calendar.dart';
import '../../../core/theme/app_colors.dart';
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
import '../dhikr/dhikr_counter_screen.dart';
import '../reading/reading_tracker_screen.dart';
import '../statistics/statistics_screen.dart';
import '../settings/settings_screen.dart';
import '../sin_tracker/sin_tracker_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocationAndShowNotificationPopup();
  }

  Future<void> _checkLocationAndShowNotificationPopup() async {
    // Wait for location permission to be checked/granted
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if location permission is granted
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      // Location granted, show notification popup
      PermissionService.showNotificationPermissionPopup(context);
    }
  }

// -------------------------------------------------
// Premium UI Helpers (Golden + Dark)
// -------------------------------------------------

static const Color _gold = Color(0xFFD4AF37);

Widget _buildHomeBackground() {
  return Stack(
    children: [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundDark,
              const Color(0xFF0B0B0B),
            ],
          ),
        ),
      ),
      Positioned(
        top: -140,
        right: -120,
        child: _glowBlob(size: 280, opacity: 0.14),
      ),
      Positioned(
        bottom: -160,
        left: -140,
        child: _glowBlob(size: 320, opacity: 0.10),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _PremiumNoisePainter(color: _gold.withOpacity(0.08), intensity: 0.22, seed: 3),
          ),
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
                  Colors.black.withOpacity(0.35),
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
        colors: [
          _gold.withOpacity(opacity),
          Colors.transparent,
        ],
      ),
    ),
  );
}

Widget _premiumCard({
  EdgeInsets margin = EdgeInsets.zero,
  EdgeInsets padding = const EdgeInsets.all(16),
  double radius = 18,
  required Widget child,
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 18,
          offset: const Offset(0, 10),
          spreadRadius: -10,
        ),
        BoxShadow(
          color: _gold.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 6),
          spreadRadius: -10,
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF202020),
                    Color(0xFF141414),
                  ],
                ),
                border: Border.all(
                  color: _gold.withOpacity(0.10),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(radius),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PremiumNoisePainter(
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    ),
  );
}

Widget _premiumInkCard({
  required VoidCallback onTap,
  EdgeInsets margin = EdgeInsets.zero,
  EdgeInsets padding = const EdgeInsets.all(16),
  double radius = 18,
  required Widget child,
}) {
  return Container(
    margin: margin,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 18,
          offset: const Offset(0, 10),
          spreadRadius: -10,
        ),
        BoxShadow(
          color: _gold.withOpacity(0.06),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF202020),
                  Color(0xFF141414),
                ],
              ),
              border: Border.all(
                color: _gold.withOpacity(0.10),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _PremiumNoisePainter(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.06),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _iconPill(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: _gold.withOpacity(0.14),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: _gold.withOpacity(0.20),
      ),
    ),
    child: Icon(
      icon,
      color: _gold,
      size: 26,
    ),
  );
}

Widget _sunChip({
  required String label,
  required String time,
  required IconData icon,
}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: _gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _gold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _gold.withOpacity(0.18),
          ),
        ),
        child: Icon(
          icon,
          color: _gold,
          size: 20,
        ),
      ),
    ],
  );
}

  
  @override
  Widget build(BuildContext context) {
    final prayerTimesState = ref.watch(prayerTimesProvider);
  
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'আমল ট্র্যাকার',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundDark,
                AppColors.backgroundDark.withOpacity(0.0),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            tooltip: 'রিফ্রেশ',
            onPressed: () async {
              ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
              ref.read(prayerTrackingProvider.notifier).loadTodayData();
              ref.read(dailyAmalProvider.notifier).loadTodayData();
              ref.read(dhikrCounterProvider.notifier).loadTodayData();
              ref.read(readingTrackerProvider.notifier).loadTodayData();
              ref.read(statisticsProvider.notifier).updateTodayStats();
  
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ডেটা আপডেট হয়েছে'),
                  duration: Duration(seconds: 1),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildHomeBackground()),
          RefreshIndicator(
            onRefresh: () async {
              ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
              ref.read(prayerTrackingProvider.notifier).loadTodayData();
              ref.read(dailyAmalProvider.notifier).loadTodayData();
              ref.read(dhikrCounterProvider.notifier).loadTodayData();
              ref.read(readingTrackerProvider.notifier).loadTodayData();
              ref.read(statisticsProvider.notifier).updateTodayStats();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: AppColors.primary,
            backgroundColor: AppColors.backgroundLight,
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
  
      // Hijri date (adjust by -1 day for correct date)
      final yesterday = now.subtract(const Duration(days: 1));
      final hijri = HijriCalendar.fromDate(yesterday);
      final hijriMonthBengali = _getHijriMonthBengali(hijri.hMonth);
      final hijriDay = _toBengaliNumber(hijri.hDay);
  
      // Bengali date (approximate)
      final bengaliDate = _getBengaliDate(now);
  
      // Gregorian date in Bengali
      final dayName = _getBengaliDayName(now.weekday);
      final dayNum = _toBengaliNumber(now.day);
      final monthName = _getBengaliMonthName(now.month);
  
      // Prayer times for sunrise/sunset
      String? sunriseTime;
      String? sunsetTime;
      if (state.prayerTimes.isNotEmpty) {
        final sunrise = state.prayerTimes['sunrise'];
        final maghrib = state.prayerTimes['maghrib'];
        if (sunrise != null) sunriseTime = _formatTimeShort(sunrise);
        if (maghrib != null) sunsetTime = _formatTimeShort(maghrib);
      }
  
      return _premiumCard(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        radius: 22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$hijriDay $hijriMonthBengali',
                    style: const TextStyle(
                      color: AppColors.textGolden,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$dayName, $dayNum $monthName',
                    style: const TextStyle(
                      color: AppColors.grey500,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bengaliDate,
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 76,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFFD4AF37).withOpacity(0.25),
                    const Color(0xFFD4AF37).withOpacity(0.55),
                    const Color(0xFFD4AF37).withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _sunChip(
                  label: 'সূর্যোদয়',
                  time: sunriseTime ?? '--:--',
                  icon: Icons.wb_sunny_rounded,
                ),
                const SizedBox(height: 12),
                _sunChip(
                  label: 'সূর্যাস্ত',
                  time: sunsetTime ?? '--:--',
                  icon: Icons.nights_stay_rounded,
                ),
              ],
            ),
          ],
        ),
      );
    }
  
    String _formatTimeShort(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    return '${_toBengaliNumber(hour)}:${_toBengaliNumber(int.parse(minute))}';
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number
        .toString()
        .split('')
        .map((d) => bengaliDigits[int.parse(d)])
        .join();
  }

  String _getHijriMonthBengali(int month) {
    const months = [
      'মুহাররম',
      'সফর',
      'রবিউল আউয়াল',
      'রবিউস সানি',
      'জমাদিউল আউয়াল',
      'জমাদিউস সানি',
      'রজব',
      'শা\'বান',
      'রমজান',
      'শাওয়াল',
      'জিলক্বদ',
      'জিলহজ্জ'
    ];
    return months[month - 1];
  }

  String _getBengaliDayName(int weekday) {
    const days = [
      'সোমবার',
      'মঙ্গলবার',
      'বুধবার',
      'বৃহস্পতিবার',
      'শুক্রবার',
      'শনিবার',
      'রবিবার'
    ];
    return days[weekday - 1];
  }

  String _getBengaliMonthName(int month) {
    const months = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর'
    ];
    return months[month - 1];
  }

  String _getBengaliDate(DateTime date) {
    // Approximate Bengali calendar calculation
    // Bengali year starts around April 14
    int bengaliMonth;
    int bengaliDay;
    int bengaliYear = date.year - 594;

    const bengaliMonthNames = [
      'পৌষ',
      'মাঘ',
      'ফাল্গুন',
      'চৈত্র',
      'বৈশাখ',
      'জ্যৈষ্ঠ',
      'আষাঢ়',
      'শ্রাবণ',
      'ভাদ্র',
      'আশ্বিন',
      'কার্তিক',
      'অগ্রহায়ণ'
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

    if (bengaliMonth <= 3) {
      bengaliYear = date.year - 594;
    }

    return '${_toBengaliNumber(bengaliDay)} ${bengaliMonthNames[bengaliMonth]}';
  }

    
  Widget _buildPrayerTimesCard(BuildContext context, PrayerTimesState state) {
      return _premiumCard(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.zero,
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      const Color(0xFFD4AF37).withOpacity(0.25),
                      const Color(0xFFD4AF37).withOpacity(0.55),
                      const Color(0xFFD4AF37).withOpacity(0.25),
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
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    )
                  else if (state.error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'ত্রুটি: ${state.error}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (state.prayerTimes['fajr'] != null)
                      _buildPrayerTimeRow(
                        context,
                        'ফজর',
                        _formatTime(state.prayerTimes['fajr']!),
                        state.currentPrayer == 'fajr',
                      ),
                    const SizedBox(height: 8),
                    if (state.prayerTimes['dhuhr'] != null)
                      _buildPrayerTimeRow(
                        context,
                        _getPrayerDisplayName('dhuhr'),
                        _formatTime(state.prayerTimes['dhuhr']!),
                        state.currentPrayer == 'dhuhr',
                      ),
                    const SizedBox(height: 8),
                    if (state.prayerTimes['asr'] != null)
                      _buildPrayerTimeRow(
                        context,
                        'আসর',
                        _formatTime(state.prayerTimes['asr']!),
                        state.currentPrayer == 'asr',
                      ),
                    const SizedBox(height: 8),
                    if (state.prayerTimes['maghrib'] != null)
                      _buildPrayerTimeRow(
                        context,
                        'মাগরিব',
                        _formatTime(state.prayerTimes['maghrib']!),
                        state.currentPrayer == 'maghrib',
                      ),
                    const SizedBox(height: 8),
                    if (state.prayerTimes['isha'] != null)
                      _buildPrayerTimeRow(
                        context,
                        'এশা',
                        _formatTime(state.prayerTimes['isha']!),
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
    // Determine status and colors
    Color statusColor;
    String statusText;
    String mainText;
    String? subtitleText;

    if (state.isForbiddenTime) {
      statusColor = Colors.red;
      statusText = 'নিষিদ্ধ সময়';
      mainText = 'নামাজ পড়া যাবে না';
      subtitleText = state.timeToCurrentPrayerEnd != null
          ? 'আর ${state.timeToCurrentPrayerEnd} বাকি'
          : null;
    } else if (state.isNaflTime) {
      statusColor = const Color(0xFFD4AF37);
      statusText = 'এখন চলছে';
      mainText = 'নফল';
      subtitleText = null;
    } else if (state.currentPrayer != null) {
      statusColor = const Color(0xFFD4AF37);
      statusText = 'এখন চলছে';
      mainText = _getPrayerDisplayName(state.currentPrayer!);
      subtitleText = 'পরবর্তী ওয়াক্তের বাকি';
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
          currentPrayerTime =
              currentPrayerTime.subtract(const Duration(days: 1));
          // Isha ends today at Fajr (prayerEndTime is already set to fajr + 1 day,
          // but we need today's fajr)
          final todayFajr = state.prayerTimes['fajr'];
          if (todayFajr != null) {
            prayerEndTime = todayFajr;
          }
        }

        final totalDuration =
            prayerEndTime.difference(currentPrayerTime).inSeconds;
        final elapsedDuration = now.difference(currentPrayerTime).inSeconds;
        if (totalDuration > 0 && elapsedDuration > 0) {
          progress = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
        }
        currentPrayerTimeStr = _formatTimeShort2(currentPrayerTime);
        prayerEndTimeStr = _formatTimeShort2(prayerEndTime);
      }

      // Get next prayer
      final prayers = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
      final currentIndex = prayers.indexOf(state.currentPrayer!);
      if (currentIndex < prayers.length - 1) {
        final nextPrayer = prayers[currentIndex + 1];
        final nextTime = state.prayerTimes[nextPrayer];
        if (nextTime != null) {
          nextPrayerName = _getPrayerNameInBangla(nextPrayer);
          nextPrayerTimeStr = _formatTime(nextTime);
        }
      } else {
        // If it's Isha (last prayer), show tomorrow's Fajr
        nextPrayerName = 'ফজর';
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
        currentPrayerTimeStr = _formatTimeShort2(sunrise);
        prayerEndTimeStr = _formatTimeShort2(dhuhr);
      }

      // Next prayer after nafl is dhuhr
      nextPrayerName = 'যোহর';
      final dhuhrTime = state.prayerTimes['dhuhr'];
      if (dhuhrTime != null) {
        nextPrayerTimeStr = _formatTime(dhuhrTime);
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF242424),
            Color(0xFF151515),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD4AF37).withOpacity(0.10),
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
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
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Countdown timer (if current prayer or nafl time)
          if ((state.currentPrayer != null &&
                  state.timeToCurrentPrayerEnd != null) ||
              (state.isNaflTime && state.timeToNextPrayer != null)) ...[
            const SizedBox(height: 8),
            Text(
              state.isNaflTime
                  ? state.timeToNextPrayer!
                  : state.timeToCurrentPrayerEnd!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state.isNaflTime
                  ? 'পরবর্তী ওয়াক্তের বাকি'
                  : (subtitleText ?? 'পরবর্তী ওয়াক্তের বাকি'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
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
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[800],
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
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            // Golden part (elapsed time)
                            Container(
                              width: goldenWidth,
                              height: 6,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
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
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            // Next prayer info
            if (nextPrayerName != null && nextPrayerTimeStr != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'পরবর্তী: $nextPrayerName - $nextPrayerTimeStr',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (nextPrayerName != null) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.grey[500],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'পরবর্তী: $nextPrayerName (আগামীকাল)',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
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
        return 'ফজর';
      case 'dhuhr':
        // Check if Friday
        if (DateTime.now().weekday == 5) {
          return 'জুম\'আ';
        }
        return 'যোহর';
      case 'asr':
        return 'আসর';
      case 'maghrib':
        return 'মাগরিব';
      case 'isha':
        return 'এশা';
      default:
        return prayerName;
    }
  }

  String _formatTimeShort2(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getPrayerNameInBangla(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'ফজর';
      case 'dhuhr':
        // Check if Friday
        if (DateTime.now().weekday == 5) {
          return 'জুম\'আ';
        }
        return 'যোহর';
      case 'asr':
        return 'আসর';
      case 'maghrib':
        return 'মাগরিব';
      case 'isha':
        return 'এশা';
      default:
        return prayerName;
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Replace your existing _buildPrayerTimeRow with this one
Widget _buildPrayerTimeRow(
  BuildContext context,
  String name,
  String time,
  bool isActive,
) {
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
            color: const Color(0xFFD4AF37).withOpacity(0.28),
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
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE0C05A),
                        Color(0xFFD4AF37),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1B1B1B).withOpacity(0.70),
                        const Color(0xFF121212).withOpacity(0.55),
                      ],
                    ),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF0A0A0A).withOpacity(0.10)
                    : const Color(0xFFD4AF37).withOpacity(0.16),
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
                        ? const Color(0xFF0A0A0A)
                        : const Color(0xFFD4AF37).withOpacity(0.35),
                    boxShadow: [
                      if (isActive)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
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
                          ? const Color(0xFF0A0A0A)
                          : Colors.white.withOpacity(0.92),
                      fontSize: 16,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),

                // Time (tabular figures => premium alignment)
                Text(
                  time,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFF0A0A0A)
                        : Colors.white.withOpacity(0.92),
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
              color: Colors.white.withOpacity(isActive ? 0.18 : 0.08),
            ),
          ),
        ],
      ),
    ),
  );
}


    
  Widget _buildTodayProgress(BuildContext context, WidgetRef ref) {
      final prayerTrackingState = ref.watch(prayerTrackingProvider);
      final dailyAmalState = ref.watch(dailyAmalProvider);
      final dhikrState = ref.watch(dhikrCounterProvider);
      final readingState = ref.watch(readingTrackerProvider);
  
      final completedPrayers = prayerTrackingState.todayData.completedPrayersCount;
      final completedAmal = dailyAmalState.todayData.completedCount;
      final totalAmal = dailyAmalState.todayData.totalCount;
      final dhikrCount = dhikrState.todayData.totalCount;
      final dhikrTarget = dhikrState.todayData.totalTarget;
      final readingMinutes = readingState.todayData.totalMinutes;
      final readingTarget = readingState.todayData.goal.totalMinutes;
  
      final prayerProgress = completedPrayers / 5;
      final amalProgress = totalAmal > 0 ? completedAmal / totalAmal : 0.0;
      final dhikrProgress =
          dhikrTarget > 0 ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0) : 0.0;
      final readingProgress = readingTarget > 0
          ? (readingMinutes / readingTarget).clamp(0.0, 1.0)
          : 0.0;
  
      final overallProgress =
          (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
      final overallPercentage = (overallProgress * 100).toInt();
  
      return _premiumCard(
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
                    color: const Color(0xFFD4AF37).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFFD4AF37),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'আজকের অগ্রগতি',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getProgressColor(overallProgress).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getProgressColor(overallProgress).withOpacity(0.30),
                    ),
                  ),
                  child: Text(
                    '$overallPercentage%',
                    style: TextStyle(
                      color: _getProgressColor(overallProgress),
                      fontSize: 13,
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
                    const Text(
                      'সামগ্রিক অগ্রগতি',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _getProgressMessage(overallProgress),
                      style: TextStyle(
                        color: _getProgressColor(overallProgress),
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
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeInOut,
                      height: 12,
                      width: (MediaQuery.of(context).size.width - 80) *
                          overallProgress.clamp(0.0, 1.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            _getProgressColor(overallProgress),
                            _getProgressColor(overallProgress).withOpacity(0.70),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _getProgressColor(overallProgress)
                                .withOpacity(0.30),
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
                _buildProgressCircle(context, completedPrayers, 5, 'নামাজ'),
                _buildProgressCircle(context, completedAmal, totalAmal, 'প্রতিদিন'),
                _buildProgressCircle(context, dhikrCount, dhikrTarget, 'যিকির'),
              ],
            ),
          ],
        ),
      );
    }
  
    Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return const Color(0xFF4CAF50); // Green for excellent
    } else if (progress >= 0.5) {
      return const Color(0xFFD4AF37); // Gold for good
    } else if (progress >= 0.25) {
      return const Color(0xFFFF9800); // Orange for moderate
    } else {
      return const Color(0xFFE57373); // Light red for needs improvement
    }
  }

  String _getProgressMessage(double progress) {
    if (progress >= 0.8) {
      return 'অসাধারণ! ';
    } else if (progress >= 0.5) {
      return 'ভালো চলছে ';
    } else if (progress >= 0.25) {
      return 'চেষ্টা চালিয়ে যান ';
    } else {
      return 'শুরু করুন';
    }
  }

  Widget _buildProgressCircle(
      BuildContext context, int current, int total, String label) {
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
                backgroundColor: const Color(0xFF2A2A2A),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$current',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '/$total',
                  style: const TextStyle(
                    color: Color(0xFF888888),
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
          style: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAmalCards(BuildContext context, WidgetRef ref) {
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
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'আজকের আমল',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildAmalCard(
            context,
            title: 'নামাজ',
            subtitle: '৫ ওয়াক্ত নামাজ',
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
            title: 'প্রতিদিনের আমল',
            subtitle: 'মিসওয়াক, সূরাহ আমল',
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
            title: 'যিকির',
            subtitle: 'দোয়া, তাসবীহ, ইস্তিগফার',
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
            title: 'পড়াশোনা',
            subtitle: 'কুরআন, তাফসীর, হাদিস',
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
      return _premiumInkCard(
        onTap: onTap,
        radius: 18,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            _iconPill(Icons.auto_fix_high_rounded),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'প্রতিদিনের গুনাহ',
                    style: TextStyle(
                      color: Color(0xFFEAEAEA),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalSins == 0
                        ? 'মাশাআল্লাহ! আজ কোনো গুনাহ নেই'
                        : pendingKaffara == 0
                            ? 'আজ $totalSins টি গুনাহ • সব কাফফারা হয়েছে ✓'
                            : 'আজ $totalSins টি গুনাহ • $pendingKaffara বাকি',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12.8,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey.shade600,
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
      final safeTotal = total <= 0 ? 1 : total;
      final percentage = (current / safeTotal).clamp(0.0, 1.0);
  
      return _premiumInkCard(
        onTap: onTap,
        radius: 18,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  _iconPill(icon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFFEAEAEA),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF8D8D8D),
                            fontSize: 12.8,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.14),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.20),
                      ),
                    ),
                    child: Text(
                      '$current/$total',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF666666),
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
                  backgroundColor: const Color(0xFF0F0F0F),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

class _PremiumNoisePainter extends CustomPainter {
  const _PremiumNoisePainter({
    required this.color,
    this.seed = 7,
    this.intensity = 0.35,
  });

  final Color color;
  final int seed;
  /// 0.0 = off, 1.0 = stronger (still subtle)
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    if (intensity <= 0) return;

    final rnd = math.Random(seed);
    final area = size.width * size.height;

    // Speckle count scales with area; kept intentionally low.
    final count = (area / 9000.0 * (0.6 + intensity)).clamp(35.0, 140.0).toInt();

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity((color.opacity * 0.35 * intensity).clamp(0.0, 0.06));

    for (int i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 0.25 + rnd.nextDouble() * 0.9; // tiny, subtle
      canvas.drawCircle(Offset(x, y), r, dotPaint);
    }

    // A few very soft "bokeh" highlights (still subtle).
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withOpacity((color.opacity * 0.18 * intensity).clamp(0.0, 0.045));

    final glowCount = (3 + intensity * 4).round();
    for (int i = 0; i < glowCount; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = 10 + rnd.nextDouble() * 28;
      canvas.drawCircle(Offset(x, y), r, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumNoisePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.seed != seed ||
        oldDelegate.intensity != intensity;
  }
}
