import 'package:amal_tracker/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum StatisticsTab { weekly, monthly, qaza }

class TabSelector extends StatelessWidget {
  final StatisticsTab selectedTab;
  final Function(StatisticsTab) onTabChanged;

  const TabSelector({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = Theme.of(context).extension<GradientColors>()!;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final shadowColor = Theme.of(context).shadowColor;
    final bulletTextColor = gradients.bulletTextColor;
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: shadowColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Weekly Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(StatisticsTab.weekly),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == StatisticsTab.weekly 
                      ? primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'সাপ্তাহিক',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.weekly 
                          ? onPrimary 
                          : bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Monthly Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(StatisticsTab.monthly),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == StatisticsTab.monthly 
                      ? primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'মাসিক',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.monthly 
                          ? onPrimary 
                          : bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Qaza Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(StatisticsTab.qaza),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == StatisticsTab.qaza 
                      ? primary 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'কাজা',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.qaza 
                          ? onPrimary 
                          : bulletTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
