import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/daily_amal_provider.dart';
import '../../../data/models/daily_amal_model.dart';
import '../../../core/theme/app_theme.dart';

class DailyAmalScreen extends ConsumerStatefulWidget {
  const DailyAmalScreen({super.key});

  @override
  ConsumerState<DailyAmalScreen> createState() => _DailyAmalScreenState();
}

class _DailyAmalScreenState extends ConsumerState<DailyAmalScreen> {
  String _selectedCategory = 'all';

  // Polish constants
  static const double _pagePad = 18;
  static const double _cardRadius = 18;
  static const double _sectionRadius = 18;

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

    final iconColor = Theme.of(context).colorScheme.primary;
    final titleColor = Theme.of(context).colorScheme.primary;

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
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'প্রতিদিনের আমল',
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).extension<GradientColors>()!.backgroundGradient,
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Category Filter
              _buildCategoryFilter(),

              // Progress Bar
              _buildProgressBar(completedCount, totalCount),

              // Checklist Items
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      _pagePad, 0, _pagePad, 22),
                  child: buildPremiumCard(
                    context: context,
                    radius: _sectionRadius,
                    padding: const EdgeInsets.all(14),
                    child: items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return _buildChecklistItem(
                                items[index],
                                amalNotifier,
                              );
                            },
                          ),
                  ),
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
        onPressed: () => _showAddItemDialog(context, amalNotifier),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 60,
      margin: const EdgeInsets.only(top: 12, bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: _pagePad),
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
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(0.95),
                          cs.primary,
                          cs.primary.withOpacity(0.85),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: theme.extension<GradientColors>()!.cardGradient.take(2).toList(),
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? theme.extension<GradientColors>()!.appBarBorder
                      : cs.outline.withOpacity(0.20),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _categoryIcons[category],
                    color: isSelected
                        ? theme.extension<GradientColors>()!.onPrimaryText
                        : cs.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _categoryNames[category]!,
                    style: TextStyle(
                      color: isSelected
                          ? theme.extension<GradientColors>()!.onPrimaryText
                          : cs.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final percentage = total > 0 ? completed / total : 0.0;

    return Padding(
      padding:
          const EdgeInsets.only(left: _pagePad, right: _pagePad, bottom: 14),
      child: buildPremiumCard(
        context: context,
        radius: _sectionRadius,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'আজকের মোট',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: theme.extension<GradientColors>()!.innerCardGradient,
                    ),
                    borderRadius: BorderRadius.circular(_sectionRadius),
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
                    '$completed/$total সম্পন্ন',
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
                        '$completed',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'লক্ষ্য: $total',
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
                          value: percentage,
                          strokeWidth: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                        ),
                      ),
                      Text(
                        '${(percentage * 100).toInt()}%',
                        style: TextStyle(
                          color: cs.primary,
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

  Widget _buildChecklistItem(
    DailyAmalItem item,
    DailyAmalNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: buildPremiumInkCard(
        context: context,
        radius: _cardRadius,
        onTap: () => notifier.toggleItem(item.id),
        backgroundColor: item.isCompleted 
            ? cs.primary.withOpacity(0.08)
            : null,
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
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                  border: item.isCompleted
                      ? null
                      : Border.all(
                          color: cs.outline.withOpacity(0.3),
                          width: 2,
                        ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.isCompleted
                    ? Icon(
                        Icons.check,
                        color: theme.extension<GradientColors>()!.onPrimaryText,
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
                            ? cs.primary
                            : cs.onSurface,
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
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.id.startsWith('custom_'))
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: cs.onSurfaceVariant.withOpacity(0.75),
                    size: 20,
                  ),
                  onPressed: () =>
                      _confirmDelete(context, item, notifier),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _categoryIcons[_selectedCategory],
            color: cs.onSurfaceVariant.withOpacity(0.70),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'কোনো ${_categoryNames[_selectedCategory]} নেই',
            style: TextStyle(
              color: cs.onSurfaceVariant.withOpacity(0.70),
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
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;

        final fieldFill = cs.surfaceContainerHighest;
        final borderCol = cs.outline.withOpacity(0.30);

        InputDecoration deco({
          required String hint,
          IconData? icon,
        }) {
          return InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fieldFill,
            prefixIcon:
                icon == null ? null : Icon(icon, color: cs.onSurfaceVariant),
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderCol),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderCol),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.primary, width: 1.6),
            ),
          );
        }

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: buildPremiumCard(
            context: context,
            radius: _cardRadius,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: cs.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'নতুন আমল যোগ করুন',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Text field
                TextField(
                  controller: titleController,
                  style: TextStyle(color: cs.onSurface),
                  decoration:
                      deco(hint: 'আমলের নাম লিখুন', icon: Icons.edit_outlined),
                ),
                const SizedBox(height: 16),
                // Dropdown
                StatefulBuilder(
                  builder: (context, setState) => DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: cs.surfaceContainerHighest,
                    style: TextStyle(color: cs.onSurface),
                    decoration: deco(
                        hint: 'ক্যাটাগরি নির্বাচন করুন',
                        icon: Icons.category_outlined),
                    items: _categoryNames.entries
                        .where((e) => e.key != 'all')
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: TextStyle(color: cs.onSurface)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'বাতিল',
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: theme.extension<GradientColors>()!.onPrimaryText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) return;

                        notifier.addCustomItem(
                          title,
                          selectedCategory,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'যোগ করুন',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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

  void _confirmDelete(
    BuildContext context,
    DailyAmalItem item,
    DailyAmalNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: buildPremiumCard(
          context: context,
          radius: _cardRadius,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: cs.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'মুছে ফেলবেন?',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Content
              Text(
                '"${item.title}" মুছে ফেলতে চান?',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'না',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      notifier.deleteItem(item.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'হ্যাঁ, মুছুন',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show info bottom sheet
  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;

          return buildPremiumCard(
            context: context,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(26)),
            gradientBegin: Alignment.topCenter,
            gradientEnd: Alignment.bottomCenter,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withOpacity(0.5),
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
                          color: cs.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: cs.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'প্রতিদিনের আমল - তথ্য ও ফযিলত',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 1, color: cs.primary.withOpacity(0.3)),
                // Content
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
                    children: [
                      // How it works
                      _buildInfoSection(
                        icon: Icons.calculate_outlined,
                        title: 'হিসাব কিভাবে হয়?',
                        content: '''
• প্রতিটি আমল সম্পন্ন করলে চেকমার্ক দিন
• ক্যাটাগরি অনুযায়ী ফিল্টার করতে পারবেন
• নিজের পছন্দমতো আমল যোগ করতে পারবেন
• প্রতিদিন মধ্যরাতে স্বয়ংক্রিয়ভাবে রিসেট হয়
• সব আমল সম্পন্ন করলে ১০০% complete''',
                      ),
                      const SizedBox(height: 20),

                      // Morning-Evening Adhkar Section (Expandable)
                      _buildExpandableDuaSection(),
                      const SizedBox(height: 18),

                      // Miswak section
                      _buildSectionHeader(
                        icon: Icons.brush,
                        title: 'মিসওয়াকের ফযিলত',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'মিসওয়াক মুখ পরিষ্কার করে এবং আল্লাহর সন্তুষ্টি অর্জন করে।',
                        reference: 'সুনানে নাসাঈ: ৫',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'যদি আমার উম্মতের উপর কষ্টকর না হতো, তাহলে আমি প্রতি নামাজের সময় মিসওয়াক করার আদেশ দিতাম।',
                        reference: 'সহীহ বুখারী: ৮৮৭, সহীহ মুসলিম: ২৫২',
                      ),
                      const SizedBox(height: 18),

                      // Surah section
                      _buildSectionHeader(
                        icon: Icons.menu_book,
                        title: 'সূরাহ পাঠের ফযিলত',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'যে ব্যক্তি সূরা ইখলাস পড়বে, সে যেন কুরআনের এক তৃতীয়াংশ পড়ল।',
                        reference: 'সহীহ বুখারী: ৫০১৫',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'যে ব্যক্তি রাতে সূরা বাকারার শেষ দুই আয়াত পড়বে, তার জন্য তা যথেষ্ট হবে।',
                        reference: 'সহীহ বুখারী: ৫০০৯, সহীহ মুসলিম: ৮০৭',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'সূরা মুলক পাঠকারীর জন্য কবরের আযাব থেকে সুপারিশ করবে যতক্ষণ না তাকে ক্ষমা করা হয়।',
                        reference: 'জামে তিরমিযী: ২৮৯১',
                      ),
                      const SizedBox(height: 18),

                      // Dua section
                      _buildSectionHeader(
                        icon: Icons.favorite,
                        title: 'দোয়ার ফযিলত',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'দোয়াই হলো ইবাদত',
                        reference: 'জামে তিরমিযী: ২৯৬৯',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'যে ব্যক্তি সকাল-সন্ধ্যায় তিনবার করে সাইয়্যিদুল ইস্তিগফার পড়বে এবং সেদিন বা সে রাতে মারা গেলে জান্নাতে যাবে।',
                        reference: 'সহীহ বুখারী: ৬৩০৬',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'যে ব্যক্তি সকালে ও সন্ধ্যায় তিনবার বলে "বিসমিল্লাহিল্লাযী লা ইয়াদুররু মাআসমিহী শাইউন ফিল আরদি ওয়ালা ফিস সামায়ি ওয়া হুয়াস সামিউল আলীম" তাকে কোনো বিপদ স্পর্শ করবে না।',
                        reference: 'সুনানে আবু দাউদ: ৫০৮৮, জামে তিরমিযী: ৩৩৮৮',
                      ),
                      const SizedBox(height: 18),

                      // Nafal prayer section
                      _buildSectionHeader(
                        icon: Icons.mosque,
                        title: 'নফল নামাজের ফযিলত',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'রাতের নামাজ (তাহাজ্জুদ) ফরয নামাজের পর সর্বোত্তম নামাজ।',
                        reference: 'সহীহ মুসলিম: ১১৬৩',
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith:
                            'চাশতের নামাজ (সালাতুদ-দুহা) দুই রাকাত পড়লে শরীরের ৩৬০টি জোড়ের সদকা আদায় হয়ে যায়।',
                        reference: 'সহীহ মুসলিম: ৭২০',
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

  Widget _buildHadithCard({
    required String hadith,
    required String reference,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.format_quote_rounded,
                    color: cs.primary, size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hadith,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
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
                color: cs.primary.withOpacity(0.75),
              ),
              const SizedBox(width: 5),
              Text(
                reference,
                style: TextStyle(
                  color: cs.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
  }) {
    final cs = Theme.of(context).colorScheme;

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
              color: cs.primary.withOpacity(0.8),
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
                color: cs.primary,
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

  // Expandable Morning-Evening Dua Section
  Widget _buildExpandableDuaSection() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return buildPremiumCard(
      context: context,
      radius: 18,
      padding: EdgeInsets.zero,
      child: Theme(
        data: theme.copyWith(dividerColor: cs.surface.withOpacity(0)),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.wb_twilight,
              color: cs.primary,
              size: 20,
            ),
          ),
          title: Text(
            'সকাল-সন্ধ্যার আযকার',
            style: TextStyle(
              color: cs.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'ট্যাপ করে দোয়াগুলো দেখুন',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ),
          iconColor: cs.primary,
          collapsedIconColor: cs.primary,
          children: [
            const SizedBox(height: 8),
            // 27.2: Ayatul Kursi
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১ - আয়াতুল কুরসি',
              arabic:
                  'اللّٰهُ لَآ اِلٰهَ اِلَّا هُوَ ۚ اَلْحَـيُّ الْقَيُّوْمُ ۚ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۚ لَهٗ مَا فِي السَّمٰوٰتِ وَمَا فِي الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَآءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ وَلَا يَـُٔوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
              pronunciation:
                  'আল্লা-হু লা ইলা-হা ইল্লা হুওয়াল হাইয়্যুল ক্বাইয়্যুম। লা তা\'খুযুহু সিনাতুঁও ওয়ালা নাউম। লাহু মা ফিস সামা-ওয়া-তি ওয়ামা ফিল আরদ। মান যাল্লাযী ইয়াশফা\'উ ইন্দাহু ইল্লা বি-ইযনিহ। ইয়া\'লামু মা বাইনা আইদীহিম ওয়ামা খালফাহুম। ওয়ালা ইউহীতূনা বিশাইইম মিন ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি\'আ কুরসিয়্যুহুস সামা-ওয়া-তি ওয়াল আরদ। ওয়ালা ইয়া\'ঊদুহু হিফযুহুমা ওয়া হুয়াল \'আলিয়্যুল \'আযীম।',
              meaning:
                  'আল্লাহ, তিনি ছাড়া কোনো (সত্য) ইলাহ নেই। তিনি চিরঞ্জীব, সর্বসত্তার ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমানসমূহে ও যমীনে যা কিছু আছে সব তাঁরই। কে সে, যে তাঁর অনুমতি ব্যতীত তাঁর কাছে সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে তা তিনি জানেন। আর তাঁর জ্ঞানের কোনো কিছুকেই তারা পরিবেষ্টন করতে পারে না, তবে তিনি যতটুকু চান। তাঁর কুরসী আসমানসমূহ ও যমীনকে পরিব্যাপ্ত করে আছে এবং এ দু\'টোর রক্ষণাবেক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি সুউচ্চ, মহান।',
              reference: 'সূরা আল-বাকারাহ: ২৫৫',
              fazilat:
                  'যে ব্যক্তি সকালে আয়াতুল কুরসি পড়বে, সন্ধ্যা পর্যন্ত শয়তান থেকে তার হেফাযত করা হবে। আর যে সন্ধ্যায় পড়বে, সকাল পর্যন্ত হেফাযত করা হবে।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.3: Surah Ikhlas, Falaq, Nas
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #২ - সূরা ইখলাস, ফালাক ও নাস',
              arabic:
                  '''قُلْ هُوَ اللّٰهُ اَحَدٌ ۚ اَللّٰهُ الصَّمَدُ ۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ

            قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۙ مِن شَرِّ مَا خَلَقَ ۙ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۙ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۙ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ

            قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۙ مَلِكِ النَّاسِ ۙ إِلَٰهِ النَّاسِ ۙ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۙ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۙ مِنَ الْجِنَّةِ وَالنَّاسِ''',
              pronunciation:
                  '''(সূরা ইখলাস): ক্বুল হুওয়াল্লা-হু আহাদ। আল্লা-হুস সামাদ। লাম ইয়ালিদ ওয়া লাম ইউলাদ। ওয়া লাম ইয়াকুল্লাহু কুফুওয়ান আহাদ।

            (সূরা ফালাক): ক্বুল আ‘উযু বিরাব্বিল ফালাক্ব। মিন শাররি মা খালাক্ব। ওয়া মিন শাররি গ-সিক্বিন ইযা ওয়াক্বাব। ওয়া মিন শাররি নাফফ-ছা-তি ফিল ‘উক্বাদ। ওয়া মিন শাররি হা-সিদিন ইযা হাসাদ।

            (সূরা নাস): ক্বুল আ‘উযু বিরাব্বিন না-স। মালিকিন না-স। ইলা-হিন না-স। মিন শাররিল ওয়াসওয়া-সিল খান্না-স। আল্লাযী ইউওয়াসউইসু ফী সুদূরিন না-স। মিনাল জিন্নাতি ওয়ান না-স।''',
              meaning:
                  '''(সূরা ইখলাস): বলুন, তিনি আল্লাহ, এক, অদ্বিতীয়। আল্লাহ অমুখাপেক্ষী; সবাই তাঁর মুখাপেক্ষী। তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেয়া হয়নি। আর তাঁর সমতুল্য কেউ নেই।

            (সূরা ফালাক): বলুন, আমি আশ্রয় গ্রহণ করছি প্রভাতের রবের। তিনি যা সৃষ্টি করেছেন, তার অনিষ্ট থেকে। অন্ধকার রাত্রির অনিষ্ট থেকে, যখন তা সমাগত হয়। গ্রন্থিতে ফুঁৎকার দিয়ে জাদুকরিনীদের অনিষ্ট থেকে। এবং হিংসুকের অনিষ্ট থেকে, যখন সে হিংসা করে।

            (সূরা নাস): বলুন, আমি আশ্রয় গ্রহণ করছি মানুষের রবের, মানুষের অধিপতির, মানুষের মাবুদের। তার কুমন্ত্রণার অনিষ্ট থেকে, যে কুমন্ত্রণা দিয়ে আত্মগোপন করে। যে মানুষের অন্তরে কুমন্ত্রণা দেয়। জিন ও মানুষের মধ্য থেকে।''',
              reference: 'আবু দাউদ: ৫০৮২, তিরমিজি: ৩৫৭৫',
              fazilat:
                  'এই তিন সূরা সকালে ও সন্ধ্যায় তিনবার করে পড়লে সব কিছু থেকে নিরাপত্তা ও হেফাজতের জন্য যথেষ্ট হবে।',
              count: '৩ বার',
            ),
            const SizedBox(height: 12),

            // 27.6: Sayyidul Istighfar
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৩ - সাইয়্যিদুল ইস্তিগফার',
              arabic:
                  'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَا اِلٰهَ اِلَّا اَنْتَ، خَلَقْتَنِيْ وَاَنَا عَبْدُكَ، وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَاَبُوْءُ بِذَنْبِيْ، فَاغْفِرْ لِيْ فَاِنَّهٗ لَا يَغْفِرُ الذُّنُوْبَ اِلَّا اَنْتَ',
              pronunciation:
                  'আল্লা-হুম্মা আনতা রব্বী, লা ইলা-হা ইল্লা আনতা, খালাক্বতানী ওয়া আনা \'আবদুকা, ওয়া আনা \'আলা \'আহদিকা ওয়া ওয়া\'দিকা মাস্তাত্বা\'তু, আ\'ঊযু বিকা মিন শাররি মা সানা\'তু, আবূউ লাকা বিনি\'মাতিকা \'আলাইয়্যা, ওয়া আবূউ বিযানবী, ফাগফির লী, ফা-ইন্নাহু লা ইয়াগফিরুয যুনূবা ইল্লা আনতা।',
              meaning:
                  'হে আল্লাহ! আপনি আমার রব, আপনি ছাড়া কোনো (সত্য) ইলাহ নেই। আপনি আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা। আমি আমার সাধ্যমত আপনার নিকট দেওয়া অঙ্গীকার ও প্রতিশ্রুতির উপর আছি। আমি আমার কৃতকর্মের অনিষ্ট থেকে আপনার নিকট আশ্রয় চাই। আমার প্রতি আপনার নেয়ামত স্বীকার করছি এবং আমার গুনাহও স্বীকার করছি। অতএব, আপনি আমাকে ক্ষমা করুন। কেননা, আপনি ছাড়া গুনাহ ক্ষমা করার কেউ নেই।',
              reference: 'সহীহ বুখারী: ৬৩০৬',
              fazilat:
                  'যে ব্যক্তি দৃঢ় বিশ্বাসের সাথে সকালে এটি পড়বে এবং সন্ধ্যার আগে মারা যাবে, সে জান্নাতি হবে। আর যে সন্ধ্যায় পড়বে এবং সকাল হওয়ার আগে মারা যাবে, সেও জান্নাতি হবে।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.9: Morning Evening Dhikr #4
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৪',
              arabic:
                  'اَللّٰهُمَّ بِكَ اَصْبَحْنَا، وَبِكَ اَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوْتُ، وَاِلَيْكَ النُّشُوْرُ',
              pronunciation:
                  'আল্লা-হুম্মা বিকা আসবাহনা, ওয়া বিকা আমসাইনা, ওয়া বিকা নাহ্ইয়া, ওয়া বিকা নামূতু, ওয়া ইলাইকান নুশূর।',
              meaning:
                  'হে আল্লাহ! আপনার (রহমতে) আমরা সকালে উপনীত হলাম, আপনার (রহমতে) সন্ধ্যায় উপনীত হলাম, আপনার ইচ্ছায় জীবন ধারণ করি, আপনার ইচ্ছায় মৃত্যুবরণ করি এবং আপনার দিকেই প্রত্যাবর্তন।',
              reference: 'তিরমিযী: ৩৩৯১',
              fazilat: 'সকালে পড়লে আল্লাহর যিম্মায় থাকবে।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.10: For all worries
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৫ - সব দুশ্চিন্তার জন্য',
              arabic:
                  'اَللّٰهُمَّ اِنِّيْ اَسْاَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْاٰخِرَةِ، اَللّٰهُمَّ اِنِّيْ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِيْ دِيْنِيْ وَدُنْيَايَ وَاَهْلِيْ وَمَالِيْ، اَللّٰهُمَّ اسْتُرْ عَوْرَاتِيْ وَاٰمِنْ رَوْعَاتِيْ، اَللّٰهُمَّ احْفَظْنِيْ مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِيْ وَعَنْ يَمِيْنِيْ وَعَنْ شِمَالِيْ وَمِنْ فَوْقِيْ، وَاَعُوْذُ بِعَظَمَتِكَ اَنْ اُغْتَالَ مِنْ تَحْتِيْ',
              pronunciation:
                  'আল্লা-হুম্মা ইন্নী আসআলুকাল \'আ-ফিয়াতা ফিদ্দুনইয়া ওয়াল আ-খিরাহ। আল্লা-হুম্মা ইন্নী আসআলুকাল \'আফওয়া ওয়াল \'আ-ফিয়াতা ফী দীনী ওয়া দুনইয়া-ইয়া ওয়া আহলী ওয়া মা-লী। আল্লা-হুম্মাসতুর \'আওরা-তী ওয়া আ-মিন রাও\'আ-তী। আল্লা-হুম্মাহফাযনী মিম বাইনি ইয়াদাইয়্যা ওয়া মিন খালফী ওয়া \'আন ইয়ামীনী ওয়া \'আন শিমা-লী ওয়া মিন ফাওক্বী, ওয়া আ\'ঊযু বি\'আযামাতিকা আন উগতা-লা মিন তাহতী।',
              meaning:
                  'হে আল্লাহ! আমি আপনার কাছে দুনিয়া ও আখিরাতে নিরাপত্তা প্রার্থনা করছি। হে আল্লাহ! আমি আপনার কাছে আমার দীন, দুনিয়া, পরিবার ও সম্পদের ক্ষেত্রে ক্ষমা ও নিরাপত্তা প্রার্থনা করছি। হে আল্লাহ! আমার দোষত্রুটি ঢেকে রাখুন এবং আমার ভয়-ভীতি দূর করুন। হে আল্লাহ! আমাকে হেফাযত করুন আমার সামনে, পেছনে, ডানে, বামে ও উপর থেকে। আর আমি আপনার মহত্ত্বের আশ্রয় নিচ্ছি যেন আমার নিচ থেকে আমাকে ধ্বংস করা না হয়।',
              reference: 'আবূ দাউদ: ৫০৭৪',
              fazilat: 'রাসূলুল্লাহ ﷺ প্রতিদিন সকাল-সন্ধ্যায় এই দোয়া পড়তেন।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.11: Morning Evening Dhikr #6
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৬ - শয়তানের অনিষ্ট থেকে হেফাযত',
              arabic:
                  'اَللّٰهُمَّ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ فَاطِرَ السَّمٰوَاتِ وَالْاَرْضِ، رَبَّ كُلِّ شَيْءٍ وَمَلِيْكَهٗ، اَشْهَدُ اَنْ لَّا اِلٰهَ اِلَّا اَنْتَ، اَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ، وَمِنْ شَرِّ الشَّيْطَانِ وَشِرْكِهٖ، وَاَنْ اَقْتَرِفَ عَلٰى نَفْسِيْ سُوْءًا اَوْ اَجُرَّهٗ اِلٰى مُسْلِمٍ',
              pronunciation:
                  'আল্লা-হুম্মা \'আ-লিমাল গাইবি ওয়াশশাহা-দাতি ফা-ত্বিরাস সামা-ওয়া-তি ওয়াল আরদ, রব্বা কুল্লি শাইইন ওয়া মালীকাহু, আশহাদু আল্লা- ইলা-হা ইল্লা আনতা, আ\'ঊযু বিকা মিন শাররি নাফসী, ওয়া মিন শাররিশ শাইত্বা-নি ওয়া শিরকিহী, ওয়া আন আক্বতারিফা \'আলা নাফসী সূআন আও আজুররাহু ইলা মুসলিম।',
              meaning:
                  'হে আল্লাহ! অদৃশ্য ও দৃশ্যের জ্ঞাতা, আসমানসমূহ ও যমীনের সৃষ্টিকর্তা, সব কিছুর রব ও মালিক! আমি সাক্ষ্য দিচ্ছি যে, আপনি ছাড়া কোনো (সত্য) ইলাহ নেই। আমি আপনার কাছে আশ্রয় চাই আমার নফসের অনিষ্ট থেকে, শয়তানের অনিষ্ট ও তার শিরক থেকে এবং আমার নিজের উপর কোনো মন্দ কাজ করা অথবা কোনো মুসলিমের প্রতি তা টেনে আনা থেকে।',
              reference: 'তিরমিযী: ৩৩৯২, আবূ দাউদ: ৫০৬৭',
              fazilat: 'শয়তানের অনিষ্ট থেকে হেফাযত হবে।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.13: Protection from harm
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৭ - ক্ষতি থেকে রক্ষা',
              arabic:
                  'بِسْمِ اللّٰهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهٖ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
              pronunciation:
                  'বিসমিল্লা-হিল্লাযী লা ইয়াদুররু মা\'আসমিহী শাইউন ফিল আরদি ওয়ালা ফিস সামা-ই ওয়া হুওয়াস সামী\'উল \'আলীম।',
              meaning:
                  'আল্লাহর নামে, যাঁর নামের সাথে আসমান ও যমীনের কোনো কিছুই ক্ষতি করতে পারে না। তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
              reference: 'আবূ দাউদ: ৫০৮৮, তিরমিযী: ৩৩৮৮',
              fazilat:
                  'যে ব্যক্তি সকাল-সন্ধ্যায় তিনবার এটি পড়বে, তাকে কোনো কিছু ক্ষতি করতে পারবে না।',
              count: '৩ বার',
            ),
            const SizedBox(height: 12),

            // 27.14: Allah's pleasure on Judgement Day
            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৮ - কিয়ামতের দিনে আল্লাহর সন্তুষ্টি',
              arabic:
                  'رَضِيْتُ بِاللّٰهِ رَبًّا، وَبِالْاِسْلَامِ دِيْنًا، وَبِمُحَمَّدٍ صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
              pronunciation:
                  'রাদীতু বিল্লা-হি রব্বান, ওয়া বিল ইসলা-মি দীনান, ওয়া বিমুহাম্মাদিন সাল্লাল্লাহু \'আলাইহি ওয়াসাল্লামা নাবিয়্যান।',
              meaning:
                  'আমি আল্লাহকে রব হিসেবে, ইসলামকে দীন হিসেবে এবং মুহাম্মাদ সাল্লাল্লাহু আলাইহি ওয়াসাল্লামকে নবী হিসেবে সন্তুষ্টচিত্তে গ্রহণ করলাম।',
              reference: 'আবূ দাউদ: ৫০৭২, তিরমিযী: ৩৩৮৯',
              fazilat:
                  'যে ব্যক্তি এটি সকাল-সন্ধ্যায় তিনবার পড়বে, কিয়ামাতের দিন আল্লাহ তাকে সন্তুষ্ট করবেন।',
              count: '৩ বার',
            ),
            const SizedBox(height: 12),

            // 27.15: Ya Hayyu Ya Qayyum
            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৯ - ইয়্যা হাইয়্যু ইয়্যা ক্বাইয়্যুম',
              arabic:
                  'يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ اَسْتَغِيْثُ، اَصْلِحْ لِيْ شَاْنِيْ كُلَّهٗ، وَلَا تَكِلْنِيْ اِلٰى نَفْسِيْ طَرْفَةَ عَيْنٍ',
              pronunciation:
                  'ইয়া হাইয়্যু ইয়া ক্বাইয়্যুমু বিরাহমাতিকা আসতাগীস, আসলিহ লী শা\'নী কুল্লাহু, ওয়ালা তাকিলনী ইলা নাফসী ত্বারফাতা \'আইন।',
              meaning:
                  'হে চিরঞ্জীব! হে সর্বসত্তার ধারক! আপনার রহমতের মাধ্যমে আপনার কাছে সাহায্য চাই। আমার সকল বিষয় সংশোধন করে দিন এবং এক পলকের জন্যও আমাকে আমার নিজের উপর ছেড়ে দিবেন না।',
              reference: 'হাকিম: ১/৫৪৫, সহীহুল জামি\': ৫৮২০',
              fazilat: 'সকল বিষয়ে সাহায্য পাওয়া যায়।',
              count: '১ বার',
            ),
            const SizedBox(height: 12),

            // 27.21: Subhanallahi wa bihamdihi
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১০ - সুবহানাল্লাহি ওয়া বিহামদিহী',
              arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ',
              pronunciation: 'সুবহা-নাল্লা-হি ওয়া বিহামদিহী।',
              meaning: 'আল্লাহর পবিত্রতা ঘোষণা করছি এবং তাঁর প্রশংসা করছি।',
              reference: 'মুসলিম: ২৬৯২',
              fazilat:
                  'যে ব্যক্তি সকাল-সন্ধ্যায় ১০০ বার এটি পড়বে, কিয়ামাতের দিন তার চেয়ে উত্তম আমল নিয়ে কেউ আসবে না, তবে সে ব্যক্তি ছাড়া যে এর সমান বা এর চেয়ে বেশি আমল করেছে।',
              count: '১০০ বার',
            ),
            const SizedBox(height: 12),

            // 27.24: La ilaha illallah
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১১ - লা ইলাহা ইল্লাল্লাহু',
              arabic:
                  'لَا اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
              pronunciation:
                  'লা ইলা-হা ইল্লাল্লা-হু ওয়াহদাহু লা শারীকা লাহু, লাহুল মুলকু ওয়া লাহুল হামদু, ওয়া হুওয়া \'আলা কুল্লি শাইইন ক্বাদীর।',
              meaning:
                  'আল্লাহ ছাড়া কোনো (সত্য) ইলাহ নেই, তিনি একক, তাঁর কোনো শরীক নেই। রাজত্ব তাঁরই এবং সকল প্রশংসা তাঁরই। আর তিনি সব কিছুর উপর ক্ষমতাবান।',
              reference: 'বুখারী: ৩২৯৩, মুসলিম: ২৬৯১',
              fazilat:
                  'সকালে ১০ বার পড়লে ১০টি গোলাম আযাদ করার সমান সওয়াব, ১০টি নেকী লেখা হয়, ১০টি গুনাহ মাফ হয়, ১০ ধাপ মর্যাদা বৃদ্ধি পায় এবং সন্ধ্যা পর্যন্ত শয়তান থেকে হেফাযত থাকে।',
              count: '১০ বার',
            ),
            const SizedBox(height: 12),

            // 27.26: Hasbiyallahu la ilaha illa huwa (7 times)
            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #১২ - হাসবিয়াল্লাহু লা ইলাহা ইল্লা হুওয়া ',
              arabic:
                  'حَسْبِيَ اللّٰهُ لَا اِلٰهَ اِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيْمِ',
              pronunciation:
                  'হাসবিয়াল্লা-হু লা ইলা-হা ইল্লা হুওয়া, \'আলাইহি তাওয়াক্কালতু, ওয়া হুওয়া রব্বুল \'আরশিল \'আযীম।',
              meaning:
                  'আমার জন্য আল্লাহই যথেষ্ট, তিনি ছাড়া কোনো (সত্য) ইলাহ নেই। আমি তাঁর উপরই ভরসা করি এবং তিনি মহান আরশের রব।',
              reference: 'আবূ দাউদ: ৫০৮১',
              fazilat:
                  'যে ব্যক্তি সকাল-সন্ধ্যায় সাতবার এটি পড়বে, আল্লাহ তার দুনিয়া ও আখিরাতের চিন্তা দূর করে দেবেন।',
              count: '৭ বার',
            ),
            const SizedBox(height: 12),

            // 27.28: Salawat upon Prophet
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১৩ - নবীজীর উপর দরূদ',
              arabic: 'اَللّٰهُمَّ صَلِّ وَسَلِّمْ عَلٰى نَبِيِّنَا مُحَمَّدٍ',
              pronunciation:
                  'আল্লা-হুম্মা সাল্লি ওয়া সাল্লিম \'আলা নাবিয়্যিনা মুহাম্মাদ।',
              meaning:
                  'হে আল্লাহ! আমাদের নবী মুহাম্মাদের উপর রহমত ও শান্তি বর্ষণ করুন।',
              reference: 'তিরমিযী: ৪৭৮',
              fazilat:
                  'যে ব্যক্তি সকালে ও সন্ধ্যায় দশবার আমার উপর দরূদ পাঠ করবে, কিয়ামাতের দিন তার জন্য আমার সুপারিশ ওয়াজিব হয়ে যাবে।',
              count: '১০ বার',
            ),
          ],
        ),
      ),
    );
  }

  // Expandable Dua Card with Arabic, Pronunciation, Meaning
  Widget _buildExpandableDuaCard({
    required String title,
    required String arabic,
    required String pronunciation,
    required String meaning,
    required String reference,
    required String fazilat,
    required String count,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Icon(
            Icons.format_quote,
            color: cs.primary,
            size: 20,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'AlinurBanglaborno',
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count,
              style: TextStyle(
                color: cs.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          iconColor: cs.primary,
          collapsedIconColor: cs.primary,
          children: [
            // Arabic Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.outline.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'আরবী',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    arabic,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 20,
                      fontFamily: 'Amiri',
                      height: 2.2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Pronunciation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.outline.withOpacity(0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: cs.tertiary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'উচ্চারণ',
                        style: TextStyle(
                          color: cs.tertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pronunciation,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Meaning
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.outline.withOpacity(0.10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.translate,
                        color: cs.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'অর্থ',
                        style: TextStyle(
                          color: cs.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meaning,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Fazilat
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cs.primary.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: cs.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ফযীলত',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    fazilat,
                    style: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.90),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Reference
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 16,
                    color: cs.onSurfaceVariant.withOpacity(0.75),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    reference,
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
