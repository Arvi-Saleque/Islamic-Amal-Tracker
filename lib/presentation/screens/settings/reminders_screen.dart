import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/custom_reminder.dart';
import '../../../services/daily_reminder_service.dart';
import '../../providers/prayer_times_provider.dart';
import '../statistics/widgets/digital_time_picker.dart';
import 'custom_reminders_screen.dart';
import 'reminder_setting_screen.dart';

enum ReminderTab { defaults, userSettings, custom }

/// NOTE:
/// - No new content/text/buttons were added.
/// - Only styling/presentation improved for a cleaner premium 3D vibe.
/// - Shadows are intentionally soft (not heavy) to avoid odd look.
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late TabController _tabController;
  ReminderTab _selectedTab = ReminderTab.defaults;

  // Daily Amal Reminder
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 22, minute: 0);

  // Dhikr Reminders
  TimeOfDay _morningDhikrTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningDhikrTime = const TimeOfDay(hour: 18, minute: 0);

  // Prayer Reminders - map of prayer name to custom reminder time
  final Map<PrayerName, TimeOfDay> _prayerReminderTimes = {};

  // Custom Reminders
  List<CustomReminder> _customReminders = [];

  // Default Prayer Reminders (Always active)
  TimeOfDay? _defaultFajrReminderTime;
  TimeOfDay? _defaultZuhrReminderTime;
  TimeOfDay? _defaultAsrReminderTime;
  TimeOfDay? _defaultMaghribReminderTime;
  TimeOfDay? _defaultIshaReminderTime;

  // Default Dhikr & Amal Reminders (Always active)
  TimeOfDay? _defaultMorningDhikrReminderTime;
  TimeOfDay? _defaultEveningDhikrReminderTime;
  TimeOfDay? _defaultDailyAmalReminderTime;

  // User Settings Reminders Enable/Disable States
  bool _isDailyReminderEnabled = false;
  bool _isMorningDhikrEnabled = false;
  bool _isEveningDhikrEnabled = false;
  bool _arePrayerRemindersEnabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = ReminderTab.values[_tabController.index];
      });
    });
    _loadAllSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);

    // Load daily reminder settings
    final dailySettings = await DailyReminderService.getReminderSettings();

    // Load dhikr settings
    final dhikrSettings = await DailyReminderService.getDhikrReminderSettings();

    // Load prayer reminder settings
    final prayerSettings =
        await DailyReminderService.getPrayerReminderSettings();

    // Load custom reminders
    final customReminders = await DailyReminderService.getCustomReminders();

    // Get prayer times for default values
    final prayerTimes = ref.read(prayerTimesProvider).prayerTimes;

    setState(() {
      _dailyReminderTime = TimeOfDay(
        hour: dailySettings['hour'] ?? 22,
        minute: dailySettings['minute'] ?? 0,
      );

      // Initialize dhikr times from saved values or calculate defaults
      final morningDhikrDefault = _calculateMorningDhikrDefault(prayerTimes);
      final eveningDhikrDefault = _calculateEveningDhikrDefault(prayerTimes);

      _morningDhikrTime = TimeOfDay(
        hour: dhikrSettings['morningHour'] ?? morningDhikrDefault.hour,
        minute: dhikrSettings['morningMinute'] ?? morningDhikrDefault.minute,
      );
      _eveningDhikrTime = TimeOfDay(
        hour: dhikrSettings['eveningHour'] ?? eveningDhikrDefault.hour,
        minute: dhikrSettings['eveningMinute'] ?? eveningDhikrDefault.minute,
      );

      // Initialize prayer reminder times - use saved custom times or calculate defaults
      for (final prayer in PrayerName.values) {
        final key = prayer.name;
        final savedHour = prayerSettings['${key}_hour'];
        final savedMinute = prayerSettings['${key}_minute'];

        if (savedHour != null && savedMinute != null) {
          _prayerReminderTimes[prayer] =
              TimeOfDay(hour: savedHour, minute: savedMinute);
        } else {
          // Use calculated default (prayer time + offset)
          _prayerReminderTimes[prayer] =
              _calculateDefaultPrayerReminderTime(prayer, prayerTimes);
        }
      }

      _customReminders = customReminders;

      // Set up default prayer reminders
      _defaultFajrReminderTime = _calculateDefaultFajrReminderTime(prayerTimes);
      _defaultZuhrReminderTime = _calculateDefaultZuhrReminderTime(prayerTimes);
      _defaultAsrReminderTime = _calculateDefaultAsrReminderTime(prayerTimes);
      _defaultMaghribReminderTime = _calculateDefaultMaghribReminderTime(prayerTimes);
      final isha = prayerTimes['isha'];
      final off = _getDefaultPrayerOffset(PrayerName.isha); // isha + 60
      final ishaDefault = (isha == null)
          ? const TimeOfDay(hour: 21, minute: 30)
          : TimeOfDay(
              hour: ((isha.hour * 60 + isha.minute + off) ~/ 60) % 24,
              minute: (isha.hour * 60 + isha.minute + off) % 60,
            );
      _defaultIshaReminderTime = ishaDefault;

      // Set up default dhikr and amal reminders
      _defaultMorningDhikrReminderTime =
          _calculateDefaultMorningDhikrReminderTime(prayerTimes);
      _defaultEveningDhikrReminderTime =
          _calculateDefaultEveningDhikrReminderTime(prayerTimes);
      _defaultDailyAmalReminderTime =
          const TimeOfDay(hour: 22, minute: 0); // Fixed at 10 PM

      _isLoading = false;

      _isDailyReminderEnabled = dailySettings['enabled'] ?? false;

      _isMorningDhikrEnabled = dhikrSettings['morningEnabled'] ?? false;
      _isEveningDhikrEnabled = dhikrSettings['eveningEnabled'] ?? false;

      if (prayerSettings.containsKey('enabled')) {
      _arePrayerRemindersEnabled = prayerSettings['enabled'] == true;
    } else {
      _arePrayerRemindersEnabled = PrayerName.values.any((p) {
        return prayerSettings['${p.name}_enabled'] == true;
      });
    }


    });

    // Apply schedules based on toggles
    await _scheduleAllReminders();
  }

  /// Get default prayer reminder offset in minutes
  int _getDefaultPrayerOffset(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 30;
      case PrayerName.dhuhr:
        return 60;
      case PrayerName.asr:
        return 15;
      case PrayerName.maghrib:
        return 10;
      case PrayerName.isha:
        return 60;
    }
  }

  /// Calculate default prayer reminder time: prayer time + offset
  TimeOfDay _calculateDefaultPrayerReminderTime(
    PrayerName prayer,
    Map<String, DateTime>? prayerTimes,
  ) {
    if (prayerTimes == null) return _getStaticDefaultPrayerTime(prayer);

    final prayerDateTime = prayerTimes[prayer.name];
    if (prayerDateTime == null) return _getStaticDefaultPrayerTime(prayer);

    final offsetMinutes = _getDefaultPrayerOffset(prayer);

    final totalMinutes =
        prayerDateTime.hour * 60 + prayerDateTime.minute + offsetMinutes;
    final hour = (totalMinutes ~/ 60) % 24;
    final minute = totalMinutes % 60;

    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Fallback if prayer times not loaded
  TimeOfDay _getStaticDefaultPrayerTime(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return const TimeOfDay(hour: 6, minute: 30);
      case PrayerName.dhuhr:
        return const TimeOfDay(hour: 13, minute: 30);
      case PrayerName.asr:
        return const TimeOfDay(hour: 16, minute: 15);
      case PrayerName.maghrib:
        return const TimeOfDay(hour: 18, minute: 10);
      case PrayerName.isha:
        return const TimeOfDay(hour: 20, minute: 30);
    }
  }

  TimeOfDay _calculateMorningDhikrDefault(Map<String, DateTime>? prayerTimes) {
    // Default: Fajr + 60 minutes
    if (prayerTimes == null || prayerTimes['fajr'] == null) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
    final fajr = prayerTimes['fajr']!;
    final total = fajr.hour * 60 + fajr.minute + 60;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateEveningDhikrDefault(Map<String, DateTime>? prayerTimes) {
    // Default: Maghrib + 25 minutes
    if (prayerTimes == null || prayerTimes['maghrib'] == null) {
      return const TimeOfDay(hour: 18, minute: 25);
    }
    final maghrib = prayerTimes['maghrib']!;
    final total = maghrib.hour * 60 + maghrib.minute + 25;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultFajrReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Fajr + 30 minutes (Always active reminder)
    if (prayerTimes == null || prayerTimes['fajr'] == null) {
      return const TimeOfDay(hour: 6, minute: 30); // Fallback time
    }
    final fajr = prayerTimes['fajr']!;
    final total = fajr.hour * 60 + fajr.minute + 30;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultZuhrReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Zuhr + 60 minutes (Always active reminder)
    if (prayerTimes == null || prayerTimes['dhuhr'] == null) {
      return const TimeOfDay(hour: 14, minute: 30); // Fallback time
    }
    final zuhr = prayerTimes['dhuhr']!;
    final total = zuhr.hour * 60 + zuhr.minute + 60;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultAsrReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Asr + 15 minutes (Always active reminder)
    if (prayerTimes == null || prayerTimes['asr'] == null) {
      return const TimeOfDay(hour: 16, minute: 30); // Fallback time
    }
    final asr = prayerTimes['asr']!;
    final total = asr.hour * 60 + asr.minute + 15;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultMaghribReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Maghrib + 10 minutes (Always active reminder)
    if (prayerTimes == null || prayerTimes['maghrib'] == null) {
      return const TimeOfDay(hour: 18, minute: 35); // Fallback time
    }
    final maghrib = prayerTimes['maghrib']!;
    final total = maghrib.hour * 60 + maghrib.minute + 10;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultMorningDhikrReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Fajr + 60 minutes (Always active dhikr reminder)
    if (prayerTimes == null || prayerTimes['fajr'] == null) {
      return const TimeOfDay(hour: 7, minute: 0); // Fallback time
    }
    final fajr = prayerTimes['fajr']!;
    final total = fajr.hour * 60 + fajr.minute + 60;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calculateDefaultEveningDhikrReminderTime(
      Map<String, DateTime>? prayerTimes) {
    // Default: Maghrib + 30 minutes (Always active dhikr reminder)
    if (prayerTimes == null || prayerTimes['maghrib'] == null) {
      return const TimeOfDay(hour: 18, minute: 30); // Fallback time
    }
    final maghrib = prayerTimes['maghrib']!;
    final total = maghrib.hour * 60 + maghrib.minute + 30;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  Future<void> _scheduleAllReminders() async {
    // DEFAULT (Always Active)
    await DailyReminderService.scheduleDefaultDailyAmalReminder();

    // Daily reminder
    if (_isDailyReminderEnabled) {
      await DailyReminderService.scheduleDailyReminder(
        hour: _dailyReminderTime.hour,
        minute: _dailyReminderTime.minute,
      );
    } else {
      await DailyReminderService.cancelDailyReminder();
    }

    // Dhikr reminders
    if (_isMorningDhikrEnabled) {
      await DailyReminderService.scheduleMorningDhikrReminder(
        hour: _morningDhikrTime.hour,
        minute: _morningDhikrTime.minute,
      );
    } else {
      await DailyReminderService.cancelMorningDhikrReminder();
    }

    if (_isEveningDhikrEnabled) {
      await DailyReminderService.scheduleEveningDhikrReminder(
        hour: _eveningDhikrTime.hour,
        minute: _eveningDhikrTime.minute,
      );
    } else {
      await DailyReminderService.cancelEveningDhikrReminder();
    }

    // Prayer reminders
    if (_arePrayerRemindersEnabled) {
      for (final prayer in PrayerName.values) {
        final time = _prayerReminderTimes[prayer];
        if (time != null) {
          await DailyReminderService.schedulePrayerReminderAtTime(
            prayer: prayer,
            hour: time.hour,
            minute: time.minute,
          );
        }
      }
    } else {
      await DailyReminderService.cancelAllPrayerReminders();
    }

  }

  Future<void> _selectTime(String type, TimeOfDay currentTime) async {
    final selectedTime = await DigitalTimePicker.show(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (type == 'daily') _dailyReminderTime = selectedTime;
        if (type == 'morningDhikr') _morningDhikrTime = selectedTime;
        if (type == 'eveningDhikr') _eveningDhikrTime = selectedTime;
      });

      await _scheduleAllReminders();
    }
  }

  Future<void> _selectPrayerTime(
      PrayerName prayer, TimeOfDay currentTime) async {
    final selectedTime = await DigitalTimePicker.show(
      context: context,
      initialTime: currentTime,
    );

    if (selectedTime != null) {
      setState(() => _prayerReminderTimes[prayer] = selectedTime);

      await _scheduleAllReminders();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _navigateToCustomReminders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomRemindersScreen(),
      ),
    );
    await _loadAllSettings();
  }

  void _showTodaysRemindersPopup() {
    final prayerTimesState = ref.read(prayerTimesProvider);
    final actualPrayerTimes = prayerTimesState.prayerTimes;

    showDialog(
      context: context,
      builder: (context) => TodaysRemindersDialog(
        dailyReminderTime: _dailyReminderTime,
        morningDhikrTime: _morningDhikrTime,
        eveningDhikrTime: _eveningDhikrTime,
        prayerReminderTimes: _prayerReminderTimes,
        customReminders: _customReminders,
        onNavigateToCustomReminders: _navigateToCustomReminders,
        actualPrayerTimes: actualPrayerTimes,
        isDailyReminderEnabled: _isDailyReminderEnabled,
        isMorningDhikrEnabled: _isMorningDhikrEnabled,
        isEveningDhikrEnabled: _isEveningDhikrEnabled,
        arePrayerRemindersEnabled: _arePrayerRemindersEnabled,
        defaultFajrReminderTime: _defaultFajrReminderTime,
        defaultZuhrReminderTime: _defaultZuhrReminderTime,
        defaultAsrReminderTime: _defaultAsrReminderTime,
        defaultMaghribReminderTime: _defaultMaghribReminderTime,
        defaultIshaReminderTime: _defaultIshaReminderTime,
        defaultMorningDhikrReminderTime: _defaultMorningDhikrReminderTime,
        defaultEveningDhikrReminderTime: _defaultEveningDhikrReminderTime,
        defaultDailyAmalReminderTime: _defaultDailyAmalReminderTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[0],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[1],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).extension<GradientColors>()!.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        shape: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'রিমাইন্ডারস',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_active, color: iconColor),
            onPressed: _showTodaysRemindersPopup,
            tooltip: 'আজকের রিমাইন্ডারস',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyReminderScreen(),
                ),
              );
            },
            tooltip: 'সেটিংস',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadAllSettings,
              color: colors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildTabSelector(),
                    const SizedBox(height: 20),
                    _buildTabContent(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final primary = Theme.of(context).colorScheme.primary;
    
    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: primary),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'প্রতিদিন নির্দিষ্ট সময়ে আমল করার রিমাইন্ডার পাবেন',
              style: TextStyle(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildDefaultReminderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isDefault,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    
    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
                    fontSize: 12,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(time),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Text(
              'ডিফল্ট',
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrayerReminderTiles() {
    final prayerIcons = {
      PrayerName.fajr: Icons.wb_twilight,
      PrayerName.dhuhr: Icons.wb_sunny,
      PrayerName.asr: Icons.wb_sunny_outlined,
      PrayerName.maghrib: Icons.nights_stay,
      PrayerName.isha: Icons.nights_stay_outlined,
    };

    final isFriday = DateTime.now().weekday == DateTime.friday;
    final prayerNames = {
      PrayerName.fajr: 'ফজরের নামাজ',
      PrayerName.dhuhr: isFriday ? 'জুম\'আর নামাজ' : 'যোহরের নামাজ',
      PrayerName.asr: 'আসরের নামাজ',
      PrayerName.maghrib: 'মাগরিবের নামাজ',
      PrayerName.isha: 'এশার নামাজ',
    };

    return PrayerName.values.map((prayer) {
      final reminderTime =
          _prayerReminderTimes[prayer] ?? _getStaticDefaultPrayerTime(prayer);

      final primary = Theme.of(context).colorScheme.primary;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: buildPremiumCard(
          context: context,
          radius: 14,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prayerIcons[prayer],
                  color: primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayerNames[prayer] ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectPrayerTime(prayer, reminderTime),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(reminderTime),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.edit,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.95),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCustomReminderCard() {
    final primary = Theme.of(context).colorScheme.primary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _navigateToCustomReminders,
        borderRadius: BorderRadius.circular(14),
        child: buildPremiumCard(
          context: context,
          radius: 14,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.add_alert, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'কাস্টম রিমাইন্ডার',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _customReminders.isEmpty
                          ? 'কোনো কাস্টম রিমাইন্ডার নেই'
                          : '${_customReminders.where((r) => r.isEnabled).length} টি সক্রিয় রিমাইন্ডার',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.68),
                        fontSize: 13,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Default Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == ReminderTab.defaults
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'ডিফল্ট',
                    style: TextStyle(
                      color: _selectedTab == ReminderTab.defaults
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).extension<GradientColors>()!.bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // User Settings Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == ReminderTab.userSettings
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'ব্যক্তিগত',
                    style: TextStyle(
                      color: _selectedTab == ReminderTab.userSettings
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).extension<GradientColors>()!.bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Custom Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(2);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTab == ReminderTab.custom
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'কাস্টম',
                    style: TextStyle(
                      color: _selectedTab == ReminderTab.custom
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).extension<GradientColors>()!.bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case ReminderTab.defaults:
        return _buildDefaultsTab();
      case ReminderTab.userSettings:
        return _buildUserSettingsTab();
      case ReminderTab.custom:
        return _buildCustomTab();
    }
  }

  Widget _buildDefaultsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('নামাজের পর ডিফল্ট রিমাইন্ডার'),
        const SizedBox(height: 8),
        if (_defaultFajrReminderTime != null)
          _buildDefaultReminderTile(
            icon: Icons.wb_twilight,
            title: 'ফজরের পর রিমাইন্ডার',
            subtitle: 'ফজরের ৩০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultFajrReminderTime!,
            isDefault: true,
          ),
        if (_defaultZuhrReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.wb_sunny,
            title: DateTime.now().weekday == DateTime.friday
                ? 'জুম\'আর পর রিমাইন্ডার'
                : 'যোহরের পর রিমাইন্ডার',
            subtitle: DateTime.now().weekday == DateTime.friday
                ? 'জুম\'আর ৬০ মিনিট পর (সবসময় সক্রিয়)'
                : 'যোহরের ৬০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultZuhrReminderTime!,
            isDefault: true,
          ),
        ],
        if (_defaultAsrReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.wb_sunny_outlined,
            title: 'আসরের পর রিমাইন্ডার',
            subtitle: 'আসরের ১৫ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultAsrReminderTime!,
            isDefault: true,
          ),
        ],
        if (_defaultMaghribReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.nights_stay,
            title: 'মাগরিবের পর রিমাইন্ডার',
            subtitle: 'মাগরিবের ১০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultMaghribReminderTime!,
            isDefault: true,
          ),
        ],
        if (_defaultIshaReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.nights_stay_outlined,
            title: 'ইশার পর রিমাইন্ডার',
            subtitle: 'ইশার ৬০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultIshaReminderTime!,
            isDefault: true,
          ),
        ],
        const SizedBox(height: 24),
        _buildSectionHeader('যিকির ও আমল ডিফল্ট রিমাইন্ডার'),
        const SizedBox(height: 8),
        if (_defaultMorningDhikrReminderTime != null)
          _buildDefaultReminderTile(
            icon: Icons.wb_sunny_outlined,
            title: 'সকালের যিকির',
            subtitle: 'ফজরের ৬০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultMorningDhikrReminderTime!,
            isDefault: true,
          ),
        if (_defaultEveningDhikrReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.nights_stay_outlined,
            title: 'সন্ধ্যার যিকির',
            subtitle: 'মাগরিবের ৩০ মিনিট পর (সবসময় সক্রিয়)',
            time: _defaultEveningDhikrReminderTime!,
            isDefault: true,
          ),
        ],
        if (_defaultDailyAmalReminderTime != null) ...[
          const SizedBox(height: 8),
          _buildDefaultReminderTile(
            icon: Icons.star,
            title: 'দৈনিক আমল',
            subtitle: 'প্রতিদিন রাত ১০ টায় (সবসময় সক্রিয়)',
            time: _defaultDailyAmalReminderTime!,
            isDefault: true,
          ),
        ],
      ],
    );
  }

  Widget _buildUserSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUserSettingsInfoCard(),
        const SizedBox(height: 24),
        _buildSectionHeader('দৈনিক আমল রিমাইন্ডার'),
        const SizedBox(height: 8),
        _buildUserReminderTile(
          icon: Icons.wb_sunny,
          title: 'দৈনিক আমল রিমাইন্ডার',
          subtitle: 'রিমাইন্ডার সময়',
          time: _dailyReminderTime,
          isEnabled: _isDailyReminderEnabled,
          onToggle: (value) async {
            setState(() => _isDailyReminderEnabled = value);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _selectTime('daily', _dailyReminderTime),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('যিকির রিমাইন্ডার'),
        const SizedBox(height: 8),
        _buildUserReminderTile(
          icon: Icons.wb_sunny_outlined,
          title: 'সকালের যিকির',
          subtitle: 'রিমাইন্ডার সময়',
          time: _morningDhikrTime,
          isEnabled: _isMorningDhikrEnabled,
          onToggle: (value) async {
            setState(() => _isMorningDhikrEnabled = value);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _selectTime('morningDhikr', _morningDhikrTime),
        ),
        const SizedBox(height: 8),
        _buildUserReminderTile(
          icon: Icons.nights_stay_outlined,
          title: 'সন্ধ্যার যিকির',
          subtitle: 'রিমাইন্ডার সময়',
          time: _eveningDhikrTime,
          isEnabled: _isEveningDhikrEnabled,
          onToggle: (value) async {
            setState(() => _isEveningDhikrEnabled = value);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _selectTime('eveningDhikr', _eveningDhikrTime),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('নামাজের রিমাইন্ডার'),
        const SizedBox(height: 8),
        _buildPrayerRemindersToggleCard(),
        const SizedBox(height: 8),
        if (_arePrayerRemindersEnabled) ..._buildPrayerReminderTiles(),
      ],
    );
  }

  Widget _buildCustomTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('কাস্টম রিমাইন্ডার'),
        const SizedBox(height: 8),
        _buildCustomReminderCard(),
      ],
    );
  }

  Widget _buildUserSettingsInfoCard() {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final textColor = gradients.bulletTextColor;
    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ডিফল্ট ৮টা সময়ে রিমাইন্ডার দেওয়া হবে। কিন্তু প্রয়োজন হলে আপনার সময় অনুযায়ী (জামাত) এই রিমাইন্ডারগুলা সেট করে নিতে পারবেন অতিরিক্ত সতর্কতা হিসেবে।',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserReminderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isEnabled,
    required Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    
    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                if (isEnabled)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTimeTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: primary.withOpacity(0.95),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(time),
                              style: TextStyle(
                                color: primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.edit,
                              size: 14,
                              color: primary.withOpacity(0.95),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!isEnabled)
                  Text(
                    'বন্ধ করা আছে',
                    style: TextStyle(
                      color: Theme.of(context).extension<GradientColors>()!.bulletTextColor.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.2,
                      letterSpacing: 0.1,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeThumbColor: primary,
            activeTrackColor: primary.withOpacity(0.3),
            inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRemindersToggleCard() {
    final primary = Theme.of(context).colorScheme.primary;
    
    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.mosque, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'নামাজের রিমাইন্ডার',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '৫টি নামাজের জন্য আলাদা সময় সেট করুন',
                  style: TextStyle(
                    color: Theme.of(context).extension<GradientColors>()!.bulletTextColor,
                    fontSize: 13,
                    height: 1.2,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: _arePrayerRemindersEnabled,
            onChanged: (value) async {
              setState(() => _arePrayerRemindersEnabled = value);
              await _scheduleAllReminders();
            },
            activeThumbColor: primary,
            activeTrackColor: primary.withOpacity(0.3),
            inactiveThumbColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
            inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          ),
        ],
      ),
    );
  }
}

