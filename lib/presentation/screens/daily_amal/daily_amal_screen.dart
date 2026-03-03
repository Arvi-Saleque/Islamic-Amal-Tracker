import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amal_tracker/core/utils/prayer_name_utils.dart';
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

  Map<String, String> get _categoryNames => {
    'all': 'all'.tr(),
    'miswak': 'miswak'.tr(),
    'surah': 'surah'.tr(),
    'dua': 'dua'.tr(),
    'prayer': 'nafl_prayer'.tr(),
    'other': 'other'.tr(),
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
                color:
                    Theme.of(context).extension<GradientColors>()!.appBarBorder,
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
          'daily_amal_title'.tr(),
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
            colors: Theme.of(context)
                .extension<GradientColors>()!
                .backgroundGradient,
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
                  padding: const EdgeInsets.fromLTRB(_pagePad, 0, _pagePad, 22),
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
                        colors: theme
                            .extension<GradientColors>()!
                            .cardGradient
                            .take(2)
                            .toList(),
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
                  'daily_amal_total'.tr(),
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
                      colors:
                          theme.extension<GradientColors>()!.innerCardGradient,
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
                    '$completed/$total ${'daily_amal_done_label'.tr()}',
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
                        '${'daily_amal_goal'.tr()}: $total',
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
        backgroundColor: item.isCompleted ? cs.primary.withOpacity(0.08) : null,
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
                      _localizedAmalTitle(context, item),
                      style: TextStyle(
                        color: item.isCompleted ? cs.primary : cs.onSurface,
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
                        '${'daily_amal_completed_at'.tr()}: ${_formatTime(item.completedAt!)}',
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
                  onPressed: () => _confirmDelete(context, item, notifier),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedAmalTitle(BuildContext context, DailyAmalItem item) {
    // Custom items: show the exact stored title (with Friday-aware tweak only in Bangla)
    if (item.id.startsWith('custom_')) {
      if (context.locale.languageCode == 'bn') {
        return fridayAwareDisplay(item.title);
      }
      return item.title;
    }

    // Default checklist items: use translation keys based on a stable ID
    final key = _amalTitleKeyForId(item.id);
    if (key != null) {
      return key.tr();
    }

    // Fallback: keep previous behaviour
    if (context.locale.languageCode == 'bn') {
      return fridayAwareDisplay(item.title);
    }
    return item.title;
  }

  String? _amalTitleKeyForId(String id) {
    switch (id) {
      // Miswak before prayers
      case 'miswak_fajr':
        return 'amal_miswak_fajr';
      case 'miswak_dhuhr':
        return 'amal_miswak_dhuhr';
      case 'miswak_asr':
        return 'amal_miswak_asr';
      case 'miswak_maghrib':
        return 'amal_miswak_maghrib';
      case 'miswak_isha':
        return 'amal_miswak_isha';

      // Surah readings
      case 'surah_mulk':
        return 'amal_surah_mulk';
      case 'surah_waqi':
        return 'amal_surah_waqi';
      case 'surah_kahf':
        return 'amal_surah_kahf';
      case 'surah_yaseen':
        return 'amal_surah_yaseen';

      // Duas
      case 'dua_morning':
        return 'amal_dua_morning';
      case 'dua_evening':
        return 'amal_dua_evening';
      case 'dua_sleep':
        return 'amal_dua_sleep';

      // Nafl prayers and other deeds
      case 'tahajjud':
        return 'amal_tahajjud';
      case 'ishraq':
        return 'amal_ishraq';
      case 'duha':
        return 'amal_duha';
      case 'awwabin':
        return 'amal_awwabin';
      case 'charity':
        return 'amal_charity';
      case 'helping':
        return 'amal_helping';

      default:
        return null;
    }
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
            'daily_amal_empty'.tr(),
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
                        'daily_amal_add'.tr(),
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
                      deco(hint: 'daily_amal_name_hint'.tr(), icon: Icons.edit_outlined),
                ),
                const SizedBox(height: 16),
                // Dropdown
                StatefulBuilder(
                  builder: (context, setState) =>
                      DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    dropdownColor: cs.surfaceContainerHighest,
                    style: TextStyle(color: cs.onSurface),
                    decoration: deco(
                        hint: 'daily_amal_category_hint'.tr(),
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
                        'cancel'.tr(),
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
                        foregroundColor:
                            theme.extension<GradientColors>()!.onPrimaryText,
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
                      child: Text(
                        'daily_amal_add_btn'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                      'daily_amal_delete_title'.tr(),
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
                '"${item.title}" ${'daily_amal_delete_msg'.tr()}',
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
                      'no'.tr(),
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
                    child: Text(
                      'daily_amal_delete_confirm'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: Theme.of(context)
          .extension<GradientColors>()!
          .onPrimaryText
          .withOpacity(0),
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
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
                          'daily_amal_info_title'.tr(),
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
                color: Theme.of(context)
                    .extension<GradientColors>()!
                    .onPrimaryText,
                size: 18),
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
            const SizedBox(height: 12),

            // Beautiful heading
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primary.withOpacity(0.12),
                    cs.primary.withOpacity(0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Decorative top line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0),
                                cs.primary.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.auto_awesome,
                          color: cs.primary.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withValues(alpha: 0.4),
                                cs.primary.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Bismillah
                  Text(
                    'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 18,
                      fontFamily: 'Amiri',
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Main title
                  Text(
                    'রাসূলুল্লাহ (সা:) এর\nসকাল - সন্ধ্যার দু\'আ ও যিকর',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Divider
                  Container(
                    width: 40,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Author
                  Text(
                    'লেখকঃ শায়খ আহমাদুল্লাহ',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'বিঃদ্রঃ বাংলা উচ্চারণ দেওয়া আছে কিন্তু বাংলা উচ্চারণ দেখে পড়ার জন্য নিরুৎসাহিত করা হচ্ছে।',
                    style: TextStyle(
                      color: cs.primary.withOpacity(0.3),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Decorative bottom line
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0),
                                cs.primary.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.auto_awesome,
                          color: cs.primary.withOpacity(0.6),
                          size: 16,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                cs.primary.withOpacity(0.4),
                                cs.primary.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 27.2: Ayatul Kursi

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১ - আয়াতুল কুরসী',
              arabic:
                  'اَللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ۚ اَلْحَيُّ الْقَيُّوْمُ ۚ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۚ لَهٗ مَا فِي السَّمٰوٰتِ وَمَا فِي الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ وَلَا يَئُوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
              pronunciation:
                  'আল্লা-হু লা ইলা-হা ইল্লা হুওয়াল হাইয়্যুল ক্বাইয়্যুম। লা তা’খুযুহু সিনাতুওঁ ওয়ালা নাওম। লাহু মা ফিস্ সামাওয়া-তি ওয়ামা ফিল আরদ্। মান যাল্লাযী ইয়াশফাউ ‘ইন্দাহু ইল্লা বিইযনিহ। ইয়ালামু মা বাইনা আইদীহিম ওয়ামা খালফাহুম। ওয়ালা ইউহীতূনা বিশাইইম্ মিন ‘ইলমিহী ইল্লা বিমা শা-আ। ওয়াসি‘আ কুরসিয়্যুহুস্ সামাওয়া-তি ওয়াল আরদ্। ওয়ালা ইয়াঊদুহু হিফযুহুমা, ওয়া হুওয়াল ‘আলিউল ‘আযীম।',
              meaning:
                  'আল্লাহ, তিনি ছাড়া কোনো (সত্য) ইলাহ নেই। তিনি চিরঞ্জীব, সর্বসত্তার ধারক। তাঁকে তন্দ্রা ও নিদ্রা স্পর্শ করে না। আসমানসমূহে ও যমীনে যা কিছু আছে সব তাঁরই। কে সে, যে তাঁর অনুমতি ব্যতীত তাঁর কাছে সুপারিশ করবে? তাদের সামনে ও পেছনে যা কিছু আছে তা তিনি জানেন। আর তাঁর জ্ঞানের কোনো কিছুকেই তারা পরিবেষ্টন করতে পারে না, তবে তিনি যতটুকু চান। তাঁর কুরসী আসমানসমূহ ও যমীনকে পরিব্যাপ্ত করে আছে এবং এ দু\'টোর রক্ষণাবেক্ষণ তাঁকে ক্লান্ত করে না। আর তিনি সুউচ্চ, মহান।',
              reference: 'সুরা বাক্বারা: ২৫৫',
              fazilat:
                  'কোনো ব্যক্তি সকাল-সন্ধ্যায় আয়াতুল কুরসী পাঠ করলে সারাদিন ও সারারাত জিনের আক্রমণ থেকে নিরাপত্তায় থাকবে। রাতে শোয়ার সময় পড়লে শয়তান নিকটবর্তী হবে না।',
              count: 'সকাল-সন্ধ্যায় \n১ বার',
            ),
            const SizedBox(height: 12),
            // ২ নং যিক্র: ৩ কুল (ইখলাস, ফালাক্ব ও নাস)
            const SizedBox(height: 14),
            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #২ - ৩টি কুল (ইখলাস, ফালাক্ব, নাস)',
              arabic:
                  'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ هُوَ اللّٰهُ اَحَدٌ ۚ اَللّٰهُ الصَّمَدُ ۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ الْفَلَقِ ۙ مِنْ شَرِّ مَا خَلَقَ ۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَ ۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِي الْعُقَدِ ۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ النَّاسِ ۙ مَلِكِ النَّاسِ ۙ اِلٰهِ النَّاسِ ۙ مِنْ شَرِّ الْوَسْوَاسِ  الْخَنَّاسِ ۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِ ۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
              pronunciation:
                  '(১) কুল হুওয়াল্লা-হু আহাদ। আল্লা-হুস সামাদ। লাম ইয়ালিদ ওয়া লাম ইউলাদ। ওয়া লাম ইয়াকুল্লাহু কুফুওয়ান আহাদ।\n\n(২) কুল আ‘উযু বিরাব্বিল ফালাক। মিন শাররি মা খালাক। ওয়া মিন শাররি গা-সিকিন ইযা ওয়াকাব। ওয়া মিন শাররি নাফফা-ছা-তি ফিল ‘উকাদ। ওয়া মিন শাররি হা-সিদিন ইযা হাসাদ।\n\n(৩) কুল আ‘উযু বিরাব্বিন না-স। মালিকিন না-স। ইলা-হিন না-স। মিন শাররিল ওয়াসওয়া-সিল খান্না-স। আল্লাযী ইউওয়াসবিসু ফী সুদূরিন না-স। মিনাল জিন্নাতি ওয়ান না-স।',
              meaning:
                  '(১) বলুন, তিনি আল্লাহ, এক, অদ্বিতীয়। আল্লাহ অমুখাপেক্ষী। তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেয়া হয়নি। আর তাঁর সমতুল্য কেউ নেই।\n\n(২) বলুন, আমি আশ্রয় প্রার্থনা করছি উষার রবের। তিনি যা সৃষ্টি করেছেন তার অনিষ্ট হতে। আর অন্ধকার রাতের অনিষ্ট হতে, যখন তা সমাগত হয়। আর গিরায় ফুঁকদানকারিনীদের অনিষ্ট হতে। আর হিংসুকের অনিষ্ট হতে যখন সে হিংসা করে।\n\n(৩) বলুন, আমি আশ্রয় চাই মানুষের রবের কাছে। মানুষের অধিপতির কাছে। মানুষের ইলাহের কাছে। আত্মগোপনকারী কুমন্ত্রণাদাতার অনিষ্ট হতে। যে মানুষের মনে কুমন্ত্রণা দেয়। জ্বিন ও মানুষ থেকে।',
              reference: 'আবু দাউদ, ৪৯১৬ তিরমিযী, ৩৫৭৩',
              fazilat:
                  'পাঠকারীর জন্য সব কিছুর ক্ষতি থেকে নিরাপত্তার জন্য যথেষ্ট হয়ে যাবে।',
              count: 'সকালে ৩ বার \nসন্ধ্যায় ৩ বার',
            ),

// ৩ নং যিক্র: হাসবিয়াল্লাহু
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৩ - হাসবিয়াল্লাহু লা ইলাহা ইল্লা হুয়া',
              arabic:
                  'حَسْبِيَ اللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ؕ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيْمِ',
              pronunciation:
                  '\'হাসবিয়াল্লা-হু লা ইলা-হা ইল্লা হুওয়া, \'আলাইহি তাওয়াক্কালতু ওয়া হুওয়া রাব্বুল \'আরশিল আযীম।',
              meaning:
                  'আল্লাহই আমার জন্য যথেষ্ট, তিনি ছাড়া আর কোনো হক ইলাহ নেই। আমি তাঁর ওপরই ভরসা করেছি। আর তিনি মহান আরশের রব।',
              reference: 'আবু দাউদ, (৫০৮১)',
              fazilat:
                  'যে ব্যক্তি দু\'আটি সকালে ৭ বার এবং সন্ধ্যায় ৭ বার বলবে, তার দুনিয়া ও আখিরাতের সকল দুশ্চিন্তা ও উৎকণ্ঠা দূর করার জন্য আল্লাহই যথেষ্ট হবেন।',
              count: 'সকাল-সন্ধ্যায় \n৭ বার',
            ),

// ৪ নং যিক্র: সায়্যিদুল ইস্তিগফার
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৪ - সায়্যিদুল ইস্তিগফার',
              arabic:
                  'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ ؕ خَلَقْتَنِيْ وَاَنَا عَبْدُكَ وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ۚ اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ۚ اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَاَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَاِنَّهٗ لَا يَغْفِرُ الذُّنُوْبَ اِلَّاۤ اَنْتَ',
              pronunciation:
                  'আল্লা-হুম্মা আনতা রাব্বী, লা ইলা-হা ইল্লা আনতা, খালাক্বতানী, ওয়া আনা \'আবদুকা, ওয়া আনা \'আলা \'আহদিকা ওয়া ওয়া\'দিকা মাস্তাত্বা\'তু। আউযু বিকা মিন শাররি মা- সানা\'তু, আবূউ লাকা বিনি\'মাতিকা \'আলাইয়্যা, ওয়া আবূউ লাকা বিযাম্বী। ফাগফির লী ফাইন্নাহ্ লা- য়াগফিরুয যুনুবা ইল্লা- আনতা।',
              meaning:
                  'হে আল্লাহ, আপনি আমার প্রতিপালক, আপনি ছাড়া কোনো হক ইলাহ নেই। আপনি আমাকে সৃষ্টি করেছেন এবং আমি আপনার বান্দা। আর আমি আমার সাধ্যানুযায়ী আপনার (তাওহীদের) অঙ্গীকার ও (জান্নাতের) প্রতিশ্রুতির ওপর রয়েছি। আমার কৃতকর্মের অনিষ্ট থেকে আপনার কাছে আশ্রয় চাই। আমার প্রতি আপনার প্রদত্ত নিয়ামত স্বীকার করছি। আর আপনার কাছে আমার পাপকর্মেরও স্বীকারোক্তি দিচ্ছি। অতএব আপনি আমাকে মাফ করুন। নিশ্চয় আপনি ছাড়া আর কেউ গুনাহসমূহ মাফ করতে পারেনা।',
              reference: 'বুখারী, ৬৩০৩',
              fazilat:
                  'দৃঢ় বিশ্বাসের সাথে সকাল এবং সন্ধ্যায় পাঠ করলে সেদিনে বা রাতে মারা গেলে নিশ্চিতভাবে জান্নাতী হবে।',
              count: 'সকাল-সন্ধ্যায় \n১ বার',
            ),

// ৫ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৫ - বিসমিল্লাহিল্লাজি লা ইয়াদুররু',
              arabic:
                  'بِسْمِ اللّٰهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهٖ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاۤءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
              pronunciation:
                  'বিসমিল্লা-হিল্লাযী লা- ইয়াদুররু মা\'আমিহী শাইউন ফিল্ আরদ্বি ওয়ালা- ফিস্ সামা-ই ওয়া হুওয়াস্ সামী\'উল \'আলীম।',
              meaning:
                  'শুরু করছি আল্লাহর নামে; যাঁর নামের সাথে আসমান এবং যমীনে কোনো কিছুই ক্ষতি করতে পারে না। আর তিনি সর্বশ্রোতা, মহাজ্ঞানী।',
              reference: 'তিরমিযী: ৩৩৮৮, ইবনে মাজাহ: ৩৮৬৯',
              fazilat:
                  'যে ব্যক্তি প্রত্যহ সকাল ও সন্ধ্যায় এই দু\'আ ৩ বার করে বলবে, কোনো কিছুই তার ক্ষতি করতে পারবে না।',
              count: 'সকাল-সন্ধ্যায়\n৩ বার',
            ),

// ৬ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৬ - লা ইলাহা ইল্লাল্লাহু... (তাহলীল)',
              arabic:
                  'لَاۤ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
              pronunciation:
                  'লা- ইলা-হা ইল্লাল্লা-হু ওয়াহদাহু লা- শারীকা লাহ্ লাহুল মুলকু ওয়া লাহুল \'হামদু ওয়া হুওয়া \'আলা- কুল্লি শাই ইন ক্বাদীর।',
              meaning:
                  'একমাত্র আল্লাহ ছাড়া কোনো হক ইলাহ নেই, তাঁর কোনো শরীক নেই, রাজত্ব তাঁরই, সমস্ত প্রশংসাও তাঁরই, আর তিনি সব কিছুর উপর ক্ষমতাবান।',
              reference: 'ইবনে হিব্বান, ২০২৩ আবু দাউদ ৫০৭৭',
              fazilat:
                  'সকাল-সন্ধ্যায় ১০ বার বললে ১০টি করে নেকী, ১০টি করে গুনাহ মাফ এবং ১০টি মর্যাদা বৃদ্ধি করা হবে এবং ৪ জন কৃতদাস মুক্ত করার সাওয়াব ও শয়তান থেকে মুক্তি নসীব হবে। অথবা কষ্ট হলে একবার বলতে হবে। এই যিক্র সকালে ১০০ বার বললে ১০ জন কৃতদাস মুক্ত করার সাওয়াব পাবে, ১০০ নেকী পাবে, ১০০ গুনাহ মাফ হবে এবং সেদিন সন্ধ্যা পর্যন্ত শয়তান থেকে নিরাপত্তা অর্জিত হবে।',
              count: 'সকাল-সন্ধ্যায় ১০ বার \nঅথবা সকালে ১০০ বার',
            ),

// ৭ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #৭ - আল্লাহুম্মা আজিরনী মিনান নার',
              arabic: 'اَللّٰهُمَّ اَجِرْنِيْ مِنَ النَّارِ',
              pronunciation: 'আল্লা-হুম্মা আজিরনী মিনান্না-র।',
              meaning: 'হে আল্লাহ, আমাকে জাহান্নামের আগুন থেকে রক্ষা করুন।',
              reference: 'ইবনে হিব্বান: ২০২২',
              fazilat:
                  'ফজর ও মাগরিবের পর কারো সাথে কথা বলার পূর্বে ৭ বার এ দু\'আ পাঠ করলে সেদিনে বা সেই রাতে মৃত্যুবরণ করলে আল্লাহ তাকে জাহান্নাম থেকে রক্ষা করবেন।',
              count: 'ফজর ও মাগরিবে \n৭ বার',
            ),

// ৮ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৮ - আল্লাহুম্মা ইন্নি আসআলুকাল আফওয়া',
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْاٰخِرَةِ ، اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِيْ دِيْنِيْ وَدُنْيَايَ وَاَهْلِيْ وَمَالِيْ ، اَللّٰهُمَّ اسْتُرْ عَوْرٰتِيْ وَاٰمِنْ رَوْعٰتِيْ ، اَللّٰهُمَّ احْفَظْنِيْ مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِيْ وَعَنْ يَّمِيْنِيْ وَعَنْ شِمَالِيْ وَمِنْ فَوْقِيْ وَاَعُوْذُ بِعَظَمَتِكَ اَنْ اُغْتَالَ مِنْ تَحْتِيْ',
              pronunciation:
                  'আল্লা-হুম্মা ইন্নী আসআলুকাল \'আফওয়া ওয়াল \'আ-ফিয়াতা ফিদ্দুনইয়া ওয়াল আ-খিরাতি। আল্লা-হুম্মা ইন্নী আসআলুকাল \'আফওয়া ওয়াল \'আ-ফিয়াতা ফী দীনী ওয়া দুয়া-য়া, ওয়া আলী ওয়া মা-লী, আল্লা-হুম্মাসতুর \'আওরা-তী, ওয়া আ-মিন রাও\'আ-তী। আল্লা-হুম্মা\'হফাযনী মিম্বাইনি ইয়াদাইয়া, ওয়া মিন খালফী, ওয়া \'আন ইয়ামীনী, ওয়া \'আন শিমা-লী, ওয়া মিন ফাওক্বী। ওয়া আ\'উযু বি‘আযামাতিকা আন উগতা-লা মিন তা\'হী।',
              meaning:
                  'হে আল্লাহ, আমি আপনার নিকট দুনিয়া ও আখিরাতে ক্ষমা ও সুস্থতা-নিরাপত্তা প্রার্থনা করছি। হে আল্লাহ! আমি আপনার নিকট ক্ষমা এবং হেফাজত চাচ্ছি- আমার দীন, দুনিয়া, পরিবার ও অর্থ-সম্পদের। হে আল্লাহ, আপনি আমার গোপন ত্রুটিসমূহ ঢেকে রাখুন এবং আমাকে ভয়ভীতি থেকে নিরাপদে রাখুন। হে আল্লাহ, আপনি আমাকে হেফাজত করুন আমার সম্মুখ থেকে, আমার পেছনের দিক থেকে, আমার ডানদিক থেকে, আমার বামদিক থেকে এবং আমার উপরের দিক থেকে। আর আপনার মহত্ত্বের ওসিলায় আশ্রয় চাই ভূমিধসে আমার আকস্মিক মৃত্যু থেকে।',
              reference: 'ইবনে মাজাহ: ৩৮৭১',
              fazilat:
                  'সার্বিক নিরাপত্তা লাভের সবচেয়ে ব্যাপক দু\'আ। রাসূলুল্লাহ (সা.) সকাল-সন্ধ্যায় কখনো এ দু\'আ ছাড়তেন না।',
              count: 'সকাল-সন্ধ্যায়\n১ বার',
            ),

// ৯ নং যিক্র

            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #৯ - আল্লাহুম্মা ইন্নি আসবাহতু উশহিদুকা',
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَصْبَحْتُ اُشْهِدُكَ وَاُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلٰٓئِكَتَكَ وَجَمِيْعَ خَلْقِكَ ، بِاَنَّكَ اَنْتَ اللّٰهُ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ وَحْدَكَ لَا شَرِيْكَ لَكَ وَاَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُوْلُكَ',
              pronunciation:
                  'আল্লা-হুম্মা ইন্নী আসবা\'হতু উশহিদুকা ওয়া উশহিদু \'হামালাতা \'আরশিকা ওয়া মালা-ইকাতাকা ওয়া জামী\'আ খালক্ট্রিক, বিআন্নাকা আনতাল্লা-হু লা ইলা-হা ইল্লা- আনতা ওয়া\'হদাকা লা শারীকা লাকা ওয়া আন্না মু\'হাম্মাদান \'আবদুকা ওয়া রাসূলুক্।\n\n(বিশেষ দ্রষ্টব্য: সন্ধ্যার সময় \'আল্লা-হুম্মা ইন্নী আসবা\'হতু\' -এর স্থলে \'আল্লা-হুম্মা ইন্নী আমসাইতু\' বলতে হবে)',
              meaning:
                  'হে আল্লাহ, আমি সকালে উপনীত হয়েছি। আপনাকে সাক্ষী রাখছি, আরও সাক্ষী রাখছি আপনার \'আরশ বহনকারীদেরকে এবং আপনার ফেরেশতাগণকে ও আপনার সকল সৃষ্টিকে (এই মর্মে) যে, নিশ্চয় আপনিই আল্লাহ, একমাত্র আপনি ছাড়া আর কোনো হক ইলাহ নেই, আপনার কোনো শরীক নেই; আর মুহাম্মাদ আপনার বান্দা ও রাসূল।\n\n(সন্ধ্যায় অর্থ: হে আল্লাহ, আমি সন্ধ্যায় উপনীত হয়েছি...)',
              reference: 'আবু দাউদ: ৫০৬৯',
              fazilat:
                  'যে ব্যক্তি সকালে অথবা সন্ধ্যায় এ দু\'আ ৪ বার বলবে, আল্লাহ তাকে জাহান্নাম থেকে মুক্ত করবেন।',
              count: 'সকাল-সন্ধ্যায়\n৪ বার',
            ),
            

// ১০ নং যিক্র
            
            const SizedBox(height: 14),
            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #১০ - আউযু বি কালিমাতিল্লাহিত তাম্মাত',
              arabic:
                  'اَعُوْذُ بِكَلِمٰتِ اللّٰهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
              pronunciation:
                  'আ\'উযু বিকালিমা-তিল্লা-হিত তা-ম্মা-তি মিন শাররি মা- খালাক্ব।',
              meaning:
                  'আল্লাহর পরিপূর্ণ কালিমাসমূহের মাধ্যমে আমি তাঁর নিকট তাঁর সৃষ্টির ক্ষতি থেকে আশ্রয় চাই।',
              reference: 'আহমাদ: ১৫৭০৯; ইবনে মাজাহ: ৩৫১৮',
              fazilat:
                  'যে ব্যক্তি সন্ধ্যায় এ দু\'আটি ৩ বার বলবে সেই রাতে কোনো বিষধর প্রাণী তার ক্ষতি করতে পারবে না।',
              count: 'সন্ধ্যায় \n৩ বার',
            ),

// ১১ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_11_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ عَافِنِيْ فِيْ بَدَنِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ سَمْعِيْ ، اَللّٰهُمَّ عَافِنِيْ فِيْ بَصَرِيْ ، لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ ، اَللّٰهُمَّ اِنِّيْۤ اَعُوْذُ بِكَ مِنَ الْكُفْرِ وَالْفَقْرِ ، اَللّٰهُمَّ اِنِّيْۤ اَعُوْذُ بِكَ مِنْ عَذَابِ الْقَبْرِ ، لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ',
              pronunciation: 'dhikr_morning_11_pron'.tr(),
              meaning: 'dhikr_morning_11_meaning'.tr(),
              reference: 'dhikr_morning_11_ref'.tr(),
              fazilat: 'dhikr_morning_11_fazilat'.tr(),
              count: 'dhikr_morning_11_count'.tr(),
            ),

