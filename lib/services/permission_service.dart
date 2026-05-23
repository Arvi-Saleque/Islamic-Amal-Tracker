import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'daily_reminder_service.dart';
import '../presentation/screens/settings/reminder_setting_screen.dart';

class PermissionService {
  static const String _notificationPopupShownKey = 'notification_popup_shown';

  /// Show notification permission popup after location permission is granted
  static Future<void> showNotificationPermissionPopup(
    BuildContext context,
  ) async {
    if (!Platform.isAndroid) return;

    // Check if popup was already shown
    final prefs = await SharedPreferences.getInstance();
    final alreadyShown = prefs.getBool(_notificationPopupShownKey) ?? false;
    if (alreadyShown) return;

    // Check if notification + exact alarm permission is already granted
    final notification = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;

    if (notification.isGranted && alarm.isGranted) return;

    // Mark as shown
    await prefs.setBool(_notificationPopupShownKey, true);

    // Wait a moment for UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    if (context.mounted) {
      _showNotificationReminderDialog(context);
    }
  }

  static void _showNotificationReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'রিমাইন্ডার সেটআপ করুন',
                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'নামাজের সময়, দৈনিক আমল ও যিকিরের রিমাইন্ডার পেতে নোটিফিকেশন পারমিশন দিন।',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
                SizedBox(width: 8),
                Text(
                  'নামাজের রিমাইন্ডার',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
                SizedBox(width: 8),
                Text(
                  'দৈনিক আমলের রিমাইন্ডার',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 20),
                SizedBox(width: 8),
                Text(
                  'যিকির ও তিলাওয়াতের রিমাইন্ডার',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('পরে দিব', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DailyReminderScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('রিমাইন্ডার সেটিংস'),
          ),
        ],
      ),
    );
  }

  /// Check all required permissions and show dialog if needed
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;

    // Wait for the widget tree to be ready
    await Future.delayed(const Duration(milliseconds: 500));

    final notification = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;

    if (!notification.isGranted || !alarm.isGranted) {
      if (context.mounted) {
        // Show only the GREEN setup dialog
        await showNotificationPermissionPopup(context);
      }
      return;
    }

    // Permissions are granted -> schedule
    await DailyReminderService.scheduleDefaultDailyAmalReminder();
    await DailyReminderService.rescheduleReminderIfNeeded();
    await DailyReminderService.scheduleDefaultRollingWindowFromApi();
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    if (!Platform.isAndroid) return true;

    final notification = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;

    return notification.isGranted && alarm.isGranted;
  }
}
