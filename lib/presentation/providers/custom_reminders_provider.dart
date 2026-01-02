import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/custom_reminder_model.dart';
import '../../services/notification_service.dart';

final customRemindersProvider = StateNotifierProvider<CustomRemindersNotifier, List<CustomReminder>>((ref) {
  return CustomRemindersNotifier();
});

class CustomRemindersNotifier extends StateNotifier<List<CustomReminder>> {
  late Box _customRemindersBox;
  final NotificationService _notificationService = NotificationService();

  CustomRemindersNotifier() : super([]) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _customRemindersBox = await Hive.openBox('custom_reminders');
      
      // Load existing reminders
      final List<CustomReminder> reminders = [];
      for (var key in _customRemindersBox.keys) {
        final data = _customRemindersBox.get(key);
        if (data != null) {
          try {
            final reminder = CustomReminder.fromJson(Map<String, dynamic>.from(data));
            reminders.add(reminder);
          } catch (e) {
            print('Error parsing reminder: $e');
          }
        }
      }
      state = reminders;
      
      // Schedule all enabled reminders
      for (var reminder in state) {
        if (reminder.isEnabled) {
          await _scheduleReminder(reminder);
        }
      }
    } catch (e) {
      print('Error initializing custom reminders: $e');
    }
  }

  Future<void> addReminder({
    required String title,
    required String description,
    required String time, // Format: "HH:mm"
    required List<int> daysOfWeek,
  }) async {
    try {
      final id = const Uuid().v4();
      final reminder = CustomReminder(
        id: id,
        title: title,
        description: description,
        time: time,
        isEnabled: true,
        daysOfWeek: daysOfWeek,
        createdAt: DateTime.now(),
      );

      _customRemindersBox.put(id, reminder.toJson());
      await _scheduleReminder(reminder);
      
      state = [...state, reminder];
    } catch (e) {
      print('Error adding reminder: $e');
      rethrow;
    }
  }

  Future<void> updateReminder(String id, {
    String? title,
    String? description,
    String? time,
    List<int>? daysOfWeek,
    bool? isEnabled,
  }) async {
    try {
      final existingData = _customRemindersBox.get(id);
      if (existingData == null) return;
      
      final existing = CustomReminder.fromJson(Map<String, dynamic>.from(existingData));

      final updated = existing.copyWith(
        title: title,
        description: description,
        time: time,
        daysOfWeek: daysOfWeek,
        isEnabled: isEnabled,
      );

      _customRemindersBox.put(id, updated.toJson());
      
      // Cancel old reminders
      await _cancelReminderNotifications(existing);
      
      // Schedule new ones if enabled
      if (updated.isEnabled) {
        await _scheduleReminder(updated);
      }

      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
    } catch (e) {
      print('Error updating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      final existingData = _customRemindersBox.get(id);
      if (existingData != null) {
        final existing = CustomReminder.fromJson(Map<String, dynamic>.from(existingData));
        await _cancelReminderNotifications(existing);
      }
      _customRemindersBox.delete(id);
      state = state.where((r) => r.id != id).toList();
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }

  Future<void> toggleReminder(String id) async {
    try {
      final existingData = _customRemindersBox.get(id);
      if (existingData == null) return;
      
      final existing = CustomReminder.fromJson(Map<String, dynamic>.from(existingData));
      final updated = existing.copyWith(isEnabled: !existing.isEnabled);
      
      _customRemindersBox.put(id, updated.toJson());

      if (updated.isEnabled) {
        await _scheduleReminder(updated);
      } else {
        await _cancelReminderNotifications(updated);
      }

      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
    } catch (e) {
      print('Error toggling reminder: $e');
      rethrow;
    }
  }

  Future<void> _scheduleReminder(CustomReminder reminder) async {
    try {
      final timeParts = reminder.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Generate a stable notification ID from reminder ID
      final baseNotificationId = reminder.id.hashCode.abs() % 100000;

      // Schedule for each selected day
      for (int day in reminder.daysOfWeek) {
        await _notificationService.scheduleCustomReminder(
          id: baseNotificationId + day,
          title: reminder.title,
          body: reminder.description,
          hour: hour,
          minute: minute,
          dayOfWeek: day,
        );
      }
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  Future<void> _cancelReminderNotifications(CustomReminder reminder) async {
    try {
      final baseNotificationId = reminder.id.hashCode.abs() % 100000;
      
      // Cancel for each day
      for (int day in reminder.daysOfWeek) {
        await _notificationService.cancelNotification(baseNotificationId + day);
      }
    } catch (e) {
      print('Error cancelling reminder notifications: $e');
    }
  }

  Future<void> rescheduleAll() async {
    try {
      for (var reminder in state) {
        if (reminder.isEnabled) {
          await _scheduleReminder(reminder);
        }
      }
    } catch (e) {
      print('Error rescheduling reminders: $e');
    }
  }
}
