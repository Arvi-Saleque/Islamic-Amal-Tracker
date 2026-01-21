import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
          'রিমাইন্ডার সেটিংস',
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
              'নোটিফিকেশন সঠিকভাবে কাজ করতে নিচের অনুমতিগুলো দিন',
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
                      color: const Color(0xFFD4AF37),
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
              color: (isGranted ? const Color(0xFFD4AF37) : Colors.red),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.black,
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
                    color: isGranted ? const Color(0xFFD4AF37) : Colors.red,
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
                _requestPermission(permission);
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
              Expanded(
                child: Text(
                  'নোটিফিকেশন কাজ না করলে',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'উপরের পার্মিশন দেওয়ার পরেও নোটিফিকেশন কাজ না করলে আপনার ডিভাইস অনুযায়ী নিচের অপশনগুলো চেক করুন। অনেক ব্র্যান্ডের ফোনে বিশেষ সেটিংস থাকে যা ম্যানুয়ালি পরিবর্তন করতে হয়। গাইড অনুযায়ী আপনার ফোনে যে যে অপশন খুজে পান সেগুলো চেক করুন।',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          
          // Auto-detect button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDeviceSpecificGuide,
              icon: const Icon(Icons.phone_android),
              label: const Text('আমার ফোনের জন্য গাইড দেখান'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.all(14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // All brands button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showAllBrandsGuide,
              icon: const Icon(Icons.list_alt),
              label: const Text('সব ব্র্যান্ডের গাইড দেখান'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.all(14),
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

  Future<void> _showDeviceSpecificGuide() async {
    String brand = 'Unknown';
    String model = 'Unknown';
    
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      brand = androidInfo.brand.toLowerCase();
      model = androidInfo.model;
    } catch (e) {
      brand = 'unknown';
    }
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeviceGuideSheet(
        brand: brand,
        model: model,
      ),
    );
  }

  void _showAllBrandsGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AllBrandsGuideSheet(),
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

// Device-specific guide sheet
class _DeviceGuideSheet extends StatelessWidget {
  final String brand;
  final String model;

  const _DeviceGuideSheet({
    required this.brand,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.phone_android, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getBrandDisplayName(brand),
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            model,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common settings first
                  _buildSectionTitle('সব Android ফোনের জন্য (আগে এগুলো চেক করুন)'),
                  _buildCommonSettings(),
                  
                  const SizedBox(height: 24),
                  
                  // Brand specific
                  _buildSectionTitle('${_getBrandDisplayName(brand)} এর জন্য বিশেষ সেটিংস'),
                  _buildBrandSpecificSettings(brand),
                  
                  const SizedBox(height: 24),
                  
                  // Open settings button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('অ্যাপ সেটিংস খুলুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBrandDisplayName(String brand) {
    switch (brand.toLowerCase()) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return 'Xiaomi / Redmi / Poco';
      case 'samsung':
        return 'Samsung';
      case 'oneplus':
        return 'OnePlus';
      case 'oppo':
        return 'Oppo';
      case 'realme':
        return 'Realme';
      case 'vivo':
      case 'iqoo':
        return 'Vivo / iQOO';
      case 'huawei':
      case 'honor':
        return 'Huawei / Honor';
      case 'motorola':
        return 'Motorola';
      case 'google':
        return 'Google Pixel';
      case 'tecno':
      case 'infinix':
      case 'itel':
        return 'Tecno / Infinix / Itel';
      default:
        return brand.isNotEmpty 
            ? '${brand[0].toUpperCase()}${brand.substring(1)}'
            : 'Unknown';
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCommonSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          'A) App Notifications',
          'Settings → Apps → (Your app) → Notifications\n'
          '• Allow notifications = ON\n'
          '• Lock screen / Pop-up / Banner / Sound = ON',
        ),
        _buildSettingItem(
          'B) Battery Optimization বন্ধ',
          'Settings → Apps → (Your app) → Battery\n'
          '• Unrestricted / Don\'t optimize সিলেক্ট করুন',
        ),
        _buildSettingItem(
          'C) Background Data',
          'Settings → Apps → (Your app) → Mobile data & Wi-Fi\n'
          '• Background data = ON\n'
          '• Unrestricted data usage = ON',
        ),
        _buildSettingItem(
          'D) Unused app বন্ধ',
          'App info → (Your app)\n'
          '• Pause app activity if unused = OFF\n'
          '• Remove permissions if unused = OFF',
        ),
        _buildSettingItem(
          'E) Exact Alarm (Android 12+)',
          'Settings → Special app access → Alarms & reminders\n'
          '• Allow',
        ),
      ],
    );
  }

  Widget _buildBrandSpecificSettings(String brand) {
    switch (brand.toLowerCase()) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return _buildXiaomiSettings();
      case 'samsung':
        return _buildSamsungSettings();
      case 'oneplus':
        return _buildOnePlusSettings();
      case 'oppo':
      case 'realme':
        return _buildOppoSettings();
      case 'vivo':
      case 'iqoo':
        return _buildVivoSettings();
      case 'huawei':
      case 'honor':
        return _buildHuaweiSettings();
      case 'motorola':
        return _buildMotorolaSettings();
      case 'google':
        return _buildPixelSettings();
      case 'tecno':
      case 'infinix':
      case 'itel':
        return _buildTecnoSettings();
      default:
        return _buildGenericSettings();
    }
  }

  Widget _buildXiaomiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Auto-start (সবচেয়ে গুরুত্বপূর্ণ)',
          'Settings → Apps → Permissions → Autostart / Background autostart\n'
          '• আমল ট্র্যাকার = ON',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery Settings',
          'Settings → Apps → Manage apps → আমল ট্র্যাকার → Battery\n'
          '• No restrictions / Unrestricted\n'
          '• Allow background activity = ON',
        ),
        _buildSettingItem(
          'Recents Lock',
          'Recent apps খুলুন → আমল ট্র্যাকার লং প্রেস → Lock',
        ),
        _buildSettingItem(
          'Security App',
          'Security app → Battery → App battery saver\n'
          '• No restrictions',
        ),
      ],
    );
  }

  Widget _buildSamsungSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Sleeping Apps বন্ধ',
          'Settings → Battery → Background usage limits\n'
          '• Put unused apps to sleep = OFF\n'
          '• Sleeping apps / Deep sleeping apps থেকে আমল ট্র্যাকার Remove করুন',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
          '• Unrestricted',
        ),
        _buildSettingItem(
          'Notifications',
          'Settings → Notifications → App notifications\n'
          '• আমল ট্র্যাকার = ON\n'
          '• Notification categories সব ON',
        ),
      ],
    );
  }

  Widget _buildOnePlusSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Auto-launch Enable',
          'Settings → Apps → Special app access → Auto-launch\n'
          '• আমল ট্র্যাকার = Enable',
          isImportant: true,
        ),
        _buildSettingItem(
          '⭐ Deep Optimization বন্ধ',
          'Settings → Battery → Deep optimization\n'
          '• OFF করুন অথবা আমল ট্র্যাকার exclude করুন',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
          '• আমল ট্র্যাকার → Don\'t optimize',
        ),
      ],
    );
  }

  Widget _buildOppoSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Auto-launch / Startup Manager',
          'Settings → Apps → Special app access → Auto-launch / Startup manager\n'
          '• আমল ট্র্যাকার = Enable\n'
          '• Secondary launch / Background launch = Allow',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
          '• আমল ট্র্যাকার → Don\'t optimize',
        ),
      ],
    );
  }

  Widget _buildVivoSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Auto-start',
          'Settings → Battery → Background power consumption management / Autostart\n'
          '• আমল ট্র্যাকার = Allow',
          isImportant: true,
        ),
        _buildSettingItem(
          'High Background Power',
          'Settings → Battery → High background power consumption\n'
          '• আমল ট্র্যাকার = Allow / Don\'t restrict',
        ),
        _buildSettingItem(
          'Battery Optimization',
          'Apps → আমল ট্র্যাকার → Battery\n'
          '• No restrictions',
        ),
      ],
    );
  }

  Widget _buildHuaweiSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ App Launch (Manual)',
          'Settings → Apps → App launch → আমল ট্র্যাকার\n'
          '• Manage manually = ON\n'
          '• Auto-launch = ON\n'
          '• Secondary launch = ON\n'
          '• Run in background = ON',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery Optimization',
          'Battery optimization\n'
          '• Don\'t allow optimize / Unrestricted',
        ),
      ],
    );
  }

  Widget _buildMotorolaSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          'Battery',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
          '• Unrestricted',
        ),
        _buildSettingItem(
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
          '• আমল ট্র্যাকার → Not optimized',
        ),
        _buildSettingItem(
          'Data',
          'Mobile data → Background data = ON',
        ),
      ],
    );
  }

  Widget _buildPixelSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          'Battery Optimization',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
          '• Unrestricted',
        ),
        _buildSettingItem(
          'Battery Saver',
          'Settings → Battery → Battery Saver\n'
          '• OFF থাকলে ভালো (ON থাকলে delay হতে পারে)',
        ),
        _buildSettingItem(
          'Exact Alarm',
          'Settings → Apps → Special app access → Alarms & reminders\n'
          '• আমল ট্র্যাকার = Allow',
        ),
      ],
    );
  }

  Widget _buildTecnoSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          '⭐ Auto-start',
          'Settings → Apps → Autostart manager\n'
          '• আমল ট্র্যাকার = Enable',
          isImportant: true,
        ),
        _buildSettingItem(
          'Battery/Power Manager',
          'Battery lab / Power manager\n'
          '• Don\'t restrict',
        ),
        _buildSettingItem(
          'Background Activity',
          'Allow background activity = ON',
        ),
        _buildSettingItem(
          'Recents Lock',
          'Lock in recent apps (যদি থাকে)',
        ),
      ],
    );
  }

  Widget _buildGenericSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          'Battery Optimization',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
          '• Unrestricted / Don\'t optimize',
        ),
        _buildSettingItem(
          'Auto-start (যদি থাকে)',
          'Settings → Apps → Special app access → Auto-launch\n'
          '• Enable করুন',
        ),
        _buildSettingItem(
          'Background Data',
          'Background data = ON',
        ),
      ],
    );
  }

  Widget _buildSettingItem(String title, String description, {bool isImportant = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImportant 
            ? const Color(0xFFD4AF37).withOpacity(0.15)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: isImportant 
            ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isImportant ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// All brands guide sheet with tabs
class _AllBrandsGuideSheet extends StatefulWidget {
  const _AllBrandsGuideSheet();

  @override
  State<_AllBrandsGuideSheet> createState() => _AllBrandsGuideSheetState();
}

class _AllBrandsGuideSheetState extends State<_AllBrandsGuideSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _brands = [
    {'name': 'সবার জন্য', 'icon': Icons.android},
    {'name': 'Xiaomi', 'icon': Icons.phone_android},
    {'name': 'Samsung', 'icon': Icons.phone_android},
    {'name': 'OnePlus', 'icon': Icons.phone_android},
    {'name': 'Oppo/Realme', 'icon': Icons.phone_android},
    {'name': 'Vivo', 'icon': Icons.phone_android},
    {'name': 'Huawei', 'icon': Icons.phone_android},
    {'name': 'Pixel', 'icon': Icons.phone_android},
    {'name': 'Tecno', 'icon': Icons.phone_android},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _brands.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0A0A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.list_alt, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ব্র্যান্ড অনুযায়ী গাইড',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          Container(
            color: const Color(0xFF0A0A0A),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFD4AF37),
              labelColor: const Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white54,
              tabAlignment: TabAlignment.start,
              tabs: _brands.map((brand) => Tab(
                text: brand['name'],
              )).toList(),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommonTab(),
                _buildXiaomiTab(),
                _buildSamsungTab(),
                _buildOnePlusTab(),
                _buildOppoTab(),
                _buildVivoTab(),
                _buildHuaweiTab(),
                _buildPixelTab(),
                _buildTecnoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('সব Android ফোনে আগে এগুলো চেক করুন'),
          const SizedBox(height: 16),
          _buildStep('A) App Notifications', 
            'Settings → Apps → আমল ট্র্যাকার → Notifications\n'
            '• Allow notifications = ON\n'
            '• Lock screen / Pop-up / Banner / Sound = ON'),
          _buildStep('B) Battery Optimization বন্ধ', 
            'Settings → Apps → আমল ট্র্যাকার → Battery\n'
            '• Unrestricted / Don\'t optimize সিলেক্ট করুন'),
          _buildStep('C) Background Data', 
            'Settings → Apps → আমল ট্র্যাকার → Mobile data & Wi-Fi\n'
            '• Background data = ON\n'
            '• Unrestricted data usage = ON'),
          _buildStep('D) Unused app বন্ধ', 
            'App info → আমল ট্র্যাকার\n'
            '• Pause app activity if unused = OFF\n'
            '• Remove permissions if unused = OFF'),
          _buildStep('E) Do Not Disturb', 
            'Do Not Disturb / Focus mode OFF রাখুন অথবা exception এ যোগ করুন'),
          _buildStep('F) Exact Alarm (Android 12+)', 
            'Settings → Special app access → Alarms & reminders\n'
            '• Allow'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildXiaomiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Xiaomi / Redmi / Poco (MIUI / HyperOS)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Auto-start (সবচেয়ে গুরুত্বপূর্ণ)', 
            'Settings → Apps → Permissions → Autostart / Background autostart\n'
            '• আমল ট্র্যাকার = ON ✅', 
            isImportant: true),
          _buildStep('Battery Settings', 
            'Settings → Apps → Manage apps → আমল ট্র্যাকার → Battery\n'
            '• No restrictions / Unrestricted\n'
            '• Allow background activity = ON'),
          _buildStep('Recents Lock', 
            'Recent apps খুলুন → আমল ট্র্যাকার লং প্রেস করুন → Lock icon এ ট্যাপ'),
          _buildStep('Security App', 
            'Security app → Battery → App battery saver\n'
            '• No restrictions\n'
            '• "Clear cache/Boost speed" এ আমল ট্র্যাকার exclude করুন'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSamsungTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Samsung (One UI)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Sleeping Apps বন্ধ', 
            'Settings → Battery → Background usage limits\n'
            '• Put unused apps to sleep = OFF\n'
            '• Sleeping apps / Deep sleeping apps এ থাকলে Remove করুন', 
            isImportant: true),
          _buildStep('Battery', 
            'Settings → Apps → আমল ট্র্যাকার → Battery\n'
            '• Unrestricted'),
          _buildStep('Notifications', 
            'Settings → Notifications → App notifications\n'
            '• আমল ট্র্যাকার = ON\n'
            '• Notification categories এ সব category ON করুন'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOnePlusTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('OnePlus (OxygenOS)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Auto-launch Enable', 
            'Settings → Apps → Special app access → Auto-launch\n'
            '• আমল ট্র্যাকার = Enable\n'
            '• Secondary launch / Background launch = Allow', 
            isImportant: true),
          _buildStep('⭐ Deep Optimization বন্ধ', 
            'Settings → Battery → Deep optimization\n'
            '• OFF করুন অথবা আমল ট্র্যাকার exclude করুন', 
            isImportant: true),
          _buildStep('Battery Optimization', 
            'Settings → Battery → Battery optimization\n'
            '• আমল ট্র্যাকার → Don\'t optimize'),
          _buildStep('Recents Lock', 
            'Recents → Lock (কিছু মডেলে আছে)'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildOppoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Oppo / Realme (ColorOS / Realme UI)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Auto-launch / Startup', 
            'Settings → Apps → Special app access → Auto-launch / Startup manager\n'
            '• আমল ট্র্যাকার = Enable\n'
            '• Secondary launch / Background launch = Allow', 
            isImportant: true),
          _buildStep('Battery Optimization', 
            'Settings → Battery → Battery optimization\n'
            '• আমল ট্র্যাকার → Don\'t optimize'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVivoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Vivo / iQOO (Funtouch OS)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Auto-start', 
            'Settings → Battery → Background power consumption management / Autostart\n'
            '• আমল ট্র্যাকার = Allow', 
            isImportant: true),
          _buildStep('High Background Power', 
            'Settings → Battery → High background power consumption\n'
            '• আমল ট্র্যাকার = Allow / Don\'t restrict'),
          _buildStep('Battery Optimization', 
            'Apps → আমল ট্র্যাকার → Battery\n'
            '• No restrictions'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHuaweiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Huawei / Honor (EMUI / MagicOS)'),
          const SizedBox(height: 16),
          _buildStep('⭐ App Launch (Manual)', 
            'Settings → Apps → App launch → আমল ট্র্যাকার\n'
            '• Manage manually = ON\n'
            '• Auto-launch = ON\n'
            '• Secondary launch = ON\n'
            '• Run in background = ON', 
            isImportant: true),
          _buildStep('Battery Optimization', 
            'Battery optimization\n'
            '• Don\'t allow optimize / Unrestricted'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPixelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Google Pixel / Stock Android'),
          const SizedBox(height: 16),
          _buildStep('Battery Optimization', 
            'Settings → Apps → আমল ট্র্যাকার → Battery\n'
            '• Unrestricted'),
          _buildStep('Battery Saver', 
            'Settings → Battery → Battery Saver\n'
            '• OFF থাকলে ভালো (ON থাকলে delay হতে পারে)'),
          _buildStep('Exact Alarm', 
            'Settings → Apps → Special app access → Alarms & reminders\n'
            '• আমল ট্র্যাকার = Allow'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTecnoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('Tecno / Infinix / Itel (HiOS / XOS)'),
          const SizedBox(height: 16),
          _buildStep('⭐ Auto-start', 
            'Settings → Apps → Autostart manager\n'
            '• আমল ট্র্যাকার = Enable', 
            isImportant: true),
          _buildStep('Battery / Power Manager', 
            'Battery lab / Power manager\n'
            '• Don\'t restrict'),
          _buildStep('Background Activity', 
            'Allow background activity = ON'),
          _buildStep('Recents Lock', 
            'Lock in recent apps (যদি থাকে)'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String title, String description, {bool isImportant = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImportant 
            ? const Color(0xFFD4AF37).withOpacity(0.15)
            : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: isImportant 
            ? Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isImportant ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
