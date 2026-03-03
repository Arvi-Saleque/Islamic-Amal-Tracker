import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../data/models/statistics_model.dart';

class WeeklyProgressChart extends StatelessWidget {
  final WeeklyStatistics weeklyStats;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyStats,
  });

  // Get Bengali weekday name from date string
  String _getWeekdayFromDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        // Dart weekday: 1=Mon, 2=Tue, ..., 7=Sun
        final weekdays = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];
        return weekdays[date.weekday - 1];
      }
    } catch (e) {
      // ignore
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final shadowColor = Theme.of(context).shadowColor;
    final bulletTextColor = gradients.bulletTextColor;
    
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'stats_weekly_progress'.tr(),
            style: TextStyle(
              color: onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                // Y-axis labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('100%', style: TextStyle(color: bulletTextColor, fontSize: 10)),
                    Text('75%', style: TextStyle(color: bulletTextColor, fontSize: 10)),
                    Text('50%', style: TextStyle(color: bulletTextColor, fontSize: 10)),
                    Text('25%', style: TextStyle(color: bulletTextColor, fontSize: 10)),
                    Text('0%', style: TextStyle(color: bulletTextColor, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: weeklyStats.days.isEmpty
                      ? Center(
                          child: Text(
                            'stats_no_data_yet'.tr(),
                            style: TextStyle(color: bulletTextColor),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => shadowColor.withOpacity(0.9),
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.toInt()}%',
                                    TextStyle(color: onSurface),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index >= 0 && index < weeklyStats.days.length) {
                                      final dayName = _getWeekdayFromDate(weeklyStats.days[index].date);
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Text(
                                          dayName,
                                          style: TextStyle(
                                            color: bulletTextColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 25,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: shadowColor.withOpacity(0.2),
                                strokeWidth: 1,
                              ),
                            ),
                            barGroups: weeklyStats.days.asMap().entries.map((entry) {
                              final score = entry.value.overallScore.toDouble();
                              return BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: score,
                                    color: _getBarColor(score, primary),
                                    width: 24,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(6),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(double score, Color primary) {
    if (score >= 80) {
      return primary;
    } else if (score >= 50) {
      return primary.withOpacity(0.7);
    } else if (score >= 1) {
      return primary.withOpacity(0.4);
    }
    return primary.withOpacity(0.2);
  }
}