// ১২ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_12_title'.tr(),
              arabic:
                  'اَصْبَحْنَا وَاَصْبَحَ الْمُلْكُ لِلّٰهِ وَالْحَمْدُ لِلّٰهِ ، لَاۤ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ ، رَبِّ اَسْاَلُكَ خَيْرَ مَا فِيْ هٰذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهٗ ، وَاَعُوْذُ بِكَ مِنْ شَرِّ مَا فِيْ هٰذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهٗ ، رَبِّ اَعُوْذُ بِكَ مِنَ الْكَسَلِ وَسُوْٓءِ الْكِبَرِ ، رَبِّ اَعُوْذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
              pronunciation: 'dhikr_morning_12_pron'.tr(),
              meaning: 'dhikr_morning_12_meaning'.tr(),
              reference: 'dhikr_morning_12_ref'.tr(),
              fazilat: 'dhikr_morning_12_fazilat'.tr(),
              count: 'dhikr_morning_12_count'.tr(),
            ),

// ১৩ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_13_title'.tr(),
              arabic: 'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ',
              pronunciation: 'dhikr_morning_13_pron'.tr(),
              meaning: 'dhikr_morning_13_meaning'.tr(),
              reference: 'dhikr_morning_13_ref'.tr(),
              fazilat: 'dhikr_morning_13_fazilat'.tr(),
              count: 'dhikr_morning_13_count'.tr(),
            ),

