import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'daily_reminder_service.dart';

class PermissionService {
  /// Check all required permissions and show dialog if needed
  static Future<void> checkAndRequestPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;
    
    // Wait for the widget tree to be ready
    await Future.delayed(const Duration(milliseconds: 500));
    
    final notification = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;
    
    if (!notification.isGranted || !alarm.isGranted) {
      if (context.mounted) {
        _showPermissionDialog(context, notification, alarm);
      }
    } else {
      // Permissions are granted, reschedule reminder if needed
      await DailyReminderService.rescheduleReminderIfNeeded();
    }
  }

  static void _showPermissionDialog(
    BuildContext context,
    PermissionStatus notification,
    PermissionStatus alarm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
            SizedBox(width: 8),
            Text(
              'অনুমতি প্রয়োজন',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'দৈনিক আমল রিমাইন্ডার পেতে নিম্নলিখিত অনুমতি প্রয়োজন:',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (!notification.isGranted)
              _buildPermissionItem(
                icon: Icons.notifications,
                title: 'নোটিফিকেশন',
                isGranted: false,
              ),
            if (!alarm.isGranted)
              _buildPermissionItem(
                icon: Icons.alarm,
                title: 'সঠিক সময়ে অ্যালার্ম',
                isGranted: false,
              ),
            const SizedBox(height: 8),
            const Text(
              'সেটিংস পেজ থেকে অনুমতি দিতে পারবেন।',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'পরে দিব',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestPermissions(notification, alarm);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text('অনুমতি দিন'),
          ),
        ],
      ),
    );
  }

  static Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required bool isGranted,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: isGranted ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isGranted ? Colors.green : Colors.orange,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Icon(
            isGranted ? Icons.check_circle : Icons.warning,
            color: isGranted ? Colors.green : Colors.orange,
            size: 18,
          ),
        ],
      ),
    );
  }

  static Future<void> _requestPermissions(
    PermissionStatus notification,
    PermissionStatus alarm,
  ) async {
    if (!notification.isGranted) {
      await Permission.notification.request();
    }
    if (!alarm.isGranted) {
      await Permission.scheduleExactAlarm.request();
    }
    
    // Reschedule reminder if permissions were granted
    await DailyReminderService.rescheduleReminderIfNeeded();
  }

  /// Check if all required permissions are granted
  static Future<bool> areAllPermissionsGranted() async {
    if (!Platform.isAndroid) return true;
    
    final notification = await Permission.notification.status;
    final alarm = await Permission.scheduleExactAlarm.status;
    
    return notification.isGranted && alarm.isGranted;
  }
}
