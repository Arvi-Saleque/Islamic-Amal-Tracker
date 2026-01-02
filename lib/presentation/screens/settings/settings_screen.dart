import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/notification_settings_provider.dart';

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
            _buildManualSection(
              title: '🕌 নামাজ ট্র্যাকার',
              description: 'আপনার স্থান অনুযায়ী পাঁচ ওয়াক্তের নামাজের সময় দেখুন এবং ট্র্যাক করুন। প্রতিটি নামাজের জন্য রাকাত কাউন্ট করতে পারবেন।',
            ),
            _buildManualSection(
              title: '✨ দৈনিক আমল',
              description: 'প্রতিদিন করার মত ১৮টি আমল। যেমন মিসওয়াক, সূরা পড়া, দোয়া করা এবং নফল নামাজ। প্রতিটি আমল সম্পন্ন হলে চেকবক্সে টিক দিন।',
            ),
            _buildManualSection(
              title: '📿 যিকর কাউন্টার',
              description: '৮টি বিখ্যাত যিকর দিয়ে শুরু করুন বা নিজের যিকর যোগ করুন। বাটন চাপিয়ে সংখ্যা বৃদ্ধি করুন বা সরাসরি সংখ্যা টাইপ করুন।',
            ),
            _buildManualSection(
              title: '📖 পড়া ট্র্যাকার',
              description: 'কুরআন, তাফসীর এবং হাদীস পড়ার হিসাব রাখুন। প্রতিদিন কতটা পড়লেন সেটি রেকর্ড করুন এবং লক্ষ্য নির্ধারণ করুন।',
            ),
            _buildManualSection(
              title: '📊 পরিসংখ্যান',
              description: 'সাপ্তাহিক এবং মাসিক গ্রাফে আপনার অগ্রগতি দেখুন। ক্যালেন্ডারে প্রতিটি দিনের বিস্তারিত তথ্য পান।',
            ),
            _buildManualSection(
              title: '🔔 রিমাইন্ডার',
              description: 'নামাজের সময় পূর্বে রিমাইন্ডার পান। যিকর এবং আমলের জন্য নির্দিষ্ট সময়ে বিজ্ঞপ্তি পাবেন।',
            ),
            _buildManualSection(
              title: '⏰ কাস্টম রিমাইন্ডার',
              description: 'আপনার পছন্দ অনুযায়ী নতুন রিমাইন্ডার যোগ করুন। যেকোনো সময় এবং যেকোনো দিনের জন্য রিমাইন্ডার সেট করতে পারবেন।',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD4AF37)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ই-মেইল সাপোর্ট 📧',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'কোনো সমস্যা পেলে বা পরামর্শ থাকলে নিচের ইমেইলে যোগাযোগ করুন:',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.email, color: Color(0xFFD4AF37), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            final Uri emailUri = Uri(
                              scheme: 'mailto',
                              path: 'alifsalek.as@gmail.com',
                            );
                            launchUrl(emailUri);
                          },
                          child: const Text(
                            'alifsalek.as@gmail.com',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
