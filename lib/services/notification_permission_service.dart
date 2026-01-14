import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class NotificationPermissionService {
  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();
  factory NotificationPermissionService() => _instance;
  NotificationPermissionService._internal();

  // Check if all required permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Check notification permission (Android 13+)
    bool notificationGranted = true;
    if (sdkInt >= 33) {
      notificationGranted = await Permission.notification.isGranted;
    }

    // Check exact alarm permission (Android 12+)
    bool exactAlarmGranted = true;
    if (sdkInt >= 31) {
      exactAlarmGranted = await Permission.scheduleExactAlarm.isGranted;
    }

    return notificationGranted && exactAlarmGranted;
  }

  // Request all required permissions with dialogs
  Future<void> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Request notification permission (Android 13+)
    if (sdkInt >= 33) {
      final notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        await _showPermissionDialog(
          context,
          title: 'নোটিফিকেশন অনুমতি',
          description:
              'দৈনিক আমল রিমাইন্ডার পেতে নোটিফিকেশন অনুমতি প্রয়োজন। এটি আপনাকে সময়মতো আমল সম্পন্ন করতে মনে করিয়ে দেবে।',
          icon: Icons.notifications_active,
          onAccept: () async {
            await Permission.notification.request();
          },
        );
      }
    }

    // Request exact alarm permission (Android 12+)
    if (sdkInt >= 31) {
      final exactAlarmStatus = await Permission.scheduleExactAlarm.status;
      if (!exactAlarmStatus.isGranted) {
        await _showPermissionDialog(
          context,
          title: 'সঠিক সময়ে রিমাইন্ডার',
          description:
              'সঠিক সময়ে রিমাইন্ডার পাঠাতে এই অনুমতি প্রয়োজন। এটি নিশ্চিত করবে যে আপনি আপনার নির্ধারিত সময়ে রিমাইন্ডার পাবেন।',
          icon: Icons.alarm,
          onAccept: () async {
            await Permission.scheduleExactAlarm.request();
          },
        );
      }
    }

    // Request battery optimization exemption
    await _requestBatteryOptimizationExemption(context);
  }

  // Show permission explanation dialog
  Future<void> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Future<void> Function() onAccept,
  }) async {
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          description,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'পরে',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'অনুমতি দিন',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldRequest == true) {
      await onAccept();
    }
  }

  // Request battery optimization exemption
  Future<void> _requestBatteryOptimizationExemption(BuildContext context) async {
    final batteryOptimizationStatus =
        await Permission.ignoreBatteryOptimizations.status;

    if (!batteryOptimizationStatus.isGranted) {
      await _showPermissionDialog(
        context,
        title: 'ব্যাটারি অপটিমাইজেশন',
        description:
            'অ্যাপটি ব্যাকগ্রাউন্ডে চলার সময় রিমাইন্ডার পাঠাতে পারে তা নিশ্চিত করতে ব্যাটারি অপটিমাইজেশন থেকে অব্যাহতি প্রয়োজন।',
        icon: Icons.battery_saver,
        onAccept: () async {
          await Permission.ignoreBatteryOptimizations.request();
        },
      );
    }
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check and show permission status
  Future<Map<String, bool>> getPermissionStatus() async {
    if (!Platform.isAndroid) {
      return {
        'notification': true,
        'exactAlarm': true,
        'batteryOptimization': true,
      };
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    return {
      'notification': sdkInt >= 33
          ? await Permission.notification.isGranted
          : true,
      'exactAlarm': sdkInt >= 31
          ? await Permission.scheduleExactAlarm.isGranted
          : true,
      'batteryOptimization':
          await Permission.ignoreBatteryOptimizations.isGranted,
    };
  }
}
