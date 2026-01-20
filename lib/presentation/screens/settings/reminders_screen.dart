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
  bool _isDailyReminderEnabled = false;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 22, minute: 0);
  
  // Dhikr Reminders
  bool _isMorningDhikrEnabled = false;
  TimeOfDay _morningDhikrTime = const TimeOfDay(hour: 6, minute: 0);
  bool _isEveningDhikrEnabled = false;
  TimeOfDay _eveningDhikrTime = const TimeOfDay(hour: 18, minute: 0);
  
  // Prayer Reminders - map of prayer name to settings
  Map<PrayerName, PrayerReminderSettings> _prayerReminders = {};
  
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
    final prayerSettings = await DailyReminderService.getPrayerReminderSettings();
    
    // Load custom reminders
    final customReminders = await DailyReminderService.getCustomReminders();
    
    setState(() {
      _isDailyReminderEnabled = dailySettings['enabled'] ?? false;
      _dailyReminderTime = TimeOfDay(
        hour: dailySettings['hour'] ?? 22,
        minute: dailySettings['minute'] ?? 0,
      );
      
      _isMorningDhikrEnabled = dhikrSettings['morningEnabled'] ?? false;
      _morningDhikrTime = TimeOfDay(
        hour: dhikrSettings['morningHour'] ?? 6,
        minute: dhikrSettings['morningMinute'] ?? 0,
      );
      _isEveningDhikrEnabled = dhikrSettings['eveningEnabled'] ?? false;
      _eveningDhikrTime = TimeOfDay(
        hour: dhikrSettings['eveningHour'] ?? 18,
        minute: dhikrSettings['eveningMinute'] ?? 0,
      );
      
      // Initialize prayer reminders
      for (final prayer in PrayerName.values) {
        final key = prayer.name;
        _prayerReminders[prayer] = PrayerReminderSettings(
          isEnabled: prayerSettings['${key}_enabled'] ?? false,
          minutesBefore: prayerSettings['${key}_minutesBefore'] ?? 10,
        );
      }
      
      _customReminders = customReminders;
      _isLoading = false;
    });
  }

  void _showTodaysRemindersPopup() {
    final prayerTimes = ref.read(prayerTimesProvider).prayerTimes;
    
    showDialog(
      context: context,
      builder: (context) => TodaysRemindersDialog(
        dailyReminderEnabled: _isDailyReminderEnabled,
        dailyReminderTime: _dailyReminderTime,
        morningDhikrEnabled: _isMorningDhikrEnabled,
        morningDhikrTime: _morningDhikrTime,
        eveningDhikrEnabled: _isEveningDhikrEnabled,
        eveningDhikrTime: _eveningDhikrTime,
        prayerReminders: _prayerReminders,
        prayerTimes: prayerTimes,
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

  Future<void> _toggleDailyReminder(bool value) async {
    setState(() => _isDailyReminderEnabled = value);
    
    if (value) {
      await DailyReminderService.scheduleDailyReminder(
        hour: _dailyReminderTime.hour,
        minute: _dailyReminderTime.minute,
      );
    } else {
      await DailyReminderService.cancelDailyReminder();
    }
    await _loadAllSettings();
  }

  Future<void> _toggleMorningDhikr(bool value) async {
    setState(() => _isMorningDhikrEnabled = value);
    
    if (value) {
      await DailyReminderService.scheduleMorningDhikrReminder(
        hour: _morningDhikrTime.hour,
        minute: _morningDhikrTime.minute,
      );
    } else {
      await DailyReminderService.cancelMorningDhikrReminder();
    }
    await _loadAllSettings();
  }

  Future<void> _toggleEveningDhikr(bool value) async {
    setState(() => _isEveningDhikrEnabled = value);
    
    if (value) {
      await DailyReminderService.scheduleEveningDhikrReminder(
        hour: _eveningDhikrTime.hour,
        minute: _eveningDhikrTime.minute,
      );
    } else {
      await DailyReminderService.cancelEveningDhikrReminder();
    }
    await _loadAllSettings();
  }

  Future<void> _togglePrayerReminder(PrayerName prayer, bool value) async {
    final current = _prayerReminders[prayer] ?? PrayerReminderSettings();
    setState(() {
      _prayerReminders[prayer] = current.copyWith(isEnabled: value);
    });
    
    final prayerTimes = ref.read(prayerTimesProvider).prayerTimes;
    final prayerTime = prayerTimes[prayer.name];
    
    if (value && prayerTime != null) {
      await DailyReminderService.schedulePrayerReminder(
        prayer: prayer,
        prayerTime: prayerTime,
        minutesBefore: current.minutesBefore,
      );
    } else {
      await DailyReminderService.cancelPrayerReminder(prayer);
    }
    await _loadAllSettings();
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
          if (_isDailyReminderEnabled) {
            await DailyReminderService.scheduleDailyReminder(
              hour: picked.hour,
              minute: picked.minute,
            );
          }
          break;
        case 'morningDhikr':
          setState(() => _morningDhikrTime = picked);
          if (_isMorningDhikrEnabled) {
            await DailyReminderService.scheduleMorningDhikrReminder(
              hour: picked.hour,
              minute: picked.minute,
            );
          }
          break;
        case 'eveningDhikr':
          setState(() => _eveningDhikrTime = picked);
          if (_isEveningDhikrEnabled) {
            await DailyReminderService.scheduleEveningDhikrReminder(
              hour: picked.hour,
              minute: picked.minute,
            );
          }
          break;
      }
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
            icon: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
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
                      isEnabled: _isDailyReminderEnabled,
                      onToggle: _toggleDailyReminder,
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
                      isEnabled: _isMorningDhikrEnabled,
                      onToggle: _toggleMorningDhikr,
                      onTimeTap: () => _selectTime('morningDhikr', _morningDhikrTime),
                    ),
                    const SizedBox(height: 8),
                    _buildReminderTile(
                      icon: Icons.nights_stay_outlined,
                      title: 'সন্ধ্যার যিকির',
                      subtitle: 'রিমাইন্ডার সময়',
                      time: _eveningDhikrTime,
                      isEnabled: _isEveningDhikrEnabled,
                      onToggle: _toggleEveningDhikr,
                      onTimeTap: () => _selectTime('eveningDhikr', _eveningDhikrTime),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Prayer Reminders Section
                    _buildSectionHeader('নামাজের রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    ..._buildPrayerReminderTiles(prayerTimesState),
                    
                    const SizedBox(height: 24),
                    
                    // Custom Reminders Section
                    _buildSectionHeader('কাস্টম রিমাইন্ডার'),
                    const SizedBox(height: 8),
                    _buildCustomReminderCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Permission Settings Button
                    _buildPermissionSettingsButton(),
                    
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
    required bool isEnabled,
    required Function(bool) onToggle,
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
              color: isEnabled 
                  ? const Color(0xFFD4AF37).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
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
                  onTap: isEnabled ? onTimeTap : null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(time),
                        style: TextStyle(
                          color: isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isEnabled) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onToggle,
            activeColor: const Color(0xFFD4AF37),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPrayerReminderTiles(PrayerTimesState prayerTimesState) {
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
      final settings = _prayerReminders[prayer] ?? PrayerReminderSettings();
      final prayerTime = prayerTimesState.prayerTimes[prayer.name];
      
      String timeString = '--:-- --';
      if (prayerTime != null) {
        final hour = prayerTime.hour > 12 ? prayerTime.hour - 12 : (prayerTime.hour == 0 ? 12 : prayerTime.hour);
        final minute = prayerTime.minute.toString().padLeft(2, '0');
        final period = prayerTime.hour >= 12 ? 'PM' : 'AM';
        timeString = '$hour:$minute $period';
      }

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
                  color: settings.isEnabled 
                      ? const Color(0xFFD4AF37).withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  prayerIcons[prayer],
                  color: settings.isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
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
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: settings.isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeString,
                          style: TextStyle(
                            color: settings.isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (settings.isEnabled) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.isEnabled,
                onChanged: (value) => _togglePrayerReminder(prayer, value),
                activeColor: const Color(0xFFD4AF37),
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

  Widget _buildPermissionSettingsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DailyReminderScreen(),
            ),
          );
        },
        icon: const Icon(Icons.security),
        label: const Text('নোটিফিকেশন অনুমতি সেটিংস'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// Helper class for prayer reminder settings
class PrayerReminderSettings {
  final bool isEnabled;
  final int minutesBefore;

  PrayerReminderSettings({
    this.isEnabled = false,
    this.minutesBefore = 10,
  });

  PrayerReminderSettings copyWith({
    bool? isEnabled,
    int? minutesBefore,
  }) {
    return PrayerReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      minutesBefore: minutesBefore ?? this.minutesBefore,
    );
  }
}

// Today's Reminders Popup Dialog
class TodaysRemindersDialog extends StatelessWidget {
  final bool dailyReminderEnabled;
  final TimeOfDay dailyReminderTime;
  final bool morningDhikrEnabled;
  final TimeOfDay morningDhikrTime;
  final bool eveningDhikrEnabled;
  final TimeOfDay eveningDhikrTime;
  final Map<PrayerName, PrayerReminderSettings> prayerReminders;
  final Map<String, DateTime> prayerTimes;
  final List<CustomReminder> customReminders;
  final VoidCallback onNavigateToCustomReminders;

  const TodaysRemindersDialog({
    super.key,
    required this.dailyReminderEnabled,
    required this.dailyReminderTime,
    required this.morningDhikrEnabled,
    required this.morningDhikrTime,
    required this.eveningDhikrEnabled,
    required this.eveningDhikrTime,
    required this.prayerReminders,
    required this.prayerTimes,
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
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todaysReminders = <ReminderItem>[];
    
    // Add daily reminder
    if (dailyReminderEnabled) {
      final reminderTime = DateTime(now.year, now.month, now.day, 
          dailyReminderTime.hour, dailyReminderTime.minute);
      todaysReminders.add(ReminderItem(
        title: 'দৈনিক আমল রিমাইন্ডার',
        time: reminderTime,
        isPassed: now.isAfter(reminderTime),
      ));
    }
    
    // Add dhikr reminders
    if (morningDhikrEnabled) {
      final reminderTime = DateTime(now.year, now.month, now.day, 
          morningDhikrTime.hour, morningDhikrTime.minute);
      todaysReminders.add(ReminderItem(
        title: 'সকালের যিকির',
        time: reminderTime,
        isPassed: now.isAfter(reminderTime),
      ));
    }
    if (eveningDhikrEnabled) {
      final reminderTime = DateTime(now.year, now.month, now.day, 
          eveningDhikrTime.hour, eveningDhikrTime.minute);
      todaysReminders.add(ReminderItem(
        title: 'সন্ধ্যার যিকির',
        time: reminderTime,
        isPassed: now.isAfter(reminderTime),
      ));
    }
    
    // Add prayer reminders
    for (final prayer in PrayerName.values) {
      final settings = prayerReminders[prayer];
      if (settings?.isEnabled == true) {
        final prayerTime = prayerTimes[prayer.name];
        if (prayerTime != null) {
          todaysReminders.add(ReminderItem(
            title: '${CustomReminder.getPrayerBengaliName(prayer)}ের নামাজ',
            time: prayerTime,
            isPassed: now.isAfter(prayerTime),
          ));
        }
      }
    }
    
    // Add custom reminders
    for (final reminder in customReminders.where((r) => r.isEnabled)) {
      DateTime? reminderTime;
      if (reminder.type == ReminderType.fixedTime && 
          reminder.fixedHour != null && reminder.fixedMinute != null) {
        reminderTime = DateTime(now.year, now.month, now.day, 
            reminder.fixedHour!, reminder.fixedMinute!);
      } else if (reminder.prayer != null) {
        final prayerTime = prayerTimes[reminder.prayer!.name];
        if (prayerTime != null) {
          reminderTime = prayerTime.add(Duration(minutes: reminder.minutesOffset));
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
