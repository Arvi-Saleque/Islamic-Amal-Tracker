import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/daily_amal_notification_service.dart';

class DailyAmalReminderScreen extends ConsumerStatefulWidget {
  const DailyAmalReminderScreen({super.key});

  @override
  ConsumerState<DailyAmalReminderScreen> createState() =>
      _DailyAmalReminderScreenState();
}

class _DailyAmalReminderScreenState extends ConsumerState<DailyAmalReminderScreen> {
  final _notificationService = DailyAmalNotificationService();
  bool _isEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0); // Default 8:00 PM
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Load saved settings
    _isEnabled = await _notificationService.isReminderEnabled();
    final savedTime = await _notificationService.getReminderTime();
    
    if (savedTime != null) {
      final parts = savedTime.split(':');
      _selectedTime = TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      
      // If reminder is already enabled, reschedule with new time
      if (_isEnabled) {
        await _notificationService.scheduleDailyReminder(
          _selectedTime.hour,
          _selectedTime.minute,
        );
        _showSnackBar('রিমাইন্ডার সময় আপডেট করা হয়েছে');
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _isEnabled = value);

    if (value) {
      await _notificationService.scheduleDailyReminder(
        _selectedTime.hour,
        _selectedTime.minute,
      );
      _showSnackBar('দৈনিক আমল রিমাইন্ডার চালু করা হয়েছে');
    } else {
      await _notificationService.cancelDailyReminder();
      _showSnackBar('দৈনিক আমল রিমাইন্ডার বন্ধ করা হয়েছে');
    }
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.sendTestNotification();
    _showSnackBar('টেস্ট নোটিফিকেশন পাঠানো হয়েছে');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('দৈনিক আমল রিমাইন্ডার'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Enable/Disable Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text(
                'রিমাইন্ডার চালু করুন',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _isEnabled 
                    ? 'প্রতিদিন ${_formatTime(_selectedTime)} এ রিমাইন্ডার পাবেন' 
                    : 'দৈনিক আমলের জন্য রিমাইন্ডার পান',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              value: _isEnabled,
              onChanged: _toggleReminder,
              activeColor: Theme.of(context).primaryColor,
            ),
          ),

          const SizedBox(height: 16),

          // Time Picker Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              title: const Text(
                'রিমাইন্ডার সময়',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                _formatTime(_selectedTime),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _pickTime,
            ),
          ),

          const SizedBox(height: 24),

          // Test Notification Button
          OutlinedButton.icon(
            onPressed: _sendTestNotification,
            icon: const Icon(Icons.notifications_active),
            label: const Text('টেস্ট নোটিফিকেশন পাঠান'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),

          const SizedBox(height: 24),

          // Info Card
          Card(
            color: Colors.blue[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'গুরুত্বপূর্ণ তথ্য',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• নোটিফিকেশন সঠিকভাবে কাজ করার জন্য ব্যাটারি অপটিমাইজেশন বন্ধ রাখুন\n'
                    '• অ্যাপকে ব্যাকগ্রাউন্ডে চলার অনুমতি দিন\n'
                    '• সময়মতো রিমাইন্ডার পেতে নোটিফিকেশন পারমিশন চালু রাখুন',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.blue[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