// ১৪ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১৪ - আল্লাহুম্মা ফাতিরাস সামাওয়াত',
              arabic:
                  'اَللّٰهُمَّ فَاطِرَ السَّمٰوٰتِ وَالْاَرْضِ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ رَبَّ كُلِّ شَيْءٍ وَّمَلِيْكَهٗ ، اَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ وَمِنْ شَرِّ الشَّيْطٰنِ وَشِرْكِهٖ وَاَنْ اَقْتَرِفَ عَلٰى نَفْسِيْ سُوْٓءًا اَوْ اَجُرَّهٗۤ اِلٰى مُسْلِمٍ',
              pronunciation:
                  'আল্লা-হুম্মা ফা-ত্বিরাস্ সামা-ওয়া-তি ওয়াল আরদ্বি \'আ-লিমাল গাইবি ওয়াশ্ শাহা-দাহ, লা- ইলা-হা ইল্লা- আনতা রাব্বা কুল্লি শাইয়িন ওয়া মালীকাহ। আ\'ঊযু বিকা মিন শাররি নাক্সী ওয়া মিন শাররিশ্ শাইত্বা-নি ওয়া শারাকিহী, ওয়া আন আক্বতারিফা \'আলা- নাক্সী সূআন, আও আজুররাহ্ ইলা মুসলিম।',
              meaning:
                  'হে আল্লাহ, হে আসমানসমূহ ও যমীনের স্রষ্টা, হে অদৃশ্য ও প্রকাশ্যের জ্ঞানী, হে সব কিছুর রব ও মালিক, আপনি ছাড়া আর কোনো হক ইলাহ নেই। আমি আপনার কাছে আশ্রয় চাই আমার আত্মার অনিষ্ট থেকে, শয়তানের অনিষ্ট থেকে ও তার ফাঁদ থেকে। আরো আশ্রয় চাই, আমার নিজের প্রতি কোনো অন্যায় করা অথবা কোনো মুসলিমের ওপর তা চাপিয়ে দেওয়া থেকে।',
              reference: 'আল-আদাবুল মুফরাদ: ১২০৪; মুসনাদে আহমাদ: ৬৮৫১',
              fazilat:
                  'রাসূলুল্লাহ (সা.) আবু বকর সিদ্দীক্ব (রা.)-কে সকাল-সন্ধ্যায় আমল করার জন্য উল্লিখিত দু\'আটি শিক্ষা দেন এবং এ দু\'আ পড়ার ওসিয়ত করেন।',
              count: 'সকাল-সন্ধ্যায়\n১ বার',
            ),

