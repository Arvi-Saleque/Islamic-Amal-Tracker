import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../providers/statistics_provider.dart';
import '../../../../data/models/sin_tracker_model.dart';
import 'package:hive/hive.dart';

class DayDetailsSheet extends StatefulWidget {
  final DateTime date;
  final StatisticsNotifier statsNotifier;

  const DayDetailsSheet({
    super.key,
    required this.date,
    required this.statsNotifier,
  });

  @override
  State<DayDetailsSheet> createState() => _DayDetailsSheetState();
}

class _DayDetailsSheetState extends State<DayDetailsSheet> {
  DayDetailedData? detailedData;
  bool isLoading = true;
  DailySinRecord? sinRecord;
  List<SinType> allSinTypes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dateKey = _formatDate(widget.date);
    final data = await widget.statsNotifier.getDetailedDataForDate(dateKey);
    
    // Load sin data and sin types
    DailySinRecord? sinData;
    List<SinType> sinTypes = getDefaultSinTypes();
    
    try {
      final box = Hive.box('sin_tracker');
      
      // Load sin record for the date
      final sinJson = box.get(dateKey);
      if (sinJson != null) {
        sinData = DailySinRecord.fromJson(Map<String, dynamic>.from(sinJson));
      }
      
      // Load all sin types (default + custom)
      final sinTypesData = box.get('sin_types');
      if (sinTypesData != null) {
        final List<dynamic> typesList = List<dynamic>.from(sinTypesData);
        sinTypes = typesList.map((s) {
          final map = Map<String, dynamic>.from(s);
          return SinType.fromJson(map);
        }).toList();
      }
    } catch (e) {
      // Handle error silently
    }
    
