import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/qaza_prayer_provider.dart';
import '../../../../core/theme/app_theme.dart';

class QazaPrayerSection extends ConsumerStatefulWidget {
  const QazaPrayerSection({super.key});

  @override
  ConsumerState<QazaPrayerSection> createState() => _QazaPrayerSectionState();
}

class _QazaPrayerSectionState extends ConsumerState<QazaPrayerSection> {
  // Track expanded state for each prayer
  final Map<String, bool> _expandedStates = {
    'ফজর': false,
    'যুহর': false,
    'আসর': false,
    'মাগরিব': false,
    'এশা': false,
  };

  @override
  Widget build(BuildContext context) {
    final qazaState = ref.watch(qazaPrayerProvider);
    final qazaNotifier = ref.read(qazaPrayerProvider.notifier);
    
    if (qazaState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryGold,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            const Color(0xFF1A1A1A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: totalPending > 0
              ? AppTheme.primaryGold.withOpacity(0.5)
              : AppTheme.primaryGold.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: totalPending > 0
                ? AppTheme.primaryGold.withOpacity(0.1)
                : AppTheme.primaryGold.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                totalPending > 0
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle,
                color: totalPending > 0 ? AppTheme.primaryGold : Colors.green,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                totalPending > 0
                    ? 'বাকি কাজা নামাজ: ${_toBengaliNumber(totalPending)}'
                    : 'আলহামদুলিল্লাহ! কোনো কাজা নেই',
                style: TextStyle(
                  color: totalPending > 0 ? AppTheme.primaryGold : Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (totalPending > 0) ...[
            const SizedBox(height: 16),
            Text(
              'গত ৩০ দিনের মধ্যে',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryGold.withOpacity(0.8),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'কাজা আদায় করার পর চেকমার্ক দিন। একবার মার্ক করলে পরে আর দেখাবে না।',
              style: TextStyle(
                color: Colors.grey[300],
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
    final isExpanded = _expandedStates[summary.prayerName] ?? false;
    final pendingCount = summary.pendingCount;
    final hasPending = pendingCount > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPending
                ? AppTheme.primaryGold.withOpacity(0.4)
                : Colors.green.withOpacity(0.4),
            width: 1.5,
          ),
        ),
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
                            ? AppTheme.primaryGold.withOpacity(0.15)
                            : Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getPrayerIcon(summary.prayerName),
                        color: hasPending ? AppTheme.primaryGold : Colors.green,
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
                            summary.prayerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasPending
                                ? 'বাকি: ${_toBengaliNumber(pendingCount)} ওয়াক্ত'
                                : 'সব কাজা আদায় হয়েছে',
                            style: TextStyle(
                              color: hasPending
                                  ? AppTheme.primaryGold.withOpacity(0.8)
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
                          color: AppTheme.primaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _toBengaliNumber(pendingCount),
                          style: const TextStyle(
                            color: AppTheme.primaryGold,
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
                        color: hasPending ? AppTheme.primaryGold : Colors.green,
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
                    color: Colors.grey[800],
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
                        'কোনো বাকি কাজা নেই',
                        style: TextStyle(
                          color: Colors.grey[500],
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
    final date = DateTime.parse(qaza.date);
    final formattedDate = _formatDateBengali(date);
    final weekday = _getWeekdayBengali(date.weekday);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => notifier.toggleQazaCompletion(qaza.date, qaza.prayerName),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF2A2A2A),
              width: 1,
            ),
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
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: qaza.isQazaDone
                        ? Colors.green
                        : AppTheme.primaryGold.withOpacity(0.6),
                    width: 2,
                  ),
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
                        color: qaza.isQazaDone
                            ? Colors.grey
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: qaza.isQazaDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      weekday,
                      style: TextStyle(
                        color: Colors.grey[500],
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
                  color: Colors.grey[500],
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
      case 'যুহর':
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

  String _formatDateBengali(DateTime date) {
    final months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
      'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'
    ];
    return '${_toBengaliNumber(date.day)} ${months[date.month - 1]}';
  }

  String _getWeekdayBengali(int weekday) {
    final days = [
      'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার',
      'শুক্রবার', 'শনিবার', 'রবিবার'
    ];
    return days[weekday - 1];
  }

  String _getDaysAgo(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(targetDate).inDays;

    if (difference == 1) return 'গতকাল';
    if (difference == 2) return 'পরশু';
    return '${_toBengaliNumber(difference)} দিন আগে';
  }

  String _toBengaliNumber(int number) {
    const bengaliDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? bengaliDigits[index] : digit;
    }).join();
  }
}