class TodaysRemindersDialog extends StatefulWidget {
  final TimeOfDay dailyReminderTime;
  final TimeOfDay morningDhikrTime;
  final TimeOfDay eveningDhikrTime;
  final Map<PrayerName, TimeOfDay> prayerReminderTimes;
  final List<CustomReminder> customReminders;
  final VoidCallback onNavigateToCustomReminders;
  final Map<String, DateTime> actualPrayerTimes;
  final TimeOfDay? defaultFajrReminderTime;
  final TimeOfDay? defaultZuhrReminderTime;
  final TimeOfDay? defaultAsrReminderTime;
  final TimeOfDay? defaultMaghribReminderTime;
  final TimeOfDay? defaultIshaReminderTime;
  final TimeOfDay? defaultMorningDhikrReminderTime;
  final TimeOfDay? defaultEveningDhikrReminderTime;
  final TimeOfDay? defaultDailyAmalReminderTime;

  // User reminder enabled flags
  final bool isDailyReminderEnabled;
  final bool isMorningDhikrEnabled;
  final bool isEveningDhikrEnabled;
  final bool arePrayerRemindersEnabled;

  const TodaysRemindersDialog({
    super.key,
    required this.dailyReminderTime,
    required this.morningDhikrTime,
    required this.eveningDhikrTime,
    required this.prayerReminderTimes,
    required this.customReminders,
    required this.onNavigateToCustomReminders,
    required this.actualPrayerTimes,
    required this.isDailyReminderEnabled,
    required this.isMorningDhikrEnabled,
    required this.isEveningDhikrEnabled,
    required this.arePrayerRemindersEnabled,
    this.defaultFajrReminderTime,
    this.defaultZuhrReminderTime,
    this.defaultAsrReminderTime,
    this.defaultMaghribReminderTime,
    this.defaultIshaReminderTime,
    this.defaultMorningDhikrReminderTime,
    this.defaultEveningDhikrReminderTime,
    this.defaultDailyAmalReminderTime,
  });

