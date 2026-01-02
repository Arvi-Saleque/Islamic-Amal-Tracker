import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
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
            'সাপ্তাহিক অগ্রগতি',
            style: TextStyle(
              color: Colors.white,
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
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('100%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('75%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('50%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('25%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('0%', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: weeklyStats.days.isEmpty
                      ? const Center(
                          child: Text(
                            'এখনো কোনো ডেটা নেই',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) => Colors.grey[800]!,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  return BarTooltipItem(
                                    '${rod.toY.toInt()}%',
                                    const TextStyle(color: Colors.white),
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
                                          style: const TextStyle(
                                            color: Colors.grey,
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
                                color: Colors.grey.withOpacity(0.2),
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
                                    color: _getBarColor(score),
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

  Color _getBarColor(double score) {
    if (score >= 80) {
      return AppTheme.primaryGold;
    } else if (score >= 50) {
      return AppTheme.primaryGold.withOpacity(0.7);
    } else if (score >= 1) {
      return AppTheme.primaryGold.withOpacity(0.4);
    }
    return Colors.grey[700]!;
  }
}
