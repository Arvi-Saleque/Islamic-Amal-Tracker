import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/prayer_tracking_provider.dart';

class PrayerTrackerScreen extends ConsumerStatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  ConsumerState<PrayerTrackerScreen> createState() =>
      _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends ConsumerState<PrayerTrackerScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> expanded = {
    'ফজর': false,
    'যোহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final completedPrayers = prayerState.todayData.completedPrayersCount;

    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[0],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[1],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 16,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'prayer_tracker_title'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Info button
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: titleColor),
            onPressed: () => _showInfoBottomSheet(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(
              context,
            ).extension<GradientColors>()!.backgroundGradient,
          ),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            children: [
              _TopSummaryCard(completed: completedPrayers),
              const SizedBox(height: 14),
              _buildPrayerTile('ফজর'),
              const SizedBox(height: 12),
              _buildPrayerTile('যোহর'),
              const SizedBox(height: 12),
              _buildPrayerTile('আসর'),
              const SizedBox(height: 12),
              _buildPrayerTile('মাগরিব'),
              const SizedBox(height: 12),
              _buildPrayerTile('এশা'),
            ],
          ),
        ),
      ),
    );
  }

  String _prayerIdFromBangla(String prayer) {
    switch (prayer) {
      case 'ফজর':
        return 'fajr';
      case 'যোহর':
        return 'dhuhr';
      case 'আসর':
        return 'asr';
      case 'মাগরিব':
        return 'maghrib';
      case 'এশা':
        return 'isha';
      default:
        return prayer;
    }
  }

  String _localizedPrayerName(BuildContext context, String prayerBangla) {
    final id = _prayerIdFromBangla(prayerBangla);
    final isFriday = DateTime.now().weekday == DateTime.friday;

    if (id == 'dhuhr' && isFriday) {
      // On Friday, show Jumu'ah instead of Dhuhr
      return 'jumuah'.tr();
    }
    return id.tr();
  }

  String _localizedRakatLabel(
    BuildContext context,
    String prayerBangla,
    String rakatKey,
  ) {
    final isFriday = DateTime.now().weekday == DateTime.friday;

    // Bengali locale: keep existing Bengali labels (with Friday-aware adjustment)
    if (context.locale.languageCode == 'bn') {
      // Existing behaviour from prayer_name_utils (now inlined)
      if (isFriday &&
          prayerBangla == 'যোহর' &&
          rakatKey == '২ রাকাত সুন্নাত (পরে)') {
        return '৪ রাকাত সুন্নাত (পরে)';
      }
      return rakatKey;
    }

    // English (and other) locales: map common Bengali rakat strings to English labels
    // Fajr
    if (prayerBangla == 'ফজর') {
      if (rakatKey.contains('ফরয') &&
          rakatKey.contains('জামাতে/আউয়াল ওয়াক্তে')) {
        return '2 rakat Fard (congregation / on time)';
      }
      if (rakatKey.contains('ফরয') && rakatKey.contains('দেরী করে')) {
        return '2 rakat Fard (late)';
      }
      if (rakatKey.contains('সুন্নাত')) {
        return '2 rakat Sunnah';
      }
    }

    // Dhuhr / Jumu'ah
    if (prayerBangla == 'যোহর') {
      if (rakatKey.contains('সুন্নাত (আগে)')) {
        return '4 rakat Sunnah (before)';
      }
      if (rakatKey.contains('ফরয') &&
          rakatKey.contains('জামাতে/আউয়াল ওয়াক্তে')) {
        return '4 rakat Fard (congregation / on time)';
      }
      if (rakatKey.contains('ফরয') && rakatKey.contains('দেরী করে')) {
        return '4 rakat Fard (late)';
      }
      if (rakatKey.contains('সুন্নাত (পরে)')) {
        // On Friday, show 4 rakat Sunnah after; otherwise 2 rakat
        final count = isFriday ? 4 : 2;
        return '$count rakat Sunnah (after)';
      }
    }

    // Asr
    if (prayerBangla == 'আসর') {
      if (rakatKey.contains('ফরয') &&
          rakatKey.contains('জামাতে/আউয়াল ওয়াক্তে')) {
        return '4 rakat Fard (congregation / on time)';
      }
      if (rakatKey.contains('ফরয') && rakatKey.contains('দেরী করে')) {
        return '4 rakat Fard (late)';
      }
    }

    // Maghrib
    if (prayerBangla == 'মাগরিব') {
      if (rakatKey.contains('ফরয') &&
          rakatKey.contains('জামাতে/আউয়াল ওয়াক্তে')) {
        return '3 rakat Fard (congregation / on time)';
      }
      if (rakatKey.contains('ফরয') && rakatKey.contains('দেরী করে')) {
        return '3 rakat Fard (late)';
      }
      if (rakatKey.contains('সুন্নাত')) {
        return '2 rakat Sunnah';
      }
    }

    // Isha
    if (prayerBangla == 'এশা') {
      if (rakatKey.contains('ফরয') &&
          rakatKey.contains('জামাতে/আউয়াল ওয়াক্তে')) {
        return '4 rakat Fard (congregation / on time)';
      }
      if (rakatKey.contains('ফরয') && rakatKey.contains('দেরী করে')) {
        return '4 rakat Fard (late)';
      }
      if (rakatKey.contains('সুন্নাত')) {
        return '2 rakat Sunnah';
      }
      if (rakatKey.contains('বেতের')) {
        return '3 rakat Witr';
      }
    }

    // Fallback: show raw key if we don't recognize the pattern
    return rakatKey;
  }

  Widget _buildPrayerTile(String prayer) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final notifier = ref.read(prayerTrackingProvider.notifier);

    final isExpanded = expanded[prayer] ?? false;
    final isDone = prayerState.todayData.prayerDone[prayer] ?? false;

    final titleColor = isDone
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final subColor = Theme.of(
      context,
    ).colorScheme.onSurfaceVariant.withOpacity(0.75);

    final arrowColor = isDone
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.70);

    // count completed rakats for small badge
    final rakats = prayerState.todayData.rakatsDone[prayer]!;
    final doneCount = rakats.values.where((v) => v).length;
    final totalCount = rakats.length;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => expanded[prayer] = !isExpanded);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
              child: Row(
                children: [
                  _PremiumCheckBox(
                    value: isDone,
                    size: 32,
                    onTap: () async {
                      HapticFeedback.lightImpact();
                      await notifier.togglePrayer(prayer);
                    },
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _localizedPrayerName(context, prayer),
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            _MiniBadge(
                              text: '$doneCount/$totalCount',
                              filled: isDone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDone
                              ? 'prayer_complete'.tr()
                              : 'prayer_tap_expand'.tr(),
                          style: TextStyle(
                            color: isDone
                                ? Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.70)
                                : subColor,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: arrowColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .extension<GradientColors>()!
                            .onPrimaryText
                            .withOpacity(0),
                        Theme.of(context).colorScheme.primary.withOpacity(0.14),
                        Theme.of(context)
                            .extension<GradientColors>()!
                            .onPrimaryText
                            .withOpacity(0),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.10),
                          Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.06),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: rakats.entries
                          .map(
                            (e) => _buildRakatRow(
                              prayer: prayer,
                              rakat: e.key,
                              done: e.value,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
            sizeCurve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  Widget _buildRakatRow({
    required String prayer,
    required String rakat,
    required bool done,
  }) {
    final notifier = ref.read(prayerTrackingProvider.notifier);

    final textColor = done
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.85);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          HapticFeedback.selectionClick();
          await notifier.toggleRakat(prayer, rakat);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: Theme.of(
                context,
              ).extension<GradientColors>()!.innerCardGradient,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _PremiumCheckBox(
                value: done,
                size: 26,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await notifier.toggleRakat(prayer, rakat);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _localizedRakatLabel(context, prayer, rakat),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.8,
                    fontWeight: done ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (done)
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Bottom sheet ----------------

  void _showInfoBottomSheet(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.outline.withOpacity(0.3);
    final bodyTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => buildPremiumCard(
          context: context,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          gradientBegin: Alignment.topCenter,
          gradientEnd: Alignment.bottomCenter,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.info_outline_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'prayer_info_title'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: dividerColor),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                  children: [
                    _InfoCard(
                      icon: Icons.calculate_outlined,
                      title: 'prayer_info_how_title'.tr(),
                      body: 'prayer_info_how_body'.tr(),
                      bodyTextColor: bodyTextColor,
                    ),
                    const SizedBox(height: 20),
                    _SectionHeader(
                      icon: Icons.mosque_outlined,
                      title: 'prayer_info_congregation_title'.tr(),
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith1_text',
                      reference: 'prayer_info_hadith1_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith2_text',
                      reference: 'prayer_info_hadith2_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith3_text',
                      reference: 'prayer_info_hadith3_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith4_text',
                      reference: 'prayer_info_hadith4_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith5_text',
                      reference: 'prayer_info_hadith5_ref',
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      icon: Icons.access_time_rounded,
                      title: 'prayer_info_early_title'.tr(),
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith6_text',
                      reference: 'prayer_info_hadith6_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith7_text',
                      reference: 'prayer_info_hadith7_ref',
                    ),
                    const SizedBox(height: 18),
                    _SectionHeader(
                      icon: Icons.auto_awesome_rounded,
                      title: 'prayer_info_sunnah_title'.tr(),
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith8_text',
                      reference: 'prayer_info_hadith8_ref',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith: 'prayer_info_hadith9_text',
                      reference: 'prayer_info_hadith9_ref',
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Premium components ----------------

class _TopSummaryCard extends StatelessWidget {
  final int completed;

  const _TopSummaryCard({required this.completed});

  @override
  Widget build(BuildContext context) {
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'today_progress'.tr(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed / 5 ${'fard'.tr()} ${'completed'.tr()}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          _MiniBadge(
            text: '${(completed / 5 * 100).round()}%',
            filled: completed == 5,
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final bool filled;

  const _MiniBadge({required this.text, required this.filled});

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final fg = filled
        ? Theme.of(context).extension<GradientColors>()!.onPrimaryText
        : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _PremiumCheckBox extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;
  final double size;

  const _PremiumCheckBox({
    required this.value,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bg = value
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final checkColor = value ? Theme.of(context).colorScheme.onPrimary : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(size * 0.30),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: value
            ? Icon(Icons.check_rounded, color: checkColor, size: size * 0.62)
            : null,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(
                context,
              ).extension<GradientColors>()!.onPrimaryText,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color bodyTextColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.bodyTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: bodyTextColor,
              fontSize: 14,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HadithCard extends StatelessWidget {
  final String hadith;
  final String reference;

  const _HadithCard({required this.hadith, required this.reference});

  @override
  Widget build(BuildContext context) {
    final hadithText = hadith.tr();
    final referenceText = reference.tr();
    final hadithTextColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.format_quote_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hadithText,
                  style: TextStyle(
                    color: hadithTextColor,
                    fontSize: 14,
                    height: 1.65,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
              ),
              const SizedBox(width: 5),
              Text(
                referenceText,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
