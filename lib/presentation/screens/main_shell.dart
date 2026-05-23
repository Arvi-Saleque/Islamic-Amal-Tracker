import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/main_shell_tab_provider.dart';
import 'home/home_screen.dart';
import 'settings/reminders_screen.dart';
import 'dhikr/dhikr_counter_screen.dart';
import 'doa/doa_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _screens = [
    HomeScreen(),
    RemindersScreen(),
    DoaScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainShellTabIndexProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const gold = Color(0xFFD4AF37);
    final activeColor = isDark ? gold : cs.primary;
    final inactiveColor = cs.onSurface.withOpacity(0.45);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(mainShellTabIndexProvider.notifier).state = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Golden gradient top divider
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    activeColor.withOpacity(0.25),
                    activeColor.withOpacity(0.55),
                    activeColor.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                ref.read(mainShellTabIndexProvider.notifier).state = index;
              },
              backgroundColor: cs.surface,
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: activeColor.withOpacity(0.14),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 300),
              destinations: [
                _buildDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'tab_home'.tr(),
                  isSelected: currentIndex == 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDestination(
                  icon: Icons.notifications_outlined,
                  selectedIcon: Icons.notifications_rounded,
                  label: 'tab_reminders'.tr(),
                  isSelected: currentIndex == 1,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDestination(
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book_rounded,
                  label: 'tab_dua'.tr(),
                  isSelected: currentIndex == 2,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDestination(
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart_rounded,
                  label: 'tab_statistics'.tr(),
                  isSelected: currentIndex == 3,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildDestination(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: 'tab_settings'.tr(),
                  isSelected: currentIndex == 4,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return NavigationDestination(
      icon: Icon(icon, color: inactiveColor, size: 24),
      selectedIcon: Icon(selectedIcon, color: activeColor, size: 24),
      label: label,
    );
  }
}
