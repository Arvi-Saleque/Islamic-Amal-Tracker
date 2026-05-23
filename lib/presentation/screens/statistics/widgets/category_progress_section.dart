import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/statistics_model.dart';

class CategoryProgressSection extends StatelessWidget {
  final WeeklyStatistics weeklyStats;
  final bool isMonthly;
  final List<DailyStatistics>? monthlyStats;

  const CategoryProgressSection({
    super.key,
    required this.weeklyStats,
    this.isMonthly = false,
    this.monthlyStats,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // Calculate averages based on view type
    final stats = isMonthly && monthlyStats != null
        ? monthlyStats!
        : weeklyStats.days;

    double avgPrayer = 0;
    double avgAmal = 0;
    double avgDhikr = 0;
    double avgReading = 0;

    if (stats.isNotEmpty) {
      avgPrayer =
          stats.map((d) => d.prayerProgress).reduce((a, b) => a + b) /
          stats.length;
      avgAmal =
          stats.map((d) => d.amalProgress).reduce((a, b) => a + b) /
          stats.length;
      avgDhikr =
          stats.map((d) => d.dhikrProgress).reduce((a, b) => a + b) /
          stats.length;
      avgReading =
          stats.map((d) => d.readingProgress).reduce((a, b) => a + b) /
          stats.length;
    }

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'stats_category_progress'.tr(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Namaz
          _CategoryProgressItem(
            icon: Icons.mosque,
            iconColor: primary,
            title: 'prayer_section'.tr(),
            progress: avgPrayer,
          ),
          const SizedBox(height: 16),

          // Daily Amal
          _CategoryProgressItem(
            icon: Icons.check_circle_outline,
            iconColor: primary,
            title: 'daily_section'.tr(),
            progress: avgAmal,
          ),
          const SizedBox(height: 16),

          // Dhikr
          _CategoryProgressItem(
            icon: Icons.favorite,
            iconColor: primary,
            title: 'dhikr_section'.tr(),
            progress: avgDhikr,
          ),
          const SizedBox(height: 16),

          // Reading
          _CategoryProgressItem(
            icon: Icons.menu_book,
            iconColor: primary,
            title: 'reading_section'.tr(),
            progress: avgReading,
          ),
        ],
      ),
    );
  }
}

class _CategoryProgressItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final double progress;

  const _CategoryProgressItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toInt();

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
