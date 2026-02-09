import 'package:amal_tracker/core/theme/app_theme.dart';
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
              bottom: BorderSide(
                color: gradients.appBarBorder,
                width: 1.5,
              ),
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
          'প্রতিদিনের গুনাহ',
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
        tooltip: 'নতুন গুনাহ যোগ করুন',
        mini: true,
        child: Icon(Icons.add, color: gradients.onPrimaryText),
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: cs.primary),
            )
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
                    'গুনাহ সমূহ',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  ...state.sinTypes.map((sinType) {
                    final record = state.todayRecord.getRecordForType(sinType.id);
                    return _buildSinTypeCard(context, ref, sinType, record);
                  }),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(SinTrackerState state, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalSins = state.todayRecord.totalSinCount;
    final pendingKaffara = state.todayRecord.pendingKaffaraCount;
    final completedKaffara = state.todayRecord.completedKaffaraCount;
    final gradients = Theme.of(context).extension<GradientColors>()!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
                gradients.cardGradient[0],
                gradients.cardGradient[1],
                gradients.cardGradient[2],
              ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'মোট গুনাহ',
            '$totalSins',
            cs.primary,
            context,
          ),
          Container(
            width: 1,
            height: 40,
            color: cs.outlineVariant.withOpacity(0.5),
          ),
          _buildStatItem(
            'বাকি কাফফারা',
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
            'কাফফারা হয়েছে',
            '$completedKaffara',
            cs.primary.withOpacity(0.6),
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, BuildContext context) {
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
        Text(
          label,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(SinTrackerState state, BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pendingKaffara = state.todayRecord.pendingKaffaraCount;
    
    String message;
    if (state.todayRecord.totalSinCount == 0) {
      message = 'মাশাআল্লাহ! আজ কোনো গুনাহ হয়নি।';
    } else if (pendingKaffara == 0) {
      message = 'আলহামদুলিল্লাহ! সব গুনাহের কাফফারা দিয়েছেন।';
    } else {
      message = '$pendingKaffara টি গুনাহের কাফফারা বাকি আছে। তওবা করুন।';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.primary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
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
    if(hasSinned && !kaffaraDone) {
      sinColor = const Color(0xFFE53935); // Red for pending sin
    } else if (hasSinned && kaffaraDone) {
      sinColor = cs.primary; // Green for completed kaffara
    } else {
      sinColor = cs.primary;
    }    

    Color? sin2Color;
    if(hasSinned && !kaffaraDone) {
      sin2Color = const Color(0xFFE53935); // Red for pending sin
    } else if (hasSinned && kaffaraDone) {
      sin2Color = cs.primary; // Green for completed kaffara
    } else {
      sin2Color = Theme.of(context).colorScheme.onSurfaceVariant;// Grey for no sin
    }

    Color? borderColor;
    if(hasSinned && !kaffaraDone) {
      borderColor = const Color(0xFFE53935).withOpacity(0.6); // Red for pending sin
    } else if (hasSinned && kaffaraDone) {
      borderColor = cs.primary.withOpacity(0.3);
    } else {
      borderColor = cs.primary.withOpacity(0.6);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
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
                              sinType.name,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!sinType.isDefault)
                            GestureDetector(
                              onTap: () => _showDeleteSinTypeDialog(context, ref, sinType),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Icon(Icons.delete_outline, color: cs.onSurfaceVariant, size: 18),
                              ),
                            ),
                        ],
                      ),
                      if (hasSinned && kaffaraDone && kaffaraType != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'কাফফারা: ${KaffaraType.getName(kaffaraType)}',
                            style: TextStyle(
                              color: sinColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Sin Toggle
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(sinTrackerProvider.notifier).toggleSin(sinType.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sin2Color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sin2Color.withOpacity(0.5),
                      ),
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
                          hasSinned ? 'হয়েছে' : 'হয়নি',
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
                  _buildKaffaraChip(context, ref, sinType.id, KaffaraType.istighfar, 'যিকির'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(context, ref, sinType.id, KaffaraType.quran, 'কোরআন'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(context, ref, sinType.id, KaffaraType.charity, 'দান'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(context, ref, sinType.id, KaffaraType.prayer, 'নামাজ'),
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
                  ref.read(sinTrackerProvider.notifier).undoKaffara(sinType.id);
                },
                child: Text(
                  'কাফফারা বাতিল করুন',
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
          ref.read(sinTrackerProvider.notifier).giveKaffara(sinTypeId, kaffaraType);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
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

  Widget _buildKaffaraButton(
    BuildContext context,
    WidgetRef ref,
    String sinTypeId,
    String kaffaraType,
    IconData icon,
    String label,
  ) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(sinTrackerProvider.notifier).giveKaffara(sinTypeId, kaffaraType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: cs.primary, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: cs.primary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          title: const Text('নতুন গুনাহ যোগ করুন'),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'গুনাহের নাম',
              hintStyle: TextStyle(color: cs.onSurfaceVariant.withOpacity(0.5)),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  ref.read(sinTrackerProvider.notifier).addCustomSinType(controller.text.trim());
                  Navigator.pop(context);
                }
              },
              child: Text('যোগ করুন', style: TextStyle(color: cs.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteSinTypeDialog(BuildContext context, WidgetRef ref, SinType sinType) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
          title: const Text('গুনাহ মুছে ফেলুন?'),
          content: Text('"${sinType.name}" মুছে ফেলতে চান?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('না', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                ref.read(sinTrackerProvider.notifier).removeCustomSinType(sinType.id);
                Navigator.pop(context);
              },
              child: const Text('হ্যাঁ', style: TextStyle(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titleTextStyle: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 14,
          ),
          title: const Text('আজকের ডেটা রিসেট?'),
          content: const Text('আজকের সব গুনাহ ও কাফফারা মুছে যাবে।'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('না', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
            TextButton(
              onPressed: () {
                ref.read(sinTrackerProvider.notifier).resetToday();
                Navigator.pop(context);
              },
              child: const Text('হ্যাঁ', style: TextStyle(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }
}
