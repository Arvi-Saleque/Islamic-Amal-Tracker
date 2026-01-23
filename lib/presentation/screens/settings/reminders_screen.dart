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
      _isLoading = false;
    });

    // Schedule all reminders (always enabled)
    await _scheduleAllReminders();
  }

  /// Get default prayer reminder offset in minutes (after prayer starts)
  int _getDefaultPrayerOffset(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return 30; // ফজর: ওয়াক্ত শুরুর ৩০ মিনিট পর
      case PrayerName.dhuhr:
        return 60; // যোহর: ওয়াক্ত শুরুর ১ ঘন্টা পর
      case PrayerName.asr:
        return 15; // আসর: ওয়াক্ত শুরুর ১৫ মিনিট পর
      case PrayerName.maghrib:
        return 10; // মাগরিব: ওয়াক্ত শুরুর ১০ মিনিট পর
      case PrayerName.isha:
        return 30; // ইশা: ওয়াক্ত শুরুর ৩০ মিনিট পর
    }
  }

  /// Calculate default prayer reminder time based on prayer time + offset
  TimeOfDay _calculateDefaultPrayerReminderTime(
      PrayerName prayer, Map<String, DateTime> prayerTimes) {
    final prayerTime = prayerTimes[prayer.name];
    if (prayerTime == null) {
      return _getStaticDefaultPrayerTime(prayer);
    }

    final offset = _getDefaultPrayerOffset(prayer);
    final reminderTime = prayerTime.add(Duration(minutes: offset));
    return TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute);
  }

  /// Static fallback default times (used when prayer times not available)
  TimeOfDay _getStaticDefaultPrayerTime(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return const TimeOfDay(hour: 5, minute: 30);
      case PrayerName.dhuhr:
        return const TimeOfDay(hour: 13, minute: 30);
      case PrayerName.asr:
        return const TimeOfDay(hour: 16, minute: 15);
      case PrayerName.maghrib:
        return const TimeOfDay(hour: 18, minute: 10);
      case PrayerName.isha:
        return const TimeOfDay(hour: 19, minute: 30);
    }
  }

  /// Calculate morning dhikr default time (Fajr + 1 hour)
  TimeOfDay _calculateMorningDhikrDefault(Map<String, DateTime> prayerTimes) {
    final fajr = prayerTimes['fajr'];
    if (fajr == null) return const TimeOfDay(hour: 6, minute: 30);
    final dhikrTime = fajr.add(const Duration(hours: 1));
    return TimeOfDay(hour: dhikrTime.hour, minute: dhikrTime.minute);
  }

  /// Calculate evening dhikr default time (Maghrib + 25 minutes)
  TimeOfDay _calculateEveningDhikrDefault(Map<String, DateTime> prayerTimes) {
    final maghrib = prayerTimes['maghrib'];
    if (maghrib == null) return const TimeOfDay(hour: 18, minute: 25);
    final dhikrTime = maghrib.add(const Duration(minutes: 25));
    return TimeOfDay(hour: dhikrTime.hour, minute: dhikrTime.minute);
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
        actualPrayerTimes: prayerTimes,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
          _prayerReminderTimes[prayer] ?? _getStaticDefaultPrayerTime(prayer);

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
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
class TodaysRemindersDialog extends StatefulWidget {
  final TimeOfDay dailyReminderTime;
  final TimeOfDay morningDhikrTime;
  final TimeOfDay eveningDhikrTime;
  final Map<PrayerName, TimeOfDay> prayerReminderTimes;
  final List<CustomReminder> customReminders;
  final VoidCallback onNavigateToCustomReminders;
  final Map<String, DateTime> actualPrayerTimes;

  const TodaysRemindersDialog({
    super.key,
    required this.dailyReminderTime,
    required this.morningDhikrTime,
    required this.eveningDhikrTime,
    required this.prayerReminderTimes,
    required this.customReminders,
    required this.onNavigateToCustomReminders,
    required this.actualPrayerTimes,
  });

  @override
  State<TodaysRemindersDialog> createState() => _TodaysRemindersDialogState();
}

class _TodaysRemindersDialogState extends State<TodaysRemindersDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'রিমাইন্ডার সময়সূচী',
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
            const SizedBox(height: 12),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                labelStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'ডিফল্ট নিয়ম'),
                  Tab(text: 'আজকের সময়'),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tab Content
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDefaultRulesTab(),
                  _buildTodaysRemindersTab(),
                ],
              ),
            ),

            // Bottom button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: widget.onNavigateToCustomReminders,
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
      ),
    );
  }

  Widget _buildDefaultRulesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRuleSection(
            'সালাত রিমাইন্ডার',
            [
              _buildRuleItem('ফজর', 'ওয়াক্ত শুরু + ৩০ মিনিট'),
              _buildRuleItem('যোহর', 'ওয়াক্ত শুরু + ৬০ মিনিট'),
              _buildRuleItem('আসর', 'ওয়াক্ত শুরু + ১৫ মিনিট'),
              _buildRuleItem('মাগরিব', 'ওয়াক্ত শুরু + ১০ মিনিট'),
              _buildRuleItem('ইশা', 'ওয়াক্ত শুরু + ৩০ মিনিট'),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            'যিকির রিমাইন্ডার',
            [
              _buildRuleItem('সকালের যিকির', 'ফজর + ৬০ মিনিট'),
              _buildRuleItem('সন্ধ্যার যিকির', 'মাগরিব + ২৫ মিনিট'),
            ],
          ),
          const SizedBox(height: 16),
          _buildRuleSection(
            'দৈনিক আমল রিমাইন্ডার',
            [
              _buildRuleItem('আমল সম্পন্ন করুন', 'রাত ১০:০০ PM'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'সময় পরিবর্তন করতে রিমাইন্ডার সেকশনে গিয়ে সময় এডিট করুন',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String name, String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          Text(
            rule,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysRemindersTab() {
    final now = DateTime.now();
    final todaysReminders = <ReminderItem>[];

    // Add daily reminder (always enabled)
    final dailyReminderDateTime = DateTime(now.year, now.month, now.day,
        widget.dailyReminderTime.hour, widget.dailyReminderTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'দৈনিক আমল রিমাইন্ডার',
      time: dailyReminderDateTime,
      isPassed: now.isAfter(dailyReminderDateTime),
    ));

    // Add dhikr reminders (always enabled)
    final morningDhikrDateTime = DateTime(now.year, now.month, now.day,
        widget.morningDhikrTime.hour, widget.morningDhikrTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'সকালের যিকির',
      time: morningDhikrDateTime,
      isPassed: now.isAfter(morningDhikrDateTime),
    ));

    final eveningDhikrDateTime = DateTime(now.year, now.month, now.day,
        widget.eveningDhikrTime.hour, widget.eveningDhikrTime.minute);
    todaysReminders.add(ReminderItem(
      title: 'সন্ধ্যার যিকির',
      time: eveningDhikrDateTime,
      isPassed: now.isAfter(eveningDhikrDateTime),
    ));

    // Add prayer reminders (always enabled)
    for (final prayer in PrayerName.values) {
      final reminderTime = widget.prayerReminderTimes[prayer];
      if (reminderTime != null) {
        final prayerReminderDateTime = DateTime(now.year, now.month, now.day,
            reminderTime.hour, reminderTime.minute);
        todaysReminders.add(ReminderItem(
          title: '${CustomReminder.getPrayerBengaliName(prayer)} সালাত',
          time: prayerReminderDateTime,
          isPassed: now.isAfter(prayerReminderDateTime),
        ));
      }
    }

    // Add custom reminders for today
    final todayWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    for (final reminder in widget.customReminders.where((r) => r.isEnabled)) {
      // Check if reminder is for today
      if (reminder.repeatDays.isNotEmpty &&
          !reminder.repeatDays.contains(todayWeekday)) {
        continue;
      }

      DateTime? reminderTime;
      if (reminder.type == ReminderType.fixedTime &&
          reminder.fixedHour != null &&
          reminder.fixedMinute != null) {
        reminderTime = DateTime(now.year, now.month, now.day,
            reminder.fixedHour!, reminder.fixedMinute!);
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

    // Sort by time
    todaysReminders.sort((a, b) => a.time.compareTo(b.time));

    // Separate pending and passed
    final pendingReminders = todaysReminders.where((r) => !r.isPassed).toList();
    final passedReminders = todaysReminders.where((r) => r.isPassed).toList();

    if (todaysReminders.isEmpty) {
      return const Center(
        child: Text(
          'আজকের জন্য কোনো রিমাইন্ডার নেই',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            ...pendingReminders
                .map((reminder) => _buildReminderRow(reminder, false)),
          ],

          if (passedReminders.isNotEmpty && pendingReminders.isNotEmpty)
            const Divider(color: Color(0xFF2A2A2A), height: 24),

          // Passed reminders
          if (passedReminders.isNotEmpty) ...[
            Text(
              'সম্পন্ন (${passedReminders.length})',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...passedReminders
                .map((reminder) => _buildReminderRow(reminder, true)),
          ],
        ],
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
            child: Row(
              children: [
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
                if (reminder.isCustom)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'কাস্টম',
                      style: TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
