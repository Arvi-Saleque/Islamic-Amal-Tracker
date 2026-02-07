import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/prayer_tracking_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_provider.dart';

class PrayerTrackerScreen extends ConsumerStatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  ConsumerState<PrayerTrackerScreen> createState() => _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends ConsumerState<PrayerTrackerScreen>
    with TickerProviderStateMixin {
  final Map<String, bool> expanded = {
    'ফজর': false,
    'যুহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider);
    final isLight = mode == ThemeMode.light;

    final prayerState = ref.watch(prayerTrackingProvider);
    final completedPrayers = prayerState.todayData.completedPrayersCount;

    final bg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'নামাজের হিসাব',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            onPressed: () => _showInfoBottomSheet(context, isLight),
            tooltip: 'Info',
          ),
          _ProgressPill(
            isLight: isLight,
            completed: completedPrayers,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
          children: [
            _TopSummaryCard(isLight: isLight, completed: completedPrayers),
            const SizedBox(height: 14),

            _buildPrayerTile('ফজর', isLight),
            const SizedBox(height: 12),
            _buildPrayerTile('যুহর', isLight),
            const SizedBox(height: 12),
            _buildPrayerTile('আসর', isLight),
            const SizedBox(height: 12),
            _buildPrayerTile('মাগরিব', isLight),
            const SizedBox(height: 12),
            _buildPrayerTile('এশা', isLight),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTile(String prayer, bool isLight) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final notifier = ref.read(prayerTrackingProvider.notifier);

    final isExpanded = expanded[prayer] ?? false;
    final isDone = prayerState.todayData.prayerDone[prayer] ?? false;

    final tileBg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundLight;
    final titleColor = isDone
        ? AppColors.primary
        : (isLight ? AppColors.textLightMode.withOpacity(0.92) : AppColors.textSecondary);

    final subColor = isLight
        ? AppColors.textSecondaryLightMode.withOpacity(0.85)
        : AppColors.textTertiary;

    final arrowColor = isDone
        ? AppColors.primary
        : (isLight ? AppColors.textSecondaryLightMode.withOpacity(0.70) : AppColors.grey500);

    // count completed rakats for small badge
    final rakats = prayerState.todayData.rakatsDone[prayer]!;
    final doneCount = rakats.values.where((v) => v).length;
    final totalCount = rakats.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          if (isDone)
            BoxShadow(
              color: AppColors.shadowGolden,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
        ],
      ),
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
                    isLight: isLight,
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
                                prayer,
                                style: TextStyle(
                                  color: titleColor,
                                  fontSize: 17.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            _MiniBadge(
                              isLight: isLight,
                              text: '$doneCount/$totalCount',
                              filled: isDone,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDone ? 'Complete' : 'Tap to expand rakats',
                          style: TextStyle(
                            color: isDone ? AppColors.primary.withOpacity(0.70) : subColor,
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
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: arrowColor, size: 30),
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
                        Colors.transparent,
                        AppColors.primary.withOpacity(0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight
                          ? AppColors.primary.withOpacity(0.05)
                          : Colors.black.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isLight ? 0.04 : 0.14),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: rakats.entries
                          .map(
                            (e) => _buildRakatRow(
                              prayer: prayer,
                              rakat: e.key,
                              done: e.value,
                              isLight: isLight,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
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
    required bool isLight,
  }) {
    final notifier = ref.read(prayerTrackingProvider.notifier);

    final rowBg = done
        ? AppColors.primaryOpacity06
        : (isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark);

    final textColor = done
        ? AppColors.primary
        : (isLight ? AppColors.textSecondaryLightMode.withOpacity(0.90) : AppColors.textTertiary);

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
            color: rowBg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.05 : 0.18),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _PremiumCheckBox(
                value: done,
                isLight: isLight,
                size: 26,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await notifier.toggleRakat(prayer, rakat);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rakat,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14.8,
                    fontWeight: done ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (done)
                const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Bottom sheet ----------------

  void _showInfoBottomSheet(BuildContext context, bool isLight) {
    final sheetBg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundLight;
    final dividerColor = isLight
        ? AppColors.borderLightMode.withOpacity(0.5)
        : AppColors.grey600.withOpacity(0.25);
    final bodyTextColor = isLight
        ? AppColors.textLightMode.withOpacity(0.90)
        : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.08 : 0.22),
                blurRadius: 22,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight ? Colors.black.withOpacity(0.18) : AppColors.grey600,
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
                        color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'নামাজের তথ্য ও ফযিলত',
                        style: TextStyle(
                          color: AppColors.primary,
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
                      isLight: isLight,
                      icon: Icons.calculate_outlined,
                      title: 'হিসাব কিভাবে হয়?',
                      body: '''
• শুধুমাত্র ফরয নামাজ পড়লেই ওয়াক্ত কাউন্ট হবে
• ফরযের ২টি অপশন আছে:
  ১) জামাতে/আউয়াল ওয়াক্তে - সময়মতো পড়লে
  ২) দেরী করে - দেরী করে পড়লে
• যেকোনো একটি ফরয অপশন সিলেক্ট করলেই নামাজ complete
• ৫ ওয়াক্ত ফরয পড়লে দিনের নামাজ ১০০% complete''',
                      bodyTextColor: bodyTextColor,
                    ),
                    const SizedBox(height: 20),

                    _SectionHeader(isLight: isLight, icon: Icons.mosque_outlined, title: 'জামাতে নামাজের ফযিলত'),
                    const SizedBox(height: 12),

                    _HadithCard(
                      isLight: isLight,
                      hadith: 'জামাতে নামাজ পড়া একাকী নামাজ পড়ার চেয়ে সাতাশ গুণ বেশি মর্যাদাসম্পন্ন।',
                      reference: 'সহীহ বুখারী: ৬৪৫, সহীহ মুসলিম: ৬৫০',
                    ),
                    const SizedBox(height: 12),

                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'যে ব্যক্তি এশার সালাত জামাআতের সাথে আদায় করবে, সে অর্ধেক রাত্রি ক্বিয়াম করার ছোয়াব পাবে। আর যে ব্যক্তি এশা ও ফজর জামাআতের সাথে আদায় করবে, সে পূর্ণ রাত্রি ক্বিয়াম করার ছোয়াব পাবে।',
                      reference: 'সহীহ মুসলিম: ৬৫৬',
                    ),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'যে ব্যক্তি চল্লিশ দিন জামাতের সাথে নামাজ আদায় করে এবং প্রথম তাকবীর পায়, তার জন্য দুটি মুক্তি লেখা হয়: জাহান্নাম থেকে মুক্তি এবং মুনাফিকী থেকে মুক্তি।',
                      reference: 'জামে তিরমিযী: ২৪১',
                    ),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'জামাআত ধরার জন্য হেটে যাওয়া প্রতিটি পদক্ষেপের বিনিময়ে মুসল্লির মর্যাদা বৃদ্ধি পায়, গুনাহ মাফ হয় ও নেকী লেখা হতে থাকে।',
                      reference: 'সহীহ বুখারী: ৬৪৭',
                    ),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'মুনাফিকদের জন্য ফজর ও এশার নামাজ সবচেয়ে ভারী। তারা যদি জানত এতে কী পরিমাণ সওয়াব আছে, তাহলে হামাগুড়ি দিয়ে হলেও আসত।',
                      reference: 'সহীহ বুখারী: ৬৫৭',
                    ),
                    const SizedBox(height: 18),

                    _SectionHeader(isLight: isLight, icon: Icons.access_time_rounded, title: 'আউয়াল ওয়াক্তে নামাজের ফযিলত'),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'রাসূলুল্লাহ (সা.) কে জিজ্ঞাসা করা হলো, কোন আমল সবচেয়ে উত্তম? তিনি বললেন: ওয়াক্তের শুরুতে নামাজ আদায় করা।',
                      reference: 'জামে তিরমিযী: ১৭০, সুনানে আবু দাউদ: ৪২৬',
                    ),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith: 'নামাজের প্রথম ওয়াক্ত আল্লাহর সন্তুষ্টি এবং শেষ ওয়াক্ত আল্লাহর ক্ষমা।',
                      reference: 'জামে তিরমিযী: ১৭২',
                    ),
                    const SizedBox(height: 18),

                    _SectionHeader(isLight: isLight, icon: Icons.auto_awesome_rounded, title: 'সুন্নাত নামাজের ফযিলত'),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith: 'দুই রাকাত ফজরের সুন্নাত দুনিয়া ও তার মধ্যে যা আছে তার চেয়ে উত্তম।',
                      reference: 'সহীহ মুসলিম: ৭২৫',
                    ),
                    const SizedBox(height: 12),
                    _HadithCard(
                      isLight: isLight,
                      hadith:
                          'যে ব্যক্তি দিনে-রাতে ১২ রাকাত সুন্নাত নামাজ আদায় করবে, তার জন্য জান্নাতে একটি ঘর নির্মাণ করা হবে।',
                      reference: 'সহীহ মুসলিম: ৭২৮',
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

class _ProgressPill extends StatelessWidget {
  final bool isLight;
  final int completed;

  const _ProgressPill({
    required this.isLight,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isLight ? AppColors.backgroundLightMode : AppColors.primaryOpacity15,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            '$completed/5',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14.8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSummaryCard extends StatelessWidget {
  final bool isLight;
  final int completed;

  const _TopSummaryCard({
    required this.isLight,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আজকের অগ্রগতি',
                  style: TextStyle(
                    color: isLight
                        ? AppColors.textLightMode.withOpacity(0.92)
                        : AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed / 5 ফরয সম্পন্ন',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          _MiniBadge(
            isLight: isLight,
            text: '${(completed / 5 * 100).round()}%',
            filled: completed == 5,
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final bool isLight;
  final String text;
  final bool filled;

  const _MiniBadge({
    required this.isLight,
    required this.text,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? AppColors.primary.withOpacity(isLight ? 0.14 : 0.20)
        : Colors.black.withOpacity(isLight ? 0.04 : 0.16);

    final fg = filled
        ? AppColors.primary
        : (isLight ? AppColors.textSecondaryLightMode.withOpacity(0.9) : AppColors.grey400);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.16),
            blurRadius: 10,
            offset: const Offset(0, 8),
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
  final bool isLight;
  final VoidCallback onTap;
  final double size;

  const _PremiumCheckBox({
    required this.value,
    required this.isLight,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final bg = value
        ? AppColors.primary
        : (isLight ? AppColors.backgroundLightMode : AppColors.grey800);

    final checkColor = value
        ? (isLight ? const Color(0xFF1F2937) : AppColors.backgroundDark)
        : null;

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
              color: Colors.black.withOpacity(isLight ? 0.10 : 0.28),
              blurRadius: value ? 16 : 12,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(value ? 0.18 : 0.10),
              blurRadius: 10,
              offset: const Offset(-2, -2),
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
  final bool isLight;
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.isLight,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final panelBg = isLight ? AppColors.primary.withOpacity(0.05) : AppColors.backgroundDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.primary,
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
  final bool isLight;
  final IconData icon;
  final String title;
  final String body;
  final Color bodyTextColor;

  const _InfoCard({
    required this.isLight,
    required this.icon,
    required this.title,
    required this.body,
    required this.bodyTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final boxBg = isLight ? AppColors.primary.withOpacity(0.05) : AppColors.backgroundDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.18),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
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
  final bool isLight;
  final String hadith;
  final String reference;

  const _HadithCard({
    required this.isLight,
    required this.hadith,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final surface = isLight ? AppColors.backgroundLightMode : const Color(0xFF1A1A1A);

    final hadithTextColor = isLight
        ? AppColors.textLightMode.withOpacity(0.90)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.22),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hadith,
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
          Text(
            '📚 $reference',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
