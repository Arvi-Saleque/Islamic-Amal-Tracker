import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
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
                      ? AppTheme.primaryGold 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'সাপ্তাহিক',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.weekly 
                          ? Colors.black 
                          : Colors.grey,
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
                      ? AppTheme.primaryGold 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'মাসিক',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.monthly 
                          ? Colors.black 
                          : Colors.grey,
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
                      ? AppTheme.primaryGold 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'কাজা',
                    style: TextStyle(
                      color: selectedTab == StatisticsTab.qaza 
                          ? Colors.black 
                          : Colors.grey,
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
