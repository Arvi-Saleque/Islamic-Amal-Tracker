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
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[0],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[1],
                Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).extension<GradientColors>()!.appBarBorder,
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
            colors: Theme.of(
              context,
            ).extension<GradientColors>()!.backgroundGradient,
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
      padding: const EdgeInsets.only(
        left: _pagePad,
        right: _pagePad,
        bottom: 14,
      ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: theme
                          .extension<GradientColors>()!
                          .innerCardGradient,
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

  Widget _buildChecklistItem(DailyAmalItem item, DailyAmalNotifier notifier) {
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

        InputDecoration deco({required String hint, IconData? icon}) {
          return InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fieldFill,
            prefixIcon: icon == null
                ? null
                : Icon(icon, color: cs.onSurfaceVariant),
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
                  decoration: deco(
                    hint: 'daily_amal_name_hint'.tr(),
                    icon: Icons.edit_outlined,
                  ),
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
                          icon: Icons.category_outlined,
                        ),
                        items: _categoryNames.entries
                            .where((e) => e.key != 'all')
                            .map(
                              (e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(
                                  e.value,
                                  style: TextStyle(color: cs.onSurface),
                                ),
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
                        foregroundColor: theme
                            .extension<GradientColors>()!
                            .onPrimaryText,
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

                        notifier.addCustomItem(title, selectedCategory);
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
      backgroundColor: Theme.of(
        context,
      ).extension<GradientColors>()!.onPrimaryText.withOpacity(0),
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
                        title: 'daily_amal_info_how_title'.tr(),
                        content: 'daily_amal_info_how_body'.tr(),
                      ),
                      const SizedBox(height: 20),

                      // Morning-Evening Adhkar Section (Expandable)
                      _buildExpandableDuaSection(),
                      const SizedBox(height: 18),

                      // Miswak section
                      _buildSectionHeader(
                        icon: Icons.brush,
                        title: 'daily_amal_info_miswak_section'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_miswak_hadith1_text'.tr(),
                        reference: 'daily_amal_info_miswak_hadith1_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_miswak_hadith2_text'.tr(),
                        reference: 'daily_amal_info_miswak_hadith2_ref'.tr(),
                      ),
                      const SizedBox(height: 18),

                      // Surah section
                      _buildSectionHeader(
                        icon: Icons.menu_book,
                        title: 'daily_amal_info_surah_section'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_surah_hadith1_text'.tr(),
                        reference: 'daily_amal_info_surah_hadith1_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_surah_hadith2_text'.tr(),
                        reference: 'daily_amal_info_surah_hadith2_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_surah_hadith3_text'.tr(),
                        reference: 'daily_amal_info_surah_hadith3_ref'.tr(),
                      ),
                      const SizedBox(height: 18),

                      // Dua section
                      _buildSectionHeader(
                        icon: Icons.favorite,
                        title: 'daily_amal_info_dua_section'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_dua_hadith1_text'.tr(),
                        reference: 'daily_amal_info_dua_hadith1_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_dua_hadith2_text'.tr(),
                        reference: 'daily_amal_info_dua_hadith2_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_dua_hadith3_text'.tr(),
                        reference: 'daily_amal_info_dua_hadith3_ref'.tr(),
                      ),
                      const SizedBox(height: 18),

                      // Nafal prayer section
                      _buildSectionHeader(
                        icon: Icons.mosque,
                        title: 'daily_amal_info_nafl_section'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_nafl_hadith1_text'.tr(),
                        reference: 'daily_amal_info_nafl_hadith1_ref'.tr(),
                      ),
                      const SizedBox(height: 12),

                      _buildHadithCard(
                        hadith: 'daily_amal_info_nafl_hadith2_text'.tr(),
                        reference: 'daily_amal_info_nafl_hadith2_ref'.tr(),
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

  Widget _buildHadithCard({required String hadith, required String reference}) {
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
                child: Icon(
                  Icons.format_quote_rounded,
                  color: cs.primary,
                  size: 14,
                ),
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

  Widget _buildSectionHeader({required IconData icon, required String title}) {
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
            child: Icon(
              icon,
              color: Theme.of(
                context,
              ).extension<GradientColors>()!.onPrimaryText,
              size: 18,
            ),
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
            child: Icon(Icons.wb_twilight, color: cs.primary, size: 20),
          ),
          title: Text(
            'daily_amal_adhkar_title'.tr(),
            style: TextStyle(
              color: cs.primary,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'daily_amal_adhkar_subtitle'.tr(),
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
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
                    'daily_amal_adhkar_main_title'.tr(),
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
                    'daily_amal_adhkar_author'.tr(),
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
                    'daily_amal_adhkar_note'.tr(),
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
              title: 'dhikr_morning_1_title'.tr(),
              arabic:
                  'اَللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ۚ اَلْحَيُّ الْقَيُّوْمُ ۚ لَا تَاْخُذُهٗ سِنَةٌ وَّلَا نَوْمٌ ۚ لَهٗ مَا فِي السَّمٰوٰتِ وَمَا فِي الْاَرْضِ ۗ مَنْ ذَا الَّذِيْ يَشْفَعُ عِنْدَهٗٓ اِلَّا بِاِذْنِهٖ ۗ يَعْلَمُ مَا بَيْنَ اَيْدِيْهِمْ وَمَا خَلْفَهُمْ ۚ وَلَا يُحِيْطُوْنَ بِشَيْءٍ مِّنْ عِلْمِهٖٓ اِلَّا بِمَا شَاۤءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمٰوٰتِ وَالْاَرْضَ ۚ وَلَا يَئُوْدُهٗ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيْمُ',
              pronunciation: 'dhikr_morning_1_pron'.tr(),
              meaning: 'dhikr_morning_1_meaning'.tr(),
              reference: 'dhikr_morning_1_ref'.tr(),
              fazilat: 'dhikr_morning_1_fazilat'.tr(),
              count: 'dhikr_morning_1_count'.tr(),
            ),
            const SizedBox(height: 12),
            // ২ নং যিক্র: ৩ কুল (ইখলাস, ফালাক্ব ও নাস)
            const SizedBox(height: 14),
            _buildExpandableDuaCard(
              title: 'dhikr_morning_2_title'.tr(),
              arabic:
                  'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ هُوَ اللّٰهُ اَحَدٌ ۚ اَللّٰهُ الصَّمَدُ ۚ لَمْ يَلِدْ وَلَمْ يُوْلَدْ ۙ وَلَمْ يَكُنْ لَّهٗ كُفُوًا اَحَدٌ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ الْفَلَقِ ۙ مِنْ شَرِّ مَا خَلَقَ ۙ وَمِنْ شَرِّ غَاسِقٍ اِذَا وَقَبَ ۙ وَمِنْ شَرِّ النَّفّٰثٰتِ فِي الْعُقَدِ ۙ وَمِنْ شَرِّ حَاسِدٍ اِذَا حَسَدَ\n\nبِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ\nقُلْ اَعُوْذُ بِرَبِّ النَّاسِ ۙ مَلِكِ النَّاسِ ۙ اِلٰهِ النَّاسِ ۙ مِنْ شَرِّ الْوَسْوَاسِ  الْخَنَّاسِ ۖ الَّذِيْ يُوَسْوِسُ فِيْ صُدُوْرِ النَّاسِ ۙ مِنَ الْجِنَّةِ وَالنَّاسِ',
              pronunciation: 'dhikr_morning_2_pron'.tr(),
              meaning: 'dhikr_morning_2_meaning'.tr(),
              reference: 'dhikr_morning_2_ref'.tr(),
              fazilat: 'dhikr_morning_2_fazilat'.tr(),
              count: 'dhikr_morning_2_count'.tr(),
            ),

            // ৩ নং যিক্র: হাসবিয়াল্লাহু
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_3_title'.tr(),
              arabic:
                  'حَسْبِيَ اللّٰهُ لَاۤ اِلٰهَ اِلَّا هُوَ ؕ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيْمِ',
              pronunciation: 'dhikr_morning_3_pron'.tr(),
              meaning: 'dhikr_morning_3_meaning'.tr(),
              reference: 'dhikr_morning_3_ref'.tr(),
              fazilat: 'dhikr_morning_3_fazilat'.tr(),
              count: 'dhikr_morning_3_count'.tr(),
            ),

            // ৪ নং যিক্র: সায়্যিদুল ইস্তিগফার
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_4_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اَنْتَ رَبِّيْ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ ؕ خَلَقْتَنِيْ وَاَنَا عَبْدُكَ وَاَنَا عَلٰى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ۚ اَعُوْذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ۚ اَبُوْءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَاَبُوْءُ بِذَنْبِيْ فَاغْفِرْ لِيْ فَاِنَّهٗ لَا يَغْفِرُ الذُّنُوْبَ اِلَّاۤ اَنْتَ',
              pronunciation: 'dhikr_morning_4_pron'.tr(),
              meaning: 'dhikr_morning_4_meaning'.tr(),
              reference: 'dhikr_morning_4_ref'.tr(),
              fazilat: 'dhikr_morning_4_fazilat'.tr(),
              count: 'dhikr_morning_4_count'.tr(),
            ),

            // ৫ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_5_title'.tr(),
              arabic:
                  'بِسْمِ اللّٰهِ الَّذِيْ لَا يَضُرُّ مَعَ اسْمِهٖ شَيْءٌ فِي الْاَرْضِ وَلَا فِي السَّمَاۤءِ وَهُوَ السَّمِيْعُ الْعَلِيْمُ',
              pronunciation: 'dhikr_morning_5_pron'.tr(),
              meaning: 'dhikr_morning_5_meaning'.tr(),
              reference: 'dhikr_morning_5_ref'.tr(),
              fazilat: 'dhikr_morning_5_fazilat'.tr(),
              count: 'dhikr_morning_5_count'.tr(),
            ),

            // ৬ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_6_title'.tr(),
              arabic:
                  'لَاۤ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ',
              pronunciation: 'dhikr_morning_6_pron'.tr(),
              meaning: 'dhikr_morning_6_meaning'.tr(),
              reference: 'dhikr_morning_6_ref'.tr(),
              fazilat: 'dhikr_morning_6_fazilat'.tr(),
              count: 'dhikr_morning_6_count'.tr(),
            ),

            // ৭ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_7_title'.tr(),
              arabic: 'اَللّٰهُمَّ اَجِرْنِيْ مِنَ النَّارِ',
              pronunciation: 'dhikr_morning_7_pron'.tr(),
              meaning: 'dhikr_morning_7_meaning'.tr(),
              reference: 'dhikr_morning_7_ref'.tr(),
              fazilat: 'dhikr_morning_7_fazilat'.tr(),
              count: 'dhikr_morning_7_count'.tr(),
            ),

            // ৮ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_8_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْاٰخِرَةِ ، اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِيْ دِيْنِيْ وَدُنْيَايَ وَاَهْلِيْ وَمَالِيْ ، اَللّٰهُمَّ اسْتُرْ عَوْرٰتِيْ وَاٰمِنْ رَوْعٰتِيْ ، اَللّٰهُمَّ احْفَظْنِيْ مِنْ بَيْنِ يَدَيَّ وَمِنْ خَلْفِيْ وَعَنْ يَّمِيْنِيْ وَعَنْ شِمَالِيْ وَمِنْ فَوْقِيْ وَاَعُوْذُ بِعَظَمَتِكَ اَنْ اُغْتَالَ مِنْ تَحْتِيْ',
              pronunciation: 'dhikr_morning_8_pron'.tr(),
              meaning: 'dhikr_morning_8_meaning'.tr(),
              reference: 'dhikr_morning_8_ref'.tr(),
              fazilat: 'dhikr_morning_8_fazilat'.tr(),
              count: 'dhikr_morning_8_count'.tr(),
            ),

            // ৯ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_9_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَصْبَحْتُ اُشْهِدُكَ وَاُشْهِدُ حَمَلَةَ عَرْشِكَ وَمَلٰٓئِكَتَكَ وَجَمِيْعَ خَلْقِكَ ، بِاَنَّكَ اَنْتَ اللّٰهُ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ وَحْدَكَ لَا شَرِيْكَ لَكَ وَاَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُوْلُكَ',
              pronunciation: 'dhikr_morning_9_pron'.tr(),
              meaning: 'dhikr_morning_9_meaning'.tr(),
              reference: 'dhikr_morning_9_ref'.tr(),
              fazilat: 'dhikr_morning_9_fazilat'.tr(),
              count: 'dhikr_morning_9_count'.tr(),
            ),

            // ১০ নং যিক্র
            const SizedBox(height: 14),
            _buildExpandableDuaCard(
              title: 'dhikr_morning_10_title'.tr(),
              arabic:
                  'اَعُوْذُ بِكَلِمٰتِ اللّٰهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
              pronunciation: 'dhikr_morning_10_pron'.tr(),
              meaning: 'dhikr_morning_10_meaning'.tr(),
              reference: 'dhikr_morning_10_ref'.tr(),
              fazilat: 'dhikr_morning_10_fazilat'.tr(),
              count: 'dhikr_morning_10_count'.tr(),
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
              title: 'dhikr_morning_14_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ فَاطِرَ السَّمٰوٰتِ وَالْاَرْضِ عَالِمَ الْغَيْبِ وَالشَّهَادَةِ لَاۤ اِلٰهَ اِلَّاۤ اَنْتَ رَبَّ كُلِّ شَيْءٍ وَّمَلِيْكَهٗ ، اَعُوْذُ بِكَ مِنْ شَرِّ نَفْسِيْ وَمِنْ شَرِّ الشَّيْطٰنِ وَشِرْكِهٖ وَاَنْ اَقْتَرِفَ عَلٰى نَفْسِيْ سُوْٓءًا اَوْ اَجُرَّهٗۤ اِلٰى مُسْلِمٍ',
              pronunciation: 'dhikr_morning_14_pron'.tr(),
              meaning: 'dhikr_morning_14_meaning'.tr(),
              reference: 'dhikr_morning_14_ref'.tr(),
              fazilat: 'dhikr_morning_14_fazilat'.tr(),
              count: 'dhikr_morning_14_count'.tr(),
            ),

            // ১৫ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_15_title'.tr(),
              arabic:
                  'يَا حَيُّ يَا قَيُّوْمُ بِرَحْمَتِكَ اَسْتَغِيْثُ ، اَصْلِحْ لِيْ شَاْنِيْ كُلَّهٗ وَلَا تَكِلْنِيْۤ اِلٰى نَفْسِيْ طَرْفَةَ عَيْنٍ',
              pronunciation: 'dhikr_morning_15_pron'.tr(),
              meaning: 'dhikr_morning_15_meaning'.tr(),
              reference: 'dhikr_morning_15_ref'.tr(),
              fazilat: 'dhikr_morning_15_fazilat'.tr(),
              count: 'dhikr_morning_15_count'.tr(),
            ),

            // ১৬ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_16_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ مَاۤ اَصْبَحَ بِيْ مِنْ نِّعْمَةٍ اَوْ بِاَحَدٍ مِّنْ خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيْكَ لَكَ ، فَلَكَ الْحَمْدُ وَلَكَ الشُّكْرُ',
              pronunciation: 'dhikr_morning_16_pron'.tr(),
              meaning: 'dhikr_morning_16_meaning'.tr(),
              reference: 'dhikr_morning_16_ref'.tr(),
              fazilat: 'dhikr_morning_16_fazilat'.tr(),
              count: 'dhikr_morning_16_count'.tr(),
            ),

            // ১৭ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_17_title'.tr(),
              arabic:
                  'سُبْحَانَ اللّٰهِ وَبِحَمْدِهٖ عَدَدَ خَلْقِهٖ وَرِضَا نَفْسِهٖ وَزِنَةَ عَرْشِهٖ وَمِدَادَ كَلِمٰتِهٖ',
              pronunciation: 'dhikr_morning_17_pron'.tr(),
              meaning: 'dhikr_morning_17_meaning'.tr(),
              reference: 'dhikr_morning_17_ref'.tr(),
              fazilat: 'dhikr_morning_17_fazilat'.tr(),
              count: 'dhikr_morning_17_count'.tr(),
            ),

            // ১৮ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_18_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ اِنِّيْۤ اَسْاَلُكَ عِلْمًا نَّافِعًا وَّرِزْقًا طَيِّبًا وَّعَمَلًا مُّتَقَبَّلًا',
              pronunciation: 'dhikr_morning_18_pron'.tr(),
              meaning: 'dhikr_morning_18_meaning'.tr(),
              reference: 'dhikr_morning_18_ref'.tr(),
              fazilat: 'dhikr_morning_18_fazilat'.tr(),
              count: 'dhikr_morning_18_count'.tr(),
            ),

            // ১৯ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_19_title'.tr(),
              arabic:
                  'اَصْبَحْنَا عَلٰى فِطْرَةِ الْاِسْلَامِ وَعَلٰى كَلِمَةِ الْاِخْلَاصِ وَعَلٰى دِيْنِ نَبِيِّنَا مُحَمَّدٍ صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ وَعَلٰى مِلَّةِ اَبِيْنَاۤ اِبْرٰهِيْمَ حَنِيْفًا مُّسْلِمًا وَّمَا كَانَ مِنَ الْمُشْرِكِيْنَ',
              pronunciation: 'dhikr_morning_19_pron'.tr(),
              meaning: 'dhikr_morning_19_meaning'.tr(),
              reference: 'dhikr_morning_19_ref'.tr(),
              fazilat: 'dhikr_morning_19_fazilat'.tr(),
              count: 'dhikr_morning_19_count'.tr(),
            ),

            // ২০ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_20_title'.tr(),
              arabic:
                  'رَضِيْتُ بِاللّٰهِ رَبًّا وَّبِالْاِسْلَامِ دِيْنًا وَّبِمُحَمَّدٍ نَبِيًّا',
              pronunciation: 'dhikr_morning_20_pron'.tr(),
              meaning: 'dhikr_morning_20_meaning'.tr(),
              reference: 'dhikr_morning_20_ref'.tr(),
              fazilat: 'dhikr_morning_20_fazilat'.tr(),
              count: 'dhikr_morning_20_count'.tr(),
            ),

            // ২১ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_21_title'.tr(),
              arabic:
                  'اَللّٰهُمَّ بِكَ اَصْبَحْنَا وَبِكَ اَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوْتُ وَاِلَيْكَ النُّشُوْرُ',
              pronunciation: 'dhikr_morning_21_pron'.tr(),
              meaning: 'dhikr_morning_21_meaning'.tr(),
              reference: 'dhikr_morning_21_ref'.tr(),
              fazilat: 'dhikr_morning_21_fazilat'.tr(),
              count: 'dhikr_morning_21_count'.tr(),
            ),

            // ২২ নং যিক্র
            const SizedBox(height: 14),

            _buildExpandableDuaCard(
              title: 'dhikr_morning_22_title'.tr(),
              arabic:
                  'سُبْحَانَ اللّٰهِ\nاَلْحَمْدُ لِلّٰهِ\nاَللّٰهُ اَكْبَرُ',
              pronunciation: 'dhikr_morning_22_pron'.tr(),
              meaning: 'dhikr_morning_22_meaning'.tr(),
              reference: 'dhikr_morning_22_ref'.tr(),
              fazilat: 'dhikr_morning_22_fazilat'.tr(),
              count: 'dhikr_morning_22_count'.tr(),
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
          leading: Icon(Icons.format_quote, color: cs.primary, size: 20),
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
                border: Border.all(color: cs.outline.withOpacity(0.15)),
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
                          horizontal: 8,
                          vertical: 3,
                        ),
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
                border: Border.all(color: cs.outline.withValues(alpha: 0.10)),
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
                border: Border.all(color: cs.outline.withOpacity(0.10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.translate, color: cs.secondary, size: 14),
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
                border: Border.all(color: cs.primary.withOpacity(0.15)),
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
                      Icon(Icons.star, color: cs.primary, size: 14),
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
