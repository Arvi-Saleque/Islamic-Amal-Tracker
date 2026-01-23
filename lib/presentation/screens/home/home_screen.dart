import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'bn');
    final prayerTimesState = ref.watch(prayerTimesProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'আমল ট্র্যাকার',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFD4AF37)),
            tooltip: 'রিফ্রেশ',
            onPressed: () async {
              // Refresh all data
              ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
              ref.read(prayerTrackingProvider.notifier).loadTodayData();
              ref.read(dailyAmalProvider.notifier).loadTodayData();
              ref.read(dhikrCounterProvider.notifier).loadTodayData();
              ref.read(readingTrackerProvider.notifier).loadTodayData();
              ref.read(statisticsProvider.notifier).updateTodayStats();
              ref.read(statisticsProvider.notifier).updateTodayStats();
              
              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ডেটা আপডেট হয়েছে'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFFD4AF37),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded, color: Color(0xFFD4AF37)),
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
            icon: const Icon(Icons.settings_outlined, color: Color(0xFFD4AF37)),
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
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh prayer times
          ref.read(prayerTimesProvider.notifier).fetchPrayerTimes();
          // Refresh prayer tracking
          ref.read(prayerTrackingProvider.notifier).loadTodayData();
          // Refresh daily amal
          ref.read(dailyAmalProvider.notifier).loadTodayData();
          // Refresh dhikr counter
          ref.read(dhikrCounterProvider.notifier).loadTodayData();
          // Refresh reading tracker
          ref.read(readingTrackerProvider.notifier).loadTodayData();
          // Refresh statistics
          ref.read(statisticsProvider.notifier).updateTodayStats();
          await Future.delayed(const Duration(milliseconds: 500));
        },
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF1A1A1A),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              
              // Date & Sun Card
              _buildDateSunCard(context, prayerTimesState),
              
              const SizedBox(height: 16),
              
              // Prayer Times Card
              _buildPrayerTimesCard(context, prayerTimesState),
              
              const SizedBox(height: 16),
              
              // Today's Progress
              _buildTodayProgress(context, ref),
              
              const SizedBox(height: 20),
              
              // Today's Amal Cards
              _buildAmalCards(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSunCard(BuildContext context, PrayerTimesState state) {
    final now = DateTime.now();
    
    // Hijri date
    final hijri = HijriCalendar.fromDate(now);
    final hijriMonthBengali = _getHijriMonthBengali(hijri.hMonth);
    final hijriDay = _toBengaliNumber(hijri.hDay);
    
    // Bengali date (approximate - Magh is around Jan-Feb)
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
      if (sunrise != null) {
        sunriseTime = _formatTimeShort(sunrise);
      }
      if (maghrib != null) {
        sunsetTime = _formatTimeShort(maghrib);
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side - Dates
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hijri date
                Text(
                  '$hijriDay $hijriMonthBengali',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                // Gregorian date
                Text(
                  '$dayNum $monthName',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  dayName,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                // Bengali date
                Text(
                  bengaliDate,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          
          // Vertical Divider
          Container(
            height: 80,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xFFD4AF37).withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          
          // Right side - Sunrise/Sunset
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Sunrise
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        sunriseTime ?? '--:--',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'সূর্যোদয়',
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
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.wb_sunny,
                      color: const Color(0xFFD4AF37),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Sunset
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        sunsetTime ?? '--:--',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'সূর্যাস্ত',
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
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.nights_stay,
                      color: const Color(0xFFD4AF37),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimeShort(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    return '${_toBengaliNumber(hour)}:${_toBengaliNumber(int.parse(minute))}';
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((d) => bengaliDigits[int.parse(d)]).join();
  }

  String _getHijriMonthBengali(int month) {
    const months = [
      'মুহাররম', 'সফর', 'রবিউল আউয়াল', 'রবিউস সানি',
      'জমাদিউল আউয়াল', 'জমাদিউস সানি', 'রজব', 'শা\'বান',
      'রমজান', 'শাওয়াল', 'জিলক্বদ', 'জিলহজ্জ'
    ];
    return months[month - 1];
  }

  String _getBengaliDayName(int weekday) {
    const days = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
    return days[weekday - 1];
  }

  String _getBengaliMonthName(int month) {
    const months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return months[month - 1];
  }

  String _getBengaliDate(DateTime date) {
    // Approximate Bengali calendar calculation
    // Bengali year starts around April 14
    int bengaliYear = date.year - 593;
    int bengaliMonth;
    int bengaliDay;
    
    // Simplified calculation - this is approximate
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    
    // Bengali months start dates (approximate)
    final bengaliMonthStarts = [
      14, // Poush starts ~Jan 14
      13, // Magh starts ~Feb 13
      14, // Falgun starts ~Mar 14
      14, // Chaitra starts ~Apr 14
      15, // Boishakh starts ~May 15
      15, // Joishtho starts ~Jun 15
      16, // Ashar starts ~Jul 16
      16, // Srabon starts ~Aug 16
      16, // Bhadro starts ~Sep 16
      17, // Ashwin starts ~Oct 17
      16, // Kartik starts ~Nov 16
      15, // Ogrohayon starts ~Dec 15
    ];
    
    const bengaliMonthNames = [
      'পৌষ', 'মাঘ', 'ফাল্গুন', 'চৈত্র', 'বৈশাখ', 'জ্যৈষ্ঠ',
      'আষাঢ়', 'শ্রাবণ', 'ভাদ্র', 'আশ্বিন', 'কার্তিক', 'অগ্রহায়ণ'
    ];
    
    // Find current Bengali month based on Gregorian date
    if (date.month == 1) {
      if (date.day >= 14) {
        bengaliMonth = 1; // Magh
        bengaliDay = date.day - 13;
      } else {
        bengaliMonth = 0; // Poush
        bengaliDay = date.day + 17;
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'নামাজের সময়',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Loading/Error/Content
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else ...[
            // Forbidden time warning (নিষিদ্ধ সময়) - RED
            if (state.isForbiddenTime)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.15),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.block,
                      color: Colors.red[400],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'নিষিদ্ধ সময়',
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.timeToCurrentPrayerEnd != null 
                                ? '${state.timeToCurrentPrayerEnd} বাকি'
                                : 'এখন নামাজ পড়া নিষিদ্ধ',
                            style: TextStyle(
                              color: Colors.red[300],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            // Nafl time (নফল নামাজের সময়) - GOLDEN
            else if (state.isNaflTime)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.15),
                      const Color(0xFFD4AF37).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✨ নফল নামাজের সময়',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'যোহর শুরু: ${state.timeToNextPrayer ?? ""} বাকি',
                            style: TextStyle(
                              color: const Color(0xFFD4AF37).withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            // Current Prayer Highlight (চলমান ওয়াক্ত) - GOLDEN
            else if (state.currentPrayer != null && state.timeToCurrentPrayerEnd != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD4AF37).withOpacity(0.15),
                      const Color(0xFFD4AF37).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_filled,
                      color: Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'চলমান: ${_getPrayerNameInBangla(state.currentPrayer!)} - ${state.timeToCurrentPrayerEnd} বাকি',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Prayer Times List
            if (state.prayerTimes['fajr'] != null)
              _buildPrayerTimeRow(context, 'ফজর', _formatTime(state.prayerTimes['fajr']!)),
            const SizedBox(height: 14),
            if (state.prayerTimes['dhuhr'] != null)
              _buildPrayerTimeRow(context, 'যোহর', _formatTime(state.prayerTimes['dhuhr']!)),
            const SizedBox(height: 14),
            if (state.prayerTimes['asr'] != null)
              _buildPrayerTimeRow(context, 'আসর', _formatTime(state.prayerTimes['asr']!)),
            const SizedBox(height: 14),
            if (state.prayerTimes['maghrib'] != null)
              _buildPrayerTimeRow(context, 'মাগরিব', _formatTime(state.prayerTimes['maghrib']!)),
            const SizedBox(height: 14),
            if (state.prayerTimes['isha'] != null)
              _buildPrayerTimeRow(context, 'এশা', _formatTime(state.prayerTimes['isha']!)),
          ],
        ],
      ),
    );
  }

  String _getPrayerNameInBangla(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'ফজর';
      case 'dhuhr':
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

  Widget _buildPrayerTimeRow(BuildContext context, String name, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              time,
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
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
    
    // Calculate overall day progress percentage
    final prayerProgress = completedPrayers / 5;
    final amalProgress = totalAmal > 0 ? completedAmal / totalAmal : 0.0;
    final dhikrProgress = dhikrTarget > 0 ? (dhikrCount / dhikrTarget).clamp(0.0, 1.0) : 0.0;
    final readingProgress = readingTarget > 0 ? (readingMinutes / readingTarget).clamp(0.0, 1.0) : 0.0;
    
    // Average of all 4 categories
    final overallProgress = (prayerProgress + amalProgress + dhikrProgress + readingProgress) / 4;
    final overallPercentage = (overallProgress * 100).toInt();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'আজকের অগ্রগতি',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Overall percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getProgressColor(overallProgress).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getProgressColor(overallProgress).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$overallPercentage%',
                  style: TextStyle(
                    color: _getProgressColor(overallProgress),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Overall Progress Bar
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  // Background
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: 12,
                    width: (MediaQuery.of(context).size.width - 80) * overallProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getProgressColor(overallProgress),
                          _getProgressColor(overallProgress).withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: _getProgressColor(overallProgress).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
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

  Widget _buildProgressCircle(BuildContext context, int current, int total, String label) {
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
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
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
    final completedPrayers = prayerTrackingState.todayData.completedPrayersCount;
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.auto_fix_high,
                  color: Color(0xFFD4AF37),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'প্রতিদিনের গুনাহ',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
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
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade600,
                size: 18,
              ),
            ],
          ),
        ),
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
    final percentage = current / total;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFFD4AF37),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFFE0E0E0),
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$current/$total',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF666666),
                    size: 16,
                  ),
                ],
              ),
            ),
            // Golden Progress Bar
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF0A0A0A),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                  minHeight: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
