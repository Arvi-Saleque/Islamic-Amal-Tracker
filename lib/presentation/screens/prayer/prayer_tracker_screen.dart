import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/prayer_tracking_provider.dart';
import '../../../core/theme/app_colors.dart';

class PrayerTrackerScreen extends ConsumerStatefulWidget {
  const PrayerTrackerScreen({super.key});

  @override
  ConsumerState<PrayerTrackerScreen> createState() =>
      _PrayerTrackerScreenState();
}

class _PrayerTrackerScreenState extends ConsumerState<PrayerTrackerScreen>
    with SingleTickerProviderStateMixin {
  // Track expanded state for each prayer
  final Map<String, bool> expanded = {
    'ফজর': false,
    'যুহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final prayerNotifier = ref.read(prayerTrackingProvider.notifier);
    final completedPrayers = prayerState.todayData.completedPrayersCount;
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Expanded(
              child: Text(
                'নামাজের হিসাব',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.textGolden,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            onPressed: () => _showInfoBottomSheet(context),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryOpacity15,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowGolden,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedPrayers/৫',
                  style: const TextStyle(
                    color: AppColors.textGolden,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPrayerTile('ফজর'),
          const SizedBox(height: 12),
          _buildPrayerTile('যুহর'),
          const SizedBox(height: 12),
          _buildPrayerTile('আসর'),
          const SizedBox(height: 12),
          _buildPrayerTile('মাগরিব'),
          const SizedBox(height: 12),
          _buildPrayerTile('এশা'),
        ],
      ),
    );
  }

  Widget _buildPrayerTile(String prayer) {
    final prayerState = ref.watch(prayerTrackingProvider);
    final prayerNotifier = ref.read(prayerTrackingProvider.notifier);
    
    final isExpanded = expanded[prayer] ?? false;
    final isDone = prayerState.todayData.prayerDone[prayer] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          if (isDone)
            BoxShadow(
              color: AppColors.shadowGolden,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                expanded[prayer] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Custom Checkbox
                  GestureDetector(
                    onTap: () => prayerNotifier.togglePrayer(prayer),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.primary
                            : AppColors.grey800,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: isDone ? AppColors.shadowGolden : Colors.black.withOpacity(0.4),
                            blurRadius: isDone ? 8 : 6,
                            offset: const Offset(0, 2),
                            spreadRadius: isDone ? 1 : 0,
                          ),
                        ],
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              color: AppColors.backgroundDark,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Prayer Name
                  Expanded(
                    child: Text(
                      prayer,
                      style: TextStyle(
                        color: isDone
                            ? AppColors.textGolden
                            : AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Expand Arrow
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDone
                          ? AppColors.textGolden
                          : AppColors.grey500,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable Rakat Section
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.transparent,
                        AppColors.primaryOpacity20,
                        AppColors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    children: prayerState.todayData.rakatsDone[prayer]!
                        .entries
                        .map((entry) => _buildRakatCheckbox(
                              prayer,
                              entry.key,
                              entry.value,
                            ))
                        .toList(),
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
    );
  }

  Widget _buildRakatCheckbox(String prayer, String rakat, bool done) {
    final prayerNotifier = ref.read(prayerTrackingProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => prayerNotifier.toggleRakat(prayer, rakat),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: done
                ? AppColors.primaryOpacity06
                : AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: done ? AppColors.shadowGolden : AppColors.shadowDark,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? AppColors.primary : AppColors.grey800,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: done ? AppColors.shadowGolden : Colors.black.withOpacity(0.3),
                      blurRadius: done ? 6 : 4,
                      offset: const Offset(0, 1),
                      spreadRadius: done ? 0.5 : 0,
                    ),
                  ],
                ),
                child: done
                    ? const Icon(
                        Icons.check,
                        color: AppColors.backgroundDark,
                        size: 14,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  rakat,
                  style: TextStyle(
                    color: done
                        ? AppColors.textGolden
                        : AppColors.textTertiary,
                    fontSize: 15,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show info bottom sheet
  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOpacity15,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'নামাজের তথ্য ও ফযিলত',
                      style: TextStyle(
                        color: AppColors.textGolden,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: AppColors.grey800,
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // How counting works
                    _buildInfoSection(
                      icon: Icons.calculate_outlined,
                      title: 'হিসাব কিভাবে হয়?',
                      content: '''
• শুধুমাত্র ফরয নামাজ পড়লেই ওয়াক্ত কাউন্ট হবে
• ফরযের ২টি অপশন আছে:
  ১) জামাতে/আউয়াল ওয়াক্তে - সময়মতো পড়লে
  ২) দেরী করে - দেরী করে পড়লে
• যেকোনো একটি ফরয অপশন সিলেক্ট করলেই নামাজ complete
• ৫ ওয়াক্ত ফরয পড়লে দিনের নামাজ ১০০% complete''',
                    ),
                    const SizedBox(height: 20),
                    
                    // Hadith section
                    _buildInfoSection(
                      icon: Icons.mosque_outlined,
                      title: 'জামাতে নামাজের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Hadith 1
                    _buildHadithCard(
                      hadith: 'জামাতে নামাজ পড়া একাকী নামাজ পড়ার চেয়ে সাতাশ গুণ বেশি মর্যাদাসম্পন্ন।',
                      reference: 'সহীহ বুখারী: ৬৪৫, সহীহ মুসলিম: ৬৫০',
                    ),
                    const SizedBox(height: 12),
                    
                    // Hadith 2
                    _buildHadithCard(
                      hadith: 'যে ব্যক্তি এশার সালাত জামাআতের সাথে আদায় করবে, সে অর্ধেক রাত্রি ক্বিয়াম করার ছোয়াব পাবে। আর যে ব্যক্তি এশা ও ফজর জামাআতের সাথে আদায় করবে, সে পূর্ণ রাত্রি ক্বিয়াম করার ছোয়াব পাবে।',
                      reference: 'সহীহ মুসলিম: ৬৫৬',
                    ),
                    const SizedBox(height: 12),
                    
                    // Hadith 3
                    _buildHadithCard(
                      hadith: 'যে ব্যক্তি চল্লিশ দিন জামাতের সাথে নামাজ আদায় করে এবং প্রথম তাকবীর পায়, তার জন্য দুটি মুক্তি লেখা হয়: জাহান্নাম থেকে মুক্তি এবং মুনাফিকী থেকে মুক্তি।',
                      reference: 'জামে তিরমিযী: ২৪১',
                    ),
                    const SizedBox(height: 12),
                    
                    // Hadith 4
                    _buildHadithCard(
                      hadith: 'জামাআত ধরার জন্য হেটে যাওয়া প্রতিটি পদক্ষেপের বিনিময়ে মুসল্লির মর্যাদা বৃদ্ধি পায়, গুনাহ মাফ হয় ও নেকী লেখা হতে থাকে।',
                      reference: 'সহীহ বুখারী: ৬৪৭',
                    ),
                    const SizedBox(height: 12),
                    
                    // Hadith 5
                    _buildHadithCard(
                      hadith: 'মুনাফিকদের জন্য ফজর ও এশার নামাজ সবচেয়ে ভারী। তারা যদি জানত এতে কী পরিমাণ সওয়াব আছে, তাহলে হামাগুড়ি দিয়ে হলেও আসত।',
                      reference: 'সহীহ বুখারী: ৬৫৭',
                    ),
                    const SizedBox(height: 20),
                    
                    // Early prayer section
                    _buildInfoSection(
                      icon: Icons.access_time,
                      title: 'আউয়াল ওয়াক্তে নামাজের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildHadithCard(
                      hadith: 'রাসূলুল্লাহ (সা.) কে জিজ্ঞাসা করা হলো, কোন আমল সবচেয়ে উত্তম? তিনি বললেন: ওয়াক্তের শুরুতে নামাজ আদায় করা।',
                      reference: 'জামে তিরমিযী: ১৭০, সুনানে আবু দাউদ: ৪২৬',
                    ),
                    const SizedBox(height: 12),
                    
                    _buildHadithCard(
                      hadith: 'নামাজের প্রথম ওয়াক্ত আল্লাহর সন্তুষ্টি এবং শেষ ওয়াক্ত আল্লাহর ক্ষমা।',
                      reference: 'জামে তিরমিযী: ১৭২',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Early prayer section
                    _buildInfoSection(
                      icon: Icons.access_time,
                      title: 'সুন্নাত নামাজের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildHadithCard(
                      hadith:
                          'দুই রাকাত ফজরের সুন্নাত দুনিয়া ও তার মধ্যে যা আছে তার চেয়ে উত্তম।',
                      reference: 'সহীহ মুসলিম: ৭২৫',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি দিনে-রাতে ১২ রাকাত সুন্নাত নামাজ আদায় করবে, তার জন্য জান্নাতে একটি ঘর নির্মাণ করা হবে।',
                      reference: 'সহীহ মুসলিম: ৭২৮',
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    bool isHadithSection = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGolden,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              content,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHadithCard({
    required String hadith,
    required String reference,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryOpacity06,
            AppColors.primaryOpacity06,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowGolden,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hadith,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '📚 $reference',
            style: const TextStyle(
              color: AppColors.textGolden,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
