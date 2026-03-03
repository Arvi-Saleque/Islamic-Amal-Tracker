import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/custom_reminder.dart';
import '../../../services/daily_reminder_service.dart';
import '../../providers/prayer_times_provider.dart';
import '../statistics/widgets/digital_time_picker.dart';
import 'custom_reminders_screen.dart';
import 'reminder_setting_screen.dart';
import '../../providers/main_shell_tab_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Quick-add preset definitions
// ─────────────────────────────────────────────────────────────────────────────
class _Preset {
  final String title;
  final String description;
  final ReminderCategory category;
  final ReminderType type;
  final PrayerName? prayer;
  final int minutesOffset;
  final int? fixedHour;
  final int? fixedMinute;

  const _Preset({
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    this.prayer,
    this.minutesOffset = 0,
    this.fixedHour,
    this.fixedMinute,
  });
}

const _presets = <_Preset>[
  _Preset(
    title: 'তাহাজ্জুদ রিমাইন্ডার',
    description: 'রাতের শেষ তৃতীয়াংশে উঠুন',
    category: ReminderCategory.general,
    type: ReminderType.fixedTime,
    fixedHour: 3,
    fixedMinute: 30,
  ),
  _Preset(
    title: 'ফজরের পর কুরআন',
    description: 'ফজরের পর কুরআন তিলাওয়াত করুন',
    category: ReminderCategory.quran,
    type: ReminderType.afterPrayer,
    prayer: PrayerName.fajr,
    minutesOffset: 10,
  ),
  _Preset(
    title: 'আসরের পর ইস্তিগফার',
    description: 'আসরের পর ১০০ বার ইস্তিগফার',
    category: ReminderCategory.dhikr,
    type: ReminderType.afterPrayer,
    prayer: PrayerName.asr,
    minutesOffset: 15,
  ),
  _Preset(
    title: 'মাগরিবের পর দোয়া',
    description: 'মাগরিবের পর বিশেষ দোয়া',
    category: ReminderCategory.dua,
    type: ReminderType.afterPrayer,
    prayer: PrayerName.maghrib,
    minutesOffset: 5,
  ),
  _Preset(
    title: 'ইশার পর দরুদ',
    description: 'ইশার পর ১০০ বার দরুদ পড়ুন',
    category: ReminderCategory.dhikr,
    type: ReminderType.afterPrayer,
    prayer: PrayerName.isha,
    minutesOffset: 20,
  ),
  _Preset(
    title: 'দুপুরের কুরআন',
    description: 'যোহরের আগে কুরআন পড়ুন',
    category: ReminderCategory.quran,
    type: ReminderType.beforePrayer,
    prayer: PrayerName.dhuhr,
    minutesOffset: 15,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Main RemindersScreen
// ─────────────────────────────────────────────────────────────────────────────
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _isLoading = true;

  // Daily Amal Reminder
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 23, minute: 0);
  bool _isDailyReminderEnabled = false;

  // Dhikr Reminders
  TimeOfDay _morningDhikrTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningDhikrTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isMorningDhikrEnabled = false;
  bool _isEveningDhikrEnabled = false;

  // Prayer Reminders
  final Map<PrayerName, TimeOfDay> _prayerReminderTimes = {};
  bool _arePrayerRemindersEnabled = false;

  // Custom Reminders
  List<CustomReminder> _customReminders = [];

  // Today's summary expand/collapse
  bool _showTodayDetails = false;

  // Default times (computed from prayer times)
  TimeOfDay? _defaultFajrTime;
  TimeOfDay? _defaultZuhrTime;
  TimeOfDay? _defaultAsrTime;
  TimeOfDay? _defaultMaghribTime;
  TimeOfDay? _defaultIshaTime;
  TimeOfDay? _defaultMorningDhikrTime;
  TimeOfDay? _defaultEveningDhikrTime;
  static const TimeOfDay _defaultDailyAmalTime = TimeOfDay(hour: 23, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
  }

  Future<void> _loadAllSettings() async {
    setState(() => _isLoading = true);

    final dailySettings = await DailyReminderService.getReminderSettings();
    final dhikrSettings = await DailyReminderService.getDhikrReminderSettings();
    final prayerSettings = await DailyReminderService.getPrayerReminderSettings();
    final customReminders = await DailyReminderService.getCustomReminders();
    final prayerTimes = ref.read(prayerTimesProvider).prayerTimes;

    setState(() {
      _isDailyReminderEnabled = dailySettings['enabled'] ?? false;
      _dailyReminderTime = TimeOfDay(
        hour: dailySettings['hour'] ?? 23,
        minute: dailySettings['minute'] ?? 0,
      );

      _isMorningDhikrEnabled = dhikrSettings['morningEnabled'] ?? false;
      _isEveningDhikrEnabled = dhikrSettings['eveningEnabled'] ?? false;

      final morningDefault = _calcTime(prayerTimes, 'fajr', 30,
          fallback: const TimeOfDay(hour: 6, minute: 30));
      final eveningDefault = _calcTime(prayerTimes, 'maghrib', 25,
          fallback: const TimeOfDay(hour: 18, minute: 25));

      _morningDhikrTime = TimeOfDay(
        hour: dhikrSettings['morningHour'] ?? morningDefault.hour,
        minute: dhikrSettings['morningMinute'] ?? morningDefault.minute,
      );
      _eveningDhikrTime = TimeOfDay(
        hour: dhikrSettings['eveningHour'] ?? eveningDefault.hour,
        minute: dhikrSettings['eveningMinute'] ?? eveningDefault.minute,
      );

      for (final prayer in PrayerName.values) {
        final key = prayer.name;
        final savedHour = prayerSettings['${key}_hour'];
        final savedMinute = prayerSettings['${key}_minute'];
        if (savedHour != null && savedMinute != null) {
          _prayerReminderTimes[prayer] =
              TimeOfDay(hour: savedHour, minute: savedMinute);
        } else {
          _prayerReminderTimes[prayer] =
              _calcDefaultPrayerTime(prayer, prayerTimes);
        }
      }

      _arePrayerRemindersEnabled = PrayerName.values.any(
        (p) => prayerSettings['${p.name}_enabled'] == true,
      );

      _customReminders = customReminders;

      // Default times for summary
      _defaultFajrTime = _calcTime(prayerTimes, 'fajr', 5,
          fallback: const TimeOfDay(hour: 5, minute: 35));
      _defaultZuhrTime = _calcTime(prayerTimes, 'dhuhr', 60,
          fallback: const TimeOfDay(hour: 14, minute: 30));
      _defaultAsrTime = _calcTime(prayerTimes, 'asr', 15,
          fallback: const TimeOfDay(hour: 16, minute: 30));
      _defaultMaghribTime = _calcTime(prayerTimes, 'maghrib', 10,
          fallback: const TimeOfDay(hour: 18, minute: 35));
      _defaultIshaTime = _calcTime(prayerTimes, 'isha', 30,
          fallback: const TimeOfDay(hour: 21, minute: 30));
      _defaultMorningDhikrTime = _calcTime(prayerTimes, 'fajr', 30,
          fallback: const TimeOfDay(hour: 6, minute: 30));
      _defaultEveningDhikrTime = _calcTime(prayerTimes, 'maghrib', 30,
          fallback: const TimeOfDay(hour: 18, minute: 30));

      _isLoading = false;
    });

    await _scheduleAllReminders();
  }

  TimeOfDay _calcTime(
    Map<String, DateTime>? prayerTimes,
    String key,
    int offsetMinutes, {
    required TimeOfDay fallback,
  }) {
    if (prayerTimes == null) return fallback;
    final dt = prayerTimes[key];
    if (dt == null) return fallback;
    final total = dt.hour * 60 + dt.minute + offsetMinutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  TimeOfDay _calcDefaultPrayerTime(
      PrayerName prayer, Map<String, DateTime>? prayerTimes) {
    const offsets = {
      PrayerName.fajr: 30,
      PrayerName.dhuhr: 60,
      PrayerName.asr: 15,
      PrayerName.maghrib: 10,
      PrayerName.isha: 30,
    };
    const fallbacks = {
      PrayerName.fajr: TimeOfDay(hour: 6, minute: 30),
      PrayerName.dhuhr: TimeOfDay(hour: 13, minute: 30),
      PrayerName.asr: TimeOfDay(hour: 16, minute: 15),
      PrayerName.maghrib: TimeOfDay(hour: 18, minute: 10),
      PrayerName.isha: TimeOfDay(hour: 20, minute: 30),
    };
    return _calcTime(prayerTimes, prayer.name, offsets[prayer]!,
        fallback: fallbacks[prayer]!);
  }

  Future<void> _scheduleAllReminders() async {
    await DailyReminderService.scheduleDefaultDailyAmalReminder();

    if (_isDailyReminderEnabled) {
      await DailyReminderService.scheduleDailyReminder(
        hour: _dailyReminderTime.hour,
        minute: _dailyReminderTime.minute,
      );
    } else {
      await DailyReminderService.cancelDailyReminder();
    }

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

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickTime(
      TimeOfDay current, ValueChanged<TimeOfDay> onPicked) async {
    final picked =
        await DigitalTimePicker.show(context: context, initialTime: current);
    if (picked != null) {
      onPicked(picked);
      await _scheduleAllReminders();
    }
  }

  // ── Today's summary helpers ──────────────────────────────────────────────

  List<_ReminderItem> _buildTodayItems() {
    final now = DateTime.now();
    final items = <_ReminderItem>[];

    void add(
      String id,
      String title,
      TimeOfDay? t, {
      bool isDefault = false,
      bool isCustom = false,
    }) {
      if (t == null) return;
      final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
      items.add(
        _ReminderItem(
          id: id,
          title: title,
          time: dt,
          isPassed: now.isAfter(dt),
          isDefault: isDefault,
          isCustom: isCustom,
        ),
      );
    }

    // Default system reminders (always on)
    add('default_fajr', 'ফজরের পর (ডিফল্ট)', _defaultFajrTime,
        isDefault: true);
    add('default_dhuhr', 'যোহরের পর (ডিফল্ট)', _defaultZuhrTime,
        isDefault: true);
    add('default_asr', 'আসরের পর (ডিফল্ট)', _defaultAsrTime, isDefault: true);
    add('default_maghrib', 'মাগরিবের পর (ডিফল্ট)', _defaultMaghribTime,
        isDefault: true);
    add('default_isha', 'ইশার পর (ডিফল্ট)', _defaultIshaTime, isDefault: true);
    add('default_morning_dhikr', 'সকালের যিকির (ডিফল্ট)',
        _defaultMorningDhikrTime,
        isDefault: true);
    add('default_evening_dhikr', 'সন্ধ্যার যিকির (ডিফল্ট)',
        _defaultEveningDhikrTime,
        isDefault: true);
    add('default_daily_amal', 'দৈনিক আমল (ডিফল্ট)', _defaultDailyAmalTime,
        isDefault: true);

    // User-toggled \"personal\" reminders
    if (_isDailyReminderEnabled) {
      add('personal_daily_amal', 'দৈনিক আমল রিমাইন্ডার', _dailyReminderTime);
    }
    if (_isMorningDhikrEnabled) {
      add('personal_morning_dhikr', 'সকালের যিকির', _morningDhikrTime);
    }
    if (_isEveningDhikrEnabled) {
      add('personal_evening_dhikr', 'সন্ধ্যার যিকির', _eveningDhikrTime);
    }
    if (_arePrayerRemindersEnabled) {
      for (final p in PrayerName.values) {
        final t = _prayerReminderTimes[p];
        if (t != null) {
          add(
            'prayer_${p.name}',
            '${CustomReminder.getPrayerBengaliName(p)} সালাত',
            t,
          );
        }
      }
    }

    final todayWeekday = now.weekday;
    for (final r in _customReminders.where((r) => r.isEnabled)) {
      if (r.repeatDays.isNotEmpty && !r.repeatDays.contains(todayWeekday)) {
        continue;
      }
      if (r.type == ReminderType.fixedTime &&
          r.fixedHour != null &&
          r.fixedMinute != null) {
        final dt = DateTime(
            now.year, now.month, now.day, r.fixedHour!, r.fixedMinute!);
        items.add(_ReminderItem(
          id: 'custom_${r.id}',
          title: r.title,
          time: dt,
          isPassed: now.isAfter(dt),
          isCustom: true,
        ));
      }
    }

    items.sort((a, b) => a.time.compareTo(b.time));
    return items;
  }

  _ReminderItem? _nextReminder() {
    final items = _buildTodayItems();
    try {
      return items.firstWhere((r) => !r.isPassed);
    } catch (_) {
      return null;
    }
  }

  // ── Quick-add preset ─────────────────────────────────────────────────────

  Future<void> _addPreset(_Preset preset) async {
    final reminder = CustomReminder(
      id: CustomReminder.generateId(),
      title: preset.title,
      description: preset.description,
      type: preset.type,
      prayer: preset.prayer,
      minutesOffset: preset.minutesOffset,
      fixedHour: preset.fixedHour,
      fixedMinute: preset.fixedMinute,
      category: preset.category,
      isOneTime: false,
    );
    await DailyReminderService.addCustomReminder(reminder);
    await _loadAllSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${preset.title}" যোগ করা হয়েছে'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPresetsSheet() {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gold = Color(0xFFD4AF37);
    final activeColor = isDark ? gold : cs.primary;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final maxHeight = MediaQuery.of(ctx).size.height * 0.80;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (fixed, not scrollable)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
            Text(
              'preset_add_quick'.tr(),
              style: TextStyle(
                color: activeColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'preset_select'.tr(),
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.55),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              // Scrollable preset list
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: _presets.map((preset) {
                    final alreadyAdded = _customReminders
                        .any((r) => r.title == preset.title);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: activeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _categoryIcon(preset.category),
                          color: activeColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        preset.title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        preset.description,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.55),
                          fontSize: 12,
                        ),
                      ),
                      trailing: alreadyAdded
                          ? const Icon(Icons.check_circle_rounded,
                              color: Colors.green, size: 22)
                          : Icon(Icons.add_circle_outline_rounded,
                              color: activeColor, size: 22),
                      onTap: alreadyAdded
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _addPreset(preset);
                            },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _categoryIcon(ReminderCategory cat) {
    switch (cat) {
      case ReminderCategory.quran:
        return Icons.menu_book_rounded;
      case ReminderCategory.dhikr:
        return Icons.favorite_rounded;
      case ReminderCategory.dua:
        return Icons.volunteer_activism_rounded;
      case ReminderCategory.general:
        return Icons.notifications_rounded;
    }
  }

  // ── Navigate to custom reminders ─────────────────────────────────────────

  Future<void> _openCustomReminders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomRemindersScreen(
          onRemindersChanged: _loadAllSettings,
        ),
      ),
    );
    await _loadAllSettings();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const gold = Color(0xFFD4AF37);
    final activeColor = isDark ? gold : cs.primary;
    final gradients = theme.extension<GradientColors>()!;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradients.appBarGradient,
            ),
            border: Border(
              bottom: BorderSide(
                color: gradients.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          'reminders'.tr(),
          style: TextStyle(
            color: activeColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add_alert_rounded, color: activeColor),
            tooltip: 'add_preset'.tr(),
            onPressed: _showPresetsSheet,
          ),
        ],
      ),
      floatingActionButton: ref.watch(mainShellTabIndexProvider) == 1
          ? FloatingActionButton.extended(
              onPressed: _openCustomReminders,
              backgroundColor: activeColor,
              foregroundColor: isDark ? Colors.black : cs.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: Text('add_reminder'.tr()),
            )
          : null,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: activeColor))
          : RefreshIndicator(
              onRefresh: _loadAllSettings,
              color: activeColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTodaySummaryCard(context, activeColor),
                    const SizedBox(height: 20),
                    _buildSectionTitle('reminder_prayer'.tr(), activeColor),
                    const SizedBox(height: 10),
                    _buildPrayerRemindersSection(context, activeColor),
                    const SizedBox(height: 20),
                    _buildSectionTitle('reminder_dhikr_amal'.tr(), activeColor),
                    const SizedBox(height: 10),
                    _buildDhikrAmalSection(context, activeColor),
                    const SizedBox(height: 20),
                    _buildSectionTitle('reminder_custom'.tr(), activeColor),
                    const SizedBox(height: 10),
                    _buildCustomRemindersSection(context, activeColor),
                    const SizedBox(height: 20),
                    _buildSectionTitle('reminder_defaults'.tr(), activeColor),
                    const SizedBox(height: 10),
                    _buildDefaultsSection(context, activeColor),
                    const SizedBox(height: 20),
                    _buildSettingsLink(context, activeColor),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  // ── Today's summary card ──────────────────────────────────────────────────

  String _localizeReminderTitle(BuildContext context, _ReminderItem item) {
    if (item.isCustom) {
      // User-created custom reminders keep their original title
      return item.title;
    }

    switch (item.id) {
      // Default system reminders
      case 'default_fajr':
        return 'reminder_default_fajr'.tr();
      case 'default_dhuhr':
        return 'reminder_default_dhuhr'.tr();
      case 'default_asr':
        return 'reminder_default_asr'.tr();
      case 'default_maghrib':
        return 'reminder_default_maghrib'.tr();
      case 'default_isha':
        return 'reminder_default_isha'.tr();
      case 'default_morning_dhikr':
        return 'reminder_default_morning_dhikr'.tr();
      case 'default_evening_dhikr':
        return 'reminder_default_evening_dhikr'.tr();
      case 'default_daily_amal':
        return 'reminder_default_daily_amal'.tr();

      // Personal toggles
      case 'personal_daily_amal':
        return 'reminder_personal_daily_amal'.tr();
      case 'personal_morning_dhikr':
        return 'reminder_personal_morning_dhikr'.tr();
      case 'personal_evening_dhikr':
        return 'reminder_personal_evening_dhikr'.tr();

      // Per-prayer reminders
      case 'prayer_fajr':
        return 'reminder_prayer_fajr'.tr();
      case 'prayer_dhuhr':
        return 'reminder_prayer_dhuhr'.tr();
      case 'prayer_asr':
        return 'reminder_prayer_asr'.tr();
      case 'prayer_maghrib':
        return 'reminder_prayer_maghrib'.tr();
      case 'prayer_isha':
        return 'reminder_prayer_isha'.tr();

      default:
        // Fallback: stored title (e.g. old data)
        return item.title;
    }
  }

  String _fmtTime(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  Widget _buildTodaySummaryCard(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _buildTodayItems();
    final pendingItems = items.where((r) => !r.isPassed).toList();
    final pending = pendingItems.length;
    final total = items.length;
    final next = _nextReminder();

    String nextText;
    if (next != null) {
      final nextTitle = _localizeReminderTitle(context, next);
      nextText = '$nextTitle — ${_fmtTime(next.time)}';
    } else {
      nextText = 'reminder_all_done'.tr();
    }

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: activeColor.withOpacity(0.2)),
                ),
                child: Icon(Icons.notifications_active_rounded,
                    color: activeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'todays_reminder'.tr(),
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$total ${'reminder_total'.tr()} • $pending ${'reminder_left'.tr()}',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$pending',
                  style: TextStyle(
                    color: isDark ? Colors.black : cs.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),

          // Next reminder chip
          if (next != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeColor.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: activeColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${'reminder_next'.tr()}: $nextText',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Expand/collapse toggle
          if (pendingItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => setState(() => _showTodayDetails = !_showTodayDetails),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showTodayDetails ? 'reminder_see_less'.tr() : '${'reminder_see_all'.tr()} (${pendingItems.length})',
                      style: TextStyle(
                        color: activeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _showTodayDetails
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: activeColor,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Pending reminder list (expandable)
          if (_showTodayDetails && pendingItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activeColor.withOpacity(0.12)),
              ),
              child: Column(
                children: pendingItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final r = entry.value;
                  final isLast = idx == pendingItems.length - 1;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: r.isDefault
                                    ? Colors.green
                                    : r.isCustom
                                        ? activeColor.withOpacity(0.7)
                                        : activeColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _localizeReminderTitle(context, r),
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              _fmtTime(r.time),
                              style: TextStyle(
                                color: activeColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (r.isDefault) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'default_badge'.tr(),
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 14,
                          endIndent: 14,
                          color: activeColor.withOpacity(0.1),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Prayer reminders section ──────────────────────────────────────────────

  Widget _buildPrayerRemindersSection(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Master toggle
        buildPremiumCard(
          context: context,
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.mosque_rounded, color: activeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'reminder_prayer'.tr(),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'reminder_prayer_subtitle'.tr(),
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _arePrayerRemindersEnabled,
                onChanged: (v) async {
                  setState(() => _arePrayerRemindersEnabled = v);
                  await _scheduleAllReminders();
                },
                activeColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.3),
              ),
            ],
          ),
        ),
        if (_arePrayerRemindersEnabled) ...[
          const SizedBox(height: 8),
          ..._buildPrayerRows(context, activeColor),
        ],
      ],
    );
  }

  List<Widget> _buildPrayerRows(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;
    final isFriday = DateTime.now().weekday == DateTime.friday;

    final icons = {
      PrayerName.fajr: Icons.wb_twilight_rounded,
      PrayerName.dhuhr: Icons.wb_sunny_rounded,
      PrayerName.asr: Icons.wb_sunny_outlined,
      PrayerName.maghrib: Icons.nights_stay_rounded,
      PrayerName.isha: Icons.nights_stay_outlined,
    };
    final names = {
      PrayerName.fajr: 'fajr'.tr(),
      PrayerName.dhuhr: isFriday ? 'jumuah'.tr() : 'dhuhr'.tr(),
      PrayerName.asr: 'asr'.tr(),
      PrayerName.maghrib: 'maghrib'.tr(),
      PrayerName.isha: 'isha'.tr(),
    };

    return PrayerName.values.map((prayer) {
      final time = _prayerReminderTimes[prayer]!;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: buildPremiumCard(
          context: context,
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[prayer], color: activeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  names[prayer]!,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _pickTime(time, (picked) {
                  setState(() => _prayerReminderTimes[prayer] = picked);
                }),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: activeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: activeColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded,
                          color: activeColor, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        _formatTime(time),
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.edit_rounded,
                          color: activeColor.withOpacity(0.7), size: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ── Dhikr & Amal section ──────────────────────────────────────────────────

  Widget _buildDhikrAmalSection(BuildContext context, Color activeColor) {
    return Column(
      children: [
        _buildToggleTile(
          context: context,
          activeColor: activeColor,
          icon: Icons.wb_sunny_outlined,
          title: 'morning_dhikr'.tr(),
          subtitle: 'morning_dhikr'.tr(),
          time: _morningDhikrTime,
          isEnabled: _isMorningDhikrEnabled,
          onToggle: (v) async {
            setState(() => _isMorningDhikrEnabled = v);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _pickTime(_morningDhikrTime, (t) {
            setState(() => _morningDhikrTime = t);
          }),
        ),
        const SizedBox(height: 8),
        _buildToggleTile(
          context: context,
          activeColor: activeColor,
          icon: Icons.nights_stay_outlined,
          title: 'evening_dhikr'.tr(),
          subtitle: 'evening_dhikr'.tr(),
          time: _eveningDhikrTime,
          isEnabled: _isEveningDhikrEnabled,
          onToggle: (v) async {
            setState(() => _isEveningDhikrEnabled = v);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _pickTime(_eveningDhikrTime, (t) {
            setState(() => _eveningDhikrTime = t);
          }),
        ),
        const SizedBox(height: 8),
        _buildToggleTile(
          context: context,
          activeColor: activeColor,
          icon: Icons.star_rounded,
          title: 'daily_amal_reminder'.tr(),
          subtitle: 'daily_amal_title'.tr(),
          time: _dailyReminderTime,
          isEnabled: _isDailyReminderEnabled,
          onToggle: (v) async {
            setState(() => _isDailyReminderEnabled = v);
            await _scheduleAllReminders();
          },
          onTimeTap: () => _pickTime(_dailyReminderTime, (t) {
            setState(() => _dailyReminderTime = t);
          }),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required Color activeColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimeTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: activeColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                if (isEnabled)
                  InkWell(
                    onTap: onTimeTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              color: activeColor, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            _formatTime(time),
                            style: TextStyle(
                              color: activeColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_rounded,
                              color: activeColor.withOpacity(0.7), size: 12),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // ── Custom reminders section ──────────────────────────────────────────────

  Widget _buildCustomRemindersSection(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;

    if (_customReminders.isEmpty) {
      return buildPremiumCard(
        context: context,
        radius: 14,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.add_alert_outlined,
                color: activeColor.withOpacity(0.4), size: 40),
            const SizedBox(height: 12),
            Text(
              'custom_rem_empty'.tr(),
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.55),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _openCustomReminders,
                  icon: Icon(Icons.add_rounded, color: activeColor, size: 18),
                  label: Text(
                    'reminder_add_new'.tr(),
                    style: TextStyle(color: activeColor),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _showPresetsSheet,
                  icon: Icon(Icons.auto_awesome_rounded,
                      color: activeColor, size: 18),
                  label: Text(
                    'reminder_preset_tab'.tr(),
                    style: TextStyle(color: activeColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ..._customReminders.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildCustomReminderTile(context, r, activeColor),
            )),
        const SizedBox(height: 4),
        InkWell(
          onTap: _openCustomReminders,
          borderRadius: BorderRadius.circular(14),
          child: buildPremiumCard(
            context: context,
            radius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_accounts_rounded,
                color: activeColor, size: 20),
            const SizedBox(width: 8),
                  Flexible(
                child: Text(
                  'manage_reminders'.tr(),
                style: TextStyle(
                  color: activeColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: activeColor, size: 20),
          ],
        ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomReminderTile(
      BuildContext context, CustomReminder r, Color activeColor) {
    final cs = Theme.of(context).colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_categoryIcon(r.category), color: activeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r.title,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (r.isOneTime)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.withOpacity(0.3)),
                        ),
                                child: Text(
                                  'one_time_badge'.tr(),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  r.getTimeDisplayString(),
                  style: TextStyle(
                    color: activeColor.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: r.isEnabled,
            onChanged: (v) async {
              await DailyReminderService.updateCustomReminder(
                  r.copyWith(isEnabled: v));
              await _loadAllSettings();
            },
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  // ── Defaults section ──────────────────────────────────────────────────────

  Widget _buildDefaultsSection(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;

    final defaults = [
      (Icons.wb_twilight_rounded, 'reminder_default_fajr_label'.tr(), _defaultFajrTime),
      (
        Icons.wb_sunny_rounded,
        'reminder_default_dhuhr_label'.tr(),
        _defaultZuhrTime
      ),
      (Icons.wb_sunny_outlined, 'reminder_default_asr_label'.tr(), _defaultAsrTime),
      (Icons.nights_stay_rounded, 'reminder_default_maghrib_label'.tr(), _defaultMaghribTime),
      (Icons.nights_stay_outlined, 'reminder_default_isha_label'.tr(), _defaultIshaTime),
      (Icons.wb_sunny_outlined, 'reminder_default_morning_dhikr_label'.tr(), _defaultMorningDhikrTime),
      (Icons.nights_stay_outlined, 'reminder_default_evening_dhikr_label'.tr(), _defaultEveningDhikrTime),
      (Icons.star_rounded, 'reminder_default_daily_amal_label'.tr(), _defaultDailyAmalTime),
    ];

    return Column(
      children: [
        buildPremiumCard(
          context: context,
          radius: 14,
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: activeColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'reminder_defaults_info'.tr(),
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...defaults.map((d) {
                final icon = d.$1;
                final label = d.$2;
                final time = d.$3;
                if (time == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(icon, color: activeColor.withOpacity(0.7), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.75),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.green.withOpacity(0.25)),
                        ),
                        child: Text(
                          _formatTime(time),
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Settings link ─────────────────────────────────────────────────────────

  Widget _buildSettingsLink(BuildContext context, Color activeColor) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailyReminderScreen()),
      ),
      borderRadius: BorderRadius.circular(14),
      child: buildPremiumCard(
        context: context,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.settings_rounded, color: activeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      'reminder_settings'.tr(),
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'reminder_settings_subtitle'.tr(),
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurface.withOpacity(0.4), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data class
// ─────────────────────────────────────────────────────────────────────────────
class _ReminderItem {
  final String id;
  final String title;
  final DateTime time;
  final bool isPassed;
  final bool isCustom;
  final bool isDefault;

  _ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.isPassed,
    this.isCustom = false,
    this.isDefault = false,
  });
}

// Keep ReminderItem public for backward compatibility
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