// ১৫ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১৫ - ইয়া হাইয়্যু ইয়া কাইয়্যুম',
              arabic:
                  'يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ اَسْتَغِيْثُ ، اَصْلِحْ لِيْ شَاْنِيْ كُلَّهٗ وَلَا تَكِلْنِيْۤ اِلٰى نَفْسِيْ طَرْفَةَ عَيْنٍ',
              pronunciation:
                  'য়া- \'হায়্যু য়া- ক্বাইয়ূমু বিরাহমাতিকা আসতাগীস্, আসলি\'হ লী শাস্ত্রী কুল্লাহ্, ওয়া লা- তাকিলনী ইলা- নাফসী ত্বারফাতা \'আইন।',
              meaning:
                  'হে চিরঞ্জীব, হে চিরস্থায়ী! আমি আপনার অনুগ্রহে সাহায্য-উদ্ধার কামনা করি, আপনি আমার সার্বিক অবস্থা সংশোধন করে দিন, আর আমাকে আমার নিজের কাছে এক পলকের জন্যও সোপর্দ করবেন না।',
              reference: 'হাকিম: ২০০০',
              fazilat:
                  'নবী (সা.) ফাতিমা (রা.)-কে ওসিয়ত করেছেন, তিনি যেন সকালে ও সন্ধ্যায় এ বাক্যগুলো বলেন।',
              count: 'সকাল-সন্ধ্যায় \n১ বার',
            ),

