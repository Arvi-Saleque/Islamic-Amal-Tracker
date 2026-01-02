import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/statistics_provider.dart';
import '../../../data/models/statistics_model.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/streak_card.dart';
import 'widgets/tab_selector.dart';
import 'widgets/weekly_progress_chart.dart';
import 'widgets/monthly_calendar_view.dart';
import 'widgets/category_progress_section.dart';
import 'widgets/weekly_summary_section.dart';
import 'widgets/day_details_sheet.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool isWeeklyView = true;
  DateTime selectedMonth = DateTime.now();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statisticsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryGold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'পরিসংখ্যান',
          style: TextStyle(
            color: AppTheme.primaryGold,
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
            // Streak Card
            StreakCard(
              currentStreak: statsState.data.currentStreak,
              bestStreak: statsState.data.bestStreak,
            ),
            const SizedBox(height: 20),

            // Weekly/Monthly Tab Selector
            TabSelector(
              isWeeklyView: isWeeklyView,
              onTabChanged: (isWeekly) {
                setState(() {
                  isWeeklyView = isWeekly;
                  selectedDate = null;
                });
              },
            ),
            const SizedBox(height: 20),

            // Content based on selected tab
            if (isWeeklyView) ...[
              // Weekly Progress Chart
              WeeklyProgressChart(weeklyStats: statsState.weeklyStats),
              const SizedBox(height: 20),

              // Category Progress Section
              CategoryProgressSection(weeklyStats: statsState.weeklyStats),
              const SizedBox(height: 20),

              // Weekly Summary Section
              WeeklySummarySection(weeklyStats: statsState.weeklyStats),
            ] else ...[
              // Monthly Calendar View
              MonthlyCalendarView(
                selectedMonth: selectedMonth,
                selectedDate: selectedDate,
                statsData: statsState.data,
                onMonthChanged: (newMonth) {
                  setState(() {
                    selectedMonth = newMonth;
                    selectedDate = null;
                  });
                },
                onDateSelected: (date) {
                  setState(() {
                    selectedDate = date;
                  });
                  _showDayDetails(date, statsState);
                },
              ),
              const SizedBox(height: 20),

              // Monthly Progress Chart
              _buildMonthlyProgressChart(statsState),
              const SizedBox(height: 20),

              // Category Progress Section for Month
              CategoryProgressSection(
                weeklyStats: statsState.weeklyStats,
                isMonthly: true,
                monthlyStats: statsState.data.getMonthlyStats(),
              ),
              const SizedBox(height: 20),

              // Monthly Summary Section
              WeeklySummarySection(
                weeklyStats: statsState.weeklyStats,
                isMonthly: true,
                monthlyStats: statsState.data.getMonthlyStats(),
              ),
            ],

            // Show day details if date is selected
            if (selectedDate != null) ...[
              const SizedBox(height: 20),
              _buildSelectedDayDetails(selectedDate!, statsState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgressChart(StatisticsState statsState) {
    final monthlyStats = statsState.data.getMonthlyStatsForMonth(
      selectedMonth.year,
      selectedMonth.month,
    );

    // Group by week for chart display
    final weeklyAverages = _calculateWeeklyAverages(monthlyStats);

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
            'মাসিক অগ্রগতি',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Y-axis labels
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
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final weekLabels = _getWeekLabels(selectedMonth);
                              if (value.toInt() < weekLabels.length) {
                                return Text(
                                  weekLabels[value.toInt()],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
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
                      lineBarsData: [
                        LineChartBarData(
                          spots: weeklyAverages.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value,
                            );
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.primaryGold,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.primaryGold.withOpacity(0.1),
                          ),
                        ),
                      ],
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

  List<double> _calculateWeeklyAverages(List<DailyStatistics> monthlyStats) {
    if (monthlyStats.isEmpty) return [0, 0, 0, 0, 0];

    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final weeksCount = (daysInMonth / 7).ceil();
    final weeklyAverages = <double>[];

    for (int week = 0; week < weeksCount; week++) {
      final startDay = week * 7 + 1;
      final endDay = (week + 1) * 7;
      
      double sum = 0;
      int count = 0;
      
      for (final stat in monthlyStats) {
        final dateParts = stat.date.split('-');
        if (dateParts.length == 3) {
          final day = int.tryParse(dateParts[2]) ?? 0;
          if (day >= startDay && day <= endDay && day <= daysInMonth) {
            sum += stat.overallScore;
            count++;
          }
        }
      }
      
      weeklyAverages.add(count > 0 ? sum / count : 0);
    }

    return weeklyAverages;
  }

  List<String> _getWeekLabels(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final weeksCount = (daysInMonth / 7).ceil();
    final labels = <String>[];
    
    for (int week = 0; week < weeksCount; week++) {
      final startDay = week * 7 + 1;
      labels.add('$startDay');
    }
    
    return labels;
  }

  Widget _buildSelectedDayDetails(DateTime date, StatisticsState statsState) {
    final dateKey = _formatDate(date);
    final dayStats = statsState.data.dailyStats[dateKey];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.calendar_today,
                  color: AppTheme.primaryGold.withOpacity(0.7),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateBengali(date),
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getWeekdayBengali(date.weekday),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${dayStats?.overallScore ?? 0}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDayDetails(DateTime date, StatisticsState statsState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DayDetailsSheet(
        date: date,
        statsNotifier: ref.read(statisticsProvider.notifier),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateBengali(DateTime date) {
    final months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return '${_toBengaliNumber(date.day)} ${months[date.month - 1]}, ${_toBengaliNumber(date.year)}';
  }

  String _getWeekdayBengali(int weekday) {
    final days = ['সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার'];
    return days[weekday - 1];
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? bengaliDigits[index] : digit;
    }).join();
  }
}
