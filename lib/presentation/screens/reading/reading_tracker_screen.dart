import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
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

    final bg = Theme.of(context).scaffoldBackgroundColor;
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;

    return Scaffold(
      backgroundColor: bg,
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
        titleSpacing: 16,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'reading_title'.tr(),
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
              title: 'reading_quran'.tr(),
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
              title: 'reading_tafsir'.tr(),
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
              title: 'reading_hadith'.tr(),
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
          final cs = Theme.of(context).colorScheme;
          final gradients = Theme.of(context).extension<GradientColors>()!;
          
          return FloatingActionButton(
            mini: true,
            onPressed: () => _showGoalSettingsDialog(context, readingNotifier),
            backgroundColor: cs.primary,
            child: Icon(
              Icons.settings,
              color: gradients.onPrimaryText,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(ReadingTrackerModel data) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'reading_total_today'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${data.totalSessions} ${'reading_sessions'.tr()}',
                    style: TextStyle(
                      color: cs.primary,
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
                        '${data.totalMinutes} ${'reading_minutes'.tr()}',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'reading_goal'.tr()}: ${data.goal.totalMinutes} ${'reading_minutes'.tr()}',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            cs.primary,
                          ),
                        ),
                      ),
                      Text(
                        '${(data.overallProgress * 100).toInt()}%',
                        style: TextStyle(
                          color: cs.onSurface,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final gradients = theme.extension<GradientColors>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        padding: EdgeInsets.zero,
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
                          color: cs.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: cs.primary,
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
                                color: cs.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$currentMinutes / $goalMinutes ${'reading_minutes'.tr()}',
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
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
                        label: Text('reading_add_session'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: gradients.onPrimaryText,
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
                      backgroundColor: cs.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        cs.primary,
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
                      color: cs.outline.withOpacity(0.3),
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
      ),
    );
  }

  Widget _buildSessionItem(
    ReadingSession session,
    ReadingTrackerNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: cs.outline.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: cs.primary,
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
                    color: cs.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (session.notes != null && session.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    session.notes!,
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.7),
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
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${session.durationMinutes} ${'reading_minutes'.tr()}',
              style: TextStyle(
                color: cs.primary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: cs.onSurfaceVariant,
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
    final fromAyahController = TextEditingController();
    final toAyahController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SingleChildScrollView(
            child: buildPremiumCard(
              context: context,
              radius: 18,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$typeTitle ${'reading_add_session'.tr()}',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                  controller: titleController,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: type == ReadingType.quran
                        ? 'reading_quran_name'.tr()
                        : type == ReadingType.tafsir
                            ? 'reading_tafsir_name'.tr()
                            : 'reading_hadith_name'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
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
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            labelText: 'reading_quran_from_ayah'.tr(),
                            labelStyle: TextStyle(color: cs.onSurfaceVariant),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.primary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: toAyahController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: cs.onSurface),
                          decoration: InputDecoration(
                            labelText: 'reading_quran_to_ayah'.tr(),
                            labelStyle: TextStyle(color: cs.onSurfaceVariant),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: cs.primary),
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
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'reading_time_minutes'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: cs.onSurface),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'reading_notes_optional'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel'.tr(),
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        backgroundColor: cs.primary,
                        foregroundColor: gradients.onPrimaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('reading_add_session'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: buildPremiumCard(
            context: context,
            radius: 18,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'daily_amal_delete_title'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'reading_delete_session_confirm'
                      .tr(namedArgs: {'title': session.title}),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'no'.tr(),
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      child: Text('daily_amal_delete_confirm'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: buildPremiumCard(
            context: context,
            radius: 18,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'reading_set_goal'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: quranController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'reading_goal_quran_minutes'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tafsirController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'reading_goal_tafsir_minutes'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hadithController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    labelText: 'reading_goal_hadith_minutes'.tr(),
                    labelStyle: TextStyle(color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel'.tr(),
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                        backgroundColor: cs.primary,
                        foregroundColor: gradients.onPrimaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('save'.tr()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show info bottom sheet
  void _showInfoBottomSheet(BuildContext context) {
    final dividerColor = Theme.of(context).colorScheme.primary.withOpacity(0.3);

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
                        'reading_info_title'.tr(),
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
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                  children: [
                    // How it works
                    _buildInfoSection(
                      icon: Icons.timer_outlined,
                      title: 'reading_info_how_title'.tr(),
                      content: 'reading_info_how_body'.tr(),
                    ),
                    const SizedBox(height: 20),

                    // Quran section
                    _SectionHeader(
                      icon: Icons.menu_book,
                      title: 'reading_info_quran_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith1_text',
                      reference: 'reading_info_hadith1_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith2_text',
                      reference: 'reading_info_hadith2_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith3_text',
                      reference: 'reading_info_hadith3_ref',
                    ),
                    const SizedBox(height: 18),

                    // Tafsir section
                    _SectionHeader(
                      icon: Icons.book,
                      title: 'reading_info_tafsir_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith4_text',
                      reference: 'reading_info_hadith4_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith5_text',
                      reference: 'reading_info_hadith5_ref',
                    ),
                    const SizedBox(height: 18),

                    // Hadith section
                    _SectionHeader(
                      icon: Icons.auto_stories,
                      title: 'reading_info_hadith_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith6_text',
                      reference: 'reading_info_hadith6_ref',
                    ),
                    const SizedBox(height: 18),

                    // Knowledge seeking
                    _SectionHeader(
                      icon: Icons.school,
                      title: 'reading_info_ilm_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith7_text',
                      reference: 'reading_info_hadith7_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith8_text',
                      reference: 'reading_info_hadith8_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'reading_info_hadith9_text',
                      reference: 'reading_info_hadith9_ref',
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
  }) {
    final cs = Theme.of(context).colorScheme;

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
                  color: cs.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cs.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: cs.primary,
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
                color: cs.onSurfaceVariant,
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

class _HadithCard extends StatelessWidget {
  final String hadith;
  final String reference;

  const _HadithCard({
    required this.hadith,
    required this.reference,
  });

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
          )
        ],
      ),
    );
  }
}