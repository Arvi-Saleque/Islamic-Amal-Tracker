import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:amal_tracker/core/utils/prayer_name_utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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

  String _formatDateLocalized(DateTime date) {
    final monthKey = () {
      switch (date.month) {
        case 1:
          return 'month_jan';
        case 2:
          return 'month_feb';
        case 3:
          return 'month_mar';
        case 4:
          return 'month_apr';
        case 5:
          return 'month_may';
        case 6:
          return 'month_jun';
        case 7:
          return 'month_jul';
        case 8:
          return 'month_aug';
        case 9:
          return 'month_sep';
        case 10:
          return 'month_oct';
        case 11:
          return 'month_nov';
        case 12:
        default:
          return 'month_dec';
      }
    }();

    return '${date.day} ${monthKey.tr()}, ${date.year}';
  }

  String _getWeekdayLocalized(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'weekday_mon'.tr();
      case DateTime.tuesday:
        return 'weekday_tue'.tr();
      case DateTime.wednesday:
        return 'weekday_wed'.tr();
      case DateTime.thursday:
        return 'weekday_thu'.tr();
      case DateTime.friday:
        return 'weekday_fri'.tr();
      case DateTime.saturday:
        return 'weekday_sat'.tr();
      case DateTime.sunday:
      default:
        return 'weekday_sun'.tr();
    }
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
      readingScore = (reading.totalMinutes / reading.goal.totalMinutes).clamp(
        0.0,
        1.0,
      );
    }

    return ((prayerScore + amalScore + dhikrScore + readingScore) / 4 * 100)
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final shadowColor = Theme.of(context).shadowColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients.backgroundGradient,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: primary.withOpacity(0.8),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateLocalized(widget.date),
                  style: TextStyle(
                    color: primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _getWeekdayLocalized(widget.date.weekday),
                  style: TextStyle(
                    color: gradients.bulletTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withOpacity(0.3), width: 1),
            ),
            child: Text(
              '$overallScore%',
              style: TextStyle(
                color: primary,
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
      title: 'prayer_section'.tr(),
      subtitle: 'stats_completed_of'.tr(
        namedArgs: {'done': completedCount.toString(), 'total': '5'},
      ),
      progress: progress,
      child: prayer != null
          ? Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prayer.prayerDone.entries.map((entry) {
                return _PrayerChip(
                  name: fridayAwareDisplay(entry.key, date: widget.date),
                  isCompleted: entry.value,
                );
              }).toList(),
            )
          : Text(
              'stats_no_data'.tr(),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.bulletTextColor,
              ),
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
      title: 'daily_section'.tr(),
      subtitle: 'stats_completed_of'.tr(
        namedArgs: {
          'done': completedCount.toString(),
          'total': totalCount.toString(),
        },
      ),
      progress: progress,
      isExpandable: true,
      child: amal != null
          ? Column(
              children: amal.items.map((item) {
                return _AmalItem(
                  title: fridayAwareDisplay(item.title, date: widget.date),
                  isCompleted: item.isCompleted,
                );
              }).toList(),
            )
          : Text(
              'stats_no_data'.tr(),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.bulletTextColor,
              ),
            ),
    );
  }

  Widget _buildDhikrSection() {
    final dhikr = detailedData?.dhikrModel;
    final totalCount = dhikr?.totalCount ?? 0;
    final totalTarget = dhikr?.totalTarget ?? 600;
    final progress = totalTarget > 0
        ? (totalCount / totalTarget).clamp(0.0, 1.0)
        : 0.0;

    return _CategoryCard(
      icon: Icons.favorite,
      title: 'dhikr_section'.tr(),
      subtitle: 'stats_completed_of'.tr(
        namedArgs: {
          'done': totalCount.toString(),
          'total': totalTarget.toString(),
        },
      ),
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
                );
              }).toList(),
            )
          : Text(
              'stats_no_data'.tr(),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.bulletTextColor,
              ),
            ),
    );
  }

  Widget _buildReadingSection() {
    final reading = detailedData?.readingModel;
    final totalMinutes = reading?.totalMinutes ?? 0;
    final targetMinutes = reading?.goal.totalMinutes ?? 35;
    final progress = targetMinutes > 0
        ? (totalMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;

    return _CategoryCard(
      icon: Icons.menu_book,
      title: 'reading_section'.tr(),
      subtitle: 'stats_completed_of'.tr(
        namedArgs: {
          'done': totalMinutes.toString(),
          'total': targetMinutes.toString(),
        },
      ),
      progress: progress,
      child: reading != null
          ? Column(
              children: [
                _ReadingItem(
                  icon: Icons.book,
                  title: 'reading_quran'.tr(),
                  minutes: reading.quranMinutes,
                  target: reading.goal.quranMinutes,
                ),
                _ReadingItem(
                  icon: Icons.book_outlined,
                  title: 'reading_tafsir'.tr(),
                  minutes: reading.tafsirMinutes,
                  target: reading.goal.tafsirMinutes,
                ),
                _ReadingItem(
                  icon: Icons.auto_stories,
                  title: 'reading_hadith'.tr(),
                  minutes: reading.hadithMinutes,
                  target: reading.goal.hadithMinutes,
                ),
              ],
            )
          : Text(
              'stats_no_data'.tr(),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.bulletTextColor,
              ),
            ),
    );
  }

  Widget _buildSinSection() {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final shadowColor = Theme.of(context).shadowColor;

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
      return 'sin_unknown'.tr();
    }

    String getKaffaraName(String? kaffaraType) {
      if (kaffaraType == null) return '';
      return KaffaraType.getName(kaffaraType);
    }

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_fix_high,
                  color: primary.withOpacity(0.8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'stats_sin_tracker'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      totalSins == 0
                          ? 'stats_mashallah_no_sin'.tr()
                          : 'stats_sin_kaffara_summary'.tr(
                              namedArgs: {
                                'total': totalSins.toString(),
                                'done': kaffaraDone.toString(),
                              },
                            ),
                      style: TextStyle(
                        color: totalSins == 0
                            ? const Color(0xFF4CAF50)
                            : gradients.bulletTextColor,
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
            Divider(color: shadowColor.withOpacity(0.2), height: 1),
            const SizedBox(height: 12),

            // Sin list
            ...committedSins.map((sin) {
              final sinName = getSinName(sin.sinTypeId);
              final kaffaraName = sin.kaffaraDone
                  ? getKaffaraName(sin.kaffaraType)
                  : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      sin.kaffaraDone ? Icons.check_circle : Icons.cancel,
                      color: sin.kaffaraDone
                          ? const Color(0xFF4CAF50)
                          : Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sinName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (sin.kaffaraDone)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'stats_kaffara_pending'.tr(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final percentage = (widget.progress * 100).toInt();

    return buildPremiumCard(
      context: context,
      radius: 18,
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
                          color: primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(widget.icon, color: primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(
                                color: gradients.bulletTextColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isExpandable) ...[
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: gradients.bulletTextColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.progress.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded || !widget.isExpandable) ...[
            Divider(
              color: Theme.of(context).shadowColor.withOpacity(0.2),
              height: 1,
            ),
            Padding(padding: const EdgeInsets.all(16), child: widget.child),
          ],
        ],
      ),
    );
  }
}

class _PrayerChip extends StatelessWidget {
  final String name;
  final bool isCompleted;

  const _PrayerChip({required this.name, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final shadowColor = Theme.of(context).shadowColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCompleted
            ? primary.withOpacity(0.2)
            : shadowColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? primary.withOpacity(0.3)
              : shadowColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isCompleted
                ? primary
                : Theme.of(
                    context,
                  ).extension<GradientColors>()!.bulletTextColor,
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              color: isCompleted
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(
                      context,
                    ).extension<GradientColors>()!.bulletTextColor,
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

  const _AmalItem({required this.title, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bulletColor = Theme.of(
      context,
    ).extension<GradientColors>()!.bulletTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: isCompleted ? primary : bulletColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted ? onSurface : bulletColor,
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

  const _DhikrItem({
    required this.title,
    this.arabic,
    required this.currentCount,
    required this.targetCount,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bulletColor = Theme.of(
      context,
    ).extension<GradientColors>()!.bulletTextColor;
    final shadowColor = Theme.of(context).shadowColor;

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
                  style: TextStyle(
                    color: onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (arabic != null)
                  Text(
                    arabic!,
                    style: TextStyle(color: bulletColor, fontSize: 12),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: currentCount >= targetCount
                  ? primary.withOpacity(0.2)
                  : shadowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: currentCount >= targetCount
                    ? primary.withOpacity(0.3)
                    : shadowColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '$currentCount/$targetCount',
              style: TextStyle(
                color: currentCount >= targetCount ? primary : bulletColor,
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

  const _ReadingItem({
    required this.icon,
    required this.title,
    required this.minutes,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final bulletColor = Theme.of(
      context,
    ).extension<GradientColors>()!.bulletTextColor;
    final shadowColor = Theme.of(context).shadowColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: bulletColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(color: onSurface, fontSize: 14),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: minutes >= target
                  ? primary.withOpacity(0.2)
                  : shadowColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: minutes >= target
                    ? primary.withOpacity(0.3)
                    : shadowColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              '$minutes/$target',
              style: TextStyle(
                color: minutes >= target ? primary : bulletColor,
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
