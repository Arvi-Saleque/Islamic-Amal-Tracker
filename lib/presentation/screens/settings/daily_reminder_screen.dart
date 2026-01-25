import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/daily_reminder_service.dart';
import '../../widgets/digital_time_picker.dart';

class DailyReminderScreen extends StatefulWidget {
  const DailyReminderScreen({super.key});

  @override
  State<DailyReminderScreen> createState() => _DailyReminderScreenState();
}

class _DailyReminderScreenState extends State<DailyReminderScreen>
    with WidgetsBindingObserver {
  bool _isReminderEnabled = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  bool _isLoading = true;

  // Platform info
  bool _isAndroid12Plus = true;

  // Permission statuses
  Map<Permission, PermissionStatus> _permissionStatuses = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    try {
      await _loadSettings();
      await _loadPlatformInfo();
      await _checkPermissions();
    } catch (e) {
      debugPrint('DailyReminderScreen init error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadPlatformInfo() async {
    if (!Platform.isAndroid) {
      _isAndroid12Plus = false;
      return;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdk = androidInfo.version.sdkInt;
      _isAndroid12Plus = sdk >= 31; // Android 12 = 31
    } catch (e) {
      // safe default
      _isAndroid12Plus = true;
      debugPrint('Platform info error: $e');
    }
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
    try {
      final settings = await DailyReminderService.getReminderSettings();
      if (!mounted) return;

      setState(() {
        _isReminderEnabled = settings['enabled'] ?? false;
        _selectedTime = TimeOfDay(
          hour: settings['hour'] ?? 8,
          minute: settings['minute'] ?? 0,
        );
      });
    } catch (e) {
      debugPrint('Error loading reminder settings: $e');
    }
  }

  List<Permission> _requiredPermissions() {
    final list = <Permission>[Permission.notification];
    if (_isAndroid12Plus) {
      list.add(Permission.scheduleExactAlarm);
    }
    return list;
  }

  Future<void> _checkPermissions() async {
    try {
      final permissions = _requiredPermissions();

      final statuses = await Future.wait(
        permissions.map((permission) => permission.status),
      );

      if (!mounted) return;
      setState(() {
        _permissionStatuses = Map.fromIterables(permissions, statuses);
      });
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      if (!mounted) return;
      setState(() {
        _permissionStatuses = {};
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    await _checkPermissions();

    if (!mounted) return;

    // Show message if permanently denied
    if (status.isPermanentlyDenied) {
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
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'অনুমতি প্রয়োজন',
          style: TextStyle(color: Color(0xFFD4AF37)),
        ),
        content: Text(
          '$permissionName অনুমতি সেটিংস থেকে দিতে হবে।',
          style: const TextStyle(color: Colors.white70, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
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
      setState(() => _selectedTime = picked);

      if (_isReminderEnabled) {
        await _scheduleReminder();
      }
    }
  }

  Future<void> _toggleReminder(bool value) async {
    setState(() => _isReminderEnabled = value);

    if (value) {
      // Check permissions first
      final notificationGranted =
          _permissionStatuses[Permission.notification]?.isGranted ?? false;

      if (!notificationGranted) {
        await _requestPermission(Permission.notification);
        await _checkPermissions();
        final ok = _permissionStatuses[Permission.notification]?.isGranted ?? false;
        if (!ok) {
          if (mounted) setState(() => _isReminderEnabled = false);
          _showSnackBar('নোটিফিকেশন অনুমতি দিন');
          return;
        }
      }

      if (_isAndroid12Plus) {
        final alarmGranted =
            _permissionStatuses[Permission.scheduleExactAlarm]?.isGranted ?? false;

        if (!alarmGranted) {
          await _requestPermission(Permission.scheduleExactAlarm);
          await _checkPermissions();
          final ok =
              _permissionStatuses[Permission.scheduleExactAlarm]?.isGranted ?? false;
          if (!ok) {
            if (mounted) setState(() => _isReminderEnabled = false);
            _showSnackBar('সঠিক সময়ে অ্যালার্ম অনুমতি দিন');
            return;
          }
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
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _testNotification() async {
    final notificationGranted =
        _permissionStatuses[Permission.notification]?.isGranted ?? false;

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
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'রিমাইন্ডার সেটিংস',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF0F0F0F),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
              )
            : RefreshIndicator(
                onRefresh: _checkPermissions,
                color: const Color(0xFFD4AF37),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Permission Section
                    _buildPermissionSection(),
                    const SizedBox(height: 16),

                    // OEM Settings Card
                    _buildOemSettingsCard(),
                    const SizedBox(height: 16),

                    // Test Notification Button
                    _buildTestButton(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'অনুমতি স্থিতি',
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        _buildPermissionTile(
          permission: Permission.notification,
          title: 'নোটিফিকেশন',
          description: 'রিমাইন্ডার দেখানোর জন্য প্রয়োজন',
          icon: Icons.notifications,
        ),
        const SizedBox(height: 10),
        if (_isAndroid12Plus)
          _buildPermissionTile(
            permission: Permission.scheduleExactAlarm,
            title: 'সঠিক সময়ে অ্যালার্ম',
            description: 'নির্দিষ্ট সময়ে রিমাইন্ডার পাঠাতে প্রয়োজন',
            icon: Icons.alarm,
          ),
        if (!_isAndroid12Plus)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'ℹ️ আপনার ডিভাইসে (Android 12-এর কম) Exact Alarm অনুমতি দরকার নেই।',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPermissionTile({
    required Permission permission,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted ?? false;

    final badgeColor = isGranted ? const Color(0xFFD4AF37) : const Color(0xFFFF5A5A);

    return _PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: badgeColor.withOpacity(0.24)),
            ),
            child: Icon(
              icon,
              color: badgeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: badgeColor.withOpacity(0.22)),
                      ),
                      child: Text(
                        isGranted ? 'Granted' : 'Required',
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12.2,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (!isGranted)
            ElevatedButton(
              onPressed: () => _requestPermission(permission),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'দিন',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOemSettingsCard() {
    return _PremiumCard(
      padding: const EdgeInsets.all(16),
      accent: const Color(0xFFFFB020),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB020).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB020).withOpacity(0.22),
                  ),
                ),
                child: const Icon(Icons.tips_and_updates, color: Color(0xFFFFB020), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'নোটিফিকেশন কাজ না করলে',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'কিছু ফোনে (বিশেষ করে Xiaomi / Samsung / Oppo ইত্যাদি) Battery/Auto-start সেটিংসের কারণে নোটিফিকেশন delay বা off থাকতে পারে। নিচের গাইড থেকে আপনার ডিভাইস অনুযায়ী অপশনগুলো চেক করুন।',
            style: TextStyle(
              color: Colors.white.withOpacity(0.68),
              fontSize: 12.6,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDeviceSpecificGuide,
                  icon: const Icon(Icons.phone_android),
                  label: const Text('আমার ফোন'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAllBrandsGuide,
                  icon: const Icon(Icons.list_alt),
                  label: const Text('সব ব্র্যান্ড'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withOpacity(0.18)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
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
      debugPrint('Device info error: $e');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DeviceGuideSheet(brand: brand, model: model),
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
          elevation: 0,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

/// Premium reusable card (subtle 3D: light shadow + border + gradient feel)
class _PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? accent;

  const _PremiumCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = accent ?? const Color(0xFFD4AF37);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
        boxShadow: [
          // very subtle shadow (as you requested)
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
          // tiny top highlight to feel "raised"
          BoxShadow(
            color: a.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF151515),
            const Color(0xFF111111),
            const Color(0xFF141414),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Small glowing icon block (premium touch but not too much)
class _GlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;

  const _GlowIcon({required this.icon, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFD4AF37).withOpacity(0.10),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37), size: 22),
    );
  }
}

// ================================
// Device-specific guide sheet
// ================================
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
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
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
                const SizedBox(height: 14),
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
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            model,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
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
                  _buildSectionTitle('সব Android ফোনের জন্য (আগে এগুলো চেক করুন)'),
                  _buildCommonSettings(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('${_getBrandDisplayName(brand)} এর জন্য বিশেষ সেটিংস'),
                  _buildBrandSpecificSettings(brand),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('অ্যাপ সেটিংস খুলুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
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
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
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

  Widget _buildSettingItem(
    String title,
    String description, {
    bool isImportant = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImportant
            ? const Color(0xFFD4AF37).withOpacity(0.12)
            : const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImportant
              ? const Color(0xFFD4AF37).withOpacity(0.28)
              : Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isImportant ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.8,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================
// All brands guide sheet with tabs
// ================================
class _AllBrandsGuideSheet extends StatefulWidget {
  const _AllBrandsGuideSheet();

  @override
  State<_AllBrandsGuideSheet> createState() => _AllBrandsGuideSheetState();
}

class _AllBrandsGuideSheetState extends State<_AllBrandsGuideSheet>
    with SingleTickerProviderStateMixin {
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
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
              ),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.list_alt, color: Color(0xFFD4AF37)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'ব্র্যান্ড অনুযায়ী গাইড',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
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

          Container(
            color: const Color(0xFF0A0A0A),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFFD4AF37),
              labelColor: const Color(0xFFD4AF37),
              unselectedLabelColor: Colors.white54,
              tabAlignment: TabAlignment.start,
              tabs: _brands.map((b) => Tab(text: b['name'])).toList(),
            ),
          ),

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
    return _GuideTab(
      title: 'সব Android ফোনে আগে এগুলো চেক করুন',
      steps: const [
        _GuideStep(
          title: 'A) App Notifications',
          desc:
              'Settings → Apps → আমল ট্র্যাকার → Notifications\n• Allow notifications = ON\n• Lock screen / Pop-up / Banner / Sound = ON',
        ),
        _GuideStep(
          title: 'B) Battery Optimization বন্ধ',
          desc:
              'Settings → Apps → আমল ট্র্যাকার → Battery\n• Unrestricted / Don\'t optimize সিলেক্ট করুন',
        ),
        _GuideStep(
          title: 'C) Background Data',
          desc:
              'Settings → Apps → আমল ট্র্যাকার → Mobile data & Wi-Fi\n• Background data = ON\n• Unrestricted data usage = ON',
        ),
        _GuideStep(
          title: 'D) Unused app বন্ধ',
          desc:
              'App info → আমল ট্র্যাকার\n• Pause app activity if unused = OFF\n• Remove permissions if unused = OFF',
        ),
        _GuideStep(
          title: 'E) Do Not Disturb',
          desc: 'Do Not Disturb / Focus mode OFF রাখুন অথবা exception এ যোগ করুন',
        ),
        _GuideStep(
          title: 'F) Exact Alarm (Android 12+)',
          desc:
              'Settings → Special app access → Alarms & reminders\n• Allow',
        ),
      ],
    );
  }

  Widget _buildXiaomiTab() {
    return _GuideTab(
      title: 'Xiaomi / Redmi / Poco (MIUI / HyperOS)',
      steps: const [
        _GuideStep(
          title: '⭐ Auto-start (সবচেয়ে গুরুত্বপূর্ণ)',
          desc:
              'Settings → Apps → Permissions → Autostart / Background autostart\n• আমল ট্র্যাকার = ON ✅',
          important: true,
        ),
        _GuideStep(
          title: 'Battery Settings',
          desc:
              'Settings → Apps → Manage apps → আমল ট্র্যাকার → Battery\n• No restrictions / Unrestricted\n• Allow background activity = ON',
        ),
        _GuideStep(
          title: 'Recents Lock',
          desc:
              'Recent apps খুলুন → আমল ট্র্যাকার লং প্রেস করুন → Lock icon এ ট্যাপ',
        ),
        _GuideStep(
          title: 'Security App',
          desc:
              'Security app → Battery → App battery saver\n• No restrictions\n• "Clear cache/Boost speed" এ আমল ট্র্যাকার exclude করুন',
        ),
      ],
    );
  }

  Widget _buildSamsungTab() {
    return _GuideTab(
      title: 'Samsung (One UI)',
      steps: const [
        _GuideStep(
          title: '⭐ Sleeping Apps বন্ধ',
          desc:
              'Settings → Battery → Background usage limits\n• Put unused apps to sleep = OFF\n• Sleeping apps / Deep sleeping apps এ থাকলে Remove করুন',
          important: true,
        ),
        _GuideStep(
          title: 'Battery',
          desc:
              'Settings → Apps → আমল ট্র্যাকার → Battery\n• Unrestricted',
        ),
        _GuideStep(
          title: 'Notifications',
          desc:
              'Settings → Notifications → App notifications\n• আমল ট্র্যাকার = ON\n• Notification categories এ সব category ON করুন',
        ),
      ],
    );
  }

  Widget _buildOnePlusTab() {
    return _GuideTab(
      title: 'OnePlus (OxygenOS)',
      steps: const [
        _GuideStep(
          title: '⭐ Auto-launch Enable',
          desc:
              'Settings → Apps → Special app access → Auto-launch\n• আমল ট্র্যাকার = Enable\n• Secondary launch / Background launch = Allow',
          important: true,
        ),
        _GuideStep(
          title: '⭐ Deep Optimization বন্ধ',
          desc:
              'Settings → Battery → Deep optimization\n• OFF করুন অথবা আমল ট্র্যাকার exclude করুন',
          important: true,
        ),
        _GuideStep(
          title: 'Battery Optimization',
          desc:
              'Settings → Battery → Battery optimization\n• আমল ট্র্যাকার → Don\'t optimize',
        ),
        _GuideStep(title: 'Recents Lock', desc: 'Recents → Lock (কিছু মডেলে আছে)'),
      ],
    );
  }

  Widget _buildOppoTab() {
    return _GuideTab(
      title: 'Oppo / Realme (ColorOS / Realme UI)',
      steps: const [
        _GuideStep(
          title: '⭐ Auto-launch / Startup',
          desc:
              'Settings → Apps → Special app access → Auto-launch / Startup manager\n• আমল ট্র্যাকার = Enable\n• Secondary launch / Background launch = Allow',
          important: true,
        ),
        _GuideStep(
          title: 'Battery Optimization',
          desc:
              'Settings → Battery → Battery optimization\n• আমল ট্র্যাকার → Don\'t optimize',
        ),
      ],
    );
  }

  Widget _buildVivoTab() {
    return _GuideTab(
      title: 'Vivo / iQOO (Funtouch OS)',
      steps: const [
        _GuideStep(
          title: '⭐ Auto-start',
          desc:
              'Settings → Battery → Background power consumption management / Autostart\n• আমল ট্র্যাকার = Allow',
          important: true,
        ),
        _GuideStep(
          title: 'High Background Power',
          desc:
              'Settings → Battery → High background power consumption\n• আমল ট্র্যাকার = Allow / Don\'t restrict',
        ),
        _GuideStep(
          title: 'Battery Optimization',
          desc: 'Apps → আমল ট্র্যাকার → Battery\n• No restrictions',
        ),
      ],
    );
  }

  Widget _buildHuaweiTab() {
    return _GuideTab(
      title: 'Huawei / Honor (EMUI / MagicOS)',
      steps: const [
        _GuideStep(
          title: '⭐ App Launch (Manual)',
          desc:
              'Settings → Apps → App launch → আমল ট্র্যাকার\n• Manage manually = ON\n• Auto-launch = ON\n• Secondary launch = ON\n• Run in background = ON',
          important: true,
        ),
        _GuideStep(
          title: 'Battery Optimization',
          desc: 'Battery optimization\n• Don\'t allow optimize / Unrestricted',
        ),
      ],
    );
  }

  Widget _buildPixelTab() {
    return _GuideTab(
      title: 'Google Pixel / Stock Android',
      steps: const [
        _GuideStep(
          title: 'Battery Optimization',
          desc:
              'Settings → Apps → আমল ট্র্যাকার → Battery\n• Unrestricted',
        ),
        _GuideStep(
          title: 'Battery Saver',
          desc: 'Settings → Battery → Battery Saver\n• OFF থাকলে ভালো (ON থাকলে delay হতে পারে)',
        ),
        _GuideStep(
          title: 'Exact Alarm',
          desc:
              'Settings → Apps → Special app access → Alarms & reminders\n• আমল ট্র্যাকার = Allow',
        ),
      ],
    );
  }

  Widget _buildTecnoTab() {
    return _GuideTab(
      title: 'Tecno / Infinix / Itel (HiOS / XOS)',
      steps: const [
        _GuideStep(
          title: '⭐ Auto-start',
          desc: 'Settings → Apps → Autostart manager\n• আমল ট্র্যাকার = Enable',
          important: true,
        ),
        _GuideStep(
          title: 'Battery / Power Manager',
          desc: 'Battery lab / Power manager\n• Don\'t restrict',
        ),
        _GuideStep(
          title: 'Background Activity',
          desc: 'Allow background activity = ON',
        ),
        _GuideStep(
          title: 'Recents Lock',
          desc: 'Lock in recent apps (যদি থাকে)',
        ),
      ],
    );
  }
}

class _GuideTab extends StatelessWidget {
  final String title;
  final List<_GuideStep> steps;

  const _GuideTab({required this.title, required this.steps});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.22)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFD4AF37), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...steps.map((s) => _GuideStepTile(step: s)),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _GuideStep {
  final String title;
  final String desc;
  final bool important;

  const _GuideStep({required this.title, required this.desc, this.important = false});
}

class _GuideStepTile extends StatelessWidget {
  final _GuideStep step;

  const _GuideStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final c = step.important ? const Color(0xFFD4AF37) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: step.important
            ? const Color(0xFFD4AF37).withOpacity(0.10)
            : const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: step.important
              ? const Color(0xFFD4AF37).withOpacity(0.26)
              : Colors.white.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: TextStyle(
              color: step.important ? const Color(0xFFD4AF37) : Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.desc,
            style: TextStyle(
              color: c.withOpacity(0.72),
              fontSize: 12.8,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}



