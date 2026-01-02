import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/statistics_model.dart';

class MonthlyCalendarView extends StatelessWidget {
  final DateTime selectedMonth;
  final DateTime? selectedDate;
  final StatisticsModel statsData;
  final Function(DateTime) onMonthChanged;
  final Function(DateTime) onDateSelected;

  const MonthlyCalendarView({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.statsData,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? bengaliDigits[index] : digit;
    }).join();
  }

  String _getMonthNameBengali(int month) {
    final months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getDateColor(int score) {
    if (score == 0) {
      return Colors.grey[850] ?? const Color(0xFF2A2A2A);
    } else if (score < 50) {
      return Colors.grey[700] ?? const Color(0xFF424242);
    } else if (score < 80) {
      return const Color(0xFF8B7930); // মাঝারি সোনালি
    }
    return AppTheme.primaryGold; // উজ্জ্বল সোনালি ৮০%+
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    // Adjust for Saturday start (Saturday = 6, Sunday = 0 in Dart)
    int startingWeekday = firstDayOfMonth.weekday;
    // Convert to Saturday-start: Sat=0, Sun=1, Mon=2, ..., Fri=6
    int adjustedStartDay = (startingWeekday + 1) % 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Month Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  onMonthChanged(DateTime(
                    selectedMonth.year,
                    selectedMonth.month - 1,
                  ));
                },
                icon: const Icon(Icons.chevron_left, color: Colors.grey),
              ),
              Text(
                '${_getMonthNameBengali(selectedMonth.month)} ${_toBengaliNumber(selectedMonth.year)}',
                style: const TextStyle(
                  color: AppTheme.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  onMonthChanged(DateTime(
                    selectedMonth.year,
                    selectedMonth.month + 1,
                  ));
                },
                icon: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Weekday Headers (Starting from Saturday)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayHeader('শনি'),
              _WeekdayHeader('রবি'),
              _WeekdayHeader('সোম'),
              _WeekdayHeader('মঙ্গল'),
              _WeekdayHeader('বুধ'),
              _WeekdayHeader('বৃহ'),
              _WeekdayHeader('শুক্র'),
            ],
          ),
          const SizedBox(height: 12),

          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 42, // 6 rows * 7 days
            itemBuilder: (context, index) {
              final dayNumber = index - adjustedStartDay + 1;
              
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox();
              }

              final date = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
              final dateKey = _formatDate(date);
              final dayStats = statsData.dailyStats[dateKey];
              final score = dayStats?.overallScore ?? 0;
              final isSelected = selectedDate != null &&
                  selectedDate!.year == date.year &&
                  selectedDate!.month == date.month &&
                  selectedDate!.day == date.day;
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              return GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getDateColor(score),
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: AppTheme.primaryGold, width: 2)
                        : isToday
                            ? Border.all(color: AppTheme.primaryGold.withOpacity(0.5), width: 1)
                            : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: score > 0 ? Colors.white : Colors.grey[400],
                        fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(color: Colors.grey[850] ?? const Color(0xFF2A2A2A), label: '০%'),
              const SizedBox(width: 12),
              _LegendItem(color: Colors.grey[700] ?? const Color(0xFF424242), label: '১-৪৯%'),
              const SizedBox(width: 12),
              const _LegendItem(color: Color(0xFF8B7930), label: '৫০-৭৯%'),
              const SizedBox(width: 12),
              const _LegendItem(color: AppTheme.primaryGold, label: '৮০%+'),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String day;

  const _WeekdayHeader(this.day);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        day,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
