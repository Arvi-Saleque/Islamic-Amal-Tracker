import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_theme.dart';
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
      final count =
          await ref.read(sinTrackerProvider.notifier).getWeeklySinCount();
      if (mounted) {
        setState(() {
          weeklySinCount = count;
        });
      }
    }
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? bengaliDigits[index] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
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

    final title =
        widget.isMonthly ? 'মাসিক সারসংক্ষেপ' : 'সাপ্তাহিক সারসংক্ষেপ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
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
          toBengaliNumber: _toBengaliNumber,
        ),
        const SizedBox(height: 12),

        // Summary Cards Grid
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.primaryGold,
                title: 'মোট আমল',
                value: _toBengaliNumber(totalAmal),
                subtitle: '/${_toBengaliNumber(maxAmal)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.favorite,
                iconColor: AppTheme.primaryGold,
                title: 'মোট\nযিকির',
                value: _toBengaliNumber(totalDhikr),
                subtitle: '/${_toBengaliNumber(maxDhikr)}',
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
                iconColor: AppTheme.primaryGold,
                title: 'পড়ার সময়',
                value: _toBengaliNumber(totalReadingMinutes),
                subtitle: '/${_toBengaliNumber(maxReadingMinutes)} মিনিট',
              ),
            ),
            const SizedBox(width: 12),
            // Perfect Days Card (inline)
            Expanded(
              child: _SummaryCard(
                icon: Icons.star,
                iconColor: AppTheme.primaryGold,
                title: 'পূর্ণ দিন',
                value: _toBengaliNumber(perfectDays),
                subtitle: '/${_toBengaliNumber(totalDays)} দিন',
              ),
            ),
          ],
        ),

        // Sin Count Card - Only for weekly view
        if (!widget.isMonthly) ...[
          const SizedBox(height: 12),
          _SinCountCard(
            sinCount: weeklySinCount,
            toBengaliNumber: _toBengaliNumber,
          ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        TextSpan(
                          text: subtitle,
                          style: const TextStyle(
                            color: Colors.grey,
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
    );
  }
}

class _PerfectDaysCard extends StatelessWidget {
  final int perfectDays;
  final int totalDays;
  final String Function(int) toBengaliNumber;

  const _PerfectDaysCard({
    required this.perfectDays,
    required this.totalDays,
    required this.toBengaliNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star,
              color: AppTheme.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'পূর্ণ দিন',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: toBengaliNumber(perfectDays),
                        style: const TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '/${toBengaliNumber(totalDays)} দিন',
                        style: const TextStyle(
                          color: Colors.grey,
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
    );
  }
}

class _SinCountCard extends StatelessWidget {
  final int sinCount;
  final String Function(int) toBengaliNumber;

  const _SinCountCard({
    required this.sinCount,
    required this.toBengaliNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_fix_high,
              color: AppTheme.primaryGold,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'মোট গুনাহ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sinCount == 0
                      ? 'মাশাআল্লাহ! কোনো গুনাহ নেই'
                      : '${toBengaliNumber(sinCount)} টি গুনাহ',
                  style: TextStyle(
                    color: sinCount == 0
                        ? const Color(0xFF4CAF50)
                        : AppTheme.primaryGold,
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
  final String Function(int) toBengaliNumber;

  const _PrayerDetailCard({
    required this.totalPrayers,
    required this.maxPrayers,
    required this.jamaatPrayers,
    required this.delayedPrayers,
    required this.toBengaliNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Check if we have detailed data
    final hasDetailedData = jamaatPrayers > 0 || delayedPrayers > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque,
                  color: AppTheme.primaryGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'মোট নামাজ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: toBengaliNumber(totalPrayers),
                            style: const TextStyle(
                              color: AppTheme.primaryGold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '/${toBengaliNumber(maxPrayers)} ওয়াক্ত',
                            style: const TextStyle(
                              color: Colors.grey,
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
                color: const Color(0xFF0A0A0A),
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
                            color: const Color(0xFF4CAF50).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.groups,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'জামাতে/সময়মত',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${toBengaliNumber(jamaatPrayers)} ওয়াক্ত',
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
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
                    color: Colors.grey.withOpacity(0.3),
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
                              const Text(
                                'দেরীতে',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                '${toBengaliNumber(delayedPrayers)} ওয়াক্ত',
                                style: const TextStyle(
                                  color: Color(0xFFFF9800),
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
                            color: const Color(0xFFFF9800).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Color(0xFFFF9800),
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
