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

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'প্রতিদিনের গুনাহ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37)),
            onPressed: () => _showAddSinTypeDialog(context, ref),
            tooltip: 'নতুন গুনাহ যোগ করুন',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () => _showResetConfirmation(context, ref),
            tooltip: 'রিসেট',
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  _buildSummaryCard(state),
                  
                  const SizedBox(height: 20),
                  
                  // Motivation
                  _buildMotivationCard(state),
                  
                  const SizedBox(height: 24),
                  
                  // Sin Types List
                  const Text(
                    'গুনাহ সমূহ',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
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

  Widget _buildSummaryCard(SinTrackerState state) {
    final totalSins = state.todayRecord.totalSinCount;
    final pendingKaffara = state.todayRecord.pendingKaffaraCount;
    final completedKaffara = state.todayRecord.completedKaffaraCount;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalSins > 0
              ? [
                  const Color(0xFFE53935).withOpacity(0.15),
                  const Color(0xFFE53935).withOpacity(0.05),
                ]
              : [
                  const Color(0xFF4CAF50).withOpacity(0.15),
                  const Color(0xFF4CAF50).withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: totalSins > 0
              ? const Color(0xFFE53935).withOpacity(0.3)
              : const Color(0xFF4CAF50).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'মোট গুনাহ',
            '$totalSins',
            totalSins > 0 ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildStatItem(
            'বাকি কাফফারা',
            '$pendingKaffara',
            pendingKaffara > 0 ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.3),
          ),
          _buildStatItem(
            'কাফফারা হয়েছে',
            '$completedKaffara',
            const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
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
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationCard(SinTrackerState state) {
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
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFD4AF37),
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
    final hasSinned = record?.hasSinned ?? false;
    final kaffaraDone = record?.kaffaraDone ?? false;
    final kaffaraType = record?.kaffaraType;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: hasSinned && !kaffaraDone
            ? Border.all(color: const Color(0xFFE53935).withOpacity(0.3))
            : null,
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: hasSinned
                        ? kaffaraDone
                            ? const Color(0xFF4CAF50).withOpacity(0.15)
                            : const Color(0xFFE53935).withOpacity(0.15)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getSinIcon(sinType.icon),
                    color: hasSinned
                        ? kaffaraDone
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE53935)
                        : Colors.grey,
                    size: 22,
                  ),
                ),
                
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (!sinType.isDefault)
                            GestureDetector(
                              onTap: () => _showDeleteSinTypeDialog(context, ref, sinType),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.delete_outline, color: Colors.grey, size: 18),
                              ),
                            ),
                        ],
                      ),
                      if (hasSinned && kaffaraDone && kaffaraType != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'কাফফারা: ${KaffaraType.getName(kaffaraType)}',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
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
                      color: hasSinned
                          ? const Color(0xFFE53935).withOpacity(0.2)
                          : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: hasSinned
                            ? const Color(0xFFE53935).withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasSinned ? Icons.check : Icons.close,
                          color: hasSinned ? const Color(0xFFE53935) : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasSinned ? 'হয়েছে' : 'হয়নি',
                          style: TextStyle(
                            color: hasSinned ? const Color(0xFFE53935) : Colors.grey,
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
                  _buildKaffaraChip(ref, sinType.id, KaffaraType.istighfar, 'যিকির'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(ref, sinType.id, KaffaraType.quran, 'কোরআন'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(ref, sinType.id, KaffaraType.charity, 'দান'),
                  const SizedBox(width: 6),
                  _buildKaffaraChip(ref, sinType.id, KaffaraType.prayer, 'নামাজ'),
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
                child: const Text(
                  'কাফফারা বাতিল করুন',
                  style: TextStyle(
                    color: Colors.grey,
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
    WidgetRef ref,
    String sinTypeId,
    String kaffaraType,
    String label,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(sinTrackerProvider.notifier).giveKaffara(sinTypeId, kaffaraType);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD4AF37),
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
    WidgetRef ref,
    String sinTypeId,
    String kaffaraType,
    IconData icon,
    String label,
  ) {
    const color = Color(0xFFD4AF37);
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ref.read(sinTrackerProvider.notifier).giveKaffara(sinTypeId, kaffaraType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: color,
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
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'নতুন গুনাহ যোগ করুন',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'গুনাহের নাম',
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF2A2A2A)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD4AF37)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(sinTrackerProvider.notifier).addCustomSinType(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('যোগ করুন', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
        ],
      ),
    );
  }

  void _showDeleteSinTypeDialog(BuildContext context, WidgetRef ref, SinType sinType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'গুনাহ মুছে ফেলুন?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '"${sinType.name}" মুছে ফেলতে চান?',
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(sinTrackerProvider.notifier).removeCustomSinType(sinType.id);
              Navigator.pop(context);
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'আজকের ডেটা রিসেট?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'আজকের সব গুনাহ ও কাফফারা মুছে যাবে।',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('না', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              ref.read(sinTrackerProvider.notifier).resetToday();
              Navigator.pop(context);
            },
            child: const Text('হ্যাঁ', style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }
}
