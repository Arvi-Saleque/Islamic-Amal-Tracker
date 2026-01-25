import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/profile_screen.dart';
import 'reminders_screen.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'সেটিংস',
          style: TextStyle(
            color: AppColors.textGolden,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
                const Divider(color: Color(0xFF2A2A2A), height: 1),
                _buildNavigationTile(
                  context: context,
                  icon: Icons.notifications_active,
                  title: 'রিমাইন্ডারস',
                  subtitle: 'দৈনিক রিমাইন্ডার সেট করুন',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RemindersScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // About Section
            const SizedBox(height: 20),
            buildAboutSection(context),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  static Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
            subtitle: 'v1.0.8',
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
      path: 'effttech@gmail.com',
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
            content: Text('ইমেইল অ্যাপ খুলতে পারছে না। effttech@gmail.com এ ইমেইল করুন।'),
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
              'সংস্করণ: v1.0.8',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'বিল্ড: 13',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'ডেভেলপার: Salek Bin Hossain, Effy Tech',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'effttech@gmail.com',
                );
                try {
                  await launchUrl(emailUri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  // Ignore
                }
              },
              child: const Text(
                'effttech@gmail.com',
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
            
            // Reminder Section
            _buildReminderSection(),
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
            
            // Cloud Sync Section
            _buildCloudSyncSection(),
            const SizedBox(height: 24),
            
            // Settings Section
            _buildSettingsSection(),
            const SizedBox(height: 24),
            
            // Troubleshooting Section
            _buildTroubleshootingSection(context),
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
            '🌟 আমল ট্র্যাকার - ব্যবহারের নিয়ম',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'এই অ্যাপটি আপনার দৈনন্দিন ইবাদত ট্র্যাক করার জন্য তৈরি। নামাজের সময় আপনার লোকেশন অনুযায়ী সঠিক ক্যালকুলেশন, স্মার্ট রিমাইন্ডার সিস্টেম এবং বিস্তারিত আমল ট্র্যাকিং সুবিধা পাবেন।',
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

  static Widget _buildReminderSection() {
    return _buildFeatureCard(
      icon: '🔔',
      title: 'স্মার্ট রিমাইন্ডার সিস্টেম',
      color: Colors.green,
      children: [
        _buildSubSection(
          title: '🎯 রিমাইন্ডার প্রকার:',
          items: [
            '🔥 ডিফল্ট রিমাইন্ডার: ৮টি সময়ে স্বয়ংক্রিয়ভাবে সক্রিয়',
            '⚙️ ব্যক্তিগত রিমাইন্ডার: আপনার নিজস্ব সময় সেট করুন',
            '🎨 কাস্টম রিমাইন্ডার: যেকোনো আমলের জন্য',
            '📅 পুনরাবৃত্তি: প্রতিদিন, নির্দিষ্ট দিন বা একবার',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🕌 ডিফল্ট নামাজ রিমাইন্ডার (সবসময় সক্রিয়):',
          items: [
            '🌅 ফজরের ৩০ মিনিট পর - সকালের যিকিরের জন্য',
            '☀️ যোহরের ৬০ মিনিট পর - দুপুরের আমলের জন্য',
            '🌤️ আসরের ১৫ মিনিট পর - বিকেলের দোয়ার জন্য',
            '🌅 মাগরিবের ১০ মিনিট পর - সন্ধ্যার যিকির',
            '🌙 ইশার ৬০ মিনিট পর - রাতের ইবাদতের জন্য',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📿 ডিফল্ট যিকির ও আমল রিমাইন্ডার:',
          items: [
            '🌅 সকালের যিকির: ফজরের ৬০ মিনিট পর',
            '🌆 সন্ধ্যার যিকির: মাগরিবের ৩০ মিনিট পর',
            '⭐ দৈনিক আমল: প্রতিদিন রাত ১০:০০ টায়',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⚙️ ব্যক্তিগত রিমাইন্ডার সেটিংস:',
          items: [
            'সেটিংস → রিমাইন্ডারস → ব্যক্তিগত ট্যাব',
            'দৈনিক আমল, সকাল/সন্ধ্যা যিকির, নামাজের সময়',
            'আপনার সুবিধামত সময় পরিবর্তন করুন',
            'জামাত/স্থানীয় সময় অনুযায়ী adjustment',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🎨 কাস্টম রিমাইন্ডার তৈরি:',
          items: [
            'সেটিংস → রিমাইন্ডারস → কাস্টম ট্যাব',
            'রিমাইন্ডারের নাম, সময় ও বিবরণ লিখুন',
            'সপ্তাহের নির্দিষ্ট দিন সিলেক্ট করুন',
            'নামাজের সময়ের সাথে offset করে সেট করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🔕 রিমাইন্ডার সমস্যা সমাধান:',
          items: [
            'ফোনের ব্যাটারি সেটিংসে "Background restriction" OFF করুন',
            'Notification permission allow করুন',
            'Do Not Disturb mode থেকে app কে exclude করুন',
            'Auto-start permission enable করুন',
            'Power saving mode এ whitelist করুন',
          ],
        ),
      ],
    );
  }

  static Widget _buildPrayerSection() {
    return _buildFeatureCard(
      icon: '🕌',
      title: 'নামাজের ওয়াক্ত ক্যালকুলেশন',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🌍 ওয়াক্ত ক্যালকুলেশন পদ্ধতি:',
          items: [
            'Calculation Method: Muslim World League (MWL)',
            'Fajr Angle: 18°, Isha Angle: 17°',
            'Madhab: Hanafi (Asr calculation)',
            'High Latitude Rule: Nearest Valid Time',
            'Coordinates: আপনার GPS location অনুযায়ী',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📍 লোকেশন ও সময় নির্ধারণ:',
          items: [
            'আপনার বর্তমান GPS coordinates ব্যবহার করে',
            'Timezone: আপনার ডিভাইসের timezone অনুযায়ী',
            'প্রতিদিন sunrise/sunset সময় হিসাব করে',
            'Elevation: Sea level থেকে calculation',
            'Location permission প্রয়োজন accurate time এর জন্য',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⏰ প্রতিটি ওয়াক্তের হিসাব:',
          items: [
            '🌅 ফজর: সুবহে সাদিক (সূর্যের 18° নিচে) থেকে সূর্যোদয়',
            '☀️ যোহর: সূর্য মধ্যাকাশ অতিক্রম করার পর',
            '🌤️ আসর: ছায়া দ্বিগুণ হলে (Hanafi method)',
            '🌅 মাগরিব: সূর্যাস্তের সাথে সাথে',
            '🌙 ইশা: শাফাক (লাল আলো) অন্তর্ধান (17° angle)',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🚫 মাকরূহ ওয়াক্ত (নিষিদ্ধ সময়):',
          items: [
            'সূর্যোদয়ের সময় ও তার পর 15 মিনিট',
            'যোহরের 10 মিনিট আগে (যাওয়াল)',
            'সূর্যাস্তের সময় ও তার 15 মিনিট আগে',
            'এই সময়ে কোনো নফল নামাজ পড়া যায় না',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '✨ বিশেষ সময়সূচী:',
          items: [
            '🌇 ইশরাক: সূর্যোদয়ের 15 মিনিট পর',
            '🌅 চাশত: ইশরাক থেকে যাওয়াল পর্যন্ত',
            '🌙 তাহাজ্জুদ: ইশার পর থেকে ফজর পর্যন্ত',
            '⭐ নফল: মাকরূহ সময় ছাড়া যেকোনো সময়',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 নামাজ ট্র্যাকিং:',
          items: [
            'পাঁচ ওয়াক্ত আলাদা আলাদা মার্ক করুন',
            'ফরজ + সুন্নত রাকাত গণনা',
            'জামাত/একাকী নামাজ ট্র্যাক করুন',
            'চলমান ওয়াক্ত ও অবশিষ্ট সময় দেখুন',
          ],
        ),
      ],
    );
  }

  static Widget _buildAmalSection() {
    return _buildFeatureCard(
      icon: '✨',
      title: 'দৈনিক আমল ট্র্যাকিং',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '📋 প্রিসেট আমল তালিকা:',
          items: [
            'কুরআন তিলাওয়াত, তাহাজ্জুদ, ইস্তিগফার',
            'সকাল-সন্ধ্যার যিকির, দুরূদ শরীফ',
            'দান-সাদাকা, পিতামাতার সেবা',
            'নেক আমলের বিস্তৃত তালিকা',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '➕ কাস্টম আমল যোগ:',
          items: [
            'নিজের মতো করে আমল তৈরি করুন',
            'আমলের নাম, বর্ণনা ও লক্ষ্য সেট করুন',
            'দৈনিক/সাপ্তাহিক ভিত্তিতে ট্র্যাক করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🎯 প্রগ্রেস ট্র্যাকিং:',
          items: [
            'দৈনিক সম্পূর্ণতার হার (%) দেখুন',
            'সাপ্তাহিক/মাসিক গ্রাফে উন্নতি বুঝুন',
            'স্ট্রিক (ধারাবাহিকতা) কাউন্টার',
            'ক্যালেন্ডার ভিউতে হিস্টোরি দেখুন',
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
          title: '🎯 যিকির ট্র্যাকিং:',
          items: [
            'ডিফল্ট ৬টি যিকির + কাস্টম যিকির যোগ করুন',
            'ডিজিটাল তসবিহ - বাটন ক্লিক বা সরাসরি নাম্বার এন্ট্রি',
            'টার্গেট সেট করুন ও প্রগ্রেস দেখুন',
            'সেশন হিস্টোরি ও ডেইলি গোল ট্র্যাকিং',
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
          title: '📚 তিন ধরনের পড়া ট্র্যাক:',
          items: [
            '📖 কুরআন তিলাওয়াত: পৃষ্ঠা/আয়াত/সূরা ভিত্তিক',
            '📜 তাফসীর পড়া: পৃষ্ঠা সংখ্যা দিয়ে',
            '📝 হাদীস পড়া: হাদীস সংখ্যা দিয়ে',
            'প্রতিটির জন্য আলাদা লক্ষ্য ও প্রগ্রেস বার',
          ],
        ),
      ],
    );
  }

  static Widget _buildSinTrackerSection() {
    return _buildFeatureCard(
      icon: '⚠️',
      title: 'গুনাহ ট্র্যাকার (ঐচ্ছিক)',
      color: Colors.red,
      children: [
        _buildSubSection(
          title: '🎯 উদ্দেশ্য ও ব্যবহার:',
          items: [
            'নিজের দুর্বলতা চিহ্নিত করা ও তওবায় সাহায্য',
            'গুনাহের ক্যাটাগরি (ছোট/বড়) ও তওবা ট্র্যাকিং',
            'সম্পূর্ণ গোপনীয় - শুধু আপনার ডিভাইসে',
            'পরিসংখ্যানে উন্নতি ও কমার ট্রেন্ড দেখুন',
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
          title: '📈 ডেটা ভিজুয়ালাইজেশন:',
          items: [
            'সাপ্তাহিক বার চার্ট ও মাসিক লাইন চার্ট',
            'ইন্টারঅ্যাক্টিভ ক্যালেন্ডার ভিউ',
            'প্রগ্রেস রেট, স্ট্রিক ও সামগ্রিক স্কোর',
            'নামাজ, আমল, যিকির, পড়া - আলাদা আলাদা ট্যাব',
          ],
        ),
      ],
    );
  }

  static Widget _buildCloudSyncSection() {
    return _buildFeatureCard(
      icon: '☁️',
      title: 'ক্লাউড সিঙ্ক ও ব্যাকআপ',
      color: Colors.blue,
      children: [
        _buildSubSection(
          title: '🔄 স্বয়ংক্রিয় ও ম্যানুয়াল সিঙ্ক:',
          items: [
            '🔥 অটো সিঙ্ক: প্রতিটি পরিবর্তন তুরন্ত ক্লাউডে',
            '💾 ম্যানুয়াল ব্যাকআপ: Profile → Backup Data',
            '📥 রিস্টোর: Profile → Restore Data',
            '📱 মাল্টি-ডিভাইস: একই একাউন্টে সব ডিভাইসে একই ডেটা',
            '📶 অফলাইন মোড: ইন্টারনেট ছাড়াই কাজ করে',
          ],
        ),
      ],
    );
  }

  static Widget _buildSettingsSection() {
    return _buildFeatureCard(
      icon: '⚙️',
      title: 'সেটিংস ও কাস্টমাইজেশন',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🔧 প্রধান সেটিংস:',
          items: [
            '🕌 Prayer Time Adjustment: স্থানীয় সময় অনুযায়ী +/- মিনিট',
            '🔔 রিমাইন্ডার কাস্টমাইজেশন: ডিফল্ট/ব্যক্তিগত/কাস্টম',
            '👤 প্রোফাইল ম্যানেজমেন্ট: নাম, ইমেইল ভেরিফিকেশন',
            '🎨 থিম: ডার্ক মোড উইথ গোল্ড একসেন্ট (#D4AF37)',
          ],
        ),
      ],
    );
  }

  static Widget _buildTroubleshootingSection(BuildContext context) {
    return _buildFeatureCard(
      icon: '🔧',
      title: 'সমস্যা সমাধান (FAQ)',
      color: Colors.orange,
      children: [
        _buildSubSection(
          title: '🆘 সাধারণ সমস্যা ও সমাধান:',
          items: [
            '📍 Prayer times update হচ্ছে না → GPS ও Internet চেক করুন',
            '☁️ Cloud sync কাজ করছে না → Email verify ও re-login করুন',
            '🔔 Notification আসছে না → Battery optimization disable করুন',
            '📊 Statistics খালি → Activity complete করে refresh করুন',
            '💥 App crash → Clear cache অথবা reinstall করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⚡ পারফরমেন্স টিপস:',
          items: [
            'Location permission শুধু প্রয়োজনে চালু রাখুন',
            'Auto-backup এর জন্য stable internet connection নিশ্চিত করুন',
            'নিয়মিত statistics চেক করে মোটিভেশন বজায় রাখুন',
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
                path: 'effttech@gmail.com',
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
                    'effttech@gmail.com',
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
          const SizedBox(height: 12),
          const Text(
            '📚 Technical Reference: নামাজের ওয়াক্ত ক্যালকুলেশন Muslim World League (MWL) standard অনুযায়ী করা হয়েছে, যা বিশ্বব্যাপী স্বীকৃত। GPS coordinates ব্যবহার করে astronomical calculation এর মাধ্যমে সঠিক সময় নির্ধারণ করা হয়।',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.4,
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
