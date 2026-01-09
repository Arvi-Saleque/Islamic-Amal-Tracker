import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reading_tracker_provider.dart';
import '../../../data/models/reading_tracker_model.dart';

class ReadingTrackerScreen extends ConsumerStatefulWidget {
  const ReadingTrackerScreen({super.key});

  @override
  ConsumerState<ReadingTrackerScreen> createState() =>
      _ReadingTrackerScreenState();
}

class _ReadingTrackerScreenState extends ConsumerState<ReadingTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final readingState = ref.watch(readingTrackerProvider);
    final readingNotifier = ref.read(readingTrackerProvider.notifier);

    final quranProgress = readingState.todayData.quranProgress;
    final tafsirProgress = readingState.todayData.tafsirProgress;
    final hadithProgress = readingState.todayData.hadithProgress;

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
          'পড়াশোনা ট্র্যাকার',
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
            icon: const Icon(Icons.settings_outlined, color: Color(0xFFD4AF37)),
            onPressed: () => _showGoalSettingsDialog(context, readingNotifier),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Overall Progress
            _buildOverallProgress(readingState.todayData),

            const SizedBox(height: 16),

            // Reading Type Cards
            _buildReadingTypeCard(
              context,
              type: ReadingType.quran,
              title: 'কুরআন তেলাওয়াত',
              icon: Icons.menu_book,
              progress: quranProgress,
              currentMinutes: readingState.todayData.quranMinutes,
              goalMinutes: readingState.todayData.goal.quranMinutes,
              sessions: readingNotifier.getSessionsByType(ReadingType.quran),
              readingNotifier: readingNotifier,
            ),

            _buildReadingTypeCard(
              context,
              type: ReadingType.tafsir,
              title: 'তাফসীর অধ্যয়ন',
              icon: Icons.book,
              progress: tafsirProgress,
              currentMinutes: readingState.todayData.tafsirMinutes,
              goalMinutes: readingState.todayData.goal.tafsirMinutes,
              sessions: readingNotifier.getSessionsByType(ReadingType.tafsir),
              readingNotifier: readingNotifier,
            ),

            _buildReadingTypeCard(
              context,
              type: ReadingType.hadith,
              title: 'হাদিস পাঠ',
              icon: Icons.auto_stories,
              progress: hadithProgress,
              currentMinutes: readingState.todayData.hadithMinutes,
              goalMinutes: readingState.todayData.goal.hadithMinutes,
              sessions: readingNotifier.getSessionsByType(ReadingType.hadith),
              readingNotifier: readingNotifier,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(ReadingTrackerModel data) {
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
                'আজকের মোট পড়া',
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
                ),
                child: Text(
                  '${data.totalSessions} সেশন',
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
                      '${data.totalMinutes} মিনিট',
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'লক্ষ্য: ${data.goal.totalMinutes} মিনিট',
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
                        value: data.overallProgress,
                        strokeWidth: 8,
                        backgroundColor: const Color(0xFF2A2A2A),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    Text(
                      '${(data.overallProgress * 100).toInt()}%',
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
        ],
      ),
    );
  }

  Widget _buildReadingTypeCard(
    BuildContext context, {
    required ReadingType type,
    required String title,
    required IconData icon,
    required double progress,
    required int currentMinutes,
    required int goalMinutes,
    required List<ReadingSession> sessions,
    required ReadingTrackerNotifier readingNotifier,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: progress >= 1.0
              ? const Color(0xFFD4AF37).withOpacity(0.5)
              : const Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFFD4AF37),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFFE0E0E0),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentMinutes / $goalMinutes মিনিট',
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSessionDialog(
                        context,
                        type,
                        title,
                        readingNotifier,
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('যোগ করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF0A0A0A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF0A0A0A),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (sessions.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFF2A2A2A),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: sessions.map((session) {
                  return _buildSessionItem(session, readingNotifier);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(
    ReadingSession session,
    ReadingTrackerNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF2A2A2A),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFFD4AF37),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${session.durationMinutes} মিনিট',
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFF666666),
              size: 20,
            ),
            onPressed: () => _confirmDeleteSession(context, session, notifier),
          ),
        ],
      ),
    );
  }

  void _showAddSessionDialog(
    BuildContext context,
    ReadingType type,
    String typeTitle,
    ReadingTrackerNotifier notifier,
  ) {
    final titleController = TextEditingController();
    final minutesController = TextEditingController(text: '15');
    final notesController = TextEditingController();

    // For Quran specific fields
    final surahController = TextEditingController();
    final fromAyahController = TextEditingController();
    final toAyahController = TextEditingController();

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
          '$typeTitle সেশন যোগ করুন',
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Color(0xFFE0E0E0)),
                decoration: InputDecoration(
                  labelText: type == ReadingType.quran
                      ? 'সূরাহর নাম'
                      : type == ReadingType.tafsir
                          ? 'তাফসীরের নাম'
                          : 'হাদিসের নাম',
                  labelStyle: const TextStyle(color: Color(0xFF888888)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
              if (type == ReadingType.quran) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromAyahController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFFE0E0E0)),
                        decoration: InputDecoration(
                          labelText: 'আয়াত থেকে',
                          labelStyle: const TextStyle(color: Color(0xFF888888)),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: toAyahController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Color(0xFFE0E0E0)),
                        decoration: InputDecoration(
                          labelText: 'আয়াত পর্যন্ত',
                          labelStyle: const TextStyle(color: Color(0xFF888888)),
                          filled: true,
                          fillColor: const Color(0xFF0A0A0A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Color(0xFFE0E0E0)),
                decoration: InputDecoration(
                  labelText: 'সময় (মিনিট)',
                  labelStyle: const TextStyle(color: Color(0xFF888888)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                style: const TextStyle(color: Color(0xFFE0E0E0)),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'নোট (ঐচ্ছিক)',
                  labelStyle: const TextStyle(color: Color(0xFF888888)),
                  filled: true,
                  fillColor: const Color(0xFF0A0A0A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ],
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
              if (titleController.text.isNotEmpty) {
                final minutes = int.tryParse(minutesController.text) ?? 15;
                final fromAyah = int.tryParse(fromAyahController.text);
                final toAyah = int.tryParse(toAyahController.text);

                notifier.addSession(
                  type: type,
                  title: titleController.text,
                  surahName: type == ReadingType.quran
                      ? titleController.text
                      : null,
                  fromAyah: fromAyah,
                  toAyah: toAyah,
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  durationMinutes: minutes,
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

  void _confirmDeleteSession(
    BuildContext context,
    ReadingSession session,
    ReadingTrackerNotifier notifier,
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
          '"${session.title}" সেশন মুছে ফেলতে চান?',
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
              notifier.deleteSession(session.id);
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

  void _showGoalSettingsDialog(
    BuildContext context,
    ReadingTrackerNotifier notifier,
  ) {
    final quranController = TextEditingController(
      text: '${ref.read(readingTrackerProvider).todayData.goal.quranMinutes}',
    );
    final tafsirController = TextEditingController(
      text: '${ref.read(readingTrackerProvider).todayData.goal.tafsirMinutes}',
    );
    final hadithController = TextEditingController(
      text: '${ref.read(readingTrackerProvider).todayData.goal.hadithMinutes}',
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
        title: const Text(
          'দৈনিক লক্ষ্য নির্ধারণ করুন',
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
              controller: quranController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFE0E0E0)),
              decoration: InputDecoration(
                labelText: 'কুরআন (মিনিট)',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tafsirController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFE0E0E0)),
              decoration: InputDecoration(
                labelText: 'তাফসীর (মিনিট)',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hadithController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Color(0xFFE0E0E0)),
              decoration: InputDecoration(
                labelText: 'হাদিস (মিনিট)',
                labelStyle: const TextStyle(color: Color(0xFF888888)),
                filled: true,
                fillColor: const Color(0xFF0A0A0A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
              notifier.updateGoal(
                quranMinutes: int.tryParse(quranController.text) ?? 15,
                tafsirMinutes: int.tryParse(tafsirController.text) ?? 10,
                hadithMinutes: int.tryParse(hadithController.text) ?? 10,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('সংরক্ষণ করুন'),
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
                        'পড়াশোনা - তথ্য ও ফযিলত',
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
                      icon: Icons.timer_outlined,
                      title: 'কিভাবে ব্যবহার করবেন?',
                      content: '''
• প্রতিটি ক্যাটাগরিতে সেশন যোগ করুন
• মিনিট এবং পৃষ্ঠা/আয়াত/হাদিস সংখ্যা লিখুন
• সেটিংস থেকে দৈনিক লক্ষ্য নির্ধারণ করুন
• লক্ষ্য পূরণ হলে সম্পন্ন দেখাবে
• প্রতিদিন মধ্যরাতে স্বয়ংক্রিয়ভাবে রিসেট হয়''',
                    ),
                    const SizedBox(height: 20),

                    // Quran section
                    _buildInfoSection(
                      icon: Icons.menu_book,
                      title: 'কুরআন তেলাওয়াতের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'কুরআনের প্রতিটি অক্ষর পাঠে একটি নেকী এবং প্রতিটি নেকী দশগুণে বৃদ্ধি পায়।',
                      reference: 'জামে তিরমিযী: ২৯১০',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি কুরআন পড়ে এবং তা মুখস্থ করে, সে সম্মানিত নেক ফেরেশতাদের সাথে থাকবে। আর যে কষ্ট করে পড়ে, তার জন্য দুই সওয়াব।',
                      reference: 'সহীহ বুখারী: ৪৯৩৭',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'তোমরা কুরআন পড়ো, কারণ এটি কিয়ামতের দিন তার পাঠকদের জন্য সুপারিশকারী হিসেবে আসবে।',
                      reference: 'সহীহ মুসলিম: ৭৩০',
                    ),
                    const SizedBox(height: 20),

                    // Tafsir section
                    _buildInfoSection(
                      icon: Icons.book,
                      title: 'কুরআন বোঝার গুরুত্ব',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'তোমাদের মধ্যে সেই ব্যক্তি সর্বোত্তম যে কুরআন শেখে এবং অন্যকে শেখায়।',
                      reference: 'সহীহ বুখারী: ৫০২২',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি ইলম অর্জনের পথে বের হয়, আল্লাহ তার জন্য জান্নাতের পথ সহজ করে দেন।',
                      reference: 'সহীহ মুসলিম: ২৬৭৬',
                    ),
                    const SizedBox(height: 20),

                    // Hadith section
                    _buildInfoSection(
                      icon: Icons.auto_stories,
                      title: 'হাদিস শিক্ষার গুরুত্ব',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'আল্লাহ সেই ব্যক্তির চেহারা উজ্জ্বল (সজীব) করুন, যে আমার কথা শুনেছে, তা সংরক্ষণ (মুখস্থ) করেছে এবং তা অন্যের কাছে পৌঁছে দিয়েছে।',
                      reference: 'জামে তিরমিযী: ২৬৫৭',
                    ),
                    const SizedBox(height: 20),

                    // Knowledge seeking
                    _buildInfoSection(
                      icon: Icons.school,
                      title: 'ইলম অর্জনের ফযিলত',
                      content: '',
                      isHadithSection: true,
                    ),
                    const SizedBox(height: 16),

                    _buildHadithCard(
                      hadith:
                          'ইলম অর্জন করা প্রতিটি মুসলিম নর-নারীর জন্য ফরজ।',
                      reference: 'সুনানে ইবনে মাজাহ: ২২৬',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'যে ব্যক্তি ইলম অর্জনের পথে বের হয়, সে ফিরে আসা পর্যন্ত সে আল্লাহর পথে থাকে।',
                      reference: 'জামে তিরমিযী: ২৬৫৪',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      hadith:
                          'আলেমরা নবীদের উত্তরাধিকারী। নবীগণ উত্তরাধিকারী রেখে যাননি দিনার-দিরহাম, বরং রেখে গেছেন ইলম।',
                      reference: 'সুনানে আবু দাউদ: ৩৬৪১',
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
