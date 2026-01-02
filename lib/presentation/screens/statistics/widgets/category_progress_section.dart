import 'package:flutter/material.dart';
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
    // Calculate averages based on view type
    final stats = isMonthly && monthlyStats != null ? monthlyStats! : weeklyStats.days;
    
    double avgPrayer = 0;
    double avgAmal = 0;
    double avgDhikr = 0;
    double avgReading = 0;

    if (stats.isNotEmpty) {
      avgPrayer = stats.map((d) => d.prayerProgress).reduce((a, b) => a + b) / stats.length;
      avgAmal = stats.map((d) => d.amalProgress).reduce((a, b) => a + b) / stats.length;
      avgDhikr = stats.map((d) => d.dhikrProgress).reduce((a, b) => a + b) / stats.length;
      avgReading = stats.map((d) => d.readingProgress).reduce((a, b) => a + b) / stats.length;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'বিভাগ অনুযায়ী অগ্রগতি',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Namaz
          _CategoryProgressItem(
            icon: Icons.mosque,
            iconColor: AppTheme.primaryGold,
            title: 'নামাজ',
            progress: avgPrayer,
          ),
          const SizedBox(height: 16),

          // Daily Amal
          _CategoryProgressItem(
            icon: Icons.check_circle_outline,
            iconColor: AppTheme.primaryGold,
            title: 'প্রতিদিনের আমল',
            progress: avgAmal,
          ),
          const SizedBox(height: 16),

          // Dhikr
          _CategoryProgressItem(
            icon: Icons.favorite,
            iconColor: AppTheme.primaryGold,
            title: 'যিকির',
            progress: avgDhikr,
          ),
          const SizedBox(height: 16),

          // Reading
          _CategoryProgressItem(
            icon: Icons.menu_book,
            iconColor: AppTheme.primaryGold,
            title: 'পড়াশোনা',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
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
                  backgroundColor: Colors.grey[800],
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
