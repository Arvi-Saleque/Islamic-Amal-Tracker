import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/profile_screen.dart';
import 'reminder_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                const Divider(color: Color(0xFF2A2A2A)),
                _buildNavigationTile(
                  context: context,
                  icon: Icons.notifications_active,
                  title: 'রিমাইন্ডার',
                  subtitle: 'পুশ নোটিফিকেশন সেটিংস',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReminderSettingsScreen(),
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
            subtitle: 'v1.0.4',
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
              'সংস্করণ: v1.0.4',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'বিল্ড: 6',
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
      title: 'স্মার্ট লোকাল নোটিফিকেশন',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🕌 নামাজের রিমাইন্ডার (ওয়াক্ত শেষের আগে):',
          items: [
            'সেটিংস → রিমাইন্ডার সেটিংস → নামাজের রিমাইন্ডার ON করুন',
            'ওয়াক্ত শেষের কত মিনিট আগে: 10/15/20/30 মিনিট সিলেক্ট করুন',
            'প্রতিটি নামাজ আলাদা ON/OFF করুন (ফজর, যোহর, আসর, মাগরিব, এশা)',
            'স্বয়ংক্রিয়ভাবে প্রতিদিন prayer times calculate হয়',
            'উদাহরণ: মাগরিব 5:30 PM, ১৫ min আগে → 5:15 PM এ notification',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📿 যিকির রিমাইন্ডার (সকাল/সন্ধ্যা):',
          items: [
            'সেটিংস → রিমাইন্ডার সেটিংস → সকালের যিকির ON করুন',
            'সময় সিলেক্ট করুন (যেমন: সকাল 8:00 AM)',
            'সন্ধ্যার যিকির আলাদাভাবে সেট করুন (যেমন: 6:00 PM)',
            'প্রতিদিন নির্দিষ্ট সময়ে reminder পাবেন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⏰ কাস্টম রিমাইন্ডার (Unlimited):',
          items: [
            'সেটিংস → রিমাইন্ডার সেটিংস → যোগ করুন (+) বাটন',
            'Title: রিমাইন্ডারের নাম লিখুন (যেমন: তাহাজ্জুদ নামাজ)',
            'Description: বিবরণ লিখুন (ঐচ্ছিক)',
            'Time: সঠিক সময় সিলেক্ট করুন (যেমন: 3:30 AM)',
            'Days: দিন সিলেক্ট করুন (একাধিক সিলেক্ট করতে পারবেন):',
            '  • রবিবার, সোমবার, মঙ্গলবার, বুধবার, বৃহস্পতিবার, শুক্রবার, শনিবার',
            'Save করুন → প্রতি সপ্তাহে নির্দিষ্ট দিনে notification পাবেন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🔧 রিমাইন্ডার ম্যানেজমেন্ট:',
          items: [
            'Custom Reminders screen এ সব রিমাইন্ডার দেখুন',
            'Toggle switch দিয়ে সাময়িক ON/OFF করুন',
            'Edit icon (✏️) দিয়ে পরিবর্তন করুন',
            'Delete icon (🗑️) দিয়ে ডিলিট করুন',
            'View Pending Notifications - সব scheduled notifications দেখুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '⚙️ Permission Setup (Android 13+):',
          items: [
            '1. Notification Permission: সেটিংস → Apps → Amal Tracker → Notifications → Allow',
            '2. Exact Alarm Permission: সেটিংস → Apps → Special Access → Alarms & Reminders → Allow',
            '3. Battery Optimization: সেটিংস → Apps → Battery → Unrestricted',
            'অ্যাপ এই permissions চাইলে "Allow" করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📱 OnePlus/Xiaomi/Samsung Phone Setup (গুরুত্বপূর্ণ!):',
          items: [
            '⚠️ এই ফোনগুলোতে রিমাইন্ডার সঠিকভাবে কাজ করতে অবশ্যই:',
            '',
            '🔋 Battery Optimization বন্ধ করুন:',
            '  • Settings → Battery → Battery optimization',
            '  • Find "আমল ট্র্যাকার" → Don\'t optimize',
            '',
            '⏰ Alarms & Reminders Permission দিন:',
            '  • Settings → Apps → Special app access',
            '  • Alarms & reminders → আমল ট্র্যাকার → Allow',
            '',
            '🚀 Auto-start Permission (OnePlus/Xiaomi):',
            '  • Settings → Apps → Autostart',
            '  • আমল ট্র্যাকার → Enable',
            '',
            '🛡️ App Lock Disable (OnePlus):',
            '  • Settings → Security → App Lock',
            '  • আমল ট্র্যাকার → Disable',
            '',
            '💡 এই সেটিংস না করলে রিমাইন্ডার কাজ নাও করতে পারে!',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🌍 Technical Features:',
          items: [
            '✅ Alarm Manager: OS-level reliable alarms',
            '✅ Battery optimization bypass: Deep sleep এও কাজ করে',
            '✅ Timezone-aware: Asia/Dhaka timezone এ সঠিক সময়',
            '✅ Offline-capable: Internet ছাড়াই কাজ করে',
            '✅ Exact scheduling: নির্দিষ্ট সময়ে notification',
            '✅ Device restart: ফোন restart হলেও notification থাকে',
            '✅ Multiple channels: Prayer, Dhikr, Custom আলাদা',
          ],
        ),
      ],
    );
  }

  static Widget _buildCloudSyncSection() {
    return _buildFeatureCard(
      icon: '☁️',
      title: 'ক্লাউড সিঙ্ক ও Backup',
      color: Colors.blue,
      children: [
        _buildSubSection(
          title: '🔄 Auto Sync (স্বয়ংক্রিয়):',
          items: [
            'প্রতিটি ডেটা পরিবর্তন স্বয়ংক্রিয়ভাবে cloud এ sync হয়',
            'নামাজ mark, আমল check, যিকির save - সব auto sync',
            'Internet থাকলে সঙ্গে সঙ্গে, না থাকলে queue তে',
            'কোনো বাটন চাপতে হয় না',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '💾 Manual Backup:',
          items: [
            'Profile screen এ যান',
            'Backup Data বাটনে ট্যাপ করুন',
            'সব ডেটা Firebase Firestore এ upload হবে',
            'Success message দেখাবে',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📥 Manual Restore:',
          items: [
            'Profile screen এ যান',
            'Restore Data বাটনে ট্যাপ করুন',
            'Firestore থেকে সব ডেটা download হবে',
            'Local Hive database update হবে',
            'UI refresh হবে',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📱 Multi-Device ব্যবহার:',
          items: [
            'একই email/password দিয়ে অন্য device এ login করুন',
            'স্বয়ংক্রিয়ভাবে সব ডেটা restore হবে',
            'দুই device এই change করলে auto-sync হবে',
            'Last-write-wins - সর্বশেষ পরিবর্তন টিকে থাকবে',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📶 Offline Mode:',
          items: [
            'Internet ছাড়াই সম্পূর্ণ কাজ করে',
            'সব ডেটা local এ থাকে',
            'Internet আসলে auto-sync হয়',
            '"Syncing..." indicator sync এর সময় দেখাবে',
          ],
        ),
      ],
    );
  }

  static Widget _buildSettingsSection() {
    return _buildFeatureCard(
      icon: '⚙️',
      title: 'সেটিংস কাস্টমাইজ',
      color: const Color(0xFFD4AF37),
      children: [
        _buildSubSection(
          title: '🕌 Prayer Time Adjustments:',
          items: [
            'যদি আপনার এলাকায় সময় একটু আলাদা হয়',
            'সেটিংস → Prayer Time Adjustment',
            'প্রতিটি নামাজের জন্য +/- minutes করতে পারবেন',
            'উদাহরণ: ফজর +2 min, মাগরিব -1 min',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '🎨 Theme & Language:',
          items: [
            'Dark mode (default - পরিবর্তন করা যায় না এখন)',
            'Gold accent color (#D4AF37)',
            'বাংলা ভাষা (default)',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '👤 Profile Management:',
          items: [
            'Display Name পরিবর্তন করুন',
            'Email verification status চেক করুন',
            'Backup/Restore data manually',
            'Logout option',
          ],
        ),
      ],
    );
  }

  static Widget _buildTroubleshootingSection(BuildContext context) {
    return _buildFeatureCard(
      icon: '🔧',
      title: 'সমস্যা সমাধান',
      color: Colors.orange,
      children: [
        _buildSubSection(
          title: '⚠️ Notification কাজ করছে না:',
          items: [
            '1. সেটিংস → Apps → Amal Tracker → Notifications → Allow',
            '2. সেটিংস → Apps → Special Access → Alarms & Reminders → Allow',
            '3. সেটিংস → Apps → Battery → Unrestricted',
            '4. Do Not Disturb mode OFF করুন',
            '5. অ্যাপ restart করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📍 Prayer times update হচ্ছে না:',
          items: [
            '1. Location permission allow করুন',
            '2. GPS চালু করুন',
            '3. Internet connection check করুন',
            '4. Home screen এ pull down করে refresh করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '☁️ Cloud sync কাজ করছে না:',
          items: [
            '1. Internet connection check করুন',
            '2. Email verified কিনা দেখুন (Profile screen)',
            '3. Manual backup করে দেখুন',
            '4. অ্যাপ restart করুন',
            '5. Re-login করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📊 Statistics খালি দেখাচ্ছে:',
          items: [
            '1. অন্তত একটি activity complete করুন',
            '2. কয়েক সেকেন্ড অপেক্ষা করুন',
            '3. Weekly/Monthly toggle করুন',
            '4. Pull down করে refresh করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '💥 App crash হচ্ছে:',
          items: [
            '1. সেটিংস → Apps → Clear Cache',
            '2. App reinstall করুন',
            '3. Android version check করুন (minimum: 5.0)',
            '4. Developer কে bug report করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          title: '📱 Performance Tips:',
          items: [
            '• GPS শুধু প্রথমবার চালু রাখুন',
            '• Important notifications রাখুন',
            '• নিয়মিত statistics check করুন',
            '• 60%+ daily progress maintain করুন',
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
