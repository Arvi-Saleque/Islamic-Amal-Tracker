import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/custom_reminder.dart';
import '../../../services/daily_reminder_service.dart';
import '../../providers/prayer_times_provider.dart';
import '../../widgets/digital_time_picker.dart';
import 'custom_reminders_screen.dart';
import 'daily_reminder_screen.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _isLoading = true;

  // Daily Amal Reminder
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 22, minute: 0);

  // Dhikr Reminders
  TimeOfDay _morningDhikrTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _eveningDhikrTime = const TimeOfDay(hour: 18, minute: 0);

  // Prayer Reminders - map of prayer name to custom reminder time
  Map<PrayerName, TimeOfDay> _prayerReminderTimes = {};

  // Custom Reminders
  List<CustomReminder> _customReminders = [];

  @override
  void initState() {
    super.initState();
    _loadAllSettings();
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

      _morningDhikrTime = TimeOfDay(
        hour: dhikrSettings['morningHour'] ?? 6,
        minute: dhikrSettings['morningMinute'] ?? 0,
      );
      _eveningDhikrTime = TimeOfDay(
        hour: dhikrSettings['eveningHour'] ?? 18,
        minute: dhikrSettings['eveningMinute'] ?? 0,
      );

      // Initialize prayer reminder times - use saved custom times or prayer times
      for (final prayer in PrayerName.values) {
        final key = prayer.name;
        final savedHour = prayerSettings['${key}_hour'];
        final savedMinute = prayerSettings['${key}_minute'];

        if (savedHour != null && savedMinute != null) {
          _prayerReminderTimes[prayer] =
              TimeOfDay(hour: savedHour, minute: savedMinute);
        } else if (prayerTimes[key] != null) {
          // Default to prayer time
          _prayerReminderTimes[prayer] = TimeOfDay(
            hour: prayerTimes[key]!.hour,
            minute: prayerTimes[key]!.minute,
          );
        } else {
          // Fallback defaults
          _prayerReminderTimes[prayer] = _getDefaultPrayerTime(prayer);
        }
      }

      _customReminders = customReminders;
      _isLoading = false;
    });

    // Schedule all reminders (always enabled)
    await _scheduleAllReminders();
  }

  TimeOfDay _getDefaultPrayerTime(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return const TimeOfDay(hour: 5, minute: 0);
      case PrayerName.dhuhr:
        return const TimeOfDay(hour: 12, minute: 30);
      case PrayerName.asr:
        return const TimeOfDay(hour: 15, minute: 30);
      case PrayerName.maghrib:
        return const TimeOfDay(hour: 18, minute: 0);
      case PrayerName.isha:
        return const TimeOfDay(hour: 20, minute: 0);
    }
  }

  Future<void> _scheduleAllReminders() async {
    // Schedule daily reminder
    await DailyReminderService.scheduleDailyReminder(
      hour: _dailyReminderTime.hour,
      minute: _dailyReminderTime.minute,
    );

    // Schedule dhikr reminders
    await DailyReminderService.scheduleMorningDhikrReminder(
      hour: _morningDhikrTime.hour,
      minute: _morningDhikrTime.minute,
    );
    await DailyReminderService.scheduleEveningDhikrReminder(
      hour: _eveningDhikrTime.hour,
      minute: _eveningDhikrTime.minute,
    );

    // Schedule prayer reminders
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
  }

  void _showTodaysRemindersPopup() {
    final prayerTimes = ref.read(prayerTimesProvider).prayerTimes;

    showDialog(
      context: context,
      builder: (context) => TodaysRemindersDialog(
        dailyReminderTime: _dailyReminderTime,
        morningDhikrTime: _morningDhikrTime,
        eveningDhikrTime: _eveningDhikrTime,
        prayerReminderTimes: _prayerReminderTimes,
        customReminders: _customReminders,
        onNavigateToCustomReminders: () {
          Navigator.pop(context);
          _navigateToCustomReminders();
        },
      ),
    );
  }

  void _navigateToCustomReminders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomRemindersScreen(
          onRemindersChanged: _loadAllSettings,
        ),
      ),
    );
  }

  Future<void> _selectTime(String type, TimeOfDay currentTime) async {
    final TimeOfDay? picked = await DigitalTimePicker.show(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      switch (type) {
        case 'daily':
          setState(() => _dailyReminderTime = picked);
          await DailyReminderService.scheduleDailyReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
          break;
        case 'morningDhikr':
          setState(() => _morningDhikrTime = picked);
          await DailyReminderService.scheduleMorningDhikrReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
          break;
        case 'eveningDhikr':
          setState(() => _eveningDhikrTime = picked);
          await DailyReminderService.scheduleEveningDhikrReminder(
            hour: picked.hour,
            minute: picked.minute,
          );
          break;
      }
    }
  }

  Future<void> _selectPrayerTime(
      PrayerName prayer, TimeOfDay currentTime) async {
    final TimeOfDay? picked = await DigitalTimePicker.show(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      setState(() {
        _prayerReminderTimes[prayer] = picked;
      });
      await DailyReminderService.schedulePrayerReminderAtTime(
        prayer: prayer,
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final prayerTimesState = ref.watch(prayerTimesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'রিমাইন্ডারস',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active,
                color: Color(0xFFD4AF37)),
            onPressed: _showTodaysRemindersPopup,
            tooltip: 'আজকের রিমাইন্ডারস',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFD4AF37)),
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
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : RefreshIndicator(
              onRefresh: _loadAllSettings,
              color: const Color(0xFFD4AF37),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info card
                    _buildInfoCard(),

                    const SizedBox(height: 20),

                    // Daily Amal Reminder Section
                    _buildSectionHeader('দৈনিক আমল রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    _buildReminderTile(
                      icon: Icons.wb_sunny,
                      title: 'দৈনিক আমল রিমাইন্ডার',
                      subtitle: 'রিমাইন্ডার সময়',
                      time: _dailyReminderTime,
                      onTimeTap: () => _selectTime('daily', _dailyReminderTime),
                    ),

                    const SizedBox(height: 24),

                    // Dhikr Reminders Section
                    _buildSectionHeader('যিকির রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    _buildReminderTile(
                      icon: Icons.wb_sunny_outlined,
                      title: 'সকালের যিকির',
                      subtitle: 'রিমাইন্ডার সময়',
                      time: _morningDhikrTime,
                      onTimeTap: () =>
                          _selectTime('morningDhikr', _morningDhikrTime),
                    ),
                    const SizedBox(height: 8),
                    _buildReminderTile(
                      icon: Icons.nights_stay_outlined,
                      title: 'সন্ধ্যার যিকির',
                      subtitle: 'রিমাইন্ডার সময়',
                      time: _eveningDhikrTime,
                      onTimeTap: () =>
                          _selectTime('eveningDhikr', _eveningDhikrTime),
                    ),

                    const SizedBox(height: 24),

                    // Prayer Reminders Section
                    _buildSectionHeader('নামাজের রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    ..._buildPrayerReminderTiles(),

                    const SizedBox(height: 24),

                    // Custom Reminders Section
                    _buildSectionHeader('কাস্টম রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    _buildCustomReminderCard(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'প্রতিদিন নির্দিষ্ট সময়ে আমল করার রিমাইন্ডার পাবেন',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 14,
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
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReminderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required TimeOfDay time,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: onTimeTap,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(time),
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit,
                        size: 14,
                        color: Color(0xFFD4AF37),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
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

    final prayerNames = {
      PrayerName.fajr: 'ফজরের নামাজ',
      PrayerName.dhuhr: 'যোহরের নামাজ',
      PrayerName.asr: 'আসরের নামাজ',
      PrayerName.maghrib: 'মাগরিবের নামাজ',
      PrayerName.isha: 'এশার নামাজ',
    };

    return PrayerName.values.map((prayer) {
      final reminderTime =
          _prayerReminderTimes[prayer] ?? _getDefaultPrayerTime(prayer);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prayerIcons[prayer],
                  color: const Color(0xFFD4AF37),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _selectPrayerTime(prayer, reminderTime),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFFD4AF37),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(reminderTime),
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFFD4AF37),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildCustomReminderCard() {
    return GestureDetector(
      onTap: _navigateToCustomReminders,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_alert,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'কাস্টম রিমাইন্ডার',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _customReminders.isEmpty
                        ? 'কোনো কাস্টম রিমাইন্ডার নেই'
                        : '${_customReminders.where((r) => r.isEnabled).length} টি সক্রিয় রিমাইন্ডার',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD4AF37),
            ),
          ],
        ),
      ),
    );
  }
}