  @override
  State<TodaysRemindersDialog> createState() => _TodaysRemindersDialogState();
}

class _TodaysRemindersDialogState extends State<TodaysRemindersDialog> {
  String _formatDateTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: buildPremiumCard(
        context: context,
        radius: 16,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'রিমাইন্ডার সময়সূচী',
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: primary),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.50,
                child: _buildTodaysRemindersTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysRemindersTab() {
    final now = DateTime.now();
    final todaysReminders = <ReminderItem>[];

    // Add default prayer reminders if they exist
    if (widget.defaultFajrReminderTime != null) {
      final defaultFajrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultFajrReminderTime!.hour,
        widget.defaultFajrReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'ফজরের পর ডিফল্ট রিমাইন্ডার',
        time: defaultFajrDateTime,
        isPassed: now.isAfter(defaultFajrDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultZuhrReminderTime != null) {
      final defaultZuhrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultZuhrReminderTime!.hour,
        widget.defaultZuhrReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: DateTime.now().weekday == DateTime.friday
            ? 'জুম\'আর পর ডিফল্ট রিমাইন্ডার'
            : 'যোহরের পর ডিফল্ট রিমাইন্ডার',
        time: defaultZuhrDateTime,
        isPassed: now.isAfter(defaultZuhrDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultAsrReminderTime != null) {
      final defaultAsrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultAsrReminderTime!.hour,
        widget.defaultAsrReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'আসরের পর ডিফল্ট রিমাইন্ডার',
        time: defaultAsrDateTime,
        isPassed: now.isAfter(defaultAsrDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultMaghribReminderTime != null) {
      final defaultMaghribDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultMaghribReminderTime!.hour,
        widget.defaultMaghribReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'মাগরিবের পর ডিফল্ট রিমাইন্ডার',
        time: defaultMaghribDateTime,
        isPassed: now.isAfter(defaultMaghribDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultIshaReminderTime != null) {
      final defaultIshaDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultIshaReminderTime!.hour,
        widget.defaultIshaReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'ইশার পর ডিফল্ট রিমাইন্ডার',
        time: defaultIshaDateTime,
        isPassed: now.isAfter(defaultIshaDateTime),
        isDefault: true,
      ));
    }

    // Add default dhikr and amal reminders
    if (widget.defaultMorningDhikrReminderTime != null) {
      final defaultMorningDhikrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultMorningDhikrReminderTime!.hour,
        widget.defaultMorningDhikrReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'সকালের যিকির (ডিফল্ট)',
        time: defaultMorningDhikrDateTime,
        isPassed: now.isAfter(defaultMorningDhikrDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultEveningDhikrReminderTime != null) {
      final defaultEveningDhikrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultEveningDhikrReminderTime!.hour,
        widget.defaultEveningDhikrReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'সন্ধ্যার যিকির (ডিফল্ট)',
        time: defaultEveningDhikrDateTime,
        isPassed: now.isAfter(defaultEveningDhikrDateTime),
        isDefault: true,
      ));
    }

    if (widget.defaultDailyAmalReminderTime != null) {
      final defaultDailyAmalDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.defaultDailyAmalReminderTime!.hour,
        widget.defaultDailyAmalReminderTime!.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'দৈনিক আমল (ডিফল্ট)',
        time: defaultDailyAmalDateTime,
        isPassed: now.isAfter(defaultDailyAmalDateTime),
        isDefault: true,
      ));
    }

