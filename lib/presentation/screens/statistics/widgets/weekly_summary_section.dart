import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/statistics_model.dart';

class WeeklySummarySection extends StatelessWidget {
  final WeeklyStatistics weeklyStats;
  final bool isMonthly;
  final List<DailyStatistics>? monthlyStats;

  const WeeklySummarySection({
    super.key,
    required this.weeklyStats,
    this.isMonthly = false,
    this.monthlyStats,
  });

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
    final stats = isMonthly && monthlyStats != null ? monthlyStats! : weeklyStats.days;
    
    int totalPrayers = 0;
    int maxPrayers = 0;
    int totalAmal = 0;
    int maxAmal = 0;
    int totalDhikr = 0;
    int maxDhikr = 0;
    int totalReadingMinutes = 0;
    int maxReadingMinutes = 0;
    int perfectDays = 0;
    int totalDays = isMonthly ? 30 : 7;

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

    final title = isMonthly ? 'মাসিক সারসংক্ষেপ' : 'সাপ্তাহিক সারসংক্ষেপ';

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
        
        // Summary Cards Grid
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.mosque,
                iconColor: AppTheme.primaryGold,
                title: 'মোট\nনামাজ',
                value: _toBengaliNumber(totalPrayers),
                subtitle: '/${_toBengaliNumber(maxPrayers)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.primaryGold,
                title: 'মোট আমল',
                value: _toBengaliNumber(totalAmal),
                subtitle: '/${_toBengaliNumber(maxAmal)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.favorite,
                iconColor: AppTheme.primaryGold,
                title: 'মোট\nযিকির',
                value: _toBengaliNumber(totalDhikr),
                subtitle: '/${_toBengaliNumber(maxDhikr)}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.menu_book,
                iconColor: AppTheme.primaryGold,
                title: 'পড়ার সময়',
                value: _toBengaliNumber(totalReadingMinutes),
                subtitle: '/${_toBengaliNumber(maxReadingMinutes)} মিনিট',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Perfect Days Card
        _PerfectDaysCard(
          perfectDays: perfectDays,
          totalDays: totalDays,
          toBengaliNumber: _toBengaliNumber,
        ),
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
