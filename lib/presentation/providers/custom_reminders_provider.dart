import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      
      // Initialize notification service first
      await _notificationService.initialize();
      
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
      
      // Schedule notifications for enabled reminders
      await _scheduleAllReminders();
      
      // Sync to Firestore
      await _syncRemindersToCloud();
    } catch (e) {
      print('Error initializing custom reminders: $e');
    }
  }

  // Schedule all enabled reminders
  Future<void> _scheduleAllReminders() async {
    for (final reminder in state) {
      if (reminder.isEnabled) {
        await _scheduleReminder(reminder);
      }
    }
  }

  // Schedule single reminder for all its days
  Future<void> _scheduleReminder(CustomReminder reminder) async {
    final timeParts = reminder.time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    print('🔔 Scheduling reminder: ${reminder.title}');
    print('   Time: $hour:$minute');
    print('   Days: ${reminder.daysOfWeek}');

    for (final dayOfWeek in reminder.daysOfWeek) {
      print('   Scheduling for day $dayOfWeek...');
      await _notificationService.scheduleCustomReminder(
        id: reminder.id.hashCode + dayOfWeek, // Unique ID for each day
        title: reminder.title,
        body: reminder.description,
        hour: hour,
        minute: minute,
        dayOfWeek: dayOfWeek,
      );
    }
    print('✅ Reminder scheduled!');
  }

  // Cancel reminder notifications
  Future<void> _cancelReminder(CustomReminder reminder) async {
    for (final dayOfWeek in reminder.daysOfWeek) {
      await _notificationService.cancelNotification(reminder.id.hashCode + dayOfWeek);
    }
  }

  Future<void> _syncRemindersToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final remindersData = state.map((r) => r.toJson()).toList();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('custom_reminders')
          .set({
        'reminders': remindersData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Custom reminders synced to cloud');
    } catch (e) {
      print('❌ Failed to sync custom reminders: $e');
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
      state = [...state, reminder];
      
      // Schedule notification
      await _scheduleReminder(reminder);
      
      // Sync to cloud
      await _syncRemindersToCloud();
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

      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
      
      // Cancel old notification and schedule new one if enabled
      await _cancelReminder(existing);
      if (updated.isEnabled) {
        await _scheduleReminder(updated);
      }
      
      // Sync to cloud
      await _syncRemindersToCloud();
    } catch (e) {
      print('Error updating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      // Cancel notification first
      final reminder = state.firstWhere((r) => r.id == id, orElse: () => throw Exception('Reminder not found'));
      await _cancelReminder(reminder);
      
      _customRemindersBox.delete(id);
      state = state.where((r) => r.id != id).toList();
      
      // Sync to cloud
      await _syncRemindersToCloud();
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

      state = [
        for (final r in state)
          if (r.id == id) updated else r,
      ];
      
      // Schedule or cancel notification based on new state
      if (updated.isEnabled) {
        await _scheduleReminder(updated);
      } else {
        await _cancelReminder(updated);
      }
      
      // Sync to cloud
      await _syncRemindersToCloud();
    } catch (e) {
      print('Error toggling reminder: $e');
      rethrow;
    }
  }
}
