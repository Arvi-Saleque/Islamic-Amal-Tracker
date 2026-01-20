import 'package:flutter/material.dart';
import '../../../data/models/custom_reminder.dart';
import '../../../services/daily_reminder_service.dart';

class CustomRemindersScreen extends StatefulWidget {
  final VoidCallback? onRemindersChanged;
  
  const CustomRemindersScreen({
    super.key,
    this.onRemindersChanged,
  });

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
    widget.onRemindersChanged?.call();
  }

  Future<void> _deleteReminder(CustomReminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'রিমাইন্ডার মুছুন?',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Text(
          '"${reminder.title}" মুছে ফেলতে চান?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছুন', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await DailyReminderService.deleteCustomReminder(reminder.id);
      await _loadReminders();
      widget.onRemindersChanged?.call();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('রিমাইন্ডার মুছে ফেলা হয়েছে'),
            backgroundColor: Color(0xFF2A2A2A),
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
            widget.onRemindersChanged?.call();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'কাস্টম রিমাইন্ডার',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddReminderScreen(),
        backgroundColor: const Color(0xFFD4AF37),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('নতুন রিমাইন্ডার'),
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
          const Text(
            'কোনো কাস্টম রিমাইন্ডার নেই',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'নতুন কাস্টম রিমাইন্ডার যোগ করুন',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 14,
            ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reminder.isEnabled 
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : const Color(0xFF2A2A2A),
        ),
      ),
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
                        ? const Color(0xFFD4AF37).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getReminderIcon(reminder),
                    color: reminder.isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
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
                          color: reminder.isEnabled ? Colors.white : Colors.grey,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.getTimeDisplayString(),
                        style: TextStyle(
                          color: reminder.isEnabled 
                              ? const Color(0xFFD4AF37) 
                              : Colors.grey.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                      if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.description!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
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
                      activeColor: const Color(0xFFD4AF37),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () => _deleteReminder(reminder),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
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
  final VoidCallback onSave;

  const AddCustomReminderScreen({
    super.key,
    this.existingReminder,
    required this.onSave,
  });

  @override
  State<AddCustomReminderScreen> createState() => _AddCustomReminderScreenState();
}

class _AddCustomReminderScreenState extends State<AddCustomReminderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  ReminderType _selectedType = ReminderType.beforePrayer;
  PrayerName _selectedPrayer = PrayerName.fajr;
  int _minutesOffset = 10;
  TimeOfDay _fixedTime = const TimeOfDay(hour: 9, minute: 0);
  List<int> _selectedDays = [];

  bool get _isEditing => widget.existingReminder != null;

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      final r = widget.existingReminder!;
      _titleController.text = r.title;
      _descriptionController.text = r.description ?? '';
      _selectedType = r.type;
      _selectedPrayer = r.prayer ?? PrayerName.fajr;
      _minutesOffset = r.minutesOffset.abs();
      if (r.fixedHour != null && r.fixedMinute != null) {
        _fixedTime = TimeOfDay(hour: r.fixedHour!, minute: r.fixedMinute!);
      }
      _selectedDays = List.from(r.repeatDays);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _fixedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFD4AF37),
              surface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() => _fixedTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('রিমাইন্ডারের নাম দিন'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final reminder = CustomReminder(
      id: widget.existingReminder?.id ?? CustomReminder.generateId(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      type: _selectedType,
      prayer: _selectedType != ReminderType.fixedTime ? _selectedPrayer : null,
      minutesOffset: _selectedType == ReminderType.beforePrayer 
          ? -_minutesOffset 
          : (_selectedType == ReminderType.afterPrayer ? _minutesOffset : 0),
      fixedHour: _selectedType == ReminderType.fixedTime ? _fixedTime.hour : null,
      fixedMinute: _selectedType == ReminderType.fixedTime ? _fixedTime.minute : null,
      isEnabled: widget.existingReminder?.isEnabled ?? true,
      repeatDays: _selectedDays,
      createdAt: widget.existingReminder?.createdAt,
    );

    if (_isEditing) {
      await DailyReminderService.updateCustomReminder(reminder);
    } else {
      await DailyReminderService.addCustomReminder(reminder);
    }

    widget.onSave();
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'রিমাইন্ডার আপডেট হয়েছে' : 'রিমাইন্ডার যোগ হয়েছে'),
          backgroundColor: const Color(0xFF2A2A2A),
        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'রিমাইন্ডার সম্পাদনা' : 'নতুন রিমাইন্ডার',
          style: const TextStyle(
            color: Color(0xFFD4AF37),
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
            // Title Input
            _buildSectionHeader('রিমাইন্ডারের টাইটেল'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'যেমন: তাহাজ্জুদ নামাজ, কুরআন তিলাওয়াত, ইত্যাদি',
              maxLines: 1,
            ),
            
            const SizedBox(height: 24),
            
            // Reminder Type Selection
            _buildSectionHeader('রিমাইন্ডারের সময়'),
            const SizedBox(height: 8),
            _buildTypeSelector(),
            
            const SizedBox(height: 16),
            
            // Time Configuration based on type
            if (_selectedType == ReminderType.fixedTime)
              _buildFixedTimeSelector()
            else
              _buildPrayerTimeSelector(),
            
            const SizedBox(height: 24),
            
            // Day Selection
            _buildSectionHeader('কোন কোন দিন'),
            const SizedBox(height: 8),
            _buildDaySelector(),
            
            const SizedBox(height: 24),
            
            // Description (optional)
            _buildSectionHeader('বিবরণ (ঐচ্ছিক)'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _descriptionController,
              hint: 'অতিরিক্ত নোট যোগ করুন...',
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveReminder,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'রিমাইন্ডার সেভ করুন' : '+ রিমাইন্ডার যোগ করুন'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFD4AF37),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          _buildTypeButton(ReminderType.beforePrayer, 'আগে'),
          _buildTypeButton(ReminderType.afterPrayer, 'পরে'),
          _buildTypeButton(ReminderType.fixedTime, 'নির্দিষ্ট'),
        ],
      ),
    );
  }

  Widget _buildTypeButton(ReminderType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedTimeSelector() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFD4AF37)),
                SizedBox(width: 12),
                Text(
                  'সময় নির্বাচন করুন',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  _formatTime(_fixedTime),
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.check, color: Colors.green, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prayer Selection
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PrayerName.values.map((prayer) {
              final isSelected = _selectedPrayer == prayer;
              return GestureDetector(
                onTap: () => setState(() => _selectedPrayer = prayer),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF3A3A3A),
                    ),
                  ),
                  child: Text(
                    CustomReminder.getPrayerBengaliName(prayer),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Minutes offset
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${CustomReminder.getPrayerBengaliName(_selectedPrayer)} এর $_minutesOffset মিনিট ${_selectedType == ReminderType.beforePrayer ? 'আগে' : 'পরে'}',
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFD4AF37),
                  inactiveTrackColor: const Color(0xFF3A3A3A),
                  thumbColor: const Color(0xFFD4AF37),
                  overlayColor: const Color(0xFFD4AF37).withOpacity(0.2),
                ),
                child: Slider(
                  value: _minutesOffset.toDouble(),
                  min: 0,
                  max: 60,
                  divisions: 12,
                  label: '$_minutesOffset মিনিট',
                  onChanged: (value) {
                    setState(() => _minutesOffset = value.toInt());
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0 মিনিট', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12)),
                  Text('60 মিনিট', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    final dayNames = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Wrap(
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
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF3A3A3A),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedDays.isEmpty 
                ? 'প্রতিদিন রিমাইন্ডার দিবে' 
                : 'নির্বাচিত দিন: ${_selectedDays.length}',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
