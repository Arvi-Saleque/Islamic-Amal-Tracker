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

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[0],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[1],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarBorder,
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
        gradient: LinearGradient(colors: gradients.cardGradient),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
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
      title: 'usage_reminder_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_reminder_types_title'.tr(),
          items: [
            'usage_reminder_types_1',
            'usage_reminder_types_2',
            'usage_reminder_types_3',
            'usage_reminder_types_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_reminder_default_prayer_title'.tr(),
          items: [
            'usage_reminder_default_prayer_1',
            'usage_reminder_default_prayer_2',
            'usage_reminder_default_prayer_3',
            'usage_reminder_default_prayer_4',
            'usage_reminder_default_prayer_5',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_reminder_default_dhikr_title'.tr(),
          items: [
            'usage_reminder_default_dhikr_1',
            'usage_reminder_default_dhikr_2',
            'usage_reminder_default_dhikr_3',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_reminder_personal_title'.tr(),
          items: [
            'usage_reminder_personal_1',
            'usage_reminder_personal_2',
            'usage_reminder_personal_3',
            'usage_reminder_personal_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_reminder_custom_title'.tr(),
          items: [
            'usage_reminder_custom_1',
            'usage_reminder_custom_2',
            'usage_reminder_custom_3',
            'usage_reminder_custom_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_reminder_trouble_title'.tr(),
          items: [
            'usage_reminder_trouble_1',
            'usage_reminder_trouble_2',
            'usage_reminder_trouble_3',
            'usage_reminder_trouble_4',
            'usage_reminder_trouble_5',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildPrayerSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.mosque,
      title: 'usage_prayer_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_prayer_calc_title'.tr(),
          items: [
            'usage_prayer_calc_1',
            'usage_prayer_calc_2',
            'usage_prayer_calc_3',
            'usage_prayer_calc_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_prayer_location_title'.tr(),
          items: [
            'usage_prayer_location_1',
            'usage_prayer_location_2',
            'usage_prayer_location_3',
            'usage_prayer_location_4',
            'usage_prayer_location_5',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_prayer_waqt_title'.tr(),
          items: [
            'usage_prayer_waqt_1',
            'usage_prayer_waqt_2',
            'usage_prayer_waqt_3',
            'usage_prayer_waqt_4',
            'usage_prayer_waqt_5',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_prayer_makruh_title'.tr(),
          items: [
            'usage_prayer_makruh_1',
            'usage_prayer_makruh_2',
            'usage_prayer_makruh_3',
            'usage_prayer_makruh_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_prayer_special_title'.tr(),
          items: [
            'usage_prayer_special_1',
            'usage_prayer_special_2',
            'usage_prayer_special_3',
            'usage_prayer_special_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_prayer_tracking_title'.tr(),
          items: [
            'usage_prayer_tracking_1',
            'usage_prayer_tracking_2',
            'usage_prayer_tracking_3',
            'usage_prayer_tracking_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildAmalSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.star,
      title: 'usage_amal_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_amal_preset_title'.tr(),
          items: [
            'usage_amal_preset_1',
            'usage_amal_preset_2',
            'usage_amal_preset_3',
            'usage_amal_preset_4',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_amal_custom_title'.tr(),
          items: [
            'usage_amal_custom_1',
            'usage_amal_custom_2',
            'usage_amal_custom_3',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_amal_progress_title'.tr(),
          items: [
            'usage_amal_progress_1',
            'usage_amal_progress_2',
            'usage_amal_progress_3',
            'usage_amal_progress_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildDhikrSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.star,
      title: 'usage_dhikr_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_dhikr_tracking_title'.tr(),
          items: [
            'usage_dhikr_tracking_1',
            'usage_dhikr_tracking_2',
            'usage_dhikr_tracking_3',
            'usage_dhikr_tracking_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildReadingSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.book,
      title: 'usage_reading_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_reading_types_title'.tr(),
          items: [
            'usage_reading_types_1',
            'usage_reading_types_2',
            'usage_reading_types_3',
            'usage_reading_types_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildSinTrackerSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.warning,
      title: 'usage_sin_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_sin_purpose_title'.tr(),
          items: [
            'usage_sin_purpose_1',
            'usage_sin_purpose_2',
            'usage_sin_purpose_3',
            'usage_sin_purpose_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildStatisticsSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.bar_chart,
      title: 'usage_stats_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_stats_viz_title'.tr(),
          items: [
            'usage_stats_viz_1',
            'usage_stats_viz_2',
            'usage_stats_viz_3',
            'usage_stats_viz_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildCloudSyncSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.cloud_sync,
      title: 'usage_cloud_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_cloud_sync_title'.tr(),
          items: [
            'usage_cloud_sync_1',
            'usage_cloud_sync_2',
            'usage_cloud_sync_3',
            'usage_cloud_sync_4',
            'usage_cloud_sync_5',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildSettingsSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.settings,
      title: 'usage_settings_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_settings_main_title'.tr(),
          items: [
            'usage_settings_main_1',
            'usage_settings_main_2',
            'usage_settings_main_3',
            'usage_settings_main_4',
          ].map((k) => k.tr()).toList(),
        ),
      ],
    );
  }

  static Widget _buildTroubleshootingSection(BuildContext context) {
    return _buildFeatureCard(
      context: context,
      icon: Icons.help_outline,
      title: 'usage_trouble_title'.tr(),
      color: Theme.of(context).colorScheme.primary,
      children: [
        _buildSubSection(
          context: context,
          title: 'usage_trouble_common_title'.tr(),
          items: [
            'usage_trouble_common_1',
            'usage_trouble_common_2',
            'usage_trouble_common_3',
            'usage_trouble_common_4',
            'usage_trouble_common_5',
          ].map((k) => k.tr()).toList(),
        ),
        const SizedBox(height: 12),
        _buildSubSection(
          context: context,
          title: 'usage_trouble_tips_title'.tr(),
          items: [
            'usage_trouble_tips_1',
            'usage_trouble_tips_2',
            'usage_trouble_tips_3',
          ].map((k) => k.tr()).toList(),
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
      title: 'usage_contact_title'.tr(),
      color: primaryColor,
      children: [
        Text(
          'usage_contact_intro'.tr(),
          style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'effttech@gmail.com',
              queryParameters: {'subject': 'usage_contact_email_subject'.tr()},
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
          'usage_contact_tips'.tr(),
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'usage_contact_tech_ref'.tr(),
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
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(color: bulletColor, fontSize: 16)),
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
          ),
        ),
      ],
    );
  }
}