// Today's Reminders Popup Dialog
class TodaysRemindersDialog extends StatelessWidget {
  final TimeOfDay dailyReminderTime;
  final TimeOfDay morningDhikrTime;
  final TimeOfDay eveningDhikrTime;
  final Map<PrayerName, TimeOfDay> prayerReminderTimes;
  final List<CustomReminder> customReminders;
  final VoidCallback onNavigateToCustomReminders;

  const TodaysRemindersDialog({
    super.key,
    required this.dailyReminderTime,
    required this.morningDhikrTime,
    required this.eveningDhikrTime,
    required this.prayerReminderTimes,
    required this.customReminders,
    required this.onNavigateToCustomReminders,
  });

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDateTime(DateTime time) {
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todaysReminders = <ReminderItem>[];

    // Add daily reminder (always enabled)
    final dailyReminderDateTime = DateTime(now.year, now.month, now.day,
        dailyReminderTime.hour, dailyReminderTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'দৈনিক আমল রিমাইন্ডার',
      time: dailyReminderDateTime,
      isPassed: now.isAfter(dailyReminderDateTime),
    ));

    // Add dhikr reminders (always enabled)
    final morningDhikrDateTime = DateTime(now.year, now.month, now.day,
        morningDhikrTime.hour, morningDhikrTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'সকালের যিকির',
      time: morningDhikrDateTime,
      isPassed: now.isAfter(morningDhikrDateTime),
    ));

    final eveningDhikrDateTime = DateTime(now.year, now.month, now.day,
        eveningDhikrTime.hour, eveningDhikrTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'সন্ধ্যার যিকির',
      time: eveningDhikrDateTime,
      isPassed: now.isAfter(eveningDhikrDateTime),
    ));

    // Add prayer reminders (always enabled)
    for (final prayer in PrayerName.values) {
      final reminderTime = prayerReminderTimes[prayer];
      if (reminderTime != null) {
        final prayerReminderDateTime = DateTime(now.year, now.month, now.day,
            reminderTime.hour, reminderTime.minute);
        todaysReminders.add(ReminderItem(
          title: '${CustomReminder.getPrayerBengaliName(prayer)} নামাজ',
          time: prayerReminderDateTime,
          isPassed: now.isAfter(prayerReminderDateTime),
        ));
      }
    }

    // Add custom reminders
    for (final reminder in customReminders.where((r) => r.isEnabled)) {
      DateTime? reminderTime;
      if (reminder.type == ReminderType.fixedTime &&
          reminder.fixedHour != null &&
          reminder.fixedMinute != null) {
        reminderTime = DateTime(now.year, now.month, now.day,
            reminder.fixedHour!, reminder.fixedMinute!);
      } else if (reminder.prayer != null) {
        final prayerTime = prayerReminderTimes[reminder.prayer!];
        if (prayerTime != null) {
          final prayerDateTime = DateTime(
              now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);
          reminderTime =
              prayerDateTime.add(Duration(minutes: reminder.minutesOffset));
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

    // Sort by time
    todaysReminders.sort((a, b) => a.time.compareTo(b.time));

    // Separate pending and passed
    final pendingReminders = todaysReminders.where((r) => !r.isPassed).toList();
    final passedReminders = todaysReminders.where((r) => r.isPassed).toList();

    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'আজকের রিমাইন্ডারস',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pending reminders
            if (pendingReminders.isNotEmpty) ...[
              const Text(
                'বাকি রিমাইন্ডার',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pendingReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = pendingReminders[index];
                    return _buildReminderRow(reminder, false);
                  },
                ),
              ),
            ],

            if (passedReminders.isNotEmpty && pendingReminders.isNotEmpty)
              const Divider(color: Color(0xFF2A2A2A), height: 24),

            // Passed reminders (collapsed)
            if (passedReminders.isNotEmpty) ...[
              Text(
                'সম্পন্ন (${passedReminders.length})',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],

            if (todaysReminders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'আজকের জন্য কোনো রিমাইন্ডার নেই',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onNavigateToCustomReminders,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('কাস্টম রিমাইন্ডার'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderRow(ReminderItem reminder, bool isPassed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPassed ? Colors.grey : const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reminder.title,
              style: TextStyle(
                color: isPassed ? Colors.grey : Colors.white,
                fontSize: 14,
                decoration: isPassed ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            _formatDateTime(reminder.time),
            style: TextStyle(
              color: isPassed ? Colors.grey : const Color(0xFFD4AF37),
              fontSize: 13,
              fontWeight: FontWeight.w600,
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

  ReminderItem({
    required this.title,
    required this.time,
    required this.isPassed,
    this.isCustom = false,
  });
}
