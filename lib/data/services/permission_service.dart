import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request location permission for accurate prayer times
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied || status.isPermanentlyDenied) {
      // Show explanation dialog
      final shouldRequest = await _showPermissionDialog(
        context,
        title: 'লোকেশন অনুমতি প্রয়োজন',
        message: 'সঠিক নামাজের সময় নির্ধারণের জন্য আপনার লোকেশন অনুমতি প্রয়োজন। এটি শুধুমাত্র নামাজের সময় হিসাব করতে ব্যবহার করা হবে।',
      );
      
      if (!shouldRequest) return false;
      
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    final result = await Permission.location.request();
    return result.isGranted;
  }
  
  // Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied || status.isPermanentlyDenied) {
      // Show explanation dialog
      final shouldRequest = await _showPermissionDialog(
        context,
        title: 'নোটিফিকেশন অনুমতি প্রয়োজন',
        message: 'নামাজের সময় এবং রিমাইন্ডারের জন্য নোটিফিকেশন অনুমতি প্রয়োজন। এটি আপনাকে সময়মত নামাজ পড়তে সাহায্য করবে।',
      );
      
      if (!shouldRequest) return false;
      
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    
    final result = await Permission.notification.request();
    return result.isGranted;
  }
  
  // Check if all required permissions are granted
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'location': await Permission.location.isGranted,
      'notification': await Permission.notification.isGranted,
    };
  }
  
  // Request all permissions at once (for onboarding)
  static Future<bool> requestAllPermissions(BuildContext context) async {
    final locationGranted = await requestLocationPermission(context);
    final notificationGranted = await requestNotificationPermission(context);
    
    return locationGranted && notificationGranted;
  }
  
  static Future<bool> _showPermissionDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'না',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
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
        );
      },
    );
    
    return result ?? false;
  }
}