// ১৬ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #১৬ - আল্লাহুম্মা মা আসবাহা বি মিন নি\'মাতিন',
              arabic:
                  'اَللّٰهُمَّ مَاۤ اَصْبَحَ بِيْ مِنْ نِّعْمَةٍ اَوْ بِاَحَدٍ مِّنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيْكَ لَكَ ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
              pronunciation:
                  'আল্লাহুম্মা মা- আসবা\'হা বী মিন নি\'মাতিন আও বি আ\'হাদিম মিন খালক্বিকা ফামিনকা ওয়া\'হদাকা লা- শারীকা লাকা, ফা লাকাল \'হামদু ওয়া লাকাশ্ শুকরু।\n\n(বিশেষ দ্রষ্টব্য: সন্ধ্যায় اَصْبَحَ এর স্থলে اَمْسٰى বলতে হবে)',
              meaning:
                  'হে আল্লাহ, আমি অথবা আপনার যে কোনো সৃষ্টি যে কোনো নিয়ামতসহ সকালে উপনীত হয়েছি, তা শুধুই আপনার তরফ থেকে, আপনার কোনো অংশীদার নেই। সুতরাং আপনার জন্যই প্রশংসা ও কৃতজ্ঞতা।',
              reference: 'ইবনে হিব্বান: ৮৬১',
              fazilat:
                  'সকালে এই বাক্যসমূহ বললে আল্লাহর প্রতি সারা দিনের শোকর-কৃতজ্ঞতা আদায় হয়ে যাবে, আর সন্ধ্যায় বললে রাতের শোকর আদায় হয়।',
              count: 'সকাল-সন্ধ্যায়\n১ বার',
            ),

