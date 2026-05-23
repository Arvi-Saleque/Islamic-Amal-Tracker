import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/models/statistics_model.dart';
import '../../../providers/sin_tracker_provider.dart';

class WeeklySummarySection extends ConsumerStatefulWidget {
  final WeeklyStatistics weeklyStats;
  final bool isMonthly;
  final List<DailyStatistics>? monthlyStats;

  const WeeklySummarySection({
    super.key,
    required this.weeklyStats,
    this.isMonthly = false,
    this.monthlyStats,
  });

  @override
  ConsumerState<WeeklySummarySection> createState() =>
      _WeeklySummarySectionState();
}

class _WeeklySummarySectionState extends ConsumerState<WeeklySummarySection> {
  int weeklySinCount = 0;
  int jamaatPrayers = 0;
  int delayedPrayers = 0;

  @override
  void initState() {
    super.initState();
    _loadSinCount();
    _loadPrayerDetails();
  }

  @override
  void didUpdateWidget(WeeklySummarySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMonthly != widget.isMonthly ||
        oldWidget.monthlyStats != widget.monthlyStats ||
        oldWidget.weeklyStats != widget.weeklyStats) {
      _loadPrayerDetails();
    }
  }

  Future<void> _loadPrayerDetails() async {
    int jamaat = 0;
    int delayed = 0;

    try {
      final prayerBox = await Hive.openBox('prayer_tracking');
      final stats = widget.isMonthly && widget.monthlyStats != null
          ? widget.monthlyStats!
          : widget.weeklyStats.days;

      for (final day in stats) {
        final dateKey = day.date;
        final prayerData = prayerBox.get(dateKey);

        if (prayerData != null) {
          final rakatsDone = prayerData['rakatsDone'] as Map?;
          if (rakatsDone != null) {
            for (var prayerRakats in rakatsDone.values) {
              if (prayerRakats is Map) {
                for (var entry in prayerRakats.entries) {
                  final rakatName = entry.key.toString();
                  final isDone = entry.value == true;

                  if (isDone) {
                    // Check if it's a fard prayer (জামাতে/আউয়াল ওয়াক্তে or দেরী করে)
                    if (rakatName.contains('ফরয') &&
                        rakatName.contains('জামাতে/আউয়াল ওয়াক্তে')) {
                      jamaat++;
                    } else if (rakatName.contains('ফরয') &&
                        rakatName.contains('দেরী করে')) {
                      delayed++;
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading prayer details: $e');
    }

    if (mounted) {
      setState(() {
        jamaatPrayers = jamaat;
        delayedPrayers = delayed;
      });
    }
  }

  Future<void> _loadSinCount() async {
    if (!widget.isMonthly) {
      final count = await ref
          .read(sinTrackerProvider.notifier)
          .getWeeklySinCount();
      if (mounted) {
        setState(() {
          weeklySinCount = count;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final shadowColor = Theme.of(context).shadowColor;
    final bulletTextColor = gradients.bulletTextColor;

    // Calculate totals based on view type
    final stats = widget.isMonthly && widget.monthlyStats != null
        ? widget.monthlyStats!
        : widget.weeklyStats.days;

    int totalPrayers = 0;
    int maxPrayers = 0;
    int totalAmal = 0;
    int maxAmal = 0;
    int totalDhikr = 0;
    int maxDhikr = 0;
    int totalReadingMinutes = 0;
    int maxReadingMinutes = 0;
    int perfectDays = 0;
    int totalDays = widget.isMonthly ? 30 : 7;

    for (final day in stats) {
      totalPrayers += day.prayersCompleted;
      maxPrayers += day.totalPrayers;
      totalAmal += day.amalCompleted;
      maxAmal += day.totalAmal;
      totalDhikr += day.dhikrCount;
      maxDhikr += day.dhikrTarget;
      totalReadingMinutes += day.readingMinutes;
      maxReadingMinutes += day.readingTarget;
      if (day.overallScore >= 80) perfectDays++;
    }

    final title = widget.isMonthly
        ? 'stats_monthly_summary'.tr()
        : 'stats_weekly_summary'.tr();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: onSurface,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Namaz Details Card (with Jamaat/Delayed breakdown)
        _PrayerDetailCard(
          totalPrayers: totalPrayers,
          maxPrayers: maxPrayers,
          jamaatPrayers: jamaatPrayers,
          delayedPrayers: delayedPrayers,
        ),
        const SizedBox(height: 12),

        // Summary Cards Grid
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                iconColor: primary,
                title: 'stats_total_amal'.tr(),
                value: totalAmal.toString(),
                subtitle: '/${maxAmal.toString()}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.favorite,
                iconColor: primary,
                title: 'stats_total_dhikr'.tr(),
                value: totalDhikr.toString(),
                subtitle: '/${maxDhikr.toString()}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.menu_book,
                iconColor: primary,
                title: 'stats_reading_time'.tr(),
                value: totalReadingMinutes.toString(),
                subtitle:
                    '/${maxReadingMinutes.toString()} ${'stats_minutes'.tr()}',
              ),
            ),
            const SizedBox(width: 12),
            // Perfect Days Card (inline)
            Expanded(
              child: _SummaryCard(
                icon: Icons.star,
                iconColor: primary,
                title: 'stats_full_day'.tr(),
                value: perfectDays.toString(),
                subtitle: '/${totalDays.toString()} ${'stats_days'.tr()}',
              ),
            ),
          ],
        ),

        // Sin Count Card - Only for weekly view
        if (!widget.isMonthly) ...[
          const SizedBox(height: 12),
          _SinCountCard(sinCount: weeklySinCount),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final bulletTextColor = gradients.bulletTextColor;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
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
                Text(
                  title,
                  style: TextStyle(color: bulletTextColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        TextSpan(
                          text: subtitle,
                          style: TextStyle(
                            color: bulletTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SinCountCard extends StatelessWidget {
  final int sinCount;

  const _SinCountCard({required this.sinCount});

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final bulletTextColor = gradients.bulletTextColor;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_fix_high, color: primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stats_total_sins'.tr(),
                  style: TextStyle(color: bulletTextColor, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  sinCount == 0
                      ? 'stats_mashallah_no_sin'.tr()
                      : 'stats_sin_count'.tr(
                          namedArgs: {'count': sinCount.toString()},
                        ),
                  style: TextStyle(
                    color: sinCount == 0 ? const Color(0xFF4CAF50) : primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Prayer Detail Card with Jamaat/Delayed breakdown
class _PrayerDetailCard extends StatelessWidget {
  final int totalPrayers;
  final int maxPrayers;
  final int jamaatPrayers;
  final int delayedPrayers;

  const _PrayerDetailCard({
    required this.totalPrayers,
    required this.maxPrayers,
    required this.jamaatPrayers,
    required this.delayedPrayers,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final shadowColor = Theme.of(context).shadowColor;
    final bulletTextColor = gradients.bulletTextColor;

    // Check if we have detailed data
    final hasDetailedData = jamaatPrayers > 0 || delayedPrayers > 0;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.mosque, color: primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'stats_total_prayer'.tr(),
                      style: TextStyle(color: bulletTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: totalPrayers.toString(),
                            style: TextStyle(
                              color: primary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                '/${maxPrayers.toString()} ${'stats_waqt'.tr()}',
                            style: TextStyle(
                              color: bulletTextColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Detailed breakdown (only show if data available)
          if (hasDetailedData) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: shadowColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Jamaat/Awal Waqt
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.groups,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'stats_on_time'.tr(),
                                style: TextStyle(
                                  color: bulletTextColor,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '$jamaatPrayers ${'stats_waqt'.tr()}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 40,
                    color: shadowColor.withOpacity(0.3),
                  ),

                  // Delayed
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'stats_late'.tr(),
                                style: TextStyle(
                                  color: bulletTextColor,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '$delayedPrayers ${'stats_waqt'.tr()}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.primary,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
