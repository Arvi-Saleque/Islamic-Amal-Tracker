import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../../services/daily_reminder_service.dart';
import '../../widgets/digital_time_picker.dart';

class DailyReminderScreen extends StatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  State<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen> with WidgetsBindingObserver {
  bool _isReminderEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = true;
  
  // Permission statuses
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permissions when coming back from settings
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _loadSettings() async {
    final settings = await DailyReminderService.getReminderSettings();
    setState(() {
      _isReminderEnabled = settings['enabled'] ?? false;
      _selectedTime = TimeOfDay(
        hour: settings['hour'] ?? 8,
        minute: settings['minute'] ?? 0,
      );
      _isLoading = false;
    });
  }

  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations,
    ];

    final statuses = await Future.wait(
      permissions.map((permission) => permission.status),
    );

    if (mounted) {
      setState(() {
        _permissionStatuses = Map.fromIterables(permissions, statuses);
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    await _checkPermissions();
    
    // Show message if permanently denied
    if (status.isPermanentlyDenied && mounted) {
      _showPermissionDeniedDialog(permission);
    }
  }

  void _showPermissionDeniedDialog(Permission permission) {
    String permissionName = '';
    switch (permission) {
      case Permission.notification:
        permissionName = 'নোটিফিকেশন';
        break;
      case Permission.scheduleExactAlarm:
        permissionName = 'সঠিক সময়ে অ্যালার্ম';
        break;
      case Permission.ignoreBatteryOptimizations:
        permissionName = 'ব্যাটারি অপটিমাইজেশন';
        break;
      default:
        permissionName = 'এই';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'অনুমতি প্রয়োজন',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Text(
          '$permissionName অনুমতি সেটিংস থেকে দিতে হবে।',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'বাতিল',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text(
              'সেটিংসে যান',
              style: TextStyle(color: Color(0xFFD4AF37)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openBatteryOptimizationSettings() async {
    if (Platform.isAndroid) {
      try {
        const intent = AndroidIntent(
          action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
          data: 'package:com.amaltracker.app',
        );
        await intent.launch();
      } catch (e) {
        // Fallback to app settings
        await openAppSettings();
      }
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await DigitalTimePicker.show(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      
      if (_isReminderEnabled) {
        await _scheduleReminder();
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() {
      _isReminderEnabled = value;
    });

    if (value) {
      // Check permissions first
      final notificationGranted = _permissionStatuses[Permission.notification]?.isGranted ?? false;
      final alarmGranted = _permissionStatuses[Permission.scheduleExactAlarm]?.isGranted ?? false;
      
      if (!notificationGranted) {
        await _requestPermission(Permission.notification);
        await _checkPermissions();
        if (!(_permissionStatuses[Permission.notification]?.isGranted ?? false)) {
          setState(() {
            _isReminderEnabled = false;
          });
          _showSnackBar('নোটিফিকেশন অনুমতি দিন');
          return;
        }
      }
      
      if (!alarmGranted) {
        await _requestPermission(Permission.scheduleExactAlarm);
        await _checkPermissions();
        if (!(_permissionStatuses[Permission.scheduleExactAlarm]?.isGranted ?? false)) {
          setState(() {
            _isReminderEnabled = false;
          });
          _showSnackBar('সঠিক সময়ে অ্যালার্ম অনুমতি দিন');
          return;
        }
      }
      
      await _scheduleReminder();
    } else {
      await DailyReminderService.cancelDailyReminder();
      _showSnackBar('রিমাইন্ডার বন্ধ করা হয়েছে');
    }
  }

  Future<void> _scheduleReminder() async {
    await DailyReminderService.scheduleDailyReminder(
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
    );
    _showSnackBar('রিমাইন্ডার সেট করা হয়েছে ${_formatTime(_selectedTime)} এ');
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF2A2A2A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    final notificationGranted = _permissionStatuses[Permission.notification]?.isGranted ?? false;
    
    if (!notificationGranted) {
      await _requestPermission(Permission.notification);
      await _checkPermissions();
      if (!(_permissionStatuses[Permission.notification]?.isGranted ?? false)) {
        _showSnackBar('নোটিফিকেশন অনুমতি দিন');
        return;
      }
    }
    
    await DailyReminderService.showTestNotification();
    _showSnackBar('টেস্ট নোটিফিকেশন পাঠানো হয়েছে');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'দৈনিক আমল রিমাইন্ডার',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
            )
          : RefreshIndicator(
              onRefresh: _checkPermissions,
              color: const Color(0xFFD4AF37),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info Card
                    _buildInfoCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Reminder Toggle Card
                    _buildReminderCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Permission Status Section
                    _buildPermissionSection(),
                    
                    const SizedBox(height: 20),
                    
                    // OEM Settings Card
                    _buildOemSettingsCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Test Notification Button
                    _buildTestButton(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFFD4AF37)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'প্রতিদিন নির্দিষ্ট সময়ে আমল করার রিমাইন্ডার পাবেন',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          // Toggle Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'রিমাইন্ডার সক্রিয়',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _isReminderEnabled,
                onChanged: _toggleReminder,
                activeColor: const Color(0xFFD4AF37),
              ),
            ],
          ),
          
          if (_isReminderEnabled) ...[
            const Divider(color: Color(0xFF2A2A2A), height: 24),
            
            // Time Selector
            InkWell(
              onTap: _selectTime,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'রিমাইন্ডার সময়',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTime(_selectedTime),
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit,
                          color: Color(0xFFD4AF37),
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'অনুমতি স্থিতি',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPermissionTile(
          Permission.notification,
          'নোটিফিকেশন',
          'রিমাইন্ডার দেখানোর জন্য প্রয়োজন',
          Icons.notifications,
        ),
        const SizedBox(height: 8),
        _buildPermissionTile(
          Permission.scheduleExactAlarm,
          'সঠিক সময়ে অ্যালার্ম',
          'নির্দিষ্ট সময়ে রিমাইন্ডার পাঠাতে প্রয়োজন',
          Icons.alarm,
        ),
        const SizedBox(height: 8),
        _buildPermissionTile(
          Permission.ignoreBatteryOptimizations,
          'ব্যাটারি অপটিমাইজেশন',
          'অ্যাপ বন্ধ থাকলেও রিমাইন্ডার কাজ করবে',
          Icons.battery_full,
        ),
      ],
    );
  }

  Widget _buildPermissionTile(
    Permission permission,
    String title,
    String description,
    IconData icon,
  ) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted ?? false;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isGranted ? Colors.green : Colors.orange).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isGranted ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGranted ? '✓ অনুমতি দেওয়া হয়েছে' : '✗ অনুমতি প্রয়োজন',
                  style: TextStyle(
                    color: isGranted ? Colors.green : Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!isGranted)
            ElevatedButton(
              onPressed: () {
                if (permission == Permission.ignoreBatteryOptimizations) {
                  _openBatteryOptimizationSettings();
                } else {
                  _requestPermission(permission);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'দিন',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOemSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'গুরুত্বপূর্ণ: অতিরিক্ত সেটিংস',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'অ্যাপ বন্ধ থাকলেও রিমাইন্ডার পেতে হলে:\n\n'
            '✓ Settings → Apps → আমল ট্র্যাকার\n'
            '1. Battery → "Don\'t optimize" বা "Unrestricted"\n'
            '2. Battery → "Allow background activity" চালু করুন\n'
            '3. Auto-launch → Enable (OnePlus/Oppo/Xiaomi)\n\n'
            'OnePlus: Battery → "Deep Optimization" বন্ধ করুন',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => openAppSettings(),
              icon: const Icon(Icons.settings),
              label: const Text('অ্যাপ সেটিংস খুলুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _testNotification,
        icon: const Icon(Icons.send),
        label: const Text('টেস্ট নোটিফিকেশন পাঠান'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4AF37),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
