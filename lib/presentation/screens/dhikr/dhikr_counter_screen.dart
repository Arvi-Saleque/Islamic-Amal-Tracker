import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dhikr_counter_provider.dart';
import '../../../data/models/dhikr_counter_model.dart';
import '../../../core/theme/app_theme.dart';

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

    final titleColor = Theme.of(context).colorScheme.primary;

    final totalCount = dhikrState.todayData.totalCount;
    final totalTarget = dhikrState.todayData.totalTarget;
    final completedItems = dhikrState.todayData.completedItemsCount;
    final totalItems = dhikrState.todayData.items.length;

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
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Text(
          'dhikr_counter_title'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
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
          child: Column(
            children: [
              // Overall Progress Card
              _buildOverallProgress(
                  totalCount, totalTarget, completedItems, totalItems),

              // Dhikr List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        mini: true,
        elevation: 10,
        highlightElevation: 14,
        onPressed: () => _showAddDhikrDialog(context, dhikrNotifier),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildOverallProgress(
      int count, int target, int completed, int total) {
    final percentage = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        padding: const EdgeInsets.all(16),
        child: Column(
              children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'dhikr_today_total'.tr(),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: theme.extension<GradientColors>()!.innerCardGradient,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: cs.primary.withOpacity(0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '$completed/$total ${'dhikr_complete'.tr()}',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${'daily_amal_goal'.tr()}: $target',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 1,
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withOpacity(0.55),
                              cs.surface.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                SizedBox(
                  width: 104,
                  height: 104,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simple progress ring (clean)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: percentage),
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return SizedBox(
                            width: 104,
                            height: 104,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 8,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                cs.primary,
                              ),
                            ),
                          );
                        },
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        child: Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
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

  Widget _buildDhikrCard(DhikrItem dhikr, DhikrCounterNotifier notifier) {
    final isCompleted = dhikr.isCompleted;
    final progress = dhikr.progress.clamp(0.0, 1.0);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final titleColor = cs.onSurface;
    final subtitleColor = cs.onSurfaceVariant;
    final trackColor = cs.surfaceContainerHighest;
    final completedBg = cs.primary.withOpacity(0.1);
    final completedBorder = cs.primary.withOpacity(0.3);
    final completedText = cs.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        padding: EdgeInsets.zero,
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (dhikr.arabic != null) ...[
                            Text(
                              dhikr.arabic!,
                              style: TextStyle(
                                color: cs.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Arial',
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            _localizedDhikrTitle(context, dhikr),
                            style: TextStyle(
                              color: isCompleted
                                  ? titleColor
                                  : subtitleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (dhikr.isCustom)
                      Row(
                        children: [
                          _IconPillButton(
                            icon: Icons.edit_outlined,
                            onTap: () => _showEditTargetDialog(
                              context,
                              dhikr,
                              notifier,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _IconPillButton(
                            icon: Icons.delete_outline,
                            onTap: () => _confirmDeleteDhikr(
                              context,
                              dhikr,
                              notifier,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Counter Display (Glass + 3D)
                _GlassPanel(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                  borderRadius: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCounterButton(
                        icon: Icons.remove,
                        onPressed: dhikr.currentCount > 0
                            ? () {
                                HapticFeedback.lightImpact();
                                notifier.decrementDhikr(dhikr.id);
                              }
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Count Display (Tappable for manual input)
                      Flexible(
                        child: InkWell(
                          onTap: () => _showManualInputDialog(
                            context,
                            dhikr,
                            notifier,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 120),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: theme.extension<GradientColors>()!.innerCardGradient,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: cs.primary.withOpacity(0.25),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 42,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${dhikr.currentCount}',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        color: cs.primary,
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                        letterSpacing: -0.6,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${'daily_amal_goal'.tr()}: ${dhikr.targetCount}',
                                  style: TextStyle(
                                    color: cs.onSurfaceVariant,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: theme.extension<GradientColors>()!.onPrimaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                      _buildCounterButton(
                        icon: Icons.add,
                        onPressed: dhikr.currentCount < dhikr.targetCount
                            ? () {
                                HapticFeedback.mediumImpact();
                                notifier.incrementDhikr(dhikr.id);
                                if (dhikr.currentCount + 1 ==
                                    dhikr.targetCount) {
                                  HapticFeedback.heavyImpact();
                                }
                              }
                            : null,
                        isPrimary: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Progress Bar + actions
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}% ${'dhikr_complete'.tr()}',
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: completedBg,
                              border: Border.all(color: completedBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: completedText,
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'dhikr_complete'.tr(),
                                  style: TextStyle(
                                    color: completedText,
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
                            icon: Icon(
                              Icons.refresh,
                              size: 14,
                              color: cs.onSurfaceVariant,
                            ),
                            label: Text(
                              'dhikr_reset'.tr(),
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
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
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: progress),
                        duration: const Duration(milliseconds: 650),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 7,
                            backgroundColor:
                                trackColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              cs.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;
        final enabled = onPressed != null;

        return Opacity(
          opacity: enabled ? 1 : 0.55,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isPrimary
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary.withOpacity(0.85),
                            cs.primary,
                            cs.primary.withOpacity(0.90),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.surfaceContainerHigh.withOpacity(0.95),
                            cs.surfaceContainerHigh.withOpacity(0.70),
                          ],
                        ),
                  border: isPrimary
                      ? Border.all(color: cs.primary.withOpacity(0.75), width: 1)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(isPrimary ? 0.30 : 0.20),
                      blurRadius: isPrimary ? 6 : 2,
                      offset: const Offset(0, 3),
                    ),
                    if (isPrimary || enabled)
                      BoxShadow(
                        color: cs.primary.withOpacity(isPrimary ? 0.25 : 0.10),
                        blurRadius: isPrimary ? 5 : 3,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: isPrimary
                      ? gradients.onPrimaryText
                      : cs.onSurface,
                  size: 28,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDhikrDialog(
      BuildContext context, DhikrCounterNotifier notifier) {
    final titleController = TextEditingController();
    final arabicController = TextEditingController();
    final targetController = TextEditingController(text: '100');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;
        final fieldFill = cs.surfaceContainerHighest;

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
                  'dhikr_add'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'dhikr_name'.tr(),
                    filled: true,
                    fillColor: fieldFill,
                    labelStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary.withOpacity(0.6),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: arabicController,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    labelText: 'dhikr_arabic_optional'.tr(),
                    filled: true,
                    fillColor: fieldFill,
                    labelStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary.withOpacity(0.6),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  style: TextStyle(
                    color: cs.onSurface,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'dhikr_target_count'.tr(),
                    filled: true,
                    fillColor: fieldFill,
                    labelStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary.withOpacity(0.6),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface,
                      ),
                      child: Text('cancel'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          final target = int.tryParse(targetController.text) ?? 100;
                          notifier.addCustomDhikr(
                            titleController.text,
                            arabicController.text.isEmpty
                                ? null
                                : arabicController.text,
                            target,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: gradients.onPrimaryText,
                        elevation: 2,
                        shadowColor: theme.shadowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Text('dhikr_add'.tr()),
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

  void _showEditTargetDialog(
    BuildContext context,
    DhikrItem dhikr,
    DhikrCounterNotifier notifier,
  ) {
    final targetController =
        TextEditingController(text: '${dhikr.targetCount}');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;
        final fieldFill = cs.surfaceContainerHighest;

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
                  'dhikr_edit_target_title'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: targetController,
                  style: TextStyle(
                    color: cs.onSurface,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'dhikr_new_target'.tr(),
                    filled: true,
                    fillColor: fieldFill,
                labelStyle: TextStyle(
                  color: cs.onSurfaceVariant,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: cs.outline.withOpacity(0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: cs.primary.withOpacity(0.6),
                    width: 1.4,
                  ),
                ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface,
                      ),
                      child: Text('cancel'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final newTarget = int.tryParse(targetController.text);
                        if (newTarget != null && newTarget > 0) {
                          notifier.updateTarget(dhikr.id, newTarget);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: gradients.onPrimaryText,
                        elevation: 2,
                        shadowColor: theme.shadowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Text('dhikr_update'.tr()),
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

  void _confirmDeleteDhikr(
    BuildContext context,
    DhikrItem dhikr,
    DhikrCounterNotifier notifier,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

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
                  'dhikr_delete_confirm'.tr(
                    namedArgs: {'title': _localizedDhikrTitle(context, dhikr)},
                  ),
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
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface,
                      ),
                      child: Text('no'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        notifier.deleteDhikr(dhikr.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                        elevation: 2,
                        shadowColor: theme.shadowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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

  String _localizedDhikrTitle(BuildContext context, DhikrItem dhikr) {
    if (dhikr.isCustom) {
      return dhikr.title;
    }
    switch (dhikr.id) {
      case 'subhanallah_100':
        return 'dhikr_subhanallah_label'.tr();
      case 'alhamdulillah_100':
        return 'dhikr_alhamdulillah_label'.tr();
      case 'allahu_akbar_100':
        return 'dhikr_allahu_akbar_label'.tr();
      case 'astaghfirullah_100':
        return 'dhikr_astaghfirullah_label'.tr();
      case 'durood_100':
        return 'dhikr_durood_label'.tr();
      case 'kalima_100':
        return 'dhikr_kalima_label'.tr();
      default:
        return dhikr.title;
    }
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final gradients = theme.extension<GradientColors>()!;
        final fieldFill = cs.surfaceContainerHighest;

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
                  _localizedDhikrTitle(context, dhikr),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: countController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'dhikr_enter_count'.tr(),
                    filled: true,
                    fillColor: fieldFill,
                    labelStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.outline.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: cs.primary.withOpacity(0.6),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${'daily_amal_goal'.tr()}: ${dhikr.targetCount}',
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
                      style: TextButton.styleFrom(
                        foregroundColor: cs.onSurface,
                      ),
                      child: Text('cancel'.tr()),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final newCount = int.tryParse(countController.text);
                        if (newCount != null && newCount >= 0) {
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
                        backgroundColor: cs.primary,
                        foregroundColor: gradients.onPrimaryText,
                        elevation: 2,
                        shadowColor: theme.shadowColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      child: Text('dhikr_set_count'.tr()),
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
                        'dhikr_info_title'.tr(),
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
                      icon: Icons.touch_app,
                      title: 'dhikr_info_how_title'.tr(),
                      content: 'dhikr_info_how_body'.tr(),
                    ),
                    const SizedBox(height: 20),

                    // Tasbih section
                    _SectionHeader(
                      icon: Icons.favorite,
                      title: 'dhikr_info_tasbih_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith1_text',
                      reference: 'dhikr_info_hadith1_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith2_text',
                      reference: 'dhikr_info_hadith2_ref',
                    ),
                    const SizedBox(height: 18),

                    // SubhanAllah section
                    _SectionHeader(
                      icon: Icons.star,
                      title: 'dhikr_info_subhanallah_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith3_text',
                      reference: 'dhikr_info_hadith3_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith4_text',
                      reference: 'dhikr_info_hadith4_ref',
                    ),
                    const SizedBox(height: 18),

                    // Istighfar section
                    _SectionHeader(
                      icon: Icons.healing,
                      title: 'dhikr_info_istighfar_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith5_text',
                      reference: 'dhikr_info_hadith5_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith6_text',
                      reference: 'dhikr_info_hadith6_ref',
                    ),
                    const SizedBox(height: 18),

                    // La ilaha illallah section
                    _SectionHeader(
                      icon: Icons.brightness_high,
                      title: 'dhikr_info_lailaha_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith7_text',
                      reference: 'dhikr_info_hadith7_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith8_text',
                      reference: 'dhikr_info_hadith8_ref',
                    ),
                    const SizedBox(height: 18),

                    // Durood section
                    _SectionHeader(
                      icon: Icons.auto_awesome,
                      title: 'dhikr_info_durud_title'.tr(),
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith9_text',
                      reference: 'dhikr_info_hadith9_ref',
                    ),
                    const SizedBox(height: 12),

                    const _HadithCard(
                      hadith: 'dhikr_info_hadith10_text',
                      reference: 'dhikr_info_hadith10_ref',
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding,
    this.borderRadius = 16,
  });

  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: theme.extension<GradientColors>()!.innerCardGradient,
            ),
            border:Border.all(color: cs.outline.withOpacity(0.10), width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _IconPillButton extends StatelessWidget {
  const _IconPillButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surface.withOpacity(0),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cs.surfaceContainerHigh,
            border: Border.all(color: cs.outline.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
