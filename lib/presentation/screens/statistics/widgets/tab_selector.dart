import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TabSelector extends StatelessWidget {
  final bool isWeeklyView;
  final Function(bool) onTabChanged;

  const TabSelector({
    super.key,
    required this.isWeeklyView,
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
              onTap: () => onTabChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isWeeklyView ? AppTheme.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'সাপ্তাহিক',
                    style: TextStyle(
                      color: isWeeklyView ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Monthly Tab
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: !isWeeklyView ? AppTheme.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Center(
                  child: Text(
                    'মাসিক',
                    style: TextStyle(
                      color: !isWeeklyView ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
