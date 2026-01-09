import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dhikr_counter_provider.dart';
import '../../../data/models/dhikr_counter_model.dart';

class DhikrCounterScreen extends ConsumerStatefulWidget {
  const DhikrCounterScreen({super.key});

  @override
  ConsumerState<DhikrCounterScreen> createState() => _DhikrCounterScreenState();
}

class _DhikrCounterScreenState extends ConsumerState<DhikrCounterScreen> {
  @override
  Widget build(BuildContext context) {
    final dhikrState = ref.watch(dhikrCounterProvider);
    final dhikrNotifier = ref.read(dhikrCounterProvider.notifier);

    final totalCount = dhikrState.todayData.totalCount;
    final totalTarget = dhikrState.todayData.totalTarget;
    final completedItems = dhikrState.todayData.completedItemsCount;
    final totalItems = dhikrState.todayData.items.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'যিকির কাউন্টার',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Info button
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
            onPressed: () => _showInfoBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            onPressed: () => _showResetConfirmDialog(context, dhikrNotifier),
          ),
        ],
      ),
      body: Column(
        children: [
          // Overall Progress Card
          _buildOverallProgress(totalCount, totalTarget, completedItems, totalItems),

          // Dhikr List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: dhikrState.todayData.items.length,
              itemBuilder: (context, index) {
                return _buildDhikrCard(
                  dhikrState.todayData.items[index],
                  dhikrNotifier,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: () => _showAddDhikrDialog(context, dhikrNotifier),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(
          Icons.add,
          color: Color(0xFF0A0A0A),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildOverallProgress(int count, int target, int completed, int total) {
    final percentage = target > 0 ? count / target : 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
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
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'আজকের মোট',
                style: TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  '$completed/$total সম্পন্ন',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'লক্ষ্য: $target',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: percentage,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF2A2A2A),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                      ),
                    ),
                    Text(
                      '${(percentage * 100).toInt()}%',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: const Color(0xFF0A0A0A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrCard(DhikrItem dhikr, DhikrCounterNotifier notifier) {
    final isCompleted = dhikr.isCompleted;
    final progress = dhikr.progress;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFD4AF37).withOpacity(0.5)
              : const Color(0xFF2A2A2A),
          width: 1.5,
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dhikr.arabic != null) ...[
                            Text(
                              dhikr.arabic!,
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            dhikr.title,
                            style: TextStyle(
                              color: isCompleted
                                  ? const Color(0xFFD4AF37)
                                  : const Color(0xFFE0E0E0),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (dhikr.isCustom)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Color(0xFF888888),
                              size: 20,
                            ),
                            onPressed: () => _showEditTargetDialog(
                              context,
                              dhikr,
                              notifier,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Color(0xFF888888),
                              size: 20,
                            ),
                            onPressed: () => _confirmDeleteDhikr(
                              context,
                              dhikr,
                              notifier,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Counter Display
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Decrement Button
                      _buildCounterButton(
                        icon: Icons.remove,
                        onPressed: dhikr.currentCount > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                notifier.decrementDhikr(dhikr.id);
                              }
                            : null,
                      ),
                      const SizedBox(width: 24),
                      // Count Display (Tappable for manual input)
                      InkWell(
                        onTap: () => _showManualInputDialog(
                          context,
                          dhikr,
                          notifier,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '${dhikr.currentCount}',
                                style: TextStyle(
                                  color: isCompleted
                                      ? const Color(0xFFD4AF37)
                                      : const Color(0xFFE0E0E0),
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'লক্ষ্য: ${dhikr.targetCount}',
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                '(ট্যাপ করুন)',
                                style: TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Increment Button
                      _buildCounterButton(
                        icon: Icons.add,
                        onPressed: dhikr.currentCount < dhikr.targetCount
                            ? () {
                                HapticFeedback.mediumImpact();
                                notifier.incrementDhikr(dhikr.id);
                                if (dhikr.currentCount + 1 == dhikr.targetCount) {
                                  HapticFeedback.heavyImpact();
                                }
                              }
                            : null,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% সম্পন্ন',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 13,
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFD4AF37),
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'সম্পূর্ণ',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          TextButton.icon(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              notifier.resetDhikr(dhikr.id);
                            },
                            icon: const Icon(
                              Icons.refresh,
                              size: 14,
                              color: Color(0xFF666666),
                            ),
                            label: const Text(
                              'রিসেট',
                              style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF0A0A0A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Material(
      color: isPrimary
          ? const Color(0xFFD4AF37)
          : const Color(0xFF2A2A2A).withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF2A2A2A),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: isPrimary
                ? const Color(0xFF0A0A0A)
                : onPressed != null
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF444444),
            size: 32,
          ),
        ),
      ),
    );
  }

  void _showAddDhikrDialog(BuildContext context, DhikrCounterNotifier notifier) {
    final titleController = TextEditingController();
    final arabicController = TextEditingController();
    final targetController = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: const Text(
          'নতুন যিকির যোগ করুন',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Color(0xFFE0E0E0)),
              decoration: InputDecoration(
                labelText: 'যিকিরের নাম',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: arabicController,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
              ),
              decoration: InputDecoration(
                labelText: 'আরবি (ঐচ্ছিক)',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              style: const TextStyle(color: Color(0xFFE0E0E0)),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'লক্ষ্য সংখ্যা',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                final target = int.tryParse(targetController.text) ?? 100;
                notifier.addCustomDhikr(
                  titleController.text,
                  arabicController.text.isEmpty ? null : arabicController.text,
                  target,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }

  void _showEditTargetDialog(
    BuildContext context,
    DhikrItem dhikr,
    DhikrCounterNotifier notifier,
  ) {
    final targetController = TextEditingController(text: '${dhikr.targetCount}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: const Text(
          'লক্ষ্য সংখ্যা পরিবর্তন করুন',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: targetController,
          style: const TextStyle(color: Color(0xFFE0E0E0)),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'নতুন লক্ষ্য',
            labelStyle: const TextStyle(color: Color(0xFF888888)),
            filled: true,
            fillColor: const Color(0xFF0A0A0A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newTarget = int.tryParse(targetController.text);
              if (newTarget != null && newTarget > 0) {
                notifier.updateTarget(dhikr.id, newTarget);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('আপডেট করুন'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDhikr(
    BuildContext context,
    DhikrItem dhikr,
    DhikrCounterNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: const Text(
          'মুছে ফেলবেন?',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '"${dhikr.title}" মুছে ফেলতে চান?',
          style: const TextStyle(color: Color(0xFFE0E0E0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'না',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.deleteDhikr(dhikr.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('হ্যাঁ, মুছুন'),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog(
    BuildContext context,
    DhikrItem dhikr,
    DhikrCounterNotifier notifier,
  ) {
    final countController = TextEditingController(
      text: '${dhikr.currentCount}',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: Text(
          dhikr.title,
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: countController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: 'কাউন্ট লিখুন',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'লক্ষ্য: ${dhikr.targetCount}',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newCount = int.tryParse(countController.text);
              if (newCount != null && newCount >= 0) {
                // Calculate difference and apply increments/decrements
                final diff = newCount - dhikr.currentCount;
                if (diff > 0) {
                  for (int i = 0; i < diff; i++) {
                    notifier.incrementDhikr(dhikr.id);
                  }
                } else if (diff < 0) {
                  for (int i = 0; i < -diff; i++) {
                    notifier.decrementDhikr(dhikr.id);
                  }
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('সেট করুন'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context, DhikrCounterNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: const Text(
          'সব রিসেট করবেন?',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'সমস্ত যিকির কাউন্টার ০-তে রিসেট হবে।',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'না',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetAllDhikr();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('হ্যাঁ, রিসেট করুন'),
          ),
        ],
      ),
    );
  }

  // Show info bottom sheet
  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
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
                  color: Colors.grey[600],
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
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFFD4AF37),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'যিকির - তথ্য ও ফযিলত',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: const Color(0xFF2A2A2A),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // How it works
                    _buildInfoSection(
                      icon: Icons.touch_app,
                      title: 'কিভাবে ব্যবহার করবেন?',
                      content: '''
• প্রতিটি যিকির কার্ডে ট্যাপ করলে কাউন্ট বাড়বে
• টার্গেট পূরণ হলে স্বয়ংক্রিয়ভাবে সম্পন্ন হবে
• নিজের পছন্দমতো যিকির যোগ করতে পারবেন
• প্রতিদিন মধ্যরাতে স্বয়ংক্রিয়ভাবে রিসেট হয়''',
                    ),
                    const SizedBox(height: 20),

                    // Tasbih section
                    _buildInfoSection(
                      icon: Icons.favorite,
                      title: 'তাসবীহ ফাতেমীর ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'প্রতি নামাজের পর ৩৩ বার সুবহানাল্লাহ, ৩৩ বার আলহামদুলিল্লাহ, ৩৩ বার আল্লাহু আকবার বললে গুনাহ মাফ হয়, যদিও সমুদ্রের ফেনার মতো হয়।',
                      reference: 'সহীহ মুসলিম: ৬৯৭',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'দুটি কালেমা আছে যা জিহ্বায় হালকা কিন্তু মীযানে ভারী: সুবহানাল্লাহি ওয়া বিহামদিহি ও লা ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।',
                      reference: 'সহীহ বুখারী: ৬৩৬০, সহীহ মুসলিম: ২৬৯২',
                    ),
                    const SizedBox(height: 20),

                    // SubhanAllah section
                    _buildInfoSection(
                      icon: Icons.star,
                      title: 'সুবহানাল্লাহির ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'সুবহানাল্লাহি ওয়াল হামদুলিল্লাহ - এটি মীযানকে ভরপুর করে দেয়, অথবা আসমান ও জমিনের মধ্যবর্তী স্থানের মতো।',
                      reference: 'সহীহ মুসলিম: ২৬৯৬',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি দিনে ১০০ বার সুবহানাল্লাহ বলবে, তার জন্য ১০০০ নেকী লেখা হবে এবং ১০০ গুনাহ মাফ হবে।',
                      reference: 'সহীহ মুসলিম: ২৬৯২',
                    ),
                    const SizedBox(height: 20),

                    // Istighfar section
                    _buildInfoSection(
                      icon: Icons.healing,
                      title: 'ইস্তিগফারের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি নিয়মিত ইস্তিগফার করবে, আল্লাহ তার সব দুশ্চিন্তা দূর করে দেবেন, সব সংকট থেকে বের করে দেবেন এবং অপ্রত্যাশিত জায়গা থেকে রিযিিক দেবেন।',
                      reference: 'সুনানে আবু দাউদ: ১৫১৮',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'আমি দিনে ৭০ বারেরও বেশি আল্লাহর কাছে তাওবা করি এবং ইস্তিগফার করি।',
                      reference: 'সহীহ বুখারী: ৬৩০৭',
                    ),
                    const SizedBox(height: 20),

                    // La ilaha illallah section
                    _buildInfoSection(
                      icon: Icons.brightness_high,
                      title: 'লা ইলাহা ইল্লাল্লাহর ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'সর্বোত্তম যিকির হলো লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইইন কাদীর।',
                      reference: 'জামে তিরমিযী: ৩৫৮৫',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি দিনে ১০০ বার লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু... বলবে, তা ১০টি গোলাম মুক্ত করার সমান, ১০০ নেকী লেখা হবে, ১০০ গুনাহ মাফ হবে এবং সন্ধ্যা পর্যন্ত শয়তান থেকে রক্ষা হবে।',
                      reference: 'সহীহ বুখারী: ৬৩০৩, সহীহ মুসলিম: ২৬৯১',
                    ),
                    const SizedBox(height: 20),

                    // Durood section
                    _buildInfoSection(
                      icon: Icons.auto_awesome,
                      title: 'দরূদ শরীফের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি আমার উপর একবার দরূদ পাঠাবে, আল্লাহ তার উপর দশবার রহমত বর্ষণ করেন।',
                      reference: 'সহীহ মুসলিম: ৪০২',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'কিয়ামতের দিন আমার নিকটতম হবে সেই ব্যক্তি যে আমার উপর সবচেয়ে বেশি দরূদ পাঠাবে।',
                      reference: 'জামে তিরমিযী: ৪৮৪',
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

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
    bool isHadithSection = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFFD4AF37),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
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
                color: Color(0xFFE0E0E0),
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
            const Color(0xFFD4AF37).withOpacity(0.08),
            const Color(0xFFD4AF37).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.format_quote,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hadith,
                  style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '📚 $reference',
              style: TextStyle(
                color: const Color(0xFFD4AF37).withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
