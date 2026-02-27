import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_screen.dart';
import 'settings/reminders_screen.dart';
import 'dhikr/dhikr_counter_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    RemindersScreen(),
    DhikrCounterScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    const gold = Color(0xFFD4AF37);
    final activeColor = isDark ? gold : cs.primary;
    final inactiveColor = cs.onSurface.withOpacity(0.45);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
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
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
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
                label: 'হোম',
                isSelected: _currentIndex == 0,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildDestination(
                icon: Icons.notifications_outlined,
                selectedIcon: Icons.notifications_rounded,
                label: 'রিমাইন্ডার',
                isSelected: _currentIndex == 1,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildDestination(
                icon: Icons.favorite_outline_rounded,
                selectedIcon: Icons.favorite_rounded,
                label: 'যিকির',
                isSelected: _currentIndex == 2,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildDestination(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart_rounded,
                label: 'পরিসংখ্যান',
                isSelected: _currentIndex == 3,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
              _buildDestination(
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'সেটিংস',
                isSelected: _currentIndex == 4,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ],
          ),
        ],
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
