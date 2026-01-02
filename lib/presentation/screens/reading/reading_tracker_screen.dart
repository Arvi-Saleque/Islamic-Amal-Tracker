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
}