// ১৭ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #১৭ - সুবহানাল্লাহি... আদাদা খালকিহি',
              arabic:
                  'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ عَدَدَ خَلْقِهٖ وَرِضَا نَفْسِهٖ وَزِنَةَ عَرْشِهٖ وَمِدَادَ كَلِمٰتِهٖ',
              pronunciation:
                  'সুবহা-নাল্লা-হি ওয়া বিহামদিহী, \'আদাদা খালকুিহী, ওয়া রিদ্বা- নাফসিহী, ওয়া যিনাতা \'আরশিহী, ওয়া মিদা-দা কালিমা-তিহ্।',
              meaning:
                  'আমি আল্লাহর প্রশংসাসহ পবিত্রতা ও মহিমা ঘোষণা করছি, তাঁর সৃষ্টির সংখ্যার সমান, তাঁর নিজের সন্তোষের সমান, তাঁর আরশের ওজনের সমান ও তাঁর বাণীসমূহ লেখার কালি সমপরিমাণ।',
              reference: 'মুসলিম: ২৭২৬',
              fazilat:
                  'ফজরের পর থেকে সকালে দীর্ঘ সময় পর্যন্ত সালাতের জায়গায় বসে থেকে আমল করার চেয়ে এই দু\'আ ১ বার বলা বেশি সাওয়াবের। সুতরাং অন্যান্য যিক্র ও দু\'আর পাশাপাশি উক্ত বাক্যগুলো বললে দ্বিগুণ আমলের সাওয়াব অর্জিত হবে ইনশা-আল্লাহ।',
              count: 'সকালে \n৩ বার',
            ),

// ১৮ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #১৮ - আল্লাহুম্মা ইন্নি আসআলুকা ইলমান নাফিআ',
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ عِلْمًا نَّافِعًا وَّرِزْقًا طَيِّبًا وَّعَمَلًا مُّتَقَبَّلًا',
              pronunciation:
                  'আল্লা-হুম্মা ইন্নী আসআলুকা \'ইলমান না-ফি\'আ, ওয়া রিযক্বান ত্বাইয়্যিবা, ওয়া \'আমালাম্ মুতাক্বাব্বালা।',
              meaning:
                  'হে আল্লাহ, আমি আপনার কাছে উপকারী জ্ঞান এবং হালাল রিযিক ও কবুলযোগ্য আমল চাই।',
              reference: 'ইবনে মাজাহ: ৯২৫',
              fazilat: 'রাসূলুল্লাহ (সা.) ফজরের সালাতের পর এ বাক্যগুলো বলতেন।',
              count: 'ফজরের সালাতে \n১ বার',
            ),

// ১৯ নং যিক্র
            
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #১৯ - আসবাহনা আলা ফিতরাতিল ইসলাম',
              arabic:
                  'اَصْبَحْنَا عَلٰى فِطْرَةِ الْاِسْلَامِ وَعَلٰى كَلِمَةِ الْاِخْلَاصِ وَعَلٰى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ وَعَلٰى مِلَّةِ اَبِيْنَاۤ اِبْرٰهِيْمَ حَنِيْفًا مُّسْلِمًا وَّمَا كَانَ مِنَ الْمُشْرِكِيْنَ',
              pronunciation:
                  'আসবা\'হনা \'আলা- ফিতরাতিল ইসলাম, ওয়া \'আলা- কালিমাতিল ইখলাস, ওয়া \'আলা- দীনি নাবিয়্যিনা মুহাম্মাদিন সাল্লাল্লাহু \'আলাইহি ওয়া সাল্লাম, ওয়া \'আলা- মিল্লাতি আবীনা- ইবরাহীমা \'হানীফাম্ মুসলিমা। ওয়া মা- কা-না মিনাল মুশরিকীন।\n\n(বিশেষ দ্রষ্টব্য: সন্ধ্যায় اَصْبَحْنَا আসবা\'হনা-এর স্থলে اَمْسَيْنَا আমসাইনা বলতে হবে)',
              meaning:
                  'আমরা সকাল যাপন করেছি ইসলামের প্রকৃতির ওপর, ইখলাসের বাণী (তাওহীদ)-এর ওপর এবং আমাদের নবী মুহাম্মাদ-এর দীনের ওপর ও আমাদের পিতা ইবরাহীমের আদর্শের ওপর- যিনি ছিলেন একনিষ্ঠ মুসলিম, তিনি মুশরিকদের অন্তর্ভুক্ত ছিলেন না।\n\n(সন্ধ্যায় অর্থ: আমরা সন্ধ্যায় উপনীত হলাম বলতে হবে।)',
              reference: 'মুসনাদে আহমাদ: ১৫৩৬৩',
              fazilat: 'নবী (সা.) এ বাক্যগুলো নিয়মিত বলতেন।',
              count: 'সকাল-সন্ধ্যায়\n১ বার',
            ),

