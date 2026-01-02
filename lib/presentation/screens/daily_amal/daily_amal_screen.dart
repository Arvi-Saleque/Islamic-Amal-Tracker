import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/daily_amal_provider.dart';
import '../../../data/models/daily_amal_model.dart';

class DailyAmalScreen extends ConsumerStatefulWidget {
  const DailyAmalScreen({super.key});

  @override
  ConsumerState<DailyAmalScreen> createState() => _DailyAmalScreenState();
}

class _DailyAmalScreenState extends ConsumerState<DailyAmalScreen> {
  String _selectedCategory = 'all';

  final Map<String, String> _categoryNames = {
    'all': 'সবগুলো',
    'miswak': 'মিসওয়াক',
    'surah': 'সূরাহ',
    'dua': 'দোয়া',
    'prayer': 'নফল নামাজ',
    'other': 'অন্যান্য',
  };

  final Map<String, IconData> _categoryIcons = {
    'all': Icons.grid_view,
    'miswak': Icons.brush,
    'surah': Icons.menu_book,
    'dua': Icons.favorite,
    'prayer': Icons.mosque,
    'other': Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    final amalState = ref.watch(dailyAmalProvider);
    final amalNotifier = ref.read(dailyAmalProvider.notifier);

    final items = _selectedCategory == 'all'
        ? amalState.todayData.items
        : amalNotifier.getItemsByCategory(_selectedCategory);

    final completedCount = amalState.todayData.completedCount;
    final totalCount = amalState.todayData.totalCount;

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
          'প্রতিদিনের আমল',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFD4AF37),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedCount/$totalCount',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          _buildCategoryFilter(),

          // Progress Bar
          _buildProgressBar(completedCount, totalCount),

          // Checklist Items
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return _buildChecklistItem(
                        items[index],
                        amalNotifier,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, amalNotifier),
        backgroundColor: const Color(0xFFD4AF37),
        child: const Icon(
          Icons.add,
          color: Color(0xFF0A0A0A),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoryNames.length,
        itemBuilder: (context, index) {
          final category = _categoryNames.keys.elementAt(index);
          final isSelected = _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF2A2A2A),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _categoryIcons[category],
                    color: isSelected
                        ? const Color(0xFF0A0A0A)
                        : const Color(0xFFD4AF37),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _categoryNames[category]!,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFFE0E0E0),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(int completed, int total) {
    final percentage = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A2A2A),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'আজকের অগ্রগতি',
                style: TextStyle(
                  color: Color(0xFFE0E0E0),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(percentage * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: const Color(0xFF0A0A0A),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    DailyAmalItem item,
    DailyAmalNotifier notifier,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isCompleted
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : const Color(0xFF2A2A2A),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => notifier.toggleItem(item.id),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: item.isCompleted
                        ? const Color(0xFFD4AF37)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: item.isCompleted
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF666666),
                      width: 2,
                    ),
                  ),
                  child: item.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF0A0A0A),
                          size: 16,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: item.isCompleted
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFFE0E0E0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item.completedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'সম্পন্ন: ${_formatTime(item.completedAt!)}',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (item.id.startsWith('custom_'))
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF666666),
                      size: 20,
                    ),
                    onPressed: () => _confirmDelete(context, item, notifier),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _categoryIcons[_selectedCategory],
            color: const Color(0xFF666666),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'কোনো ${_categoryNames[_selectedCategory]} নেই',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showAddItemDialog(BuildContext context, DailyAmalNotifier notifier) {
    final titleController = TextEditingController();
    String selectedCategory = 'other';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFD4AF37),
            width: 1,
          ),
        ),
        title: const Text(
          'নতুন আমল যোগ করুন',
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
                hintText: 'আমলের নাম লিখুন',
                hintStyle: const TextStyle(color: Color(0xFF666666)),
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
            StatefulBuilder(
              builder: (context, setState) => DropdownButtonFormField<String>(
                value: selectedCategory,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Color(0xFFE0E0E0)),
                decoration: InputDecoration(
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
                ),
                items: _categoryNames.entries
                    .where((entry) => entry.key != 'all')
                    .map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
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
                notifier.addCustomItem(
                  titleController.text,
                  selectedCategory,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: const Color(0xFF0A0A0A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    DailyAmalItem item,
    DailyAmalNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
          '"${item.title}" মুছে ফেলতে চান?',
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
              notifier.deleteItem(item.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('হ্যাঁ, মুছুন'),
          ),
        ],
      ),
    );
  }
}
