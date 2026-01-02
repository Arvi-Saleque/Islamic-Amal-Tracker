import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/prayer_tracking_provider.dart';

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
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'নামাজের হিসাব',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFD4AF37),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedPrayers/৫',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
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
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone
              ? const Color(0xFFD4AF37).withOpacity(0.4)
              : const Color(0xFF2A2A2A),
          width: 1.5,
        ),
        boxShadow: isDone
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
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
                            ? const Color(0xFFD4AF37)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDone
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF666666),
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFF0A0A0A),
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
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFE0E0E0),
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
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF888888),
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
                        Colors.transparent,
                        const Color(0xFFD4AF37).withOpacity(0.2),
                        Colors.transparent,
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
                ? const Color(0xFFD4AF37).withOpacity(0.08)
                : const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: done
                  ? const Color(0xFFD4AF37).withOpacity(0.3)
                  : const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFFD4AF37) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        done ? const Color(0xFFD4AF37) : const Color(0xFF555555),
                    width: 2,
                  ),
                ),
                child: done
                    ? const Icon(
                        Icons.check,
                        color: Color(0xFF0A0A0A),
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
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFFB0B0B0),
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
}