// ২০ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #২০ - রাধীতু বিল্লাহি রাব্বা',
              arabic:
                  'رَضِيْتُ بِاللّٰهِ رَبًّا وَّبِالْاِسْلَامِ دِيْنًا وَّبِمُحَمَّدٍ نَبِيًّا',
              pronunciation:
                  'রাদ্বীতু বিল্লা-হি রাব্বা, ওয়াবিল ইসলা-মি দীনা, ওয়া বিমু\'হাম্মাদিন নাবিয়্যা।',
              meaning:
                  'আমি সন্তুষ্টচিত্তে আল্লাহকে রব, ইসলামকে দীন ও মুহাম্মাদ-কে নবীরূপে গ্রহণ করেছি।',
              reference: 'হাকেম: ১৯০৫; ইবনে মাজাহ: ৩৮৭০; আহমাদ',
              fazilat:
                  'যে ব্যক্তি এ দু\'আ সকাল ও সন্ধ্যায় ৩ বার করে বলবে, আল্লাহর কাছে তার প্রাপ্য হয়ে যায় কিয়ামাতের দিন তাকে সন্তুষ্ট করা।',
              count: 'সকাল-সন্ধ্যায় \n৩ বার',
            ),

// ২১ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'সকাল ও বিকালের যিক্‌র #২১ - আল্লাহুম্মা বিকা আসবাহনা',
              arabic:
                  'اَللّٰهُمَّ بِكَ اَصْبَحْنَا وَبِكَ اَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَاِلَيْكَ النُّشُوْرُ',
              pronunciation:
                  'আল্লা-হুম্মা বিকা আসবা\'না, ওয়া বিকা আমসাইনা, ওয়াবিকা না\'হয়া, ওয়াবিকা নামৃতু, ওয়া ইলাইকান নুশূর।\n\n(সন্ধ্যায় বলবেন: আল্লা-হুম্মা বিকা আমসাইনা, ওয়া বিকা আসবাহনা, ওয়াবিকা না\'হয়া, ওয়াবিকা নামৃতু, ওয়া ইলাইকাল মাসীর।)',
              meaning:
                  'হে আল্লাহ, আমরা আপনার অনুগ্রহে সকালে উপনীত হয়েছি এবং আপনারই অনুগ্রহে আমরা সন্ধ্যায় উপনীত হয়েছি। আর আপনার করুণায় আমরা জীবিত থাকি, আপনার ইচ্ছায়ই আমরা মৃত্যুবরণ করব; আর আপনার কাছেই পুনরুত্থিত হব।\n\n(সন্ধ্যায় অর্থ: হে আল্লাহ, আমরা আপনার অনুগ্রহে সন্ধ্যায় উপনীত হয়েছি এবং আপনারই অনুগ্রহে আমরা সকালে উপনীত হয়েছি। আর আপনার করুণায় আমরা জীবিত থাকি, আপনার ইচ্ছায়ই আমরা মৃত্যুবরণ করব; আর আপনার দিকেই প্রত্যাবর্তিত হব।)',
              reference: 'তিরমিযী: ৩৩৯১; ইবনে মাজাহ: ৩৮৬৮',
              fazilat: 'নবী (সা.) এ দু\'আ পড়ার প্রতি উৎসাহ দিয়েছেন।',
              count: 'সকাল-সন্ধ্যায়\n১ বার',
            ),

// ২২ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title:
                  'সকাল ও বিকালের যিক্‌র #২২ - তাসবীহ (সুবহানাল্লাহ, আলহামদুলিল্লাহ, আল্লাহু আকবার)',
              arabic:
                  'سُبْحَانَ اللّٰهِ\nاَلْحَمْدُ لِلّٰهِ\nاَللّٰهُ اَكْبَرُ',
              pronunciation:
                  '(১) সুবহানাল্লা-হ। (২) আল হামদু লিল্লা-হ। (৩) আল্লা-হু আকবার।',
              meaning:
                  '(১) আল্লাহর পবিত্রতা বর্ণনা করছি।\n(২) সকল প্রশংসা আল্লাহর।\n(৩) আল্লাহ সবচেয়ে মহান।',
              reference: 'আত তারগীব ওয়াত তারহীব: ৯৭৪; সুনানুল কুবরা: ১০৫৮৮',
              fazilat:
                  'সুবহানাল্লাহ: আল্লাহর রাস্তায় ১০০ উট দানের চেয়ে উত্তম।\nআলহামদুলিল্লাহ: জিহাদের জন্য আরোহণকারীসহ ১০০ অশ্ব দানের চেয়ে বেশি উত্তম।\nআল্লাহু আকবার: ১০০ কৃতদাস মুক্ত করার চেয়ে উত্তম।',
              count: 'ফজরের পরে \nমাগরিবের পূর্বে \nপ্রতিটি ১০০ বার করে',
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
                          'arabic'.tr(),
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
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      arabic,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontFamily: 'NotoNaskhArabic',
                        height: 2.0,
                        locale: const Locale('ar'),
                        fontFeatures: const [
                          FontFeature.enable('liga'),
                          FontFeature.enable('kern'),
                        ],
                      ),
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
                  color: cs.outline.withValues(alpha: 0.10),
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
                        'pronunciation'.tr(),
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
                        'meaning'.tr(),
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
                        'virtue'.tr(),
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
