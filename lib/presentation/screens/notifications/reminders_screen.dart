import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/custom_reminder_model.dart';
import '../../providers/custom_reminders_provider.dart';
import '../../../services/notification_service.dart';

class RemindersScreenWidget extends ConsumerWidget {
  const RemindersScreenWidget({Key? key}) : super(key: key);

  static const List<String> daysOfWeek = ['রবি', 'সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminders = ref.watch(customRemindersProvider);
    const isDarkMode = true; // Always dark mode
    
    // Theme colors
    final bgColor = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF7F6F2);
    final appBarBg = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF7F6F2);
    final titleColor = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF1F1F1F);
    final emptyIconColor = isDarkMode ? Colors.grey[700] : const Color(0xFF9A9A9A);
    final emptyTextColor = isDarkMode ? Colors.grey[600] : const Color(0xFF6B6B6B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'কাস্টম রিমাইন্ডার',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Show pending notifications
          IconButton(
            icon: const Icon(Icons.list_alt, color: Color(0xFFD4AF37)),
            tooltip: 'পেন্ডিং নোটিফিকেশন',
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.initialize();
              final pending = await notificationService.getPendingNotifications();
              
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: Text(
                    'পেন্ডিং নোটিফিকেশন (${pending.length})',
                    style: const TextStyle(color: Color(0xFFD4AF37)),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    height: 300,
                    child: pending.isEmpty
                        ? const Center(
                            child: Text(
                              'কোনো পেন্ডিং নোটিফিকেশন নেই',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: pending.length,
                            itemBuilder: (context, index) {
                              final p = pending[index];
                              return ListTile(
                                title: Text(
                                  p.title ?? 'No title',
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'ID: ${p.id}\n${p.body ?? ''}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('বন্ধ', style: TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  ],
                ),
              );
            },
          ),
          // Test notification button
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
            tooltip: 'টেস্ট নোটিফিকেশন',
            onPressed: () async {
              final notificationService = NotificationService();
              await notificationService.initialize();
              
              // Immediate notification
              await notificationService.showTestNotification(
                title: '✅ নোটিফিকেশন কাজ করছে!',
                body: 'এটি একটি টেস্ট নোটিফিকেশন',
              );
              
              // Also schedule one for 10 seconds later
              await notificationService.scheduleTestNotification(
                seconds: 10,
                title: '⏰ ১০ সেকেন্ড পরের টেস্ট',
                body: 'স্কেজুল নোটিফিকেশন কাজ করছে!',
              );
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('টেস্ট নোটিফিকেশন পাঠানো হয়েছে! ১০ সেকেন্ড অপেক্ষা করুন'),
                  backgroundColor: Color(0xFFD4AF37),
                ),
              );
            },
          ),
        ],
      ),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: emptyIconColor),
                  const SizedBox(height: 16),
                  Text(
                    'কোনো কাস্টম রিমাইন্ডার নেই',
                    style: TextStyle(color: emptyTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ বাটন চেপে নতুন রিমাইন্ডার যোগ করুন',
                    style: TextStyle(color: emptyIconColor, fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminders[index];
                return _buildReminderCard(context, ref, reminder, isDarkMode);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddReminderDialog(context, ref, isDarkMode),
        backgroundColor: const Color(0xFFD4AF37),
        child: Icon(Icons.add, color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white),
      ),
    );
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, CustomReminder reminder, bool isDarkMode) {
    final daysText = reminder.daysOfWeek.map((day) => daysOfWeek[day]).join(', ');
    
    final cardBg = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final borderColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFD6C08A);
    final titleColor = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF1F1F1F);
    final subtitleColor = isDarkMode ? Colors.grey : const Color(0xFF6B6B6B);
    final inactiveThumb = isDarkMode ? const Color(0xFF666666) : const Color(0xFF9A9A9A);
    final inactiveTrack = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE6E1D5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: TextStyle(
                          color: titleColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.description,
                        style: TextStyle(color: subtitleColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (value) {
                    ref.read(customRemindersProvider.notifier).toggleReminder(reminder.id);
                  },
                  activeColor: const Color(0xFFD4AF37),
                  inactiveThumbColor: inactiveThumb,
                  inactiveTrackColor: inactiveTrack,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatStoredTime(reminder.time),
                  style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    daysText,
                    style: TextStyle(color: subtitleColor, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditReminderDialog(context, ref, reminder, isDarkMode),
                  icon: const Icon(Icons.edit, color: Color(0xFFD4AF37), size: 18),
                  label: const Text('Edit', style: TextStyle(color: Color(0xFFD4AF37))),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref, reminder.id, isDarkMode),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format stored time (HH:MM) to display format with AM/PM
  String _formatStoredTime(String time) {
    final parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    
    String period = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<int> selectedDays = [];
    
    final dialogBg = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final inputTextColor = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF1F1F1F);
    final hintColor = isDarkMode ? Colors.grey : const Color(0xFF9A9A9A);
    final chipBg = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF7F6F2);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: dialogBg,
          title: const Text(
            'নতুন রিমাইন্ডার',
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: inputTextColor),
                  decoration: InputDecoration(
                    hintText: 'শিরোনাম',
                    hintStyle: TextStyle(color: hintColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: inputTextColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'বিবরণ',
                    hintStyle: TextStyle(color: hintColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Custom Time Picker Button
                GestureDetector(
                  onTap: () {
                    _showCustomTimePicker(
                      context,
                      selectedTime,
                      isDarkMode,
                      (newTime) {
                        setState(() => selectedTime = newTime);
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimeOfDay(selectedTime),
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFFD4AF37)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'দিন নির্বাচন করুন:',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                    7,
                    (index) => FilterChip(
                      label: Text(
                        daysOfWeek[index],
                        style: TextStyle(
                          color: selectedDays.contains(index) 
                            ? (isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)
                            : const Color(0xFFD4AF37),
                          fontSize: 12,
                        ),
                      ),
                      selected: selectedDays.contains(index),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(index);
                          } else {
                            selectedDays.remove(index);
                          }
                        });
                      },
                      backgroundColor: chipBg,
                      selectedColor: const Color(0xFFD4AF37),
                      checkmarkColor: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: TextStyle(color: hintColor)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('সব ফিল্ড পূরণ করুন')),
                  );
                  return;
                }

                ref.read(customRemindersProvider.notifier).addReminder(
                  title: titleController.text,
                  description: descriptionController.text,
                  time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  daysOfWeek: selectedDays,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('রিমাইন্ডার যোগ হয়েছে'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: Text('যোগ করুন', style: TextStyle(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditReminderDialog(BuildContext context, WidgetRef ref, CustomReminder reminder, bool isDarkMode) {
    final titleController = TextEditingController(text: reminder.title);
    final descriptionController = TextEditingController(text: reminder.description);
    List<int> selectedDays = List.from(reminder.daysOfWeek);

    final timeParts = reminder.time.split(':');
    TimeOfDay selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    
    final dialogBg = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final inputTextColor = isDarkMode ? const Color(0xFFD4AF37) : const Color(0xFF1F1F1F);
    final hintColor = isDarkMode ? Colors.grey : const Color(0xFF9A9A9A);
    final chipBg = isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF7F6F2);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: dialogBg,
          title: const Text(
            'রিমাইন্ডার সম্পাদনা',
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: TextStyle(color: inputTextColor),
                  decoration: InputDecoration(
                    hintText: 'শিরোনাম',
                    hintStyle: TextStyle(color: hintColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(color: inputTextColor),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'বিবরণ',
                    hintStyle: TextStyle(color: hintColor),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Custom Time Picker Button
                GestureDetector(
                  onTap: () {
                    _showCustomTimePicker(
                      context,
                      selectedTime,
                      isDarkMode,
                      (newTime) {
                        setState(() => selectedTime = newTime);
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD4AF37)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimeOfDay(selectedTime),
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFFD4AF37)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'দিন নির্বাচন করুন:',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(
                    7,
                    (index) => FilterChip(
                      label: Text(
                        daysOfWeek[index],
                        style: TextStyle(
                          color: selectedDays.contains(index) 
                            ? (isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)
                            : const Color(0xFFD4AF37),
                          fontSize: 12,
                        ),
                      ),
                      selected: selectedDays.contains(index),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedDays.add(index);
                          } else {
                            selectedDays.remove(index);
                          }
                        });
                      },
                      backgroundColor: chipBg,
                      selectedColor: const Color(0xFFD4AF37),
                      checkmarkColor: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: TextStyle(color: hintColor)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(customRemindersProvider.notifier).updateReminder(
                  reminder.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  time: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  daysOfWeek: selectedDays,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('রিমাইন্ডার আপডেট হয়েছে'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: Text('আপডেট', style: TextStyle(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String reminderId, bool isDarkMode) {
    final dialogBg = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    final contentColor = isDarkMode ? Colors.grey : const Color(0xFF6B6B6B);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBg,
        title: const Text('রিমাইন্ডার ডিলিট করুন?', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Text('এটি বাতিল করা যাবে না।', style: TextStyle(color: contentColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('বাতিল', style: TextStyle(color: contentColor)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customRemindersProvider.notifier).deleteReminder(reminderId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('রিমাইন্ডার ডিলিট হয়েছে'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('ডিলিট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Format TimeOfDay to display string with AM/PM
  String _formatTimeOfDay(TimeOfDay time) {
    int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    String period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour12.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  /// Custom dropdown-based time picker (Hour 1-12, Minute 0-59, AM/PM)
  void _showCustomTimePicker(
    BuildContext context,
    TimeOfDay currentTime,
    bool isDarkMode,
    void Function(TimeOfDay) onTimeSelected,
  ) {
    // Convert 24-hour to 12-hour format
    int hour12 = currentTime.hourOfPeriod == 0 ? 12 : currentTime.hourOfPeriod;
    bool isAM = currentTime.period == DayPeriod.am;
    int minute = currentTime.minute;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          title: const Text(
            'সময় নির্বাচন করুন',
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Hour and Minute Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hour Dropdown (1-12)
                    _buildTimeDropdown(
                      value: hour12,
                      items: List.generate(12, (i) => i + 1),
                      isDarkMode: isDarkMode,
                      padZero: false,
                      onChanged: (val) => setState(() => hour12 = val!),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        ':',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Minute Dropdown (0-59)
                    _buildTimeDropdown(
                      value: minute,
                      items: List.generate(60, (i) => i),
                      isDarkMode: isDarkMode,
                      padZero: true,
                      onChanged: (val) => setState(() => minute = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // AM/PM Toggle (separate row)
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F6F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => isAM = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isAM ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(7),
                              bottomLeft: Radius.circular(7),
                            ),
                          ),
                          child: Text(
                            'AM',
                            style: TextStyle(
                              color: isAM ? const Color(0xFF0A0A0A) : const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => isAM = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: !isAM ? const Color(0xFFD4AF37) : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(7),
                              bottomRight: Radius.circular(7),
                            ),
                          ),
                          child: Text(
                            'PM',
                            style: TextStyle(
                              color: !isAM ? const Color(0xFF0A0A0A) : const Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF7F6F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Text(
                    '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} ${isAM ? "AM" : "PM"}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'বাতিল',
                style: TextStyle(color: isDarkMode ? Colors.grey : const Color(0xFF9A9A9A)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Convert back to 24-hour format
                int hour24;
                if (isAM) {
                  hour24 = hour12 == 12 ? 0 : hour12;
                } else {
                  hour24 = hour12 == 12 ? 12 : hour12 + 12;
                }
                onTimeSelected(TimeOfDay(hour: hour24, minute: minute));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: Text(
                'ঠিক আছে',
                style: TextStyle(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDropdown({
    required int value,
    required List<int> items,
    required bool isDarkMode,
    required bool padZero,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: DropdownButton<int>(
        value: value,
        dropdownColor: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD4AF37)),
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item,
            child: Text(
              padZero ? item.toString().padLeft(2, '0') : item.toString(),
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 18,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
