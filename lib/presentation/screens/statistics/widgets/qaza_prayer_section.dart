import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../providers/qaza_prayer_provider.dart';

class QazaPrayerSection extends ConsumerStatefulWidget {
  const QazaPrayerSection({super.key});

  @override
  ConsumerState<QazaPrayerSection> createState() => _QazaPrayerSectionState();
}

class _QazaPrayerSectionState extends ConsumerState<QazaPrayerSection> {
  // Track expanded state for each prayer
  final Map<String, bool> _expandedStates = {
    'ফজর': false,
    'যোহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  @override
  Widget build(BuildContext context) {
    final qazaState = ref.watch(qazaPrayerProvider);
    final qazaNotifier = ref.read(qazaPrayerProvider.notifier);

    if (qazaState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    final totalPending = qazaState.totalPendingCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        _buildSummaryCard(totalPending, qazaState),
        const SizedBox(height: 20),

        // Info Card
        _buildInfoCard(),
        const SizedBox(height: 20),

        // Prayer List
        ...qazaState.prayerSummaries.map((summary) {
          return _buildPrayerExpandableCard(summary, qazaNotifier);
        }),
      ],
    );
  }

  Widget _buildSummaryCard(int totalPending, QazaPrayerState state) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                totalPending > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle,
                color: totalPending > 0 ? primary : Colors.green,
                size: 32,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  totalPending > 0
                      ? 'stats_qaza_pending'
                          .tr(namedArgs: {'count': totalPending.toString()})
                      : 'stats_qaza_none'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: totalPending > 0 ? primary : Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (totalPending > 0) ...[
            const SizedBox(height: 16),
            Text(
              'stats_qaza_last30'.tr(),
              style: TextStyle(
                color: Theme.of(context)
                    .extension<GradientColors>()!
                    .bulletTextColor,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: primary.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'stats_qaza_instruction'.tr(),
              style: TextStyle(
                color: onSurface.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerExpandableCard(
    QazaPrayerSummary summary,
    QazaPrayerNotifier notifier,
  ) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final shadowColor = Theme.of(context).shadowColor;
    final isExpanded = _expandedStates[summary.prayerName] ?? false;
    final pendingCount = summary.pendingCount;
    final hasPending = pendingCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () {
                setState(() {
                  _expandedStates[summary.prayerName] = !isExpanded;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Prayer icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasPending
                            ? primary.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPrayerIcon(summary.prayerName),
                        color: hasPending ? primary : Colors.green,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Prayer Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _localizedPrayerName(summary.prayerName),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasPending
                                ? 'stats_qaza_pending_waqt'.tr(namedArgs: {'count': pendingCount.toString()})
                                : 'stats_qaza_all_done'.tr(),
                            style: TextStyle(
                              color: hasPending
                                  ? primary.withOpacity(0.8)
                                  : Colors.green[300],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Count badge
                    if (hasPending)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pendingCount.toString(),
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Expand Arrow
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: hasPending ? primary : Colors.green,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    color: Theme.of(context).shadowColor.withOpacity(0.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: summary.missedPrayers
                          .where((p) => !p.isQazaDone)
                          .map((qaza) => _buildQazaItem(qaza, notifier))
                          .toList(),
                    ),
                  ),
                  if (summary.missedPrayers.where((p) => !p.isQazaDone).isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'stats_qaza_none_pending'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).extension<GradientColors>()!.bulletTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQazaItem(MissedPrayer qaza, QazaPrayerNotifier notifier) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final shadowColor = Theme.of(context).shadowColor;
    final bulletColor = gradients.bulletTextColor;
    
    final date = DateTime.parse(qaza.date);
    final formattedDate = _formatDate(date);
    final weekday = _getWeekday(date.weekday);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => notifier.toggleQazaCompletion(qaza.date, qaza.prayerName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: shadowColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: shadowColor.withOpacity(0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: qaza.isQazaDone 
                      ? Colors.green 
                      : shadowColor.withOpacity(0.15),
                  border: qaza.isQazaDone
                      ? null
                      : Border.all(
                          color: shadowColor.withOpacity(0.3),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: qaza.isQazaDone
                          ? Colors.green.withOpacity(0.4)
                          : primary.withOpacity(0.2),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: qaza.isQazaDone
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              // Date info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: qaza.isQazaDone ? bulletColor : onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration:
                            qaza.isQazaDone ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      weekday,
                      style: TextStyle(
                        color: bulletColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Days ago
              Text(
                _getDaysAgo(date),
                style: TextStyle(
                  color: bulletColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'ফজর':
        return Icons.wb_twilight;
      case 'যোহর':
        return Icons.wb_sunny;
      case 'আসর':
        return Icons.sunny_snowing;
      case 'মাগরিব':
        return Icons.nightlight;
      case 'এশা':
        return Icons.nights_stay;
      default:
        return Icons.mosque;
    }
  }

  String _localizedPrayerName(String prayerName) {
    final isFriday = DateTime.now().weekday == DateTime.friday;
    if (isFriday && prayerName == 'যোহর') return 'prayer_jumua'.tr();
    const keys = {
      'ফজর': 'prayer_fajr',
      'যোহর': 'prayer_dhuhr',
      'আসর': 'prayer_asr',
      'মাগরিব': 'prayer_maghrib',
      'এশা': 'prayer_isha',
    };
    final key = keys[prayerName];
    return key != null ? key.tr() : prayerName;
  }

  String _formatDate(DateTime date) {
    const monthKeys = [
      'month_jan', 'month_feb', 'month_mar', 'month_apr', 'month_may', 'month_jun',
      'month_jul', 'month_aug', 'month_sep', 'month_oct', 'month_nov', 'month_dec',
    ];
    return '${date.day} ${monthKeys[date.month - 1].tr()}';
  }

  String _getWeekday(int weekday) {
    const dayKeys = [
      'weekday_mon', 'weekday_tue', 'weekday_wed', 'weekday_thu',
      'weekday_fri', 'weekday_sat', 'weekday_sun',
    ];
    return dayKeys[weekday - 1].tr();
  }

  String _getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 1) return 'stats_yesterday'.tr();
    if (difference == 2) return 'stats_day_before_yesterday'.tr();
    return 'stats_days_ago'.tr(namedArgs: {'days': difference.toString()});
  }
}
