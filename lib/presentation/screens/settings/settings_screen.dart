import 'package:amal_tracker/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../profile/profile_screen.dart';
import 'reminders_screen.dart';
import 'usage_rules.dart';
import '../../../core/theme/app_theme.dart';

// false = dark (default), true = light

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme provider to rebuild when theme changes
    ref.watch(appThemeModeProvider);
    
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'সেটিংস',
          style: TextStyle(
            color: titleColor,
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
            const SizedBox(height: 22),

            // Theme toggle card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _softCard(
                context: context,
                child: Builder(
                  builder: (context) {
                    return SwitchListTile(
                      value: Theme.of(context).brightness == Brightness.light,
                      onChanged: (v) => ref.read(appThemeModeProvider.notifier)
                        .setTheme(v ? 'light' : 'dark'),

                      title: Text(
                        'Light Theme',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'শুধু সেটিংস পেজে থিম পরিবর্তন হবে',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      secondary: Icon(
                        Theme.of(context).brightness == Brightness.dark 
                            ? Icons.nightlight_round 
                            : Icons.wb_sunny_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      activeColor: Theme.of(context).colorScheme.primary,
                    );
                  }
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Profile + Reminders card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _softCard(
                context: context,
                child: Column(
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
                    _softDivider(context: context),
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
              ),
            ),

            const SizedBox(height: 22),

            // About section
            _buildAboutSection(context),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  // ---------- UI helpers (Premium card styling) ----------

  Widget _softCard({
    required BuildContext context,
    required Widget child,
  }) {
    return buildPremiumCard(
      context: context,
      radius: 16,
      child: child,
    );
  }

  Widget _softDivider({required BuildContext context}) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final subColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.7);


    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: subColor,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
      ),
    );
  }

  // ---------- About section (now supports light + dark) ----------

  Widget _buildAboutSection(BuildContext context) {

    final headerColor = Theme.of(context).colorScheme.primary;
    final titleColor = Theme.of(context).colorScheme.onSurface;
    final subColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.60);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'অ্যাপ সম্পর্কে',
            style: TextStyle(
              color: headerColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          _aboutTile(
            context: context,
            icon: Icons.help,
            title: 'ব্যবহারের নিয়ম',
            subtitle: 'অ্যাপ কীভাবে ব্যবহার করতে হয় জানুন',
            titleColor: titleColor,
            subColor: subColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UsageRulesScreen()),
              );
            },
          ),
          const SizedBox(height: 10),

          _aboutTile(
            context: context,
            icon: Icons.bug_report,
            title: 'বাগ রিপোর্ট করুন',
            subtitle: 'সমস্যা পেলে আমাদের জানান',
            titleColor: titleColor,
            subColor: subColor,
            onTap: () => _sendBugReport(context),
          ),
          const SizedBox(height: 10),

          _aboutTile(
            context: context,
            icon: Icons.info,
            title: 'সংস্করণ',
            subtitle: 'v1.0.8',
            titleColor: titleColor,
            subColor: subColor,
            onTap: () => _showVersionDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _aboutTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color titleColor,
    required Color subColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: buildPremiumCard(
        context: context,
        radius: 16,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Bug report + version dialog (unchanged logic) ----------

  Future<void> _sendBugReport(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'effttech@gmail.com',
      query: _encodeQueryParameters(<String, String>{
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
            content: Text(
              'ইমেইল অ্যাপ খুলতে পারছে না। effttech@gmail.com এ ইমেইল করুন।',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: buildPremiumCard(
          context: context,
          radius: 16,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info, color: Color(0xFFD4AF37)),
                  SizedBox(width: 8),
                  Text(
                    'আমল ট্র্যাকার',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'সংস্করণ: v1.0.8',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'বিল্ড: 13',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ডেভেলপার: Salek Bin Hossain, Effy Tech',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final Uri emailUri = Uri(scheme: 'mailto', path: 'effttech@gmail.com');
                  try {
                    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
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
              Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.10)),
              const SizedBox(height: 8),
              Text(
                '© ২০২৬ সর্বস্বত্ব সংরক্ষিত',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'ঠিক আছে',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

