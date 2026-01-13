import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_settings_provider.dart';
import '../../providers/custom_reminders_provider.dart';
import '../notifications/reminders_screen.dart';
import '../../../services/notification_service.dart';

class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsProvider);
    final settings = settingsState.settings;
    final hasPermission = settingsState.hasPermission;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'রিমাইন্ডার সেটিংস',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: settingsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // How it works card
                  _buildHowItWorksCard(),

                  // Permission Required Card (if no permission)
                  if (!hasPermission) _buildPermissionRequiredCard(context, ref),

                  // Prayer Notifications Section
                  _buildSectionHeader('নামাজের রিমাইন্ডার 🕌'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        title: 'নামাজের রিমাইন্ডার',
                        subtitle: 'ওয়াক্ত শেষ হওয়ার আগে নোটিফিকেশন পান',
                        value: settings.prayerNotificationsEnabled,
                        enabled: hasPermission,
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .togglePrayerNotifications(value);
                        },
                      ),
                      if (settings.prayerNotificationsEnabled && hasPermission) ...[
                        const Divider(color: Color(0xFF2A2A2A)),
                        _buildMinuteSelector(
                          title: 'ওয়াক্ত শেষের আগে',
                          value: settings.prayerReminderMinutesBefore,
                          onChanged: (value) {
                            ref
                                .read(notificationSettingsProvider.notifier)
                                .setPrayerReminderMinutes(value);
                          },
                        ),
                        const Divider(color: Color(0xFF2A2A2A)),
                        _buildPrayerToggle(
                          'ফজর',
                          settings.fajrEnabled,
                          (value) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleFajr(value),
                        ),
                        _buildPrayerToggle(
                          'যোহর',
                          settings.dhuhrEnabled,
                          (value) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleDhuhr(value),
                        ),
                        _buildPrayerToggle(
                          'আসর',
                          settings.asrEnabled,
                          (value) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleAsr(value),
                        ),
                        _buildPrayerToggle(
                          'মাগরিব',
                          settings.maghribEnabled,
                          (value) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleMaghrib(value),
                        ),
                        _buildPrayerToggle(
                          'এশা',
                          settings.ishaEnabled,
                          (value) => ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleIsha(value),
                        ),
                      ],
                    ],
                  ),

                  // Dhikr Notifications Section
                  _buildSectionHeader('যিকির রিমাইন্ডার 💛'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        title: 'সকালের যিকির',
                        subtitle: 'সময়: ${settings.morningDhikrTime}',
                        value: settings.morningDhikrEnabled,
                        enabled: hasPermission,
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleMorningDhikr(value);
                        },
                        onTap: settings.morningDhikrEnabled && hasPermission
                            ? () => _showTimePicker(
                                  context,
                                  ref,
                                  settings.morningDhikrHour,
                                  settings.morningDhikrMinute,
                                  (hour, minute) {
                                    ref
                                        .read(notificationSettingsProvider
                                            .notifier)
                                        .setMorningDhikrTime(hour, minute);
                                  },
                                )
                            : null,
                      ),
                      const Divider(color: Color(0xFF2A2A2A)),
                      _buildSwitchTile(
                        title: 'সন্ধ্যার যিকির',
                        subtitle: 'সময়: ${settings.eveningDhikrTime}',
                        value: settings.eveningDhikrEnabled,
                        enabled: hasPermission,
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleEveningDhikr(value);
                        },
                        onTap: settings.eveningDhikrEnabled && hasPermission
                            ? () => _showTimePicker(
                                  context,
                                  ref,
                                  settings.eveningDhikrHour,
                                  settings.eveningDhikrMinute,
                                  (hour, minute) {
                                    ref
                                        .read(notificationSettingsProvider
                                            .notifier)
                                        .setEveningDhikrTime(hour, minute);
                                  },
                                )
                            : null,
                      ),
                    ],
                  ),

                  // Daily Amal Reminder
                  _buildSectionHeader('দৈনিক আমল রিমাইন্ডার ✨'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        title: 'দৈনিক আমল রিমাইন্ডার',
                        subtitle: 'সময়: ${settings.dailyAmalReminderTime}',
                        value: settings.dailyAmalReminderEnabled,
                        enabled: hasPermission,
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleDailyAmalReminder(value);
                        },
                        onTap: settings.dailyAmalReminderEnabled && hasPermission
                            ? () => _showTimePicker(
                                  context,
                                  ref,
                                  settings.dailyAmalReminderHour,
                                  settings.dailyAmalReminderMinute,
                                  (hour, minute) {
                                    ref
                                        .read(notificationSettingsProvider
                                            .notifier)
                                        .setDailyAmalReminderTime(hour, minute);
                                  },
                                )
                            : null,
                      ),
                    ],
                  ),

                  // Custom Reminders Section
                  _buildCustomRemindersSection(context, ref, hasPermission),

                  // Tips Section
                  _buildTipsSection(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildHowItWorksCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'রিমাইন্ডার সিস্টেম কিভাবে কাজ করে?',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildHowItWorksItem(Icons.save, 'আপনার সেটিংস ফোনে সেভ থাকে'),
          _buildHowItWorksItem(Icons.notifications_active, 'নির্ধারিত সময়ে ফোন নোটিফিকেশন দেখায়'),
        ],
      ),
    );
  }

  Widget _buildHowItWorksItem(IconData icon, String text) {
    return Padding( 
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequiredCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.2),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_off,
            color: Colors.orange,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'নোটিফিকেশন পারমিশন প্রয়োজন',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'রিমাইন্ডার পেতে নোটিফিকেশন ও অ্যালার্ম পারমিশন দিন। এটি আপনার ফোনে লোকালি সেভ থাকবে এবং অফলাইনেও কাজ করবে।',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.requestPermissions();
              ref.read(notificationSettingsProvider.notifier).requestPermission();
              
              // Check exact alarm permission
              final permissions = await notificationService.checkAllPermissions();
              if (permissions['exactAlarm'] != true && context.mounted) {
                _showExactAlarmDialog(context);
              }
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('পারমিশন দিন'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Check permission status button
          TextButton.icon(
            onPressed: () async {
              final notificationService = NotificationService();
              final permissions = await notificationService.checkAllPermissions();
              if (context.mounted) {
                _showPermissionStatusDialog(context, permissions);
              }
            },
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('পারমিশন স্ট্যাটাস দেখুন'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  void _showExactAlarmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.amber),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'অ্যালার্ম পারমিশন',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        content: const Text(
          'সঠিক সময়ে রিমাইন্ডার পেতে Settings > Apps > আমল ট্র্যাকার > Alarms & reminders থেকে অনুমতি দিন।\n\nOnePlus, Xiaomi, Samsung ফোনে Battery Optimization ও বন্ধ করুন।',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বুঝেছি', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await NotificationService().openNotificationSettings();
            },
            child: const Text('সেটিংস'),
          ),
        ],
      ),
    );
  }

  void _showPermissionStatusDialog(BuildContext context, Map<String, bool> permissions) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text(
              'পারমিশন স্ট্যাটাস',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPermissionStatusItem(
              'নোটিফিকেশন',
              permissions['notification'] == true,
            ),
            const SizedBox(height: 12),
            _buildPermissionStatusItem(
              'সঠিক সময়ে অ্যালার্ম',
              permissions['exactAlarm'] == true,
            ),
            if (permissions['exactAlarm'] != true) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠️ "Alarms & reminders" পারমিশন ছাড়া রিমাইন্ডার সঠিক সময়ে নাও আসতে পারে।',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (permissions['notification'] != true || permissions['exactAlarm'] != true)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                Navigator.pop(context);
                await NotificationService().openNotificationSettings();
              },
              child: const Text('সেটিংস'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStatusItem(String title, bool granted) {
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: granted ? Colors.green[300] : Colors.red[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          granted ? 'দেওয়া আছে' : 'দেওয়া নেই',
          style: TextStyle(
            color: granted ? Colors.green[300] : Colors.red[300],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'পরামর্শ',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem(Icons.battery_charging_full, 'ব্যাটারি অপটিমাইজেশন বন্ধ রাখুন'),
          _buildTipItem(Icons.notifications_active, 'নোটিফিকেশন পারমিশন দিন'),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF888888), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
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

  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? Colors.white : Colors.grey,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: enabled ? const Color(0xFF888888) : const Color(0xFF555555),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFFD4AF37),
        inactiveThumbColor: const Color(0xFF666666),
        inactiveTrackColor: const Color(0xFF2A2A2A),
      ),
      onTap: onTap,
    );
  }

  Widget _buildMinuteSelector({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final options = [5, 10, 15, 20, 30, 45, 60];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((minutes) {
              final isSelected = value == minutes;
              return GestureDetector(
                onTap: () => onChanged(minutes),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$minutes মিনিট',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFF888888),
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerToggle(
    String name,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD4AF37),
            inactiveThumbColor: const Color(0xFF666666),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }

  void _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
    void Function(int hour, int minute) onTimeSelected,
  ) {
    // Convert 24-hour to 12-hour format
    int hour12 = currentHour == 0 ? 12 : (currentHour > 12 ? currentHour - 12 : currentHour);
    bool isAM = currentHour < 12;
    int minute = currentMinute;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'সময় নির্বাচন করুন',
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hour and Minute Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hour Dropdown (1-12)
                    _buildDropdown(
                      value: hour12,
                      items: List.generate(12, (i) => i + 1),
                      label: 'Hour',
                      onChanged: (val) => setState(() => hour12 = val!),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Minute Dropdown (0-59)
                    _buildDropdown(
                      value: minute,
                      items: List.generate(60, (i) => i),
                      label: 'Min',
                      padZero: true,
                      onChanged: (val) => setState(() => minute = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // AM/PM Toggle (separate row)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isAM = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isAM ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7),
                              bottomLeft: Radius.circular(7),
                            ),
                          ),
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color: isAM ? const Color(0xFF0A0A0A) : const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isAM = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: !isAM ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                          ),
                          child: Text(
                            'PM',
                            style: TextStyle(
                              color: !isAM ? const Color(0xFF0A0A0A) : const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isAM ? "AM" : "PM"}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'বাতিল',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Convert back to 24-hour format
                int hour24;
                if (isAM) {
                  hour24 = hour12 == 12 ? 0 : hour12;
                } else {
                  hour24 = hour12 == 12 ? 12 : hour12 + 12;
                }
                onTimeSelected(hour24, minute);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: const Text(
                'ঠিক আছে',
                style: TextStyle(color: Color(0xFF0A0A0A)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int value,
    required List<int> items,
    required String label,
    required ValueChanged<int?> onChanged,
    bool padZero = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: DropdownButton<int>(
        value: value,
        dropdownColor: const Color(0xFF2A2A2A),
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item,
            child: Text(
              padZero ? item.toString().padLeft(2, '0') : item.toString(),
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 18,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCustomRemindersSection(BuildContext context, WidgetRef ref, bool hasPermission) {
    final customReminders = ref.watch(customRemindersProvider);
    final activeCount = customReminders.where((r) => r.isEnabled).length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('কাস্টম রিমাইন্ডার 🔔'),
        _buildSettingsCard(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.edit_notifications,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              title: const Text(
                'কাস্টম রিমাইন্ডার',
                style: TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                customReminders.isEmpty
                    ? 'নিজের পছন্দমতো রিমাইন্ডার তৈরি করুন'
                    : '$activeCount/${customReminders.length} টি সক্রিয়',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (customReminders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: activeCount > 0 
                            ? Colors.green.withOpacity(0.2) 
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeCount > 0 ? 'সক্রিয়' : 'নিষ্ক্রিয়',
                        style: TextStyle(
                          color: activeCount > 0 ? Colors.green : Colors.grey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: hasPermission ? const Color(0xFFD4AF37) : Colors.grey,
                  ),
                ],
              ),
              onTap: hasPermission
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersScreenWidget(),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
        
        // Quick info
        if (customReminders.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2A2A2A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'আপনার ${customReminders.length} টি কাস্টম রিমাইন্ডার আছে। ম্যানেজ করতে উপরে ট্যাপ করুন।',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
