import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/sin_tracker_model.dart';
import '../../providers/sin_tracker_provider.dart';

class SinTrackerScreen extends ConsumerWidget {
  const SinTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sinTrackerProvider);
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final cs = Theme.of(context).colorScheme;
    final gradients = Theme.of(context).extension<GradientColors>()!;

    final iconColor = cs.primary;
    final titleColor = cs.primary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradients.appBarGradient[0],
                gradients.appBarGradient[1],
                gradients.appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(color: gradients.appBarBorder, width: 1.5),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'sin_tracker_title_full'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSinTypeDialog(context, ref),
        backgroundColor: cs.primary,
        tooltip: 'sin_add'.tr(),
        mini: true,
        child: Icon(Icons.add, color: gradients.onPrimaryText),
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: cs.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(state, context),

                  const SizedBox(height: 20),

                  // Motivation
                  _buildMotivationCard(state, context),

                  const SizedBox(height: 24),

                  // Sin Types List
                  Text(
                    'sin_list_title'.tr(),
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...state.sinTypes.map((sinType) {
                    final record = state.todayRecord.getRecordForType(
                      sinType.id,
                    );
                    return _buildSinTypeCard(context, ref, sinType, record);
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMotivationCard(SinTrackerState state, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pendingKaffara = state.todayRecord.pendingKaffaraCount;

    String message;
    if (state.todayRecord.totalSinCount == 0) {
      message = 'sin_no_sins'.tr();
    } else if (pendingKaffara == 0) {
      message = 'sin_kaffara_done_all'.tr();
    } else {
      message = 'sin_kaffara_pending'.tr(
        namedArgs: {'count': pendingKaffara.toString()},
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.primary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(SinTrackerState state, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalSins = state.todayRecord.totalSinCount;
    final pendingKaffara = state.todayRecord.pendingKaffaraCount;
    final completedKaffara = state.todayRecord.completedKaffaraCount;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('sin_total'.tr(), '$totalSins', cs.primary, context),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withOpacity(0.5),
          ),
          _buildStatItem(
            'sin_kaffara_pending_label'.tr(),
            '$pendingKaffara',
            cs.primary.withOpacity(0.8),
            context,
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withOpacity(0.5),
          ),
          _buildStatItem(
            'sin_kaffara_done_label'.tr(),
            '$completedKaffara',
            cs.primary.withOpacity(0.6),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    BuildContext context,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }

  Widget _buildSinTypeCard(
    BuildContext context,
    WidgetRef ref,
    SinType sinType,
    SinRecord? record,
  ) {
    final cs = Theme.of(context).colorScheme;
    final hasSinned = record?.hasSinned ?? false;
    final kaffaraDone = record?.kaffaraDone ?? false;
    final kaffaraType = record?.kaffaraType;

    Color? sinColor;
    if (hasSinned && !kaffaraDone) {
      sinColor = const Color(0xFFE53935); // Red for pending sin
    } else if (hasSinned && kaffaraDone) {
      sinColor = cs.primary; // Green for completed kaffara
    } else {
      sinColor = cs.primary;
    }

    Color? sin2Color;
    if (hasSinned && !kaffaraDone) {
      sin2Color = const Color(0xFFE53935); // Red for pending sin
    } else if (hasSinned && kaffaraDone) {
      sin2Color = cs.primary; // Green for completed kaffara
    } else {
      sin2Color = Theme.of(
        context,
      ).colorScheme.onSurfaceVariant; // Grey for no sin
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: buildPremiumCard(
        context: context,
        radius: 18,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Main Row - Sin Name & Toggle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSinIcon(sinType.icon),
                      color: sinColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  const SizedBox(width: 12),

                  // Name & Status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _localizedSinName(context, sinType),
                                style: TextStyle(
                                  color: cs.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (!sinType.isDefault)
                              GestureDetector(
                                onTap: () => _showDeleteSinTypeDialog(
                                  context,
                                  ref,
                                  sinType,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.delete_outline,
                                    color: cs.onSurfaceVariant,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (hasSinned && kaffaraDone && kaffaraType != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${'sin_kaffara'.tr()}: ${_localizedKaffaraName(kaffaraType)}',
                              style: TextStyle(color: sinColor, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Sin Toggle
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref
                          .read(sinTrackerProvider.notifier)
                          .toggleSin(sinType.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sin2Color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sin2Color.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasSinned ? Icons.check : Icons.close,
                            color: sin2Color,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            hasSinned ? 'sin_done'.tr() : 'sin_not_done'.tr(),
                            style: TextStyle(
                              color: sin2Color,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kaffara Section - Only if sinned and not done
            if (hasSinned && !kaffaraDone) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    _buildKaffaraChip(
                      context,
                      ref,
                      sinType.id,
                      KaffaraType.istighfar,
                      'sin_kaffara_dhikr',
                    ),
                    const SizedBox(width: 6),
                    _buildKaffaraChip(
                      context,
                      ref,
                      sinType.id,
                      KaffaraType.quran,
                      'sin_kaffara_quran',
                    ),
                    const SizedBox(width: 6),
                    _buildKaffaraChip(
                      context,
                      ref,
                      sinType.id,
                      KaffaraType.charity,
                      'sin_kaffara_charity',
                    ),
                    const SizedBox(width: 6),
                    _buildKaffaraChip(
                      context,
                      ref,
                      sinType.id,
                      KaffaraType.prayer,
                      'sin_kaffara_prayer',
                    ),
                  ],
                ),
              ),
            ],

            // Undo Kaffara - Only if kaffara done
            if (hasSinned && kaffaraDone)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(sinTrackerProvider.notifier)
                        .undoKaffara(sinType.id);
                  },
                  child: Text(
                    'sin_undo_kaffara'.tr(),
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKaffaraChip(
    BuildContext context,
    WidgetRef ref,
    String sinTypeId,
    String kaffaraType,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref
              .read(sinTrackerProvider.notifier)
              .giveKaffara(sinTypeId, kaffaraType);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label.tr(),
            style: TextStyle(
              color: cs.primary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _localizedSinName(BuildContext context, SinType sinType) {
    if (!sinType.isDefault) {
      // Custom sins: show the name exactly as the user entered it
      return sinType.name;
    }

    switch (sinType.id) {
      case 'sin_lie':
        return 'sin_lie_label'.tr();
      case 'sin_backbiting':
        return 'sin_backbiting_label'.tr();
      case 'sin_eye':
        return 'sin_eye_label'.tr();
      case 'sin_ear':
        return 'sin_ear_label'.tr();
      default:
        // Fallback to stored name if we don't recognize the id
        return sinType.name;
    }
  }

  String _localizedKaffaraName(String kaffaraType) {
    switch (kaffaraType) {
      case KaffaraType.istighfar:
        return 'sin_kaffara_dhikr'.tr();
      case KaffaraType.quran:
        return 'sin_kaffara_quran'.tr();
      case KaffaraType.charity:
        return 'sin_kaffara_charity'.tr();
      case KaffaraType.prayer:
        return 'sin_kaffara_prayer'.tr();
      default:
        return kaffaraType;
    }
  }

  IconData _getSinIcon(String iconName) {
    switch (iconName) {
      case 'voice':
        return Icons.record_voice_over;
      case 'chat':
        return Icons.chat_bubble;
      case 'eye':
        return Icons.visibility;
      case 'ear':
        return Icons.hearing;
      default:
        return Icons.warning;
    }
  }

  void _showAddSinTypeDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();

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
                  'sin_add'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: TextStyle(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'sin_name_hint'.tr(),
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                    ),
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
                        if (controller.text.trim().isNotEmpty) {
                          ref
                              .read(sinTrackerProvider.notifier)
                              .addCustomSinType(controller.text.trim());
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).extension<GradientColors>()!.onPrimaryText,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('sin_add'.tr()),
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

  void _showDeleteSinTypeDialog(
    BuildContext context,
    WidgetRef ref,
    SinType sinType,
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
                  'sin_delete_title'.tr(),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'sin_delete_confirm'.tr(namedArgs: {'name': sinType.name}),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
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
                        ref
                            .read(sinTrackerProvider.notifier)
                            .removeCustomSinType(sinType.id);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: cs.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('yes'.tr()),
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
}
