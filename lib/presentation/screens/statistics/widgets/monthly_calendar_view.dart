import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/statistics_model.dart';

class MonthlyCalendarView extends StatefulWidget {
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

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  Map<String, int> _monthScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  @override
  void didUpdateWidget(MonthlyCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _loadMonthData();
    }
  }

  Future<void> _loadMonthData() async {
    setState(() => _isLoading = true);
    
    final scores = <String, int>{};
    final daysInMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0).day;
    
    try {
      final prayerBox = await Hive.openBox('prayer_tracking');
      final amalBox = await Hive.openBox('daily_amal');
      final dhikrBox = await Hive.openBox('dhikr_counter');
      final readingBox = await Hive.openBox('reading_tracker');

      for (int day = 1; day <= daysInMonth; day++) {
        final dateKey = _formatDate(DateTime(widget.selectedMonth.year, widget.selectedMonth.month, day));
        
        // Get prayer data - Count completed prayers
        int prayersCompleted = 0;
        final prayerData = prayerBox.get(dateKey);
        if (prayerData != null) {
          final prayerDone = prayerData['prayerDone'] as Map?;
          if (prayerDone != null) {
            for (var done in prayerDone.values) {
              if (done == true) {
                prayersCompleted++;
              }
            }
          }
        }

        // Get amal data - Count completed items
        int amalCompleted = 0;
        int totalAmal = 1; // Avoid division by zero
        final amalData = amalBox.get(dateKey);
        if (amalData != null) {
          final items = amalData['items'] as List?;
          if (items != null && items.isNotEmpty) {
            totalAmal = items.length;
            for (var item in items) {
              if (item is Map && item['isCompleted'] == true) {
                amalCompleted++;
              }
            }
          }
        }

        // Get dhikr data - Sum all counts vs targets
        int dhikrCount = 0;
        int dhikrTarget = 1; // Avoid division by zero
        final dhikrData = dhikrBox.get(dateKey);
        if (dhikrData != null) {
          final items = dhikrData['items'] as List?;
          if (items != null && items.isNotEmpty) {
            dhikrTarget = 0;
            for (var item in items) {
              if (item is Map) {
                dhikrCount += (item['currentCount'] as int? ?? item['count'] as int? ?? 0);
                dhikrTarget += (item['targetCount'] as int? ?? item['target'] as int? ?? 100);
              }
            }
            if (dhikrTarget == 0) dhikrTarget = 1;
          }
        }

        // Get reading data - Total minutes
        int readingMinutes = 0;
        final readingData = readingBox.get(dateKey);
        if (readingData != null) {
          final sessions = readingData['sessions'] as List?;
          if (sessions != null) {
            for (var session in sessions) {
              if (session is Map) {
                readingMinutes += (session['duration'] as int? ?? 0);
              }
            }
          }
        }

        // Calculate overall score - only count categories that have data
        double prayerProgress = prayersCompleted / 5.0;
        double amalProgress = amalCompleted / totalAmal;
        double dhikrProgress = (dhikrCount / dhikrTarget).clamp(0.0, 1.0);
        double readingProgress = (readingMinutes / 35.0).clamp(0.0, 1.0); // 35 min target (15+10+10)

        // Count only active categories (has some data for that day)
        double totalProgress = 0;
        int activeCategories = 0;
        
        // Prayer is always counted if there's any prayer data for the day
        if (prayerData != null) {
          totalProgress += prayerProgress;
          activeCategories++;
        }
        
        // Amal is counted if there's amal data
        if (amalData != null && totalAmal > 0) {
          totalProgress += amalProgress;
          activeCategories++;
        }
        
        // Dhikr is counted only if user has done some dhikr
        if (dhikrData != null && dhikrCount > 0) {
          totalProgress += dhikrProgress;
          activeCategories++;
        }
        
        // Reading is counted only if user has read something
        if (readingData != null && readingMinutes > 0) {
          totalProgress += readingProgress;
          activeCategories++;
        }

        int score = 0;
        if (activeCategories > 0) {
          score = ((totalProgress / activeCategories) * 100).toInt();
        }
        
        // Debug log
        debugPrint('📅 $dateKey: Prayer=$prayersCompleted/5, Amal=$amalCompleted/$totalAmal, Dhikr=$dhikrCount/$dhikrTarget, Read=${readingMinutes}min, Active=$activeCategories → Score=$score%');
        
        if (score > 0) {
          scores[dateKey] = score;
        }
      }
    } catch (e) {
      debugPrint('Error loading month data: $e');
    }

    if (mounted) {
      setState(() {
        _monthScores = scores;
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  Color _getDateColor(int score) {
    if (score == 0) {
      return Colors.grey[850] ?? const Color(0xFF2A2A2A); // ধূসর (০%)
    } else if (score < 80) {
      return const Color(0xFF7A6528); // হালকা/ডিম গোল্ড (১-৭৯%)
    }
    return AppTheme.primaryGold; // ফুল গোল্ড (৮০%+)
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, 1);
    int startingWeekday = firstDayOfMonth.weekday;
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
                  widget.onMonthChanged(DateTime(
                    widget.selectedMonth.year,
                    widget.selectedMonth.month - 1,
                  ));
                },
                icon: const Icon(Icons.chevron_left, color: Colors.grey),
              ),
              Text(
                '${_getMonthNameBengali(widget.selectedMonth.month)} ${_toBengaliNumber(widget.selectedMonth.year)}',
                style: const TextStyle(
                  color: AppTheme.primaryGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.onMonthChanged(DateTime(
                    widget.selectedMonth.year,
                    widget.selectedMonth.month + 1,
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
          _isLoading 
            ? const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryGold),
                ),
              )
            : GridView.builder(
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

              final date = DateTime(widget.selectedMonth.year, widget.selectedMonth.month, dayNumber);
              final dateKey = _formatDate(date);
              final score = _monthScores[dateKey] ?? 0;
              final isSelected = widget.selectedDate != null &&
                  widget.selectedDate!.year == date.year &&
                  widget.selectedDate!.month == date.month &&
                  widget.selectedDate!.day == date.day;
              final isToday = DateTime.now().year == date.year &&
                  DateTime.now().month == date.month &&
                  DateTime.now().day == date.day;

              return GestureDetector(
                onTap: () => widget.onDateSelected(date),
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
              const SizedBox(width: 16),
              const _LegendItem(color: Color(0xFF7A6528), label: '১-৭৯%'),
              const SizedBox(width: 16),
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
