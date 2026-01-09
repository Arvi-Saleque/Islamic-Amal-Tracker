import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/notification_settings_provider.dart';
import '../profile/profile_screen.dart';
import '../notifications/reminders_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(notificationSettingsProvider);
    final settings = settingsState.settings;

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
          'সেটিংস',
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
                  // Quick Access Section
                  const SizedBox(height: 30),
                  _buildSettingsCard(
                    children: [
                      _buildNavigationTile(
                        context: context,
                        icon: Icons.person_outline,
                        title: 'প্রোফাইল',
                        subtitle: 'অ্যাকাউন্ট ও ক্লাউড সিঙ্ক',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: Color(0xFF2A2A2A)),
                      _buildNavigationTile(
                        context: context,
                        icon: Icons.alarm,
                        title: 'কাস্টম রিমাইন্ডার',
                        subtitle: 'নিজের রিমাইন্ডার তৈরি করুন',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RemindersScreenWidget(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Permission Card
                  if (!settingsState.hasPermission)
                    _buildPermissionCard(context, ref),

                  // Prayer Notifications Section
                  _buildSectionHeader('নামাজের রিমাইন্ডার 🕌'),
                  _buildSettingsCard(
                    children: [
                      _buildSwitchTile(
                        title: 'নামাজের রিমাইন্ডার',
                        subtitle: 'নামাজের সময়ের আগে নোটিফিকেশন পান',
                        value: settings.prayerNotificationsEnabled,
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .togglePrayerNotifications(value);
                        },
                      ),
                      if (settings.prayerNotificationsEnabled) ...[
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
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleMorningDhikr(value);
                        },
                        onTap: settings.morningDhikrEnabled
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
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleEveningDhikr(value);
                        },
                        onTap: settings.eveningDhikrEnabled
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
                        onChanged: (value) {
                          ref
                              .read(notificationSettingsProvider.notifier)
                              .toggleDailyAmalReminder(value);
                        },
                        onTap: settings.dailyAmalReminderEnabled
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

                  // Test Notification
                  _buildSectionHeader('টেস্ট'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: settingsState.hasPermission
                          ? () {
                              ref
                                  .read(notificationSettingsProvider.notifier)
                                  .sendTestNotification();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('টেস্ট নোটিফিকেশন পাঠানো হয়েছে'),
                                  backgroundColor: Color(0xFFD4AF37),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('টেস্ট নোটিফিকেশন পাঠান'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0A0A0A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // About Section
                  buildAboutSection(context),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionCard(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.2),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.notifications_off,
            color: Colors.red,
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
            'রিমাইন্ডার পেতে নোটিফিকেশন পারমিশন দিন',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .requestPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('পারমিশন দিন'),
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

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFD4AF37),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFD4AF37),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE0E0E0),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFD4AF37),
        activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.3),
        inactiveThumbColor: const Color(0xFF666666),
        inactiveTrackColor: const Color(0xFF2A2A2A),
      ),
    );
  }

  Widget _buildPrayerToggle(
    String name,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 14,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD4AF37),
            activeTrackColor: const Color(0xFFD4AF37).withOpacity(0.3),
            inactiveThumbColor: const Color(0xFF666666),
            inactiveTrackColor: const Color(0xFF2A2A2A),
          ),
        ],
      ),
    );
  }

  Widget _buildMinuteSelector({
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    final options = [5, 10, 15, 20, 30];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFE0E0E0),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: options.map((minutes) {
              final isSelected = value == minutes;
              return GestureDetector(
                onTap: () => onChanged(minutes),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF2A2A2A),
                    ),
                  ),
                  child: Text(
                    '$minutes মিনিট',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFF888888),
                      fontSize: 13,
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

  void _showTimePicker(
    BuildContext context,
    WidgetRef ref,
    int currentHour,
    int currentMinute,
    Function(int, int) onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: currentHour, minute: currentMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              onPrimary: Color(0xFF0A0A0A),
              surface: Color(0xFF1A1A1A),
              onSurface: Color(0xFFE0E0E0),
            ),
            dialogBackgroundColor: const Color(0xFF1A1A1A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked.hour, picked.minute);
    }
  }

  // About section with help and bug report
  static Widget buildAboutSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'অ্যাপ সম্পর্কে 📱',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildOptionCard(
            title: 'ব্যবহারের নিয়ম',
            subtitle: 'অ্যাপ কীভাবে ব্যবহার করতে হয় জানুন',
            icon: Icons.help,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ManualScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'বাগ রিপোর্ট করুন',
            subtitle: 'সমস্যা পেলে আমাদের জানান',
            icon: Icons.bug_report,
            onTap: () => _sendBugReport(context),
          ),
          const SizedBox(height: 8),
          _buildOptionCard(
            title: 'সংস্করণ',
            subtitle: 'v1.0.0',
            icon: Icons.info,
            onTap: () => _showVersionDialog(context),
          ),
        ],
      ),
    );
  }

  static Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF1A1A1A),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _sendBugReport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'alifsalek.as@gmail.com',
      query: encodeQueryParameters(<String, String>{
        'subject': 'আমাল ট্র্যাকার - বাগ রিপোর্ট',
        'body': 'দয়া করে এখানে বাগের বিবরণ লিখুন:\n\n',
      }),
    );
    
    try {
      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ইমেইল অ্যাপ খুলতে পারছে না। alifsalek.as@gmail.com এ ইমেইল করুন।'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.info, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text(
              'আমল ট্র্যাকার',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'সংস্করণ: v1.0.0',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'বিল্ড: 1',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'ডেভেলপার: Salek Bin Hossain',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'alifsalek.as@gmail.com',
                );
                try {
                  await launchUrl(emailUri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  // Ignore
                }
              },
              child: const Text(
                'alifsalek.as@gmail.com',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2A2A2A)),
            const SizedBox(height: 8),
            const Text(
              '© ২০২৬ সর্বস্বত্ব সংরক্ষিত',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ঠিক আছে',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
        '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

class ManualScreen extends StatelessWidget {
  const ManualScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'ব্যবহারের নিয়ম',
          style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeaderSection(),
            const SizedBox(height: 24),
            
            // Prayer Section
            _buildPrayerSection(),
            const SizedBox(height: 24),
            
            // Amal Section
            _buildAmalSection(),
            const SizedBox(height: 24),
            
            // Dhikr Section
            _buildDhikrSection(),
            const SizedBox(height: 24),
            
            // Reading Section
            _buildReadingSection(),
            const SizedBox(height: 24),
            
            // Sin Tracker Section
            _buildSinTrackerSection(),
            const SizedBox(height: 24),
            
            // Statistics Section
            _buildStatisticsSection(),
            const SizedBox(height: 24),
            
            // Reminders Section
            _buildRemindersSection(),
            const SizedBox(height: 24),
            
            // Contact Section
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  static Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4AF37).withOpacity(0.2),
            const Color(0xFFD4AF37).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 আমল ট্র্যাকার অ্যাপে স্বাগতম',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'এই অ্যাপটি আপনার দৈনন্দিন ইবাদত, আমল এবং ইসলামিক কাজকর্ম ট্র্যাক করতে সাহায্য করবে। নিচে প্রতিটি ফিচারের বিস্তারিত বর্ণনা দেওয়া হলো।',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildPrayerSection() {
    return _buildFeatureCard(
      icon: '🕌',
      title: 'নামাজ ট্র্যাকার',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '📍 কি করতে পারবেন:',
          items: [
            'আপনার লোকেশন অনুযায়ী স্বয়ংক্রিয় নামাজের সময় দেখুন',
            'পাঁচ ওয়াক্ত নামাজ ট্র্যাক করুন (ফজর, যোহর, আসর, মাগরিব, ইশা)',
            'প্রতিটি নামাজের জন্য ফরজ + সুন্নত রাকাত আলাদা আলাদা কাউন্ট করুন',
            'চলমান ওয়াক্ত এবং কতক্ষণ বাকি আছে তা দেখুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⏰ নামাজের সময়:',
          items: [
            'ফজর: সুবহে সাদিক থেকে সূর্যোদয় পর্যন্ত',
            'যোহর: সূর্য মধ্যাকাশ পার থেকে আসর পর্যন্ত',
            'আসর: আসর সময় থেকে সূর্যাস্তের ১৫ মিনিট আগে পর্যন্ত',
            'মাগরিব: সূর্যাস্ত থেকে ইশা পর্যন্ত',
            'ইশা: ইশা থেকে পরের দিন ফজর পর্যন্ত',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🚫 নিষিদ্ধ সময় (মাকরূহ ওয়াক্ত):',
          items: [
            'সূর্যোদয়ের পর ১৫ মিনিট',
            'যোহরের ১০ মিনিট আগে (যাওয়াল)',
            'সূর্যাস্তের ১৫ মিনিট আগে',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✨ নফল সময়:',
          items: [
            'সূর্যোদয়ের ১৫ মিনিট পর থেকে যোহরের ১০ মিনিট আগে পর্যন্ত',
            'এই সময়ে শুধু নফল নামাজ পড়া যায়',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 হিস্টোরি কোথায় পাবেন:',
          items: [
            'হোম স্ক্রিনে "Prayer Tracker" কার্ডে ট্যাপ করুন',
            'পরিসংখ্যান পেজে গিয়ে নামাজের গ্রাফ এবং ক্যালেন্ডার দেখুন',
            'প্রতিদিনের কত নামাজ পড়েছেন তা দেখতে পারবেন',
          ],
        ),
      ],
    );
  }

  static Widget _buildAmalSection() {
    return _buildFeatureCard(
      icon: '✨',
      title: 'দৈনিক আমল',
      color: const Color(0xFFD4AF37),
      children: [
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✅ কিভাবে ব্যবহার করবেন:',
          items: [
            'হোম স্ক্রিনে "Daily Amal" কার্ডে যান',
            'যে আমল করেছেন সেটার চেকবক্সে টিক দিন',
            'টিক দিলেই তা সেভ হয়ে যাবে',
            'পরের দিন সব আমল আবার রিসেট হয়ে যাবে',
            'নতুন কাস্টম আমল যোগ করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 হিস্টোরি:',
          items: [
            'পরিসংখ্যান পেজে "Amal" ট্যাবে যান',
            'সাপ্তাহিক/মাসিক গ্রাফে আমলের হার দেখুন',
            'ক্যালেন্ডারে প্রতিদিন কত আমল করেছেন তা দেখুন',
            'প্রতিটি আমলের আলাদা হিস্টোরি দেখতে পারবেন',
          ],
        ),
      ],
    );
  }

  static Widget _buildDhikrSection() {
    return _buildFeatureCard(
      icon: '📿',
      title: 'যিকির কাউন্টার',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🎯 কি করতে পারবেন:',
          items: [
            'ডিফল্ট ৬টি যিকির দিয়ে শুরু করুন',
            'নতুন কাস্টম যিকির যোগ করুন',
            'বাটন ক্লিক করে কাউন্ট বাড়ান',
            'সরাসরি সংখ্যা টাইপ করে দিতে পারবেন',
            'টার্গেট সেট করুন (যেমন: ১০০ বার)',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '➕ নতুন যিকির যোগ করুন:',
          items: [
            'যিকির পেজে + বাটনে ক্লিক করুন',
            'যিকিরের নাম লিখুন (আরবি/বাংলা)',
            'টার্গেট সংখ্যা সেট করুন',
            'Save করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 হিস্টোরি:',
          items: [
            'পরিসংখ্যান পেজে "Dhikr" ট্যাবে যান',
            'প্রতিদিন কত যিকির করেছেন গ্রাফে দেখুন',
            'কোন যিকির কতবার করেছেন তা দেখুন',
            'সেশন হিস্টোরি দেখতে পারবেন',
          ],
        ),
      ],
    );
  }

  static Widget _buildReadingSection() {
    return _buildFeatureCard(
      icon: '📖',
      title: 'পড়াশোনা ট্র্যাকার',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '📚 কি কি ট্র্যাক করতে পারবেন:',
          items: [
            'কুরআন তিলাওয়াত (পৃষ্ঠা/আয়াত সংখ্যা)',
            'তাফসীর পড়া (পৃষ্ঠা সংখ্যা)',
            'হাদীস পড়া (হাদীস সংখ্যা)',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✍️ কিভাবে রেকর্ড করবেন:',
          items: [
            'Reading Tracker পেজে যান',
            'কুরআন/তাফসীর/হাদীস ট্যাব সিলেক্ট করুন',
            '+ Add Session বাটনে ক্লিক করুন',
            'কত পৃষ্ঠা/আয়াত/হাদীস পড়েছেন লিখুন',
            'ঐচ্ছিক: নোট যোগ করতে পারবেন',
            'Save করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🎯 লক্ষ্য নির্ধারণ:',
          items: [
            'দৈনিক লক্ষ্য সেট করুন',
            'সাপ্তাহিক/মাসিক লক্ষ্য দেখুন',
            'কতটা সম্পন্ন হয়েছে প্রগ্রেস বারে দেখুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📖 কুরআন বিশেষ ফিচার:',
          items: [
            'সূরা নম্বর এবং আয়াত নম্বর দিয়ে ট্র্যাক করুন',
            'কতটি সূরা সম্পূর্ণ পড়েছেন দেখুন',
            'পারা অনুযায়ী প্রগ্রেস দেখতে পারবেন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 হিস্টোরি:',
          items: [
            'Reading Tracker পেজেই নিচে স্ক্রল করুন',
            'সব সেশনের লিস্ট দেখুন (তারিখ সহ)',
            'পরিসংখ্যান পেজে গ্রাফ দেখুন',
            'মোট কত পড়েছেন তা দেখুন',
          ],
        ),
      ],
    );
  }

  static Widget _buildSinTrackerSection() {
    return _buildFeatureCard(
      icon: '⚠️',
      title: 'গুনাহ ট্র্যাকার',
      color: Colors.red,
      children: [
        _buildSubSection(
          title: '🎯 উদ্দেশ্য:',
          items: [
            'নিজের গুনাহ সম্পর্কে সচেতন হওয়া',
            'গুনাহ থেকে ফিরে আসতে সাহায্য করা',
            'তওবা এবং ইস্তিগফারের অভ্যাস তৈরি করা',
            'কোন গুনাহ বেশি হচ্ছে তা চিহ্নিত করা',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📝 কিভাবে রেকর্ড করবেন:',
          items: [
            'Sin Tracker পেজে যান',
            '+ বাটনে ক্লিক করুন',
            'গুনাহের ক্যাটাগরি সিলেক্ট করুন (ছোট/বড়)',
            'গুনাহের বর্ণনা লিখুন (ঐচ্ছিক)',
            'তওবা করেছেন কিনা মার্ক করুন',
            'Save করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🔒 গোপনীয়তা:',
          items: [
            'সব ডাটা শুধুমাত্র আপনার ফোনে সংরক্ষিত',
            'কোনো তথ্য বাইরে শেয়ার হয় না',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✅ তওবা ট্র্যাকিং:',
          items: [
            'প্রতিটি গুনাহের জন্য তওবা মার্ক করুন',
            'কতবার তওবা করেছেন তা দেখুন',
            'তওবার পর পুনরায় করেছেন কিনা ট্র্যাক করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 হিস্টোরি ও পরিসংখ্যান:',
          items: [
            'Sin Tracker পেজেই সব রেকর্ড দেখুন',
            'পরিসংখ্যান পেজে গ্রাফ দেখুন',
            'সপ্তাহ/মাস অনুযায়ী তুলনা করুন',
            'কোন গুনাহ কমছে/বাড়ছে তা বুঝুন',
          ],
        ),
      ],
    );
  }

  static Widget _buildStatisticsSection() {
    return _buildFeatureCard(
      icon: '📊',
      title: 'পরিসংখ্যান ও হিস্টোরি',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '📈 কি কি দেখতে পারবেন:',
          items: [
            'নামাজ, আমল, যিকির, পড়া - সব আলাদা ট্যাবে',
            'সাপ্তাহিক বার চার্ট',
            'মাসিক লাইন চার্ট',
            'বর্তমান মাসের ক্যালেন্ডার ভিউ',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🗓️ ক্যালেন্ডার ফিচার:',
          items: [
            'প্রতিদিন কত আমল/নামাজ করেছেন দেখুন',
            'তারিখে ক্লিক করে বিস্তারিত দেখুন',
            'কোন দিন বেশি ভালো ছিল তা বুঝুন',
            'মাস পরিবর্তন করে আগের ডাটা দেখুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 গ্রাফ বিশ্লেষণ:',
          items: [
            'সাপ্তাহিক: গত ৭ দিনের তুলনা',
            'মাসিক: পুরো মাসের ট্রেন্ড',
            'গড় হিসাব দেখুন',
            'সর্বোচ্চ ও সর্বনিম্ন দিন চিহ্নিত করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🎯 প্রগ্রেস ট্র্যাকিং:',
          items: [
            'মোট স্কোর দেখুন',
            'কমপ্লিশন রেট (%) দেখুন',
            'স্ট্রিক (পরপর কতদিন) দেখুন',
            'উন্নতির হার বুঝতে পারবেন',
          ],
        ),
      ],
    );
  }

  static Widget _buildRemindersSection() {
    return _buildFeatureCard(
      icon: '🔔',
      title: 'রিমাইন্ডার ও নোটিফিকেশন',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🕌 নামাজের রিমাইন্ডার:',
          items: [
            'প্রতিটি ওয়াক্তের জন্য আলাদা সেটিংস',
            'নামাজের কত মিনিট আগে রিমাইন্ডার চান সেট করুন',
            'কোন কোন নামাজের জন্য চান সিলেক্ট করুন',
            'সেটিংস > Notifications থেকে কনফিগার করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✨ দৈনিক আমল রিমাইন্ডার:',
          items: [
            'প্রতিদিন একটি নির্দিষ্ট সময়ে রিমাইন্ডার',
            'সময় সেট করুন (যেমন: সকাল ৮টা)',
            'আমল করতে ভুলে যাবেন না',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⏰ কাস্টম রিমাইন্ডার:',
          items: [
            'Reminders পেজে + বাটনে ক্লিক করুন',
            'রিমাইন্ডারের টাইটেল লিখুন',
            'সময় এবং দিন সিলেক্ট করুন',
            'Repeat অপশন সেট করুন (Daily/Weekly)',
            'নির্দিষ্ট দিনগুলো সিলেক্ট করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🔧 ম্যানেজমেন্ট:',
          items: [
            'Reminders পেজে সব রিমাইন্ডার দেখুন',
            'On/Off টগল করুন',
            'এডিট বা ডিলিট করুন',
            'পরমিশন ঠিক আছে কিনা চেক করুন',
          ],
        ),
      ],
    );
  }

  static Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD4AF37)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1A1A1A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: Color(0xFFD4AF37), size: 24),
              SizedBox(width: 12),
              Text(
                'সাহায্য ও সাপোর্ট',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '📧 কোনো সমস্যা, বাগ রিপোর্ট, বা নতুন ফিচারের পরামর্শ থাকলে আমাদের ইমেইল করুন:',
            style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'alifsalek.as@gmail.com',
                queryParameters: {
                  'subject': 'আমল ট্র্যাকার - সাপোর্ট',
                },
              );
              launchUrl(emailUri);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.email, color: Color(0xFFD4AF37), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'alifsalek.as@gmail.com',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '💡 টিপস: স্ক্রিনশট সহ সমস্যার বর্ণনা দিলে দ্রুত সমাধান পাবেন।',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureCard({
    required String icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  static Widget _buildSubSection({
    required String title,
    required List<String> items,
  }) {
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
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '• ',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  static Widget _buildManualSection({
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
