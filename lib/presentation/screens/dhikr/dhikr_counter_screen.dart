import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/dhikr_counter_provider.dart';
import '../../../data/models/dhikr_counter_model.dart';
import '../../../core/theme/app_colors.dart';

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

    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg = isLight ? AppColors.backgroundLightMode : AppColors.backgroundDark;
    final iconColor = isLight ? AppColors.textLightMode : AppColors.primary;
    final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;

    final totalCount = dhikrState.todayData.totalCount;
    final totalTarget = dhikrState.todayData.totalTarget;
    final completedItems = dhikrState.todayData.completedItemsCount;
    final totalItems = dhikrState.todayData.items.length;

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
          'যিকির কাউন্টার',
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
            icon: Icon(Icons.info_outline, color: iconColor),
            onPressed: () => _showInfoBottomSheet(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: iconColor),
            onPressed: () => _showResetConfirmDialog(context, dhikrNotifier),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _PremiumBackground(),
          Column(
            children: [
              // Overall Progress Card
              _buildOverallProgress(
                  totalCount, totalTarget, completedItems, totalItems),

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
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final isLight = Theme.of(context).brightness == Brightness.light;
          return FloatingActionButton(
            mini: true,
            onPressed: () => _showAddDhikrDialog(context, dhikrNotifier),
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.add,
              color: isLight ? Colors.white : Colors.black,
              size: 20,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(
      int count, int target, int completed, int total) {
    final percentage = target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;

    final isLight = Theme.of(context).brightness == Brightness.light;

    final labelColor =
        isLight ? AppColors.textSecondaryLightMode : AppColors.textSecondary;

    final mainTextColor =
        isLight ? AppColors.textLightMode : AppColors.textSecondary;

    final subTextColor =
        isLight ? AppColors.textSecondaryLightMode : AppColors.grey500;

    final ringBg =
        isLight ? Colors.black.withOpacity(0.08) : AppColors.grey800.withOpacity(0.45);

    final chipTextColor =
        isLight ? AppColors.textLightMode : AppColors.textSecondary;

    final chipShadowColor =
        Colors.black.withOpacity(isLight ? 0.10 : 0.25);

    return _PremiumCard(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      padding: const EdgeInsets.all(20),
      glow: false,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'আজকের মোট',
                style: TextStyle(
                  color: labelColor,
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
                    colors: [
                      AppColors.primary.withOpacity(0.18),
                      AppColors.primary.withOpacity(0.07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  // No border (clean)
                  border: null,
                  // Softer shadow (premium but not odd)
                  boxShadow: [
                    BoxShadow(
                      color: chipShadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  '$completed/$total সম্পন্ন',
                  style: TextStyle(
                    color: chipTextColor,
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
                        color: mainTextColor,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'লক্ষ্য: $target',
                      style: TextStyle(
                        color: subTextColor,
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
                            AppColors.primary.withOpacity(0.55),
                            Colors.transparent,
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
                            backgroundColor:
                                ringBg,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
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
                          color: mainTextColor,
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
    );
  }

  Widget _buildDhikrCard(DhikrItem dhikr, DhikrCounterNotifier notifier) {
    final isCompleted = dhikr.isCompleted;
    final progress = dhikr.progress.clamp(0.0, 1.0);

    final isLight = Theme.of(context).brightness == Brightness.light;

    final titleColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;
    final subtitleColor =
        isLight ? AppColors.textSecondaryLightMode : AppColors.textSecondary;

    final trackColor =
        isLight ? Colors.black.withOpacity(0.08) : Colors.white.withOpacity(0.10);

    final completedBg =
        isLight ? AppColors.primary.withOpacity(0.12) : AppColors.primary.withOpacity(0.22);

    final completedBorder =
        isLight ? AppColors.primary.withOpacity(0.22) : AppColors.primary.withOpacity(0.30);

    final completedText =
        isLight ? AppColors.textLightMode : AppColors.textSecondary;

    return _PremiumCard(
      margin: const EdgeInsets.only(bottom: 16),
      glow: isCompleted,
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
                      child: Builder(
                        builder: (context) {
                          final isLight = Theme.of(context).brightness == Brightness.light;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dhikr.arabic != null) ...[
                                Text(
                                  dhikr.arabic!,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Arial',
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                          Text(
                            dhikr.title,
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
                      );
                        },
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
                      SizedBox(width: 16),

                      // Count Display (Tappable for manual input)
                      Flexible(
                        child: Builder(
                          builder: (context) {
                            final isLight = Theme.of(context).brightness == Brightness.light;
                            return InkWell(
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
                                    colors: isLight
                                        ? [
                                            AppColors.primary.withOpacity(0.14),
                                            AppColors.primary.withOpacity(0.06),
                                          ]
                                        : [
                                            AppColors.primary.withOpacity(0.22),
                                            AppColors.primary.withOpacity(0.08),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  border: null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isLight ? 0.12 : 0.35),
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
                                            color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
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
                                  'লক্ষ্য: ${dhikr.targetCount}',
                                  style: TextStyle(
                                    color: AppColors.grey400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Builder(
                                  builder: (context) {
                                    final isLight = Theme.of(context).brightness == Brightness.light;
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isLight
                                            ? Colors.black.withOpacity(0.06)
                                            : AppColors.backgroundDark.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              AppColors.primary.withOpacity(0.20),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.edit,
                                            size: 10,
                                            color: AppColors.primary,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              'সংখ্যা লিখুন',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                          },
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
                          '${(progress * 100).toInt()}% সম্পন্ন',
                          style: const TextStyle(
                            color: AppColors.grey500,
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
                                  'সম্পূর্ণ',
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
                            icon: const Icon(
                              Icons.refresh,
                              size: 14,
                              color: AppColors.grey600,
                            ),
                            label: const Text(
                              'রিসেট',
                              style: TextStyle(
                                color: AppColors.grey600,
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
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
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Builder(
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final enabled = onPressed != null;

        final base = isPrimary
            ? AppColors.primary
            : (isLight ? AppColors.cardLightMode : const Color(0xFF1B1B1B).withOpacity(0.85));

        final border = isPrimary
            ? AppColors.primary
            : (isLight ? Colors.black.withOpacity(0.08) : const Color(0xFF2A2A2A));

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
                            AppColors.primary.withOpacity(0.85),
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.90),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            base.withOpacity(0.95),
                            base.withOpacity(0.70),
                          ],
                        ),
                  border: isPrimary
                      ? Border.all(color: border.withOpacity(0.75), width: 1)
                      : null,
                  boxShadow: [
                    // Lift
                    BoxShadow(
                      color: Colors.black.withOpacity(isPrimary ? 0.60 : 0.75),
                      blurRadius: isPrimary ? 18 : 14,
                      offset: const Offset(0, 10),
                    ),
                    // Soft top highlight
                    BoxShadow(
                      color: Colors.white.withOpacity(isPrimary ? 0.14 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(-2, -2),
                    ),
                    // Golden glow
                    if (isPrimary || enabled)
                      BoxShadow(
                        color: AppColors.shadowGolden
                            .withOpacity(isPrimary ? 0.75 : 0.30),
                        blurRadius: isPrimary ? 10 : 6,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: isPrimary
                      ? (isLight ? Colors.white : Colors.black)
                      : (isLight ? AppColors.textLightMode : AppColors.textSecondary),
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        final cancelText =
            isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final primaryBg = AppColors.primary;
        final primaryText = isLight ? Colors.white : Colors.black;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
            titleTextStyle: TextStyle(
              color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: TextStyle(
              color: isLight
                  ? AppColors.textSecondaryLightMode
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
            title: const Text('নতুন যিকির যোগ করুন'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(
                    color: isLight ? AppColors.textLightMode : Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: 'যিকিরের নাম',
                    filled: true,
                    fillColor: isLight
                        ? AppColors.cardLightMode
                        : Colors.white.withOpacity(0.06),
                    labelStyle: TextStyle(
                      color: isLight
                          ? AppColors.textSecondaryLightMode
                          : AppColors.textSecondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? Colors.black.withOpacity(0.10)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            AppColors.primary.withOpacity(isLight ? 0.55 : 0.75),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: arabicController,
                  style: TextStyle(
                    color: isLight ? AppColors.textLightMode : Colors.white,
                    fontSize: 20,
                  ),
                  decoration: InputDecoration(
                    labelText: 'আরবি (ঐচ্ছিক)',
                    filled: true,
                    fillColor: isLight
                        ? AppColors.cardLightMode
                        : Colors.white.withOpacity(0.06),
                    labelStyle: TextStyle(
                      color: isLight
                          ? AppColors.textSecondaryLightMode
                          : AppColors.textSecondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? Colors.black.withOpacity(0.10)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            AppColors.primary.withOpacity(isLight ? 0.55 : 0.75),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: targetController,
                  style: TextStyle(
                    color: isLight ? AppColors.textLightMode : Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'লক্ষ্য সংখ্যা',
                    filled: true,
                    fillColor: isLight
                        ? AppColors.cardLightMode
                        : Colors.white.withOpacity(0.06),
                    labelStyle: TextStyle(
                      color: isLight
                          ? AppColors.textSecondaryLightMode
                          : AppColors.textSecondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? Colors.black.withOpacity(0.10)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            AppColors.primary.withOpacity(isLight ? 0.55 : 0.75),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: cancelText,
                ),
                child: const Text('বাতিল'),
              ),
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
                  backgroundColor: primaryBg,
                  foregroundColor: primaryText,
                  elevation: isLight ? 6 : 0,
                  shadowColor: Colors.black.withOpacity(isLight ? 0.18 : 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('যোগ করুন'),
              ),
            ],
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        final cancelText =
            isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final primaryBg = AppColors.primary;
        final primaryText = isLight ? Colors.white : Colors.black;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
            titleTextStyle: TextStyle(
              color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: TextStyle(
              color: isLight
                  ? AppColors.textSecondaryLightMode
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
            title: const Text('লক্ষ্য সংখ্যা পরিবর্তন করুন'),
            content: TextField(
              controller: targetController,
              style: TextStyle(
                color: isLight ? AppColors.textLightMode : Colors.white,
              ),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'নতুন লক্ষ্য',
                filled: true,
                fillColor: isLight
                    ? AppColors.cardLightMode
                    : Colors.white.withOpacity(0.06),
                labelStyle: TextStyle(
                  color: isLight
                      ? AppColors.textSecondaryLightMode
                      : AppColors.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isLight
                        ? Colors.black.withOpacity(0.10)
                        : Colors.white.withOpacity(0.10),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.primary.withOpacity(isLight ? 0.55 : 0.75),
                    width: 1.4,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: cancelText,
                ),
                child: const Text('বাতিল'),
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
                  backgroundColor: primaryBg,
                  foregroundColor: primaryText,
                  elevation: isLight ? 6 : 0,
                  shadowColor: Colors.black.withOpacity(isLight ? 0.18 : 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('আপডেট করুন'),
              ),
            ],
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        final cancelText =
            isLight ? AppColors.textLightMode : AppColors.textSecondary;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
            titleTextStyle: TextStyle(
              color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: TextStyle(
              color: isLight
                  ? AppColors.textSecondaryLightMode
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
            title: const Text('মুছে ফেলবেন?'),
            content: Text('"${dhikr.title}" মুছে ফেলতে চান?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: cancelText,
                ),
                child: const Text('না'),
              ),
              ElevatedButton(
                onPressed: () {
                  notifier.deleteDhikr(dhikr.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: isLight ? 6 : 0,
                  shadowColor: Colors.black.withOpacity(isLight ? 0.18 : 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('হ্যাঁ, মুছুন'),
              ),
            ],
          ),
        );
      },
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
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        final cancelText =
            isLight ? AppColors.textLightMode : AppColors.textSecondary;
        final primaryBg = AppColors.primary;
        final primaryText = isLight ? Colors.white : Colors.black;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
            titleTextStyle: TextStyle(
              color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: TextStyle(
              color: isLight
                  ? AppColors.textSecondaryLightMode
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
            title: Text(dhikr.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: countController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isLight ? AppColors.textLightMode : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    labelText: 'কাউন্ট লিখুন',
                    filled: true,
                    fillColor: isLight
                        ? AppColors.cardLightMode
                        : Colors.white.withOpacity(0.06),
                    labelStyle: TextStyle(
                      color: isLight
                          ? AppColors.textSecondaryLightMode
                          : AppColors.textSecondary,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isLight
                            ? Colors.black.withOpacity(0.10)
                            : Colors.white.withOpacity(0.10),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color:
                            AppColors.primary.withOpacity(isLight ? 0.55 : 0.75),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('লক্ষ্য: ${dhikr.targetCount}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: cancelText,
                ),
                child: const Text('বাতিল'),
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
                  backgroundColor: primaryBg,
                  foregroundColor: primaryText,
                  elevation: isLight ? 6 : 0,
                  shadowColor: Colors.black.withOpacity(isLight ? 0.18 : 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('সেট করুন'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetConfirmDialog(
      BuildContext context, DhikrCounterNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;

        final cancelText =
            isLight ? AppColors.textLightMode : AppColors.textSecondary;

        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            backgroundColor: isLight
                ? AppColors.surfaceLightMode
                : AppColors.backgroundDark,
            titleTextStyle: TextStyle(
              color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            contentTextStyle: TextStyle(
              color: isLight
                  ? AppColors.textSecondaryLightMode
                  : AppColors.textSecondary,
              fontSize: 14,
            ),
            title: const Text('সব রিসেট করবেন?'),
            content: const Text('সমস্ত যিকির কাউন্টার ০-তে রিসেট হবে।'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: cancelText,
                ),
                child: const Text('না'),
              ),
              ElevatedButton(
                onPressed: () {
                  notifier.resetAllDhikr();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: isLight ? 6 : 0,
                  shadowColor: Colors.black.withOpacity(isLight ? 0.18 : 0.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('হ্যাঁ, রিসেট করুন'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method for showing snackbars
  void _showSnack(BuildContext context, String message, {bool success = true}) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final bg = isLight
        ? (success
            ? AppColors.primary.withOpacity(0.18)
            : Colors.red.withOpacity(0.12))
        : (success
            ? AppColors.primary.withOpacity(0.28)
            : Colors.red.withOpacity(0.22));

    final textColor = isLight ? AppColors.textLightMode : AppColors.textSecondary;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: bg,
        elevation: isLight ? 10 : 0,
        margin: const EdgeInsets.all(14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
                      child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'যিকির - তথ্য ও ফযিলত',
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
                      icon: Icons.touch_app,
                      title: 'কিভাবে ব্যবহার করবেন?',
                      content: '''
• প্রতিটি যিকির কার্ডে ট্যাপ করলে কাউন্ট বাড়বে
• টার্গেট পূরণ হলে স্বয়ংক্রিয়ভাবে সম্পন্ন হবে
• ৬টি ডিফল্ট যিকির রয়েছে যেগুলোর লক্ষ্য ১০০ বার নির্ধারিত এবং পরিবর্তনযোগ্য নয়
• নিজের পছন্দমতো কাস্টম যিকির যোগ করতে পারবেন এবং সেগুলোর লক্ষ্য সংখ্যা পরিবর্তন করতে পারবেন  
• কমলা সংখ্যায় ট্যাপ করে দ্রুত কাউন্ট যোগ করতে পারবেন
• প্রতিদিন মধ্যরাতে স্বয়ংক্রিয়ভাবে রিসেট হয়''',
                    ),
                    const SizedBox(height: 20),

                    // Tasbih section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.favorite,
                      title: 'তাসবীহ ফাতেমীর ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'প্রতি নামাজের পর ৩৩ বার সুবহানাল্লাহ, ৩৩ বার আলহামদুলিল্লাহ, ৩৩ বার আল্লাহু আকবার বললে গুনাহ মাফ হয়, যদিও সমুদ্রের ফেনার মতো হয়।',
                      reference: 'সহীহ মুসলিম: ৬৯৭',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'দুটি কালেমা আছে যা জিহ্বায় হালকা কিন্তু মীযানে ভারী: সুবহানাল্লাহি ওয়া বিহামদিহি ও লা ইলাহা ইল্লাল্লাহু ওয়াল্লাহু আকবার।',
                      reference: 'সহীহ বুখারী: ৬৩৬০, সহীহ মুসলিম: ২৬৯২',
                    ),
                    const SizedBox(height: 18),

                    // SubhanAllah section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.star,
                      title: 'সুবহানাল্লাহির ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'সুবহানাল্লাহি ওয়াল হামদুলিল্লাহ - এটি মীযানকে ভরপুর করে দেয়, অথবা আসমান ও জমিনের মধ্যবর্তী স্থানের মতো।',
                      reference: 'সহীহ মুসলিম: ২৬৯৬',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি দিনে ১০০ বার সুবহানাল্লাহ বলবে, তার জন্য ১০০০ নেকী লেখা হবে এবং ১০০ গুনাহ মাফ হবে।',
                      reference: 'সহীহ মুসলিম: ২৬৯২',
                    ),
                    const SizedBox(height: 18),

                    // Istighfar section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.healing,
                      title: 'ইস্তিগফারের ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি নিয়মিত ইস্তিগফার করবে, আল্লাহ তার সব দুশ্চিন্তা দূর করে দেবেন, সব সংকট থেকে বের করে দেবেন এবং অপ্রত্যাশিত জায়গা থেকে রিযিিক দেবেন।',
                      reference: 'সুনানে আবু দাউদ: ১৫১৮',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'আমি দিনে ৭০ বারেরও বেশি আল্লাহর কাছে তাওবা করি এবং ইস্তিগফার করি।',
                      reference: 'সহীহ বুখারী: ৬৩০৭',
                    ),
                    const SizedBox(height: 18),

                    // La ilaha illallah section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.brightness_high,
                      title: 'লা ইলাহা ইল্লাল্লাহর ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'সর্বোত্তম যিকির হলো লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুয়া আলা কুল্লি শাইইন কাদীর।',
                      reference: 'জামে তিরমিযী: ৩৫৮৫',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি দিনে ১০০ বার লা ইলাহা ইল্লাল্লাহু ওয়াহদাহু লা শারীকা লাহু... বলবে, তা ১০টি গোলাম মুক্ত করার সমান, ১০০ নেকী লেখা হবে, ১০০ গুনাহ মাফ হবে এবং সন্ধ্যা পর্যন্ত শয়তান থেকে রক্ষা হবে।',
                      reference: 'সহীহ বুখারী: ৬৩০৩, সহীহ মুসলিম: ২৬৯১',
                    ),
                    const SizedBox(height: 18),

                    // Durood section
                    _buildSectionHeader(
                      isDark: !isLight,
                      icon: Icons.auto_awesome,
                      title: 'দরূদ শরীফের ফযিলত',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
                      hadith:
                          'যে ব্যক্তি আমার উপর একবার দরূদ পাঠাবে, আল্লাহ তার উপর দশবার রহমত বর্ষণ করেন।',
                      reference: 'সহীহ মুসলিম: ৪০২',
                    ),
                    const SizedBox(height: 12),

                    _buildHadithCard(
                      isDark: !isLight,
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
    required bool isDark,
    required Color bodyTextColor,
    required IconData icon,
    required String title,
    required String content,
  }) {
    final isLight = !isDark;
    final boxBg = isLight ? AppColors.primary.withOpacity(0.05) : AppColors.backgroundDark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.18),
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
                  color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
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

  Widget _buildSectionHeader({
    required bool isDark,
    required IconData icon,
    required String title,
  }) {
    final isLight = !isDark;
    final panelBg = isLight ? AppColors.primary.withOpacity(0.05) : AppColors.backgroundDark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.05 : 0.18),
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
              color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
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

  Widget _buildHadithCard({
    required bool isDark,
    required String hadith,
    required String reference,
  }) {
    final isLight = !isDark;
    final surface = isLight ? AppColors.backgroundLightMode : const Color(0xFF1A1A1A);
    final hadithTextColor = isLight
        ? AppColors.textLightMode.withOpacity(0.90)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isLight ? 0.06 : 0.22),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(isLight ? 0.12 : 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.format_quote_rounded, color: AppColors.primary, size: 18),
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
          Text(
            '📚 $reference',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
//                 PREMIUM UI HELPERS
// =====================================================

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final baseGradientColors = isLight
        ? [
            AppColors.backgroundLightMode,
            AppColors.surfaceLightMode.withOpacity(0.98),
            AppColors.cardLightMode.withOpacity(0.96),
          ]
        : [
            AppColors.backgroundDark,
            AppColors.backgroundDark.withOpacity(0.92),
            const Color(0xFF0F0F12),
          ];

    return SizedBox.expand(
      child: Stack(
        children: [
          // Base gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: baseGradientColors,
              ),
            ),
          ),

          // Bottom glow
          Positioned(
            bottom: -180,
            right: -140,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(isLight ? 0.10 : 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Subtle vignette (light mode should be MUCH softer)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    (isLight ? Colors.black : Colors.black)
                        .withOpacity(isLight ? 0.08 : 0.40),
                  ],
                ),
              ),
            ),
          ),

          // Noise texture (keep it very light)
          IgnorePointer(
            child: CustomPaint(
              painter: _NoisePainter(seed: 7),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({
    required this.child,
    this.margin,
    this.padding,
    this.glow = false,
  });

  final Widget child;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    final gradientColors = isLight
        ? [
            AppColors.surfaceLightMode.withOpacity(0.98),
            AppColors.cardLightMode.withOpacity(0.96),
          ]
        : [
            AppColors.backgroundLight.withOpacity(0.98),
            const Color(0xFF151515).withOpacity(0.94),
          ];

    final shadows = isLight
        ? <BoxShadow>[
            // soft lift
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            // subtle highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.55),
              blurRadius: 12,
              offset: const Offset(-2, -2),
            ),
            if (glow)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.14),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ]
        : <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
            if (glow)
              BoxShadow(
                color: AppColors.shadowGolden.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ];

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: isLight
            ? Border.all(
                color: Colors.black.withOpacity(0.06),
                width: 1,
              )
            : null,
        boxShadow: shadows,
      ),
      child: child,
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
    final isLight = Theme.of(context).brightness == Brightness.light;

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
              colors: isLight
                  ? [
                      Colors.white.withOpacity(0.55),
                      Colors.white.withOpacity(0.30),
                      Colors.white.withOpacity(0.10),
                    ]
                  : [
                      Colors.white.withOpacity(0.06),
                      Colors.white.withOpacity(0.03),
                      Colors.black.withOpacity(0.15),
                    ],
            ),
            border: isLight
                ? Border.all(color: Colors.black.withOpacity(0.06), width: 1)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.10 : 0.40),
                blurRadius: isLight ? 16 : 12,
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
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isLight
                  ? [
                      Colors.white.withOpacity(0.70),
                      Colors.white.withOpacity(0.45),
                    ]
                  : [
                      Colors.white.withOpacity(0.08),
                      Colors.black.withOpacity(0.22),
                    ],
            ),
            border: isLight ? Border.all(color: Colors.black.withOpacity(0.06)) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isLight ? 0.10 : 0.35),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: isLight ? AppColors.textLightMode : AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _NoisePainter extends CustomPainter {
  _NoisePainter({required this.seed});

  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rnd = Random(seed);
    final paint = Paint()..style = PaintingStyle.fill;

    // Density scales with screen size (kept very light)
    final n = (size.width * size.height / 4500).clamp(120.0, 520.0).toInt();

    for (var i = 0; i < n; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final r = rnd.nextDouble() * 0.9 + 0.25;

      // Mostly dark specks, few bright specks
      final isBright = rnd.nextDouble() > 0.88;
      paint.color = (isBright ? Colors.white : Colors.black)
          .withOpacity(isBright ? 0.022 : 0.030);

      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) =>
      oldDelegate.seed != seed;
}
