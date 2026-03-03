import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class UsageRulesScreen extends StatelessWidget {
  const UsageRulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final bg = Theme.of(context).scaffoldBackgroundColor;
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: bg,
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
          'usage_title'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            // Reminder Section
            _buildReminderSection(context),
            const SizedBox(height: 24),

            // Prayer Section
            _buildPrayerSection(context),
            const SizedBox(height: 24),

            // Amal Section
            _buildAmalSection(context),
            const SizedBox(height: 24),

            // Dhikr Section
            _buildDhikrSection(context),
            const SizedBox(height: 24),

            // Reading Section
            _buildReadingSection(context),
            const SizedBox(height: 24),

            // Sin Tracker Section
            _buildSinTrackerSection(context),
            const SizedBox(height: 24),

            // Statistics Section
            _buildStatisticsSection(context),
            const SizedBox(height: 24),

            // Cloud Sync Section
            _buildCloudSyncSection(context),
            const SizedBox(height: 24),

            // Settings Section
            _buildSettingsSection(context),
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

  static Widget _buildHeaderSection(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradients.cardGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'usage_intro'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReminderSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.notifications_active,
      title: 'স্মার্ট রিমাইন্ডার সিস্টেম',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'রিমাইন্ডার প্রকার:',
          items: [
            'ডিফল্ট রিমাইন্ডার: ৭টি সময়ে স্বয়ংক্রিয়ভাবে সক্রিয়',
            'ব্যক্তিগত রিমাইন্ডার: আপনার নিজস্ব সময় সেট করুন',
            'কাস্টম রিমাইন্ডার: যেকোনো আমলের জন্য',
            'পুনরাবৃত্তি: প্রতিদিন, নির্দিষ্ট দিন বা একবার',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'ডিফল্ট নামাজ রিমাইন্ডার (সবসময় সক্রিয়):',
          items: [
            'ফজরের ৩০ মিনিট পর',
            'যোহরের ৬০ মিনিট পর',
            'আসরের ১৫ মিনিট পর',
            'মাগরিবের ১০ মিনিট পর',
            'ইশার ৬০ মিনিট পর',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'ডিফল্ট যিকির ও আমল রিমাইন্ডার:',
          items: [
            'সকালের যিকির: ফজরের ৬০ মিনিট পর',
            'সন্ধ্যার যিকির: মাগরিবের ৩০ মিনিট পর',
            'দৈনিক আমল: প্রতিদিন রাত ১০:০০ টায়',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'ব্যক্তিগত রিমাইন্ডার সেটিংস:',
          items: [
            'সেটিংস → রিমাইন্ডারস → ব্যক্তিগত ট্যাব',
            'দৈনিক আমল, সকাল/সন্ধ্যা যিকির, নামাজের সময়',
            'আপনার সুবিধামত সময় পরিবর্তন করুন',
            'জামাত/স্থানীয় সময় অনুযায়ী adjustment',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'কাস্টম রিমাইন্ডার তৈরি:',
          items: [
            'সেটিংস → রিমাইন্ডারস → কাস্টম ট্যাব',
            'রিমাইন্ডারের নাম, সময় ও বিবরণ লিখুন',
            'সপ্তাহের নির্দিষ্ট দিন সিলেক্ট করুন',
            'নামাজের সময়ের সাথে offset করে সেট করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'রিমাইন্ডার সমস্যা সমাধান:',
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

  static Widget _buildPrayerSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.mosque,
      title: 'নামাজের ওয়াক্ত ক্যালকুলেশন',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'ওয়াক্ত ক্যালকুলেশন পদ্ধতি:',
          items: [
            'Calculation Method: University of Islamic Sciences, Karachi',
            'Madhab: Hanafi (Asr = ছায়া দ্বিগুণ)',
            'Coordinates: আপনার GPS location অনুযায়ী (২ দশমিক স্থান)',
            'API: AlAdhan Timings API',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'লোকেশন ও সময় নির্ধারণ:',
          items: [
            'আপনার বর্তমান GPS coordinates ব্যবহার করে',
            'লোকেশন বন্ধ থাকলে ঢাকার সময় অনুযায়ী দেখাবে',
            'একই এলাকার ডিভাইসে একই সময় দেখাবে',
            'Timezone: আপনার ডিভাইসের timezone অনুযায়ী',
            'Location permission প্রয়োজন সঠিক সময়ের জন্য',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'প্রতিটি ওয়াক্তের হিসাব:',
          items: [
            'ফজর: সুবহে সাদিক (সূর্যের 18° নিচে) থেকে সূর্যোদয়',
            'যোহর: সূর্য মধ্যাকাশ অতিক্রম করার পর',
            'আসর: ছায়া দ্বিগুণ হলে (Hanafi method)',
            'মাগরিব: সূর্যাস্তের সাথে সাথে',
            'ইশা: শাফাক (লাল আলো) অন্তর্ধান (17° angle)',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'মাকরূহ ওয়াক্ত (নিষিদ্ধ সময়):',
          items: [
            'সূর্যোদয়ের সময় ও তার পর 15 মিনিট',
            'যোহরের 10 মিনিট আগে (যাওয়াল)',
            'সূর্যাস্তের সময় ও তার 15 মিনিট আগে',
            'এই সময়ে কোনো নফল নামাজ পড়া যায় না',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'বিশেষ সময়সূচী:',
          items: [
            'ইশরাক: সূর্যোদয়ের 15 মিনিট পর',
            'চাশত: ইশরাক থেকে যাওয়াল পর্যন্ত',
            'তাহাজ্জুদ: ইশার পর থেকে ফজর পর্যন্ত',
            'নফল: মাকরূহ সময় ছাড়া যেকোনো সময়',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'নামাজ ট্র্যাকিং:',
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

  static Widget _buildAmalSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.star,
      title: 'দৈনিক আমল ট্র্যাকিং',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'প্রিসেট আমল তালিকা:',
          items: [
            'কুরআন তিলাওয়াত, তাহাজ্জুদ, ইস্তিগফার',
            'সকাল-সন্ধ্যার যিকির, দুরূদ শরীফ',
            'দান-সাদাকা, পিতামাতার সেবা',
            'নেক আমলের বিস্তৃত তালিকা',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'কাস্টম আমল যোগ:',
          items: [
            'নিজের মতো করে আমল তৈরি করুন',
            'আমলের নাম, বর্ণনা ও লক্ষ্য সেট করুন',
            'দৈনিক/সাপ্তাহিক ভিত্তিতে ট্র্যাক করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'প্রগ্রেস ট্র্যাকিং:',
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

  static Widget _buildDhikrSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.star,
      title: 'যিকির কাউন্টার',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'যিকির ট্র্যাকিং:',
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

  static Widget _buildReadingSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.book,
      title: 'পড়াশোনা ট্র্যাকার',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(          context: context,          title: 'তিন ধরনের পড়া ট্র্যাক:',
          items: [
            'কুরআন তিলাওয়াত: পৃষ্ঠা/আয়াত/সূরা ভিত্তিক',
            'তাফসীর পড়া: পৃষ্ঠা সংখ্যা দিয়ে',
            'হাদীস পড়া: হাদীস সংখ্যা দিয়ে',
            'প্রতিটির জন্য আলাদা লক্ষ্য ও প্রগ্রেস বার',
          ],
        ),
      ],
    );
  }

  static Widget _buildSinTrackerSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.warning,
      title: 'গুনাহ ট্র্যাকার (ঐচ্ছিক)',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'উদ্দেশ্য ও ব্যবহার:',
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

  static Widget _buildStatisticsSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.bar_chart,
      title: 'পরিসংখ্যান ও হিস্টোরি',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'ডেটা ভিজুয়ালাইজেশন:',
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

  static Widget _buildCloudSyncSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.cloud_sync,
      title: 'ক্লাউড সিঙ্ক ও ব্যাকআপ',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'স্বয়ংক্রিয় ও ম্যানুয়াল সিঙ্ক:',
          items: [
            'অটো সিঙ্ক: প্রতিটি পরিবর্তন তুরন্ত ক্লাউডে',
            'ম্যানুয়াল ব্যাকআপ: Profile → Backup Data',
            'রিস্টোর: Profile → Restore Data',
            'মাল্টি-ডিভাইস: একই একাউন্টে সব ডিভাইসে একই ডেটা',
            'অফলাইন মোড: ইন্টারনেট ছাড়াই কাজ করে',
          ],
        ),
      ],
    );
  }

  static Widget _buildSettingsSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.settings,
      title: 'সেটিংস ও কাস্টমাইজেশন',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'প্রধান সেটিংস:',
          items: [
            'Prayer Time Adjustment: স্থানীয় সময় অনুযায়ী +/- মিনিট',
            'রিমাইন্ডার কাস্টমাইজেশন: ডিফল্ট/ব্যক্তিগত/কাস্টম',
            'প্রোফাইল ম্যানেজমেন্ট: নাম, ইমেইল ভেরিফিকেশন',
            'থিম: ডার্ক মোড উইথ গোল্ড একসেন্ট (#D4AF37)',
          ],
        ),
      ],
    );
  }

  static Widget _buildTroubleshootingSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.help_outline,
      title: 'সমস্যা সমাধান (FAQ)',
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'সাধারণ সমস্যা ও সমাধান:',
          items: [
            'Prayer times update হচ্ছে না → GPS ও Internet চেক করুন',
            'Cloud sync কাজ করছে না → Email verify ও re-login করুন',
            'Notification আসছে না → Battery optimization disable করুন',
            'Statistics খালি → Activity complete করে refresh করুন',
            'App crash → Clear cache অথবা reinstall করুন',
          ],
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'পারফরমেন্স টিপস:',
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final textColor = gradients.bulletTextColor;
    
    return _buildFeatureCard(
      context: context,
      icon: Icons.support_agent,
      title: 'সাহায্য ও সাপোর্ট',
      color: primaryColor,
      children: [
        Text(
          'কোনো সমস্যা, বাগ রিপোর্ট, বা নতুন ফিচারের পরামর্শ থাকলে আমাদের ইমেইল করুন:',
          style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
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
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.email, color: primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  'effttech@gmail.com',
                  style: TextStyle(
                    color: primaryColor,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'টিপস: স্ক্রিনশট সহ সমস্যার বর্ণনা দিলে দ্রুত সমাধান পাবেন।',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Technical Reference: নামাজের ওয়াক্ত ক্যালকুলেশন University of Islamic Sciences, Karachi পদ্ধতি অনুযায়ী করা হয়েছে। Hanafi মাযহাব অনুসারে আসরের সময় নির্ধারণ করা হয়। GPS coordinates ব্যবহার করে AlAdhan API এর মাধ্যমে সঠিক সময় নির্ধারণ করা হয়।',
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  static Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
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
    required BuildContext context,
    required String title,
    required List<String> items,
  }) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final bulletColor = gradients.bulletTextColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
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
                  Text(
                    '• ',
                    style: TextStyle(color: bulletColor, fontSize: 16),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: bulletColor,
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
}
