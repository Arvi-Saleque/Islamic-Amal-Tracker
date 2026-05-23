import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../data/models/custom_reminder.dart';
import '../../../services/daily_reminder_service.dart';
import '../statistics/widgets/digital_time_picker.dart';

class CustomRemindersScreen extends StatefulWidget {
  final Future<void> Function()? onRemindersChanged;

  const CustomRemindersScreen({super.key, this.onRemindersChanged});

  @override
  State<CustomRemindersScreen> createState() => _CustomRemindersScreenState();
}

class _CustomRemindersScreenState extends State<CustomRemindersScreen> {
  List<CustomReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    final reminders = await DailyReminderService.getCustomReminders();
    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  Future<void> _toggleReminder(CustomReminder reminder) async {
    final updated = reminder.copyWith(isEnabled: !reminder.isEnabled);
    await DailyReminderService.updateCustomReminder(updated);
    await _loadReminders();
    await widget.onRemindersChanged?.call();
  }

  Future<void> _deleteReminder(CustomReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: buildPremiumCard(
          context: context,
          radius: 16,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'custom_rem_delete_title'.tr(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'custom_rem_delete_confirm'.tr(
                  namedArgs: {'title': reminder.title},
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'cancel'.tr(),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'custom_rem_delete_tooltip'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await DailyReminderService.deleteCustomReminder(reminder.id);
      await _loadReminders();
      await widget.onRemindersChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('custom_rem_deleted'.tr()),
            backgroundColor: Theme.of(context).snackBarTheme.backgroundColor,
          ),
        );
      }
    }
  }

  void _openAddReminderScreen([CustomReminder? existingReminder]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomReminderScreen(
          existingReminder: existingReminder,
          onSave: () async {
            await _loadReminders();
            await widget.onRemindersChanged?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          'custom_rem_title'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : _reminders.isEmpty
          ? _buildEmptyState()
          : _buildRemindersList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddReminderScreen(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text('custom_rem_new'.tr()),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'custom_rem_empty'.tr(),
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'custom_rem_add_hint'.tr(),
            style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(CustomReminder reminder) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: buildPremiumCard(
        context: context,
        radius: 12,
        padding: EdgeInsets.zero,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openAddReminderScreen(reminder),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: reminder.isEnabled
                          ? primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getReminderIcon(reminder),
                      color: reminder.isEnabled ? primary : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: TextStyle(
                            color: reminder.isEnabled
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.getTimeDisplayString(),
                          style: TextStyle(
                            color: reminder.isEnabled
                                ? primary
                                : Colors.grey.withOpacity(0.7),
                            fontSize: 13,
                          ),
                        ),
                        if (reminder.description != null &&
                            reminder.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            reminder.description!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).extension<GradientColors>()!.bulletTextColor,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Switch(
                        value: reminder.isEnabled,
                        onChanged: (_) => _toggleReminder(reminder),
                        activeThumbColor: primary,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              color: primary,
                              size: 20,
                            ),
                            onPressed: () => _openAddReminderScreen(reminder),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'custom_rem_edit_tooltip'.tr(),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => _deleteReminder(reminder),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'custom_rem_delete_tooltip'.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getReminderIcon(CustomReminder reminder) {
    if (reminder.type == ReminderType.fixedTime) {
      return Icons.access_time;
    }
    switch (reminder.prayer) {
      case PrayerName.fajr:
        return Icons.wb_twilight;
      case PrayerName.dhuhr:
        return Icons.wb_sunny;
      case PrayerName.asr:
        return Icons.wb_sunny_outlined;
      case PrayerName.maghrib:
        return Icons.nights_stay;
      case PrayerName.isha:
        return Icons.nights_stay_outlined;
      default:
        return Icons.notifications;
    }
  }
}

// Add/Edit Custom Reminder Screen
class AddCustomReminderScreen extends StatefulWidget {
  final CustomReminder? existingReminder;
  final Future<void> Function() onSave;

  const AddCustomReminderScreen({
    super.key,
    this.existingReminder,
    required this.onSave,
  });

  @override
  State<AddCustomReminderScreen> createState() =>
      _AddCustomReminderScreenState();
}

class _AddCustomReminderScreenState extends State<AddCustomReminderScreen> {
  final _titleController = TextEditingController();

  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _selectedDays = [];

  bool get _isEditing => widget.existingReminder != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      final r = widget.existingReminder!;
      _titleController.text = r.title;
      if (r.fixedHour != null && r.fixedMinute != null) {
        _reminderTime = TimeOfDay(hour: r.fixedHour!, minute: r.fixedMinute!);
      }
      _selectedDays = List.from(r.repeatDays);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await DigitalTimePicker.show(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('custom_rem_name_required'.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('custom_rem_day_required'.tr()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final reminder = CustomReminder(
      id: widget.existingReminder?.id ?? CustomReminder.generateId(),
      title: _titleController.text.trim(),
      description: null,
      type: ReminderType.fixedTime,
      prayer: null,
      minutesOffset: 0,
      fixedHour: _reminderTime.hour,
      fixedMinute: _reminderTime.minute,
      isEnabled: widget.existingReminder?.isEnabled ?? true,
      repeatDays: _selectedDays,
      createdAt: widget.existingReminder?.createdAt,
    );

    try {
      if (_isEditing) {
        await DailyReminderService.updateCustomReminder(reminder);
      } else {
        await DailyReminderService.addCustomReminder(reminder);
      }
    } catch (e) {
      print('Error saving/scheduling custom reminder: $e');
      // Still proceed — data is saved even if notification scheduling fails
    }

    await widget.onSave();

    if (mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final snackBarBg = Theme.of(context).snackBarTheme.backgroundColor;
      final message = _isEditing
          ? 'custom_rem_updated'.tr()
          : 'custom_rem_added'.tr();
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: snackBarBg),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          _isEditing ? 'custom_rem_edit_title'.tr() : 'custom_rem_new'.tr(),
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input Section
            _buildSectionCard(
              icon: Icons.title,
              title: 'custom_rem_title_label'.tr(),
              child: TextField(
                controller: _titleController,
                maxLength: 50,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'custom_rem_title_hint'.tr(),
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  border: InputBorder.none,
                  counterStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time Selection Section
            _buildSectionCard(
              icon: Icons.access_time,
              title: 'custom_rem_time_label'.tr(),
              child: GestureDetector(
                onTap: _selectTime,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'custom_rem_time_select'.tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTime(_reminderTime),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Day Selection Section
            _buildSectionCard(
              icon: Icons.calendar_today,
              title: 'custom_rem_repeat_days'.tr(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDaySelector(),
                  if (_selectedDays.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'custom_rem_day_required'.tr(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                icon: const Icon(Icons.add),
                label: Text(
                  _isEditing ? 'custom_rem_save'.tr() : 'custom_rem_save'.tr(),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return buildPremiumCard(
      context: context,
      radius: 12,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final dayNames = [
      'weekday_mon_short'.tr(),
      'weekday_tue_short'.tr(),
      'weekday_wed_short'.tr(),
      'weekday_thu_short'.tr(),
      'weekday_fri_short'.tr(),
      'weekday_sat_short'.tr(),
      'weekday_sun_short'.tr(),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1;
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedDays.remove(day);
              } else {
                _selectedDays.add(day);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              dayNames[index],
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }),
    );
  }
}
