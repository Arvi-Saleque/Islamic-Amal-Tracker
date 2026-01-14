import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionService {
  // Request location permission for accurate prayer times
  static Future<bool> requestLocationPermission(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showPermissionDialog(
        context,
        title: 'লোকেশন সার্ভিস বন্ধ',
        message: 'দয়া করে আপনার ডিভাইসের লোকেশন সার্ভিস চালু করুন।',
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Show explanation dialog
      final shouldRequest = await _showPermissionDialog(
        context,
        title: 'লোকেশন অনুমতি প্রয়োজন',
        message: 'সঠিক নামাজের সময় নির্ধারণের জন্য আপনার লোকেশন অনুমতি প্রয়োজন। এটি শুধুমাত্র নামাজের সময় হিসাব করতে ব্যবহার করা হবে।',
      );
      
      if (!shouldRequest) return false;
      
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDialog(
        context,
        title: 'লোকেশন অনুমতি স্থায়ীভাবে বন্ধ',
        message: 'দয়া করে সেটিংস থেকে লোকেশন অনুমতি চালু করুন।',
      );
      await Geolocator.openAppSettings();
      return false;
    }
    
    return true;
  }
  
  // Check if location permission is granted
  static Future<bool> checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
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
