import 'dart:io';
import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../services/daily_reminder_service.dart';
import '../statistics/widgets/digital_time_picker.dart';

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
        title: Text(
          'অনুমতি প্রয়োজন',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          '$permissionName অনুমতি সেটিংস থেকে দিতে হবে।',
          style: TextStyle(color: Colors.white70, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'সেটিংসে যান',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
    final colors = Theme.of(context).colorScheme;

    final iconColor = colors.primary;
    final titleColor = colors.primary;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[0],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[1],
                Theme.of(context)
                    .extension<GradientColors>()!
                    .appBarGradient[2],
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).extension<GradientColors>()!.appBarBorder,
                width: 1.5,
              ),
            ),
          ),
        ),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'নামাজের হিসাব',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context)
                    .extension<GradientColors>()!
                    .backgroundGradient[0],
              Theme.of(context)
                    .extension<GradientColors>()!
                    .backgroundGradient[1],
            ],
          ),
        ),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              )
            : RefreshIndicator(
                onRefresh: _checkPermissions,
                color: Theme.of(context).colorScheme.primary,
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
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            'অনুমতি স্থিতি',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
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

    final badgeColor = isGranted ? Theme.of(context).colorScheme.primary : const Color(0xFFFF5A5A);
    final gradients = Theme.of(context).extension<GradientColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients.cardGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
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
                    color: gradients.bulletTextColor,
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child:  const Text(
                'দিন',
                style: TextStyle(
                  fontSize: 12, fontWeight: 
                  FontWeight.w900,
                  color: Colors.white
                  ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOemSettingsCard() {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients.cardGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primary.withOpacity(0.24),
                  ),
                ),
                child: Icon(Icons.tips_and_updates, color: primary, size: 20),
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
              color: gradients.bulletTextColor,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
    final a = accent ?? Theme.of(context).colorScheme.primary;

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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF151515),
            Color(0xFF111111),
            Color(0xFF141414),
          ],
        ),
      ),
      child: child,
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradients.backgroundGradient,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.phone_android, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getBrandDisplayName(brand),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            model,
                            style:  TextStyle(
                              color: Theme.of(context).extension<GradientColors>()!.bulletTextColor,
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
                  _buildSectionTitle('সব Android ফোনের জন্য (আগে এগুলো চেক করুন)', context),
                  _buildCommonSettings(context),
                  const SizedBox(height: 22),
                  _buildSectionTitle('${_getBrandDisplayName(brand)} এর জন্য বিশেষ সেটিংস', context),
                  _buildBrandSpecificSettings(brand, context),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: const Text('অ্যাপ সেটিংস খুলুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildCommonSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'A) App Notifications',
          'Settings → Apps → আমল ট্রাকার → Notifications\n'
              '• Allow notifications = ON\n'
              '• Lock screen / Pop-up / Banner / Sound = ON',
        ),
        _buildSettingItem(
          context,
          'B) Battery Optimization বন্ধ',
          'Settings → Apps → আমল ট্রাকার → Battery\n'
              '• Unrestricted / Don\'t optimize সিলেক্ট করুন',
        ),
        _buildSettingItem(
          context,
          'C) Background Data',
          'Settings → Apps → আমল ট্রাকার → Mobile data & Wi-Fi\n'
              '• Background data = ON\n'
              '• Unrestricted data usage = ON',
        ),
        _buildSettingItem(
          context,
          'D) Unused app বন্ধ',
          'App info → আমল ট্রাকার\n'
              '• Pause app activity if unused = OFF\n'
              '• Remove permissions if unused = OFF',
        ),
        _buildSettingItem(
          context,
          'E) Exact Alarm (Android 12+)',
          'Settings → Special app access → Alarms & reminders\n'
              '• Allow',
        ),
      ],
    );
  }

  Widget _buildBrandSpecificSettings(String brand, BuildContext context) {
    switch (brand.toLowerCase()) {
      case 'xiaomi':
      case 'redmi':
      case 'poco':
        return _buildXiaomiSettings(context);
      case 'samsung':
        return _buildSamsungSettings(context);
      case 'oneplus':
        return _buildOnePlusSettings(context);
      case 'oppo':
      case 'realme':
        return _buildOppoSettings(context);
      case 'vivo':
      case 'iqoo':
        return _buildVivoSettings(context);
      case 'huawei':
      case 'honor':
        return _buildHuaweiSettings(context);
      case 'motorola':
        return _buildMotorolaSettings(context);
      case 'google':
        return _buildPixelSettings(context);
      case 'tecno':
      case 'infinix':
      case 'itel':
        return _buildTecnoSettings(context);
      default:
        return _buildGenericSettings(context);
    }
  }

  Widget _buildXiaomiSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Auto-start (সবচেয়ে গুরুত্বপূর্ণ)',
          'Settings → Apps → Permissions → Autostart / Background autostart\n'
              '• আমল ট্র্যাকার = ON',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery Settings',
          'Settings → Apps → Manage apps → আমল ট্র্যাকার → Battery\n'
              '• No restrictions / Unrestricted\n'
              '• Allow background activity = ON',
        ),
        _buildSettingItem(
          context,
          'Recents Lock',
          'Recent apps খুলুন → আমল ট্র্যাকার লং প্রেস → Lock',
        ),
        _buildSettingItem(
          context,
          'Security App',
          'Security app → Battery → App battery saver\n'
              '• No restrictions',
        ),
      ],
    );
  }

  Widget _buildSamsungSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Sleeping Apps বন্ধ',
          'Settings → Battery → Background usage limits\n'
              '• Put unused apps to sleep = OFF\n'
              '• Sleeping apps / Deep sleeping apps থেকে আমল ট্র্যাকার Remove করুন',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
              '• Unrestricted',
        ),
        _buildSettingItem(
          context,
          'Notifications',
          'Settings → Notifications → App notifications\n'
              '• আমল ট্র্যাকার = ON\n'
              '• Notification categories সব ON',
        ),
      ],
    );
  }

  Widget _buildOnePlusSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Auto-launch Enable',
          'Settings → Apps → Special app access → Auto-launch\n'
              '• আমল ট্র্যাকার = Enable',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          '⭐ Deep Optimization বন্ধ',
          'Settings → Battery → Deep optimization\n'
              '• OFF করুন অথবা আমল ট্র্যাকার exclude করুন',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
              '• আমল ট্র্যাকার → Don\'t optimize',
        ),
      ],
    );
  }

  Widget _buildOppoSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Auto-launch / Startup Manager',
          'Settings → Apps → Special app access → Auto-launch / Startup manager\n'
              '• আমল ট্র্যাকার = Enable\n'
              '• Secondary launch / Background launch = Allow',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
              '• আমল ট্র্যাকার → Don\'t optimize',
        ),
      ],
    );
  }

  Widget _buildVivoSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Auto-start',
          'Settings → Battery → Background power consumption management / Autostart\n'
              '• আমল ট্র্যাকার = Allow',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'High Background Power',
          'Settings → Battery → High background power consumption\n'
              '• আমল ট্র্যাকার = Allow / Don\'t restrict',
        ),
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Apps → আমল ট্র্যাকার → Battery\n'
              '• No restrictions',
        ),
      ],
    );
  }

  Widget _buildHuaweiSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ App Launch (Manual)',
          'Settings → Apps → App launch → আমল ট্র্যাকার\n'
              '• Manage manually = ON\n'
              '• Auto-launch = ON\n'
              '• Secondary launch = ON\n'
              '• Run in background = ON',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Battery optimization\n'
              '• Don\'t allow optimize / Unrestricted',
        ),
      ],
    );
  }

  Widget _buildMotorolaSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'Battery',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
              '• Unrestricted',
        ),
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Settings → Battery → Battery optimization\n'
              '• আমল ট্র্যাকার → Not optimized',
        ),
        _buildSettingItem(
          context,
          'Data',
          'Mobile data → Background data = ON',
        ),
      ],
    );
  }

  Widget _buildPixelSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
              '• Unrestricted',
        ),
        _buildSettingItem(
          context,
          'Battery Saver',
          'Settings → Battery → Battery Saver\n'
              '• OFF থাকলে ভালো (ON থাকলে delay হতে পারে)',
        ),
        _buildSettingItem(
          context,
          'Exact Alarm',
          'Settings → Apps → Special app access → Alarms & reminders\n'
              '• আমল ট্র্যাকার = Allow',
        ),
      ],
    );
  }

  Widget _buildTecnoSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          '⭐ Auto-start',
          'Settings → Apps → Autostart manager\n'
              '• আমল ট্র্যাকার = Enable',
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'Battery/Power Manager',
          'Battery lab / Power manager\n'
              '• Don\'t restrict',
        ),
        _buildSettingItem(
          context,
          'Background Activity',
          'Allow background activity = ON',
        ),
        _buildSettingItem(
          context,
          'Recents Lock',
          'Lock in recent apps (যদি থাকে)',
        ),
      ],
    );
  }

  Widget _buildGenericSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'Battery Optimization',
          'Settings → Apps → আমল ট্র্যাকার → Battery\n'
              '• Unrestricted / Don\'t optimize',
        ),
        _buildSettingItem(
          context,
          'Auto-start (যদি থাকে)',
          'Settings → Apps → Special app access → Auto-launch\n'
              '• Enable করুন',
        ),
        _buildSettingItem(
          context,
          'Background Data',
          'Background data = ON',
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String description, {
    bool isImportant = false,
  }) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients.cardGradient,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isImportant
              ? primary.withOpacity(0.28)
              : primary.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
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
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style:  TextStyle(
              color: Theme.of(context).extension<GradientColors>()!.bulletTextColor,
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradients.backgroundGradient,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              border: Border(
                bottom: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ব্র্যান্ড অনুযায়ী গাইড',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).extension<GradientColors>()!.bulletTextColor),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).extension<GradientColors>()!.bulletTextColor,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
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
    return const _GuideTab(
      title: 'সব Android ফোনে আগে এগুলো চেক করুন',
      steps: [
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
    return const _GuideTab(
      title: 'Xiaomi / Redmi / Poco (MIUI / HyperOS)',
      steps: [
        _GuideStep(
          title: 'Auto-start (সবচেয়ে গুরুত্বপূর্ণ)',
          desc:
              'Settings → Apps → Permissions → Autostart / Background autostart\n• আমল ট্র্যাকার = ON',
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
    return const _GuideTab(
      title: 'Samsung (One UI)',
      steps: [
        _GuideStep(
          title: 'Sleeping Apps বন্ধ',
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
    return const _GuideTab(
      title: 'OnePlus (OxygenOS)',
      steps: [
        _GuideStep(
          title: 'Auto-launch Enable',
          desc:
              'Settings → Apps → Special app access → Auto-launch\n• আমল ট্র্যাকার = Enable\n• Secondary launch / Background launch = Allow',
          important: true,
        ),
        _GuideStep(
          title: 'Deep Optimization বন্ধ',
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
    return const _GuideTab(
      title: 'Oppo / Realme (ColorOS / Realme UI)',
      steps: [
        _GuideStep(
          title: 'Auto-launch / Startup',
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
    return const _GuideTab(
      title: 'Vivo / iQOO (Funtouch OS)',
      steps: [
        _GuideStep(
          title: 'Auto-start',
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
    return const _GuideTab(
      title: 'Huawei / Honor (EMUI / MagicOS)',
      steps: [
        _GuideStep(
          title: 'App Launch (Manual)',
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
    return const _GuideTab(
      title: 'Google Pixel / Stock Android',
      steps: [
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
    return const _GuideTab(
      title: 'Tecno / Infinix / Itel (HiOS / XOS)',
      steps: [
        _GuideStep(
          title: 'Auto-start',
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients.cardGradient,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primary.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primary,
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
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradients.cardGradient,
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: step.important
              ? primary.withOpacity(0.26)
              : primary.withOpacity(0.1),
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
              color: primary,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.desc,
            style: TextStyle(
              color: gradients.bulletTextColor,
              fontSize: 12.8,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}