    if (widget.isDailyReminderEnabled) {
      final dailyReminderDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.dailyReminderTime.hour,
        widget.dailyReminderTime.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'দৈনিক আমল রিমাইন্ডার',
        time: dailyReminderDateTime,
        isPassed: now.isAfter(dailyReminderDateTime),
      ));
    }

    if (widget.isMorningDhikrEnabled) {
      final morningDhikrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.morningDhikrTime.hour,
        widget.morningDhikrTime.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'সকালের যিকির',
        time: morningDhikrDateTime,
        isPassed: now.isAfter(morningDhikrDateTime),
      ));
    }

    if (widget.isEveningDhikrEnabled) {
      final eveningDhikrDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        widget.eveningDhikrTime.hour,
        widget.eveningDhikrTime.minute,
      );
      todaysReminders.add(ReminderItem(
        title: 'সন্ধ্যার যিকির',
        time: eveningDhikrDateTime,
        isPassed: now.isAfter(eveningDhikrDateTime),
      ));
    }

    if (widget.arePrayerRemindersEnabled) {
      for (final prayer in PrayerName.values) {
        final reminderTime = widget.prayerReminderTimes[prayer];
        if (reminderTime != null) {
          final prayerReminderDateTime = DateTime(
            now.year,
            now.month,
            now.day,
            reminderTime.hour,
            reminderTime.minute,
          );
          todaysReminders.add(ReminderItem(
            title: '${CustomReminder.getPrayerBengaliName(prayer)} সালাত',
            time: prayerReminderDateTime,
            isPassed: now.isAfter(prayerReminderDateTime),
          ));
        }
      }
    }

    final todayWeekday = now.weekday;
    for (final reminder in widget.customReminders.where((r) => r.isEnabled)) {
      if (reminder.repeatDays.isNotEmpty &&
          !reminder.repeatDays.contains(todayWeekday)) {
        continue;
      }

      DateTime? reminderTime;
      if (reminder.type == ReminderType.fixedTime &&
          reminder.fixedHour != null &&
          reminder.fixedMinute != null) {
        reminderTime = DateTime(
          now.year,
          now.month,
          now.day,
          reminder.fixedHour!,
          reminder.fixedMinute!,
        );
      } else if (reminder.prayer != null) {
        final actualPrayerTime =
            widget.actualPrayerTimes[reminder.prayer!.name];
        if (actualPrayerTime != null) {
          reminderTime =
              actualPrayerTime.add(Duration(minutes: reminder.minutesOffset));
        }
      }

      if (reminderTime != null) {
        todaysReminders.add(ReminderItem(
          title: reminder.title,
          time: reminderTime,
          isPassed: now.isAfter(reminderTime),
          isCustom: true,
        ));
      }
    }

    todaysReminders.sort((a, b) {
      // Sort by time, but put default reminders first within same time
      final timeComparison = a.time.compareTo(b.time);
      if (timeComparison != 0) return timeComparison;

      // If same time, put default first
      if (a.isDefault && !b.isDefault) return -1;
      if (!a.isDefault && b.isDefault) return 1;
      return 0;
    });

    final pendingReminders = todaysReminders.where((r) => !r.isPassed).toList();
    final passedReminders = todaysReminders.where((r) => r.isPassed).toList();

    if (todaysReminders.isEmpty) {
      return Center(
        child: Text(
          'আজকের জন্য কোনো রিমাইন্ডার নেই',
          style: TextStyle(color: Theme.of(context).extension<GradientColors>()!.bulletTextColor),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pendingReminders.isNotEmpty) ...[
            Text(
              'বাকি রিমাইন্ডার',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...pendingReminders.map((r) => _buildReminderRow(r, false)),
          ],
          if (passedReminders.isNotEmpty && pendingReminders.isNotEmpty)
            Divider(color: Theme.of(context).extension<GradientColors>()!.bulletTextColor.withOpacity(0.2), height: 24),
          if (passedReminders.isNotEmpty) ...[
            Text(
              'সম্পন্ন (${passedReminders.length})',
              style: TextStyle(color: Theme.of(context).extension<GradientColors>()!.bulletTextColor, fontSize: 12),
            ),
            const SizedBox(height: 8),
            ...passedReminders.map((r) => _buildReminderRow(r, true)),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderRow(ReminderItem reminder, bool isPassed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    reminder.title,
                    style: TextStyle(
                      color: isPassed ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.2,
                      decoration: isPassed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                if (reminder.isCustom)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                    ),
                    child: Text(
                      'কাস্টম',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                if (reminder.isDefault)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ডিফল্ট',
                      style: TextStyle(
                        color: Colors.green.shade300,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDateTime(reminder.time),
            style: TextStyle(
              color: isPassed ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6) : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class ReminderItem {
  final String title;
  final DateTime time;
  final bool isPassed;
  final bool isCustom;
  final bool isDefault;

  ReminderItem({
    required this.title,
    required this.time,
    required this.isPassed,
    this.isCustom = false,
    this.isDefault = false,
  });
}
