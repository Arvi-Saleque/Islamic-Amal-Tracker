import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/custom_reminder_model.dart';
import '../../providers/custom_reminders_provider.dart';

class RemindersScreenWidget extends ConsumerWidget {
  const RemindersScreenWidget({Key? key}) : super(key: key);

  static const List<String> daysOfWeek = ['\u09b0\u09ac\u09bf', '\u09b8\u09cb\u09ae', '\u09ae\u0999\u09cd\u0997\u09b2', '\u09ac\u09c1\u09a7', '\u09ac\u09c3\u09b9', '\u09b6\u09c1\u0995\u09cd\u09b0', '\u09b6\u09a8\u09bf'];

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '\u0995\u09be\u09b8\u09cd\u099f\u09ae \u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: emptyIconColor),
                  const SizedBox(height: 16),
                  Text(
                    '\u0995\u09cb\u09a8\u09cb \u0995\u09be\u09b8\u09cd\u099f\u09ae \u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09a8\u09c7\u0987',
                    style: TextStyle(color: emptyTextColor, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+ \u09ac\u09be\u099f\u09a8 \u099a\u09c7\u09aa\u09c7 \u09a8\u09a4\u09c1\u09a8 \u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09af\u09cb\u0997 \u0995\u09b0\u09c1\u09a8',
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.description,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (_) => ref.read(customRemindersProvider.notifier).toggleReminder(reminder.id),
                  activeColor: const Color(0xFFD4AF37),
                  inactiveThumbColor: inactiveThumb,
                  inactiveTrackColor: inactiveTrack,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text(
                        reminder.time,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: subtitleColor),
                      const SizedBox(width: 4),
                      Text(
                        daysText,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditReminderDialog(context, ref, reminder, isDarkMode),
                  icon: const Icon(Icons.edit, size: 18, color: Color(0xFFD4AF37)),
                  label: const Text(
                    '\u09b8\u09ae\u09cd\u09aa\u09be\u09a6\u09a8\u09be',
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteDialog(context, ref, reminder.id, isDarkMode),
                  icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text(
                    '\u09a1\u09bf\u09b2\u09bf\u099f',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
            '\u09a8\u09a4\u09c1\u09a8 \u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0',
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
                    hintText: '\u09b6\u09bf\u09b0\u09cb\u09a8\u09be\u09ae',
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
                    hintText: '\u09ac\u09bf\u09ac\u09b0\u09a3',
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
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: isDarkMode 
                            ? ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFD4AF37),
                                  onPrimary: Color(0xFF0A0A0A),
                                  surface: Color(0xFF1A1A1A),
                                ),
                              )
                            : ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFD4AF37),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFFF7F6F2),
                                ),
                              ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
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
                          '\u09b8\u09ae\u09af\u09bc: ${selectedTime.format(context)}',
                          style: const TextStyle(color: Color(0xFFD4AF37)),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFFD4AF37)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '\u09a6\u09bf\u09a8 \u09a8\u09bf\u09b0\u09cd\u09ac\u09be\u099a\u09a8 \u0995\u09b0\u09c1\u09a8:',
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
              child: Text('\u09ac\u09be\u09a4\u09bf\u09b2', style: TextStyle(color: hintColor)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isEmpty || descriptionController.text.isEmpty || selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('\u09b8\u09ac \u09ab\u09bf\u09b2\u09cd\u09a1 \u09aa\u09c2\u09b0\u09a3 \u0995\u09b0\u09c1\u09a8')),
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
                    content: Text('\u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09af\u09cb\u0997 \u09b9\u09af\u09bc\u09c7\u099b\u09c7'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: Text('\u09af\u09cb\u0997 \u0995\u09b0\u09c1\u09a8', style: TextStyle(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)),
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
            '\u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09b8\u09ae\u09cd\u09aa\u09be\u09a6\u09a8\u09be',
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
                    hintText: '\u09b6\u09bf\u09b0\u09cb\u09a8\u09be\u09ae',
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
                    hintText: '\u09ac\u09bf\u09ac\u09b0\u09a3',
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
                GestureDetector(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                      builder: (context, child) {
                        return Theme(
                          data: isDarkMode 
                            ? ThemeData.dark().copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFFD4AF37),
                                  onPrimary: Color(0xFF0A0A0A),
                                  surface: Color(0xFF1A1A1A),
                                ),
                              )
                            : ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFFD4AF37),
                                  onPrimary: Colors.white,
                                  surface: Color(0xFFF7F6F2),
                                ),
                              ),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() => selectedTime = time);
                    }
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
                          '\u09b8\u09ae\u09af\u09bc: ${selectedTime.format(context)}',
                          style: const TextStyle(color: Color(0xFFD4AF37)),
                        ),
                        const Icon(Icons.access_time, color: Color(0xFFD4AF37)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '\u09a6\u09bf\u09a8 \u09a8\u09bf\u09b0\u09cd\u09ac\u09be\u099a\u09a8 \u0995\u09b0\u09c1\u09a8:',
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
              child: Text('\u09ac\u09be\u09a4\u09bf\u09b2', style: TextStyle(color: hintColor)),
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
                    content: Text('\u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u0986\u09aa\u09a1\u09c7\u099f \u09b9\u09af\u09bc\u09c7\u099b\u09c7'),
                    backgroundColor: Color(0xFFD4AF37),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
              ),
              child: Text('\u0986\u09aa\u09a1\u09c7\u099f', style: TextStyle(color: isDarkMode ? const Color(0xFF0A0A0A) : Colors.white)),
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
        title: const Text('\u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09a1\u09bf\u09b2\u09bf\u099f \u0995\u09b0\u09c1\u09a8?', style: TextStyle(color: Color(0xFFD4AF37))),
        content: Text('\u098f\u099f\u09bf \u09ac\u09be\u09a4\u09bf\u09b2 \u0995\u09b0\u09be \u09af\u09be\u09ac\u09c7 \u09a8\u09be\u0964', style: TextStyle(color: contentColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('\u09ac\u09be\u09a4\u09bf\u09b2', style: TextStyle(color: contentColor)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(customRemindersProvider.notifier).deleteReminder(reminderId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('\u09b0\u09bf\u09ae\u09be\u0987\u09a8\u09cd\u09a1\u09be\u09b0 \u09a1\u09bf\u09b2\u09bf\u099f \u09b9\u09af\u09bc\u09c7\u099b\u09c7'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('\u09a1\u09bf\u09b2\u09bf\u099f', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
