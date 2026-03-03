import 'dart:io';
import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
        permissionName = 'reminder_set_perm_notification'.tr();
        break;
      case Permission.scheduleExactAlarm:
        permissionName = 'reminder_set_perm_exact_alarm'.tr();
        break;
      default:
        permissionName = 'reminder_set_perm_this'.tr();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'permission_required'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          'reminder_set_perm_dialog_msg'.tr(namedArgs: {'perm': permissionName}),
          style: TextStyle(color: Colors.white70, height: 1.35),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(), style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              'reminder_set_go_settings'.tr(),
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
        _showSnackBar('reminder_set_grant_perm'.tr());
        return;
      }
    }

    await DailyReminderService.showTestNotification();
    _showSnackBar('reminder_set_test_sent'.tr());
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
          'reminder_set_title'.tr(),
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
            'reminder_set_perm_status'.tr(),
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
          title: 'reminder_set_perm_notification'.tr(),
          description: 'reminder_set_perm_desc_notification'.tr(),
          icon: Icons.notifications,
        ),
        const SizedBox(height: 10),
        if (_isAndroid12Plus)
          _buildPermissionTile(
            permission: Permission.scheduleExactAlarm,
            title: 'reminder_set_perm_exact_alarm'.tr(),
            description: 'reminder_set_perm_desc_exact_alarm'.tr(),
            icon: Icons.alarm,
          ),
        if (!_isAndroid12Plus)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'reminder_set_android12_note'.tr(),
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
                        isGranted
                            ? 'reminder_set_granted'.tr()
                            : 'reminder_set_required'.tr(),
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
              child: Text(
                'reminder_set_grant_btn'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
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
              Expanded(
                child: Text(
                  'reminder_set_not_working'.tr(),
                  style: const TextStyle(
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
            'reminder_set_battery_guide_intro'.tr(),
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
                      label: Text('reminder_set_my_phone'.tr()),
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
                  label: Text('reminder_set_all_brands'.tr()),
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
        label: Text('reminder_set_test'.tr()),
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
                  _buildSectionTitle('reminder_set_all_for'.tr(), context),
                  _buildCommonSettings(context),
                  const SizedBox(height: 22),
                  _buildSectionTitle(
                    'reminder_set_brand_specific'
                        .tr(namedArgs: {'brand': _getBrandDisplayName(brand)}),
                    context,
                  ),
                  _buildBrandSpecificSettings(brand, context),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings),
                      label: Text('reminder_set_open_app_settings'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
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
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_a_title'.tr(),
          'reminder_set_guide_a_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_b_title'.tr(),
          'reminder_set_guide_b_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_c_title'.tr(),
          'reminder_set_guide_c_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_d_title'.tr(),
          'reminder_set_guide_d_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_f_title'.tr(),
          'reminder_set_guide_f_desc'.tr(namedArgs: {'appName': appName}),
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
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_xiaomi_autostart_title'.tr(),
          'reminder_set_guide_xiaomi_autostart_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_xiaomi_battery_title'.tr(),
          'reminder_set_guide_xiaomi_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_xiaomi_recents_title'.tr(),
          'reminder_set_guide_xiaomi_recents_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_xiaomi_security_title'.tr(),
          'reminder_set_guide_xiaomi_security_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildSamsungSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_samsung_sleeping_title'.tr(),
          'reminder_set_guide_samsung_sleeping_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_samsung_battery_title'.tr(),
          'reminder_set_guide_samsung_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_samsung_notif_title'.tr(),
          'reminder_set_guide_samsung_notif_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildOnePlusSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_oneplus_autostart_title'.tr(),
          'reminder_set_guide_oneplus_autostart_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_oneplus_deep_title'.tr(),
          'reminder_set_guide_oneplus_deep_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_oneplus_battery_title'.tr(),
          'reminder_set_guide_oneplus_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildOppoSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_oppo_autostart_title'.tr(),
          'reminder_set_guide_oppo_autostart_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_oppo_battery_title'.tr(),
          'reminder_set_guide_oppo_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildVivoSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_vivo_autostart_title'.tr(),
          'reminder_set_guide_vivo_autostart_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_vivo_high_title'.tr(),
          'reminder_set_guide_vivo_high_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_vivo_battery_title'.tr(),
          'reminder_set_guide_vivo_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildHuaweiSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_huawei_launch_title'.tr(),
          'reminder_set_guide_huawei_launch_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_huawei_battery_title'.tr(),
          'reminder_set_guide_huawei_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildMotorolaSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_samsung_battery_title'.tr(),
          'reminder_set_guide_motorola_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_oneplus_battery_title'.tr(),
          'reminder_set_guide_motorola_opt_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_c_title'.tr(),
          'reminder_set_guide_data_desc'.tr(),
        ),
      ],
    );
  }

  Widget _buildPixelSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_pixel_battery_title'.tr(),
          'reminder_set_guide_pixel_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_pixel_saver_title'.tr(),
          'reminder_set_guide_pixel_saver_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_pixel_exact_title'.tr(),
          'reminder_set_guide_pixel_exact_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildTecnoSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_tecno_autostart_title'.tr(),
          'reminder_set_guide_tecno_autostart_desc'.tr(namedArgs: {'appName': appName}),
          isImportant: true,
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_tecno_battery_title'.tr(),
          'reminder_set_guide_tecno_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_tecno_background_title'.tr(),
          'reminder_set_guide_tecno_background_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_tecno_recents_title'.tr(),
          'reminder_set_guide_tecno_recents_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildGenericSettings(BuildContext context) {
    final appName = 'app_name'.tr();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingItem(
          context,
          'reminder_set_guide_b_title'.tr(),
          'reminder_set_guide_b_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_generic_autostart_title'.tr(),
          'reminder_set_guide_generic_autostart_note'.tr(),
        ),
        _buildSettingItem(
          context,
          'reminder_set_guide_c_title'.tr(),
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
    {'id': 'all', 'name': null, 'icon': Icons.android},
    {'id': 'xiaomi', 'name': 'Xiaomi', 'icon': Icons.phone_android},
    {'id': 'samsung', 'name': 'Samsung', 'icon': Icons.phone_android},
    {'id': 'oneplus', 'name': 'OnePlus', 'icon': Icons.phone_android},
    {'id': 'oppo_realme', 'name': 'Oppo/Realme', 'icon': Icons.phone_android},
    {'id': 'vivo', 'name': 'Vivo', 'icon': Icons.phone_android},
    {'id': 'huawei', 'name': 'Huawei', 'icon': Icons.phone_android},
    {'id': 'pixel', 'name': 'Pixel', 'icon': Icons.phone_android},
    {'id': 'tecno', 'name': 'Tecno', 'icon': Icons.phone_android},
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
                        'reminder_set_brand_guide'.tr(),
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
              tabs: _brands.map((b) {
                if (b['id'] == 'all') {
                  return Tab(text: 'reminder_set_all_for_label'.tr());
                }
                return Tab(text: b['name'] as String);
              }).toList(),
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommonTab(context),
                _buildXiaomiTab(context),
                _buildSamsungTab(context),
                _buildOnePlusTab(context),
                _buildOppoTab(context),
                _buildVivoTab(context),
                _buildHuaweiTab(context),
                _buildPixelTab(context),
                _buildTecnoTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_common_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_a_title'.tr(),
          desc: 'reminder_set_guide_a_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_b_title'.tr(),
          desc: 'reminder_set_guide_b_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_c_title'.tr(),
          desc: 'reminder_set_guide_c_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_d_title'.tr(),
          desc: 'reminder_set_guide_d_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_e_title'.tr(),
          desc: 'reminder_set_guide_e_desc'.tr(),
        ),
        _GuideStep(
          title: 'reminder_set_guide_f_title'.tr(),
          desc: 'reminder_set_guide_f_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildXiaomiTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_xiaomi_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_xiaomi_autostart_title'.tr(),
          desc: 'reminder_set_guide_xiaomi_autostart_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_xiaomi_battery_title'.tr(),
          desc: 'reminder_set_guide_xiaomi_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_xiaomi_recents_title'.tr(),
          desc: 'reminder_set_guide_xiaomi_recents_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_xiaomi_security_title'.tr(),
          desc: 'reminder_set_guide_xiaomi_security_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildSamsungTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_samsung_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_samsung_sleeping_title'.tr(),
          desc: 'reminder_set_guide_samsung_sleeping_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_samsung_battery_title'.tr(),
          desc: 'reminder_set_guide_samsung_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_samsung_notif_title'.tr(),
          desc: 'reminder_set_guide_samsung_notif_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildOnePlusTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_oneplus_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_oneplus_autostart_title'.tr(),
          desc: 'reminder_set_guide_oneplus_autostart_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_oneplus_deep_title'.tr(),
          desc: 'reminder_set_guide_oneplus_deep_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_oneplus_battery_title'.tr(),
          desc: 'reminder_set_guide_oneplus_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_oneplus_recents_title'.tr(),
          desc: 'reminder_set_guide_oneplus_recents_desc'.tr(),
        ),
      ],
    );
  }

  Widget _buildOppoTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_oppo_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_oppo_autostart_title'.tr(),
          desc: 'reminder_set_guide_oppo_autostart_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_oppo_battery_title'.tr(),
          desc: 'reminder_set_guide_oppo_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildVivoTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_vivo_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_vivo_autostart_title'.tr(),
          desc: 'reminder_set_guide_vivo_autostart_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_vivo_high_title'.tr(),
          desc: 'reminder_set_guide_vivo_high_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_vivo_battery_title'.tr(),
          desc: 'reminder_set_guide_vivo_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildHuaweiTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_huawei_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_huawei_launch_title'.tr(),
          desc: 'reminder_set_guide_huawei_launch_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_huawei_battery_title'.tr(),
          desc: 'reminder_set_guide_huawei_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildPixelTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_pixel_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_pixel_battery_title'.tr(),
          desc: 'reminder_set_guide_pixel_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_pixel_saver_title'.tr(),
          desc: 'reminder_set_guide_pixel_saver_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_pixel_exact_title'.tr(),
          desc: 'reminder_set_guide_pixel_exact_desc'.tr(namedArgs: {'appName': appName}),
        ),
      ],
    );
  }

  Widget _buildTecnoTab(BuildContext context) {
    final appName = 'app_name'.tr();
    return _GuideTab(
      title: 'reminder_set_guide_tecno_title'.tr(),
      steps: [
        _GuideStep(
          title: 'reminder_set_guide_tecno_autostart_title'.tr(),
          desc: 'reminder_set_guide_tecno_autostart_desc'.tr(namedArgs: {'appName': appName}),
          important: true,
        ),
        _GuideStep(
          title: 'reminder_set_guide_tecno_battery_title'.tr(),
          desc: 'reminder_set_guide_tecno_battery_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_tecno_background_title'.tr(),
          desc: 'reminder_set_guide_tecno_background_desc'.tr(namedArgs: {'appName': appName}),
        ),
        _GuideStep(
          title: 'reminder_set_guide_tecno_recents_title'.tr(),
          desc: 'reminder_set_guide_tecno_recents_desc'.tr(namedArgs: {'appName': appName}),
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



