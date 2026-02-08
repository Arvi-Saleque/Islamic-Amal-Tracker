import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/reading_tracker_provider.dart';
import '../../../data/models/reading_tracker_model.dart';
import '../../../core/theme/app_colors.dart';

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

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark;

    final quranProgress = readingState.todayData.quranProgress;
    final tafsirProgress = readingState.todayData.tafsirProgress;
    final hadithProgress = readingState.todayData.hadithProgress;

    final iconColor =  AppColors.primary;
    final titleColor = AppColors.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'পড়াশোনা',
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
      floatingActionButton: Builder(
        builder: (context) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          return FloatingActionButton(
            mini: true,
            onPressed: () => _showGoalSettingsDialog(context, readingNotifier),
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.settings,
              color: isLight ? Colors.white : Colors.black,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(ReadingTrackerModel data) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppColors.surfaceLightMode : AppColors.backgroundLight;
    final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
    final subColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;
    final ringBg = isLight ? Colors.black.withOpacity(0.08) : const Color(0xFF2A2A2A);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            if (isLight)
              ...[
            Colors.red,
          ]
            else
              ...[
                AppColors.backgroundLight,
                AppColors.backgroundLight,
              ],
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: isLight ? Border.all(color: Colors.black.withOpacity(0.06), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.08 : 0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          if (data.overallProgress >= 1.0)
            BoxShadow(
              color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.15),
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
              Text(
                'আজকের মোট পড়া',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isLight ? 0.10 : 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${data.totalSessions} সেশন',
                  style: const TextStyle(
                    color: AppColors.primary,
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
                        color: AppColors.primary,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'লক্ষ্য: ${data.goal.totalMinutes} মিনিট',
                      style: TextStyle(
                        color: subColor,
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
                        backgroundColor: isLight
                            ? AppColors.surfaceLightMode.withOpacity(0.3)
                            : cs.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      '${(data.overallProgress * 100).toInt()}%',
                      style: TextStyle(
                        color: isLight ? AppColors.textLightMode : AppColors.primary,
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppColors.surfaceLightMode : AppColors.backgroundLight;
    final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
    final subColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;
    final trackBg = isLight ? Colors.black.withOpacity(0.08) : AppColors.backgroundDark;
    final dividerColor = isLight ? AppColors.borderLightMode : const Color(0xFF2A2A2A).withOpacity(0.5);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            if (isLight)
              ...[
            Colors.red,
          ]
            else
              ...[
                AppColors.backgroundLight,
                AppColors.backgroundLight,
              ],
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: isLight ? Border.all(color: Colors.black.withOpacity(0.06), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.3),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          if (progress >= 1.0)
            BoxShadow(
              color: AppColors.primary.withOpacity(isLight ? 0.10 : 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
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
                        color: AppColors.primary.withOpacity(isLight ? 0.10 : 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
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
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentMinutes / $goalMinutes মিনিট',
                            style: TextStyle(
                              color: subColor,
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: isLight ? Colors.white : AppColors.backgroundDark,
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
                    backgroundColor: trackBg,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (sessions.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: dividerColor,
                    width: 0.5,
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
    final isLight = Theme.of(context).brightness == Brightness.light;
    final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
    final noteColor = isLight ? AppColors.textSecondaryLightMode.withOpacity(0.7) : AppColors.grey600;
    final dividerColor = isLight ? AppColors.borderLightMode : const Color(0xFF2A2A2A).withOpacity(0.3);
    final badgeBg = isLight ? AppColors.primary.withOpacity(0.08) : const Color(0xFF2A2A2A);
    final deleteColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey600;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isLight ? 0.10 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.primary,
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
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: TextStyle(
                      color: noteColor,
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
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${session.durationMinutes} মিনিট',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: deleteColor,
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final dialogBg = isLight ? AppColors.surfaceLightMode : AppColors.backgroundLight;
        final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final inputTextColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final labelColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;
        final fillColor = isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark;
        final cancelColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: titleColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          title: Text('$typeTitle সেশন যোগ করুন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: inputTextColor),
                  decoration: InputDecoration(
                    labelText: type == ReadingType.quran
                        ? 'সূরাহর নাম'
                        : type == ReadingType.tafsir
                            ? 'তাফসীরের নাম'
                            : 'হাদিসের নাম',
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
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
                          style: TextStyle(color: inputTextColor),
                          decoration: InputDecoration(
                            labelText: 'আয়াত থেকে',
                            labelStyle: TextStyle(color: labelColor),
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: toAyahController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: inputTextColor),
                          decoration: InputDecoration(
                            labelText: 'আয়াত পর্যন্ত',
                            labelStyle: TextStyle(color: labelColor),
                            filled: true,
                            fillColor: fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: AppColors.primary),
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
                  style: TextStyle(color: inputTextColor),
                  decoration: InputDecoration(
                    labelText: 'সময় (মিনিট)',
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: inputTextColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'নোট (ঐচ্ছিক)',
                    labelStyle: TextStyle(color: labelColor),
                    filled: true,
                    fillColor: fillColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'বাতিল',
                style: TextStyle(color: cancelColor),
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
                    surahName:
                        type == ReadingType.quran ? titleController.text : null,
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
                backgroundColor: AppColors.primary,
                foregroundColor: isLight ? Colors.white : AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('যোগ করুন'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteSession(
    BuildContext context,
    ReadingSession session,
    ReadingTrackerNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final dialogBg = isLight ? AppColors.surfaceLightMode : AppColors.backgroundLight;
        final cancelColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            color: isLight ? AppColors.textSecondaryLightMode : AppColors.textSecondary,
            fontSize: 14,
          ),
          title: const Text('মুছে ফেলবেন?'),
          content: Text('"${session.title}" সেশন মুছে ফেলতে চান?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'না',
                style: TextStyle(color: cancelColor),
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
        );
      },
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final dialogBg = isLight ? AppColors.surfaceLightMode : AppColors.backgroundLight;
        final inputTextColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final labelColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;
        final fillColor = isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark;
        final cancelColor = isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;

        return AlertDialog(
          backgroundColor: dialogBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          title: const Text('দৈনিক লক্ষ্য নির্ধারণ করুন'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quranController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: inputTextColor),
                decoration: InputDecoration(
                  labelText: 'কুরআন (মিনিট)',
                  labelStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: tafsirController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: inputTextColor),
                decoration: InputDecoration(
                  labelText: 'তাফসীর (মিনিট)',
                  labelStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hadithController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: inputTextColor),
                decoration: InputDecoration(
                  labelText: 'হাদিস (মিনিট)',
                  labelStyle: TextStyle(color: labelColor),
                  filled: true,
                  fillColor: fillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'বাতিল',
                style: TextStyle(color: cancelColor),
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
                backgroundColor: AppColors.primary,
                foregroundColor: isLight ? Colors.white : AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        );
      },
    );
  }

  // Show info bottom sheet
  void _showInfoBottomSheet(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
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
        initialChildSize: 0.85,
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight ? Colors.black.withOpacity(0.18) : AppColors.grey600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
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
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'পড়াশোনা - তথ্য ও ফযিলত',
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
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                  children: [
                    // How it works
                    _buildInfoSection(
                      isDark: !isLight,
                      bodyTextColor: bodyTextColor,
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
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.menu_book,
                      title: 'কুরআন তেলাওয়াতের ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'কুরআনের প্রতিটি অক্ষর পাঠে একটি নেকী এবং প্রতিটি নেকী দশগুণে বৃদ্ধি পায়।',
                      reference: 'জামে তিরমিযী: ২৯১০',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি কুরআন পড়ে এবং তা মুখস্থ করে, সে সম্মানিত নেক ফেরেশতাদের সাথে থাকবে। আর যে কষ্ট করে পড়ে, তার জন্য দুই সওয়াব।',
                      reference: 'সহীহ বুখারী: ৪৯৩৭',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'তোমরা কুরআন পড়ো, কারণ এটি কিয়ামতের দিন তার পাঠকদের জন্য সুপারিশকারী হিসেবে আসবে।',
                      reference: 'সহীহ মুসলিম: ৭৩০',
                    ),
                    const SizedBox(height: 18),

                    // Tafsir section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.book,
                      title: 'কুরআন বোঝার গুরুত্ব',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'তোমাদের মধ্যে সেই ব্যক্তি সর্বোত্তম যে কুরআন শেখে এবং অন্যকে শেখায়।',
                      reference: 'সহীহ বুখারী: ৫০২২',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি ইলম অর্জনের পথে বের হয়, আল্লাহ তার জন্য জান্নাতের পথ সহজ করে দেন।',
                      reference: 'সহীহ মুসলিম: ২৬৭৬',
                    ),
                    const SizedBox(height: 18),

                    // Hadith section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.auto_stories,
                      title: 'হাদিস শিক্ষার গুরুত্ব',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'আল্লাহ সেই ব্যক্তির চেহারা উজ্জ্বল (সজীব) করুন, যে আমার কথা শুনেছে, তা সংরক্ষণ (মুখস্থ) করেছে এবং তা অন্যের কাছে পৌঁছে দিয়েছে।',
                      reference: 'জামে তিরমিযী: ২৬৫৭',
                    ),
                    const SizedBox(height: 18),

                    // Knowledge seeking
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.school,
                      title: 'ইলম অর্জনের ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith: 'ইলম অর্জন করা প্রতিটি মুসলিম নর-নারীর জন্য ফরজ।',
                      reference: 'সুনানে ইবনে মাজাহ: ২২৬',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি ইলম অর্জনের পথে বের হয়, সে ফিরে আসা পর্যন্ত সে আল্লাহর পথে থাকে।',
                      reference: 'জামে তিরমিযী: ২৬৫৪',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
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
    required bool isDark,
    required Color bodyTextColor,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final boxBg = isDark ? AppColors.backgroundDark : AppColors.primary.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
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
                  color: AppColors.primary.withOpacity(isDark ? 0.18 : 0.12),
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
          if (content.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              content,
              style: TextStyle(
                color: bodyTextColor,
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHadithCard({
    required bool isDark,
    required String hadith,
    required String reference,
  }) {
    final surface = isDark ? const Color(0xFF1A1A1A) : AppColors.backgroundLightMode;
    final hadithTextColor = isDark
        ? AppColors.textSecondary
        : AppColors.textLightMode.withOpacity(0.90);

    final isLight = !isDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.06),
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
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(isLight ? 0.12 : 0.18),
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
                '$reference',
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

  Widget _buildSectionHeader({
    required bool isDark,
    required IconData icon,
    required String title,
  }) {
    final panelBg = isDark ? AppColors.backgroundDark : AppColors.primary.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.05),
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
              color: AppColors.primary.withOpacity(isDark ? 0.18 : 0.12),
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
