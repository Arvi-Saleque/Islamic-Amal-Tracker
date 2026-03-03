import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:amal_tracker/core/utils/prayer_name_utils.dart';
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
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[0],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[1],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).extension<GradientColors>()!.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
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
            colors: Theme.of(context)
                .extension<GradientColors>()!
                .backgroundGradient,
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

  Widget _buildPrayerTile(String prayer) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final notifier = ref.read(prayerTrackingProvider.notifier);

    final isExpanded = expanded[prayer] ?? false;
    final isDone = prayerState.todayData.prayerDone[prayer] ?? false;

    final titleColor = isDone
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final subColor =
        Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.75);

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
                                fridayAwareDisplay(prayer),
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
                          isDone ? 'Complete' : 'Tap to expand rakats',
                          style: TextStyle(
                            color: isDone
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.70)
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
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: arrowColor, size: 30),
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
                        Theme.of(context).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
                        Theme.of(context).colorScheme.primary.withOpacity(0.14),
                        Theme.of(context).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
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
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.10),
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.06),
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

    final rowBg = done
        ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
        : Theme.of(context).scaffoldBackgroundColor;

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
              colors: Theme.of(context)
                      .extension<GradientColors>()!
                      .innerCardGradient,
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
                  fridayAwareRakat(prayer, rakat),
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
      backgroundColor: Theme.of(context).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
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
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.5),
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
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'নামাজের তথ্য ও ফযিলত',
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
                    const _SectionHeader(
                        icon: Icons.mosque_outlined,
                        title: 'জামাতে নামাজের ফযিলত'
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'জামাতে নামাজ পড়া একাকী নামাজ পড়ার চেয়ে সাতাশ গুণ বেশি মর্যাদাসম্পন্ন।',
                      reference: 'সহীহ বুখারী: ৬৪৫, সহীহ মুসলিম: ৬৫০',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'যে ব্যক্তি এশার সালাত জামাআতের সাথে আদায় করবে, সে অর্ধেক রাত্রি ক্বিয়াম করার ছোয়াব পাবে। আর যে ব্যক্তি এশা ও ফজর জামাআতের সাথে আদায় করবে, সে পূর্ণ রাত্রি ক্বিয়াম করার ছোয়াব পাবে।',
                      reference: 'সহীহ মুসলিম: ৬৫৬',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'যে ব্যক্তি চল্লিশ দিন জামাতের সাথে নামাজ আদায় করে এবং প্রথম তাকবীর পায়, তার জন্য দুটি মুক্তি লেখা হয়: জাহান্নাম থেকে মুক্তি এবং মুনাফিকী থেকে মুক্তি।',
                      reference: 'জামে তিরমিযী: ২৪১',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'জামাআত ধরার জন্য হেটে যাওয়া প্রতিটি পদক্ষেপের বিনিময়ে মুসল্লির মর্যাদা বৃদ্ধি পায়, গুনাহ মাফ হয় ও নেকী লেখা হতে থাকে।',
                      reference: 'সহীহ বুখারী: ৬৪৭',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'মুনাফিকদের জন্য ফজর ও এশার নামাজ সবচেয়ে ভারী। তারা যদি জানত এতে কী পরিমাণ সওয়াব আছে, তাহলে হামাগুড়ি দিয়ে হলেও আসত।',
                      reference: 'সহীহ বুখারী: ৬৫৭',
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(
                        icon: Icons.access_time_rounded,
                        title: 'আউয়াল ওয়াক্তে নামাজের ফযিলত'),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'রাসূলুল্লাহ (সা.) কে জিজ্ঞাসা করা হলো, কোন আমল সবচেয়ে উত্তম? তিনি বললেন: ওয়াক্তের শুরুতে নামাজ আদায় করা।',
                      reference: 'জামে তিরমিযী: ১৭০, সুনানে আবু দাউদ: ৪২৬',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'নামাজের প্রথম ওয়াক্ত আল্লাহর সন্তুষ্টি এবং শেষ ওয়াক্ত আল্লাহর ক্ষমা।',
                      reference: 'জামে তিরমিযী: ১৭২',
                    ),
                    const SizedBox(height: 18),
                    const _SectionHeader(
                        icon: Icons.auto_awesome_rounded,
                        title: 'সুন্নাত নামাজের ফযিলত'),
                    const SizedBox(height: 12),
                    const _HadithCard(
                      hadith:
                          'দুই রাকাত ফজরের সুন্নাত দুনিয়া ও তার মধ্যে যা আছে তার চেয়ে উত্তম।',
                      reference: 'সহীহ মুসলিম: ৭২৫',
                    ),
                    const SizedBox(height: 12),
                    const _HadithCard(
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


class _TopSummaryCard extends StatelessWidget {
  final int completed;

  const _TopSummaryCard({
    required this.completed,
  });

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
            child: Icon(Icons.mosque_rounded,
                color: Theme.of(context).colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আজকের অগ্রগতি',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completed / 5 ফরয সম্পন্ন',
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

  const _MiniBadge({
    required this.text,
    required this.filled,
  });

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

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

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
            child: Icon(icon,
                color: Theme.of(context).extension<GradientColors>()!.onPrimaryText, size: 18),
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
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: Theme.of(context).colorScheme.primary, size: 18),
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

  const _HadithCard({
    required this.hadith,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
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
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    color: Theme.of(context).colorScheme.primary, size: 14),
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
          Row(
            children: [
              Icon(
                Icons.book_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.75),
              ),
              const SizedBox(width: 5),
              Text(
                reference,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