    if (mounted) {
      setState(() {
        detailedData = data;
        sinRecord = sinData;
        allSinTypes = sinTypes;
        isLoading = false;
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

  int _calculateOverallScore() {
    if (detailedData == null) return 0;
    
    double prayerScore = 0;
    double amalScore = 0;
    double dhikrScore = 0;
    double readingScore = 0;

    final prayer = detailedData!.prayerModel;
    if (prayer != null) {
      prayerScore = prayer.completedPrayersCount / 5;
    }

    final amal = detailedData!.amalModel;
    if (amal != null && amal.totalCount > 0) {
      amalScore = amal.completedCount / amal.totalCount;
    }

    final dhikr = detailedData!.dhikrModel;
    if (dhikr != null && dhikr.totalTarget > 0) {
      dhikrScore = (dhikr.totalCount / dhikr.totalTarget).clamp(0.0, 1.0);
    }

    final reading = detailedData!.readingModel;
    if (reading != null && reading.goal.totalMinutes > 0) {
      readingScore = (reading.totalMinutes / reading.goal.totalMinutes).clamp(0.0, 1.0);
    }

    return ((prayerScore + amalScore + dhikrScore + readingScore) / 4 * 100).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryGold,
                        ),
                      )
                    : ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          // Date Header
                          _buildDateHeader(),
                          const SizedBox(height: 20),

                          // Namaz Section
                          _buildNamazSection(),
                          const SizedBox(height: 16),

                          // Daily Amal Section
                          _buildDailyAmalSection(),
                          const SizedBox(height: 16),

                          // Dhikr Section
                          _buildDhikrSection(),
                          const SizedBox(height: 16),

                          // Reading Section
                          _buildReadingSection(),
                          const SizedBox(height: 16),

                          // Sin Tracker Section
                          _buildSinSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateHeader() {
    final overallScore = _calculateOverallScore();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: AppTheme.primaryGold.withOpacity(0.8),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateBengali(widget.date),
                  style: const TextStyle(
                    color: AppTheme.primaryGold,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getWeekdayBengali(widget.date.weekday),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$overallScore%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamazSection() {
    final prayer = detailedData?.prayerModel;
    final completedCount = prayer?.completedPrayersCount ?? 0;
    final progress = completedCount / 5;

    return _CategoryCard(
      icon: Icons.mosque,
      title: 'নামাজ',
      subtitle: '${_toBengaliNumber(completedCount)} টি / ৫ টি সম্পন্ন',
      progress: progress,
      child: prayer != null
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prayer.prayerDone.entries.map((entry) {
                return _PrayerChip(
                  name: entry.key,
                  isCompleted: entry.value,
                );
              }).toList(),
            )
          : const Text(
              'কোনো ডেটা নেই',
              style: TextStyle(color: Colors.grey),
            ),
    );
  }

  Widget _buildDailyAmalSection() {
    final amal = detailedData?.amalModel;
    final completedCount = amal?.completedCount ?? 0;
    final totalCount = amal?.totalCount ?? 18;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return _CategoryCard(
      icon: Icons.check_circle_outline,
      title: 'প্রতিদিনের আমল',
      subtitle: '${_toBengaliNumber(completedCount)} টি / ${_toBengaliNumber(totalCount)} টি সম্পন্ন',
      progress: progress,
      isExpandable: true,
      child: amal != null
          ? Column(
              children: amal.items.map((item) {
                return _AmalItem(
                  title: item.title,
                  isCompleted: item.isCompleted,
                );
              }).toList(),
            )
          : const Text(
              'কোনো ডেটা নেই',
              style: TextStyle(color: Colors.grey),
            ),
    );
  }

  Widget _buildDhikrSection() {
    final dhikr = detailedData?.dhikrModel;
    final totalCount = dhikr?.totalCount ?? 0;
    final totalTarget = dhikr?.totalTarget ?? 600;
    final progress = totalTarget > 0 ? (totalCount / totalTarget).clamp(0.0, 1.0) : 0.0;

    return _CategoryCard(
      icon: Icons.favorite,
      title: 'যিকির',
      subtitle: '${_toBengaliNumber(totalCount)} বার / ${_toBengaliNumber(totalTarget)} বার সম্পন্ন',
      progress: progress,
      isExpandable: true,
      child: dhikr != null
          ? Column(
              children: dhikr.items.map((item) {
                return _DhikrItem(
                  title: item.title,
                  arabic: item.arabic,
                  currentCount: item.currentCount,
                  targetCount: item.targetCount,
                  toBengaliNumber: _toBengaliNumber,
                );
              }).toList(),
            )
          : const Text(
              'কোনো ডেটা নেই',
              style: TextStyle(color: Colors.grey),
            ),
    );
  }

  Widget _buildReadingSection() {
    final reading = detailedData?.readingModel;
    final totalMinutes = reading?.totalMinutes ?? 0;
    final targetMinutes = reading?.goal.totalMinutes ?? 35;
    final progress = targetMinutes > 0 ? (totalMinutes / targetMinutes).clamp(0.0, 1.0) : 0.0;

    return _CategoryCard(
      icon: Icons.menu_book,
      title: 'পড়াশোনা',
      subtitle: '${_toBengaliNumber(totalMinutes)} মিনিট / ${_toBengaliNumber(targetMinutes)} মিনিট সম্পন্ন',
      progress: progress,
      child: reading != null
          ? Column(
              children: [
                _ReadingItem(
                  icon: Icons.book,
                  title: 'কুরআন তিলাওয়াত',
                  minutes: reading.quranMinutes,
                  target: reading.goal.quranMinutes,
                  toBengaliNumber: _toBengaliNumber,
                ),
                _ReadingItem(
                  icon: Icons.book_outlined,
                  title: 'তাফসীর',
                  minutes: reading.tafsirMinutes,
                  target: reading.goal.tafsirMinutes,
                  toBengaliNumber: _toBengaliNumber,
                ),
                _ReadingItem(
                  icon: Icons.auto_stories,
                  title: 'হাদিস',
                  minutes: reading.hadithMinutes,
                  target: reading.goal.hadithMinutes,
                  toBengaliNumber: _toBengaliNumber,
                ),
              ],
            )
          : const Text(
              'কোনো ডেটা নেই',
              style: TextStyle(color: Colors.grey),
            ),
    );
  }

  Widget _buildSinSection() {
    final sins = sinRecord?.records ?? [];
    final committedSins = sins.where((s) => s.hasSinned).toList();
    final totalSins = committedSins.length;
    final kaffaraDone = committedSins.where((s) => s.kaffaraDone).length;

    String getSinName(String sinTypeId) {
      // First check in loaded sin types (includes custom)
      for (final sinType in allSinTypes) {
        if (sinType.id == sinTypeId) {
          return sinType.name;
        }
      }
      // Fallback to default types
      for (final sinType in getDefaultSinTypes()) {
        if (sinType.id == sinTypeId) {
          return sinType.name;
        }
      }
      return 'অজানা গুনাহ';
    }

    String getKaffaraName(String? kaffaraType) {
      if (kaffaraType == null) return '';
      return KaffaraType.getName(kaffaraType);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_fix_high,
                  color: AppTheme.primaryGold.withOpacity(0.8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'গুনাহ ট্র্যাকার',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalSins == 0
                          ? 'মাশাআল্লাহ! কোনো গুনাহ নেই'
                          : '${_toBengaliNumber(totalSins)} টি গুনাহ, ${_toBengaliNumber(kaffaraDone)} টি কাফফারা দেওয়া',
                      style: TextStyle(
                        color: totalSins == 0 ? const Color(0xFF4CAF50) : Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (committedSins.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 12),
            
            // Sin list
            ...committedSins.map((sin) {
              final sinName = getSinName(sin.sinTypeId);
              final kaffaraName = sin.kaffaraDone ? getKaffaraName(sin.kaffaraType) : '';
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      sin.kaffaraDone ? Icons.check_circle : Icons.cancel,
                      color: sin.kaffaraDone ? const Color(0xFF4CAF50) : Colors.red.shade300,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sinName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (sin.kaffaraDone)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          kaffaraName,
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 11,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade300.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'কাফফারা বাকি',
                          style: TextStyle(
                            color: Colors.red.shade300,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double progress;
  final Widget child;
  final bool isExpandable;

  const _CategoryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.child,
    this.isExpandable = false,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.progress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: widget.isExpandable
                ? () => setState(() => isExpanded = !isExpanded)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: AppTheme.primaryGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isExpandable) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.grey,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded || !widget.isExpandable) ...[
            const Divider(color: Color(0xFF3A3A3A), height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final String name;
  final bool isCompleted;

  const _PrayerChip({
    required this.name,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.primaryGold.withOpacity(0.2)
            : Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppTheme.primaryGold.withOpacity(0.5)
              : Colors.grey[700]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isCompleted ? AppTheme.primaryGold : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: isCompleted ? Colors.white : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmalItem extends StatelessWidget {
  final String title;
  final bool isCompleted;

  const _AmalItem({
    required this.title,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isCompleted ? AppTheme.primaryGold : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? Colors.white : Colors.grey,
                fontSize: 14,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrItem extends StatelessWidget {
  final String title;
  final String? arabic;
  final int currentCount;
  final int targetCount;
  final String Function(int) toBengaliNumber;

  const _DhikrItem({
    required this.title,
    this.arabic,
    required this.currentCount,
    required this.targetCount,
    required this.toBengaliNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (arabic != null)
                  Text(
                    arabic!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentCount >= targetCount
                  ? AppTheme.primaryGold.withOpacity(0.2)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${toBengaliNumber(currentCount)}/${toBengaliNumber(targetCount)}',
              style: TextStyle(
                color: currentCount >= targetCount
                    ? AppTheme.primaryGold
                    : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int minutes;
  final int target;
  final String Function(int) toBengaliNumber;

  const _ReadingItem({
    required this.icon,
    required this.title,
    required this.minutes,
    required this.target,
    required this.toBengaliNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: minutes >= target
                  ? AppTheme.primaryGold.withOpacity(0.2)
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${toBengaliNumber(minutes)}/${toBengaliNumber(target)} মি.',
              style: TextStyle(
                color: minutes >= target ? AppTheme.primaryGold : Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
