import 'package:flutter/material.dart';

/// A custom digital time picker widget with scrollable hour and minute wheels
/// that supports cyclic scrolling and automatic hour increment/decrement
class DigitalTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay>? onTimeChanged;
  final bool use24HourFormat;

  const DigitalTimePicker({
    super.key,
    required this.initialTime,
    this.onTimeChanged,
    this.use24HourFormat = false,
  });

  /// Show as a dialog and return selected time
  static Future<TimeOfDay?> show({
    required BuildContext context,
    required TimeOfDay initialTime,
    bool use24HourFormat = false,
  }) async {
    return showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _DigitalTimePickerDialog(
        initialTime: initialTime,
        use24HourFormat: use24HourFormat,
      ),
    );
  }

  @override
  State<DigitalTimePicker> createState() => _DigitalTimePickerState();
}

class _DigitalTimePickerState extends State<DigitalTimePicker> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;
  
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _initializeTime();
  }

  void _initializeTime() {
    if (widget.use24HourFormat) {
      _selectedHour = widget.initialTime.hour;
      _isAM = true; // Not used in 24h format
    } else {
      _selectedHour = widget.initialTime.hourOfPeriod;
      if (_selectedHour == 0) _selectedHour = 12;
      _isAM = widget.initialTime.period == DayPeriod.am;
    }
    _selectedMinute = widget.initialTime.minute;
    
    // Initialize controllers with large initial offset for infinite scroll illusion
    final hourMax = widget.use24HourFormat ? 24 : 12;
    _hourController = FixedExtentScrollController(
      initialItem: 1000 * hourMax + (_selectedHour - (widget.use24HourFormat ? 0 : 1)),
    );
    _minuteController = FixedExtentScrollController(
      initialItem: 1000 * 60 + _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  TimeOfDay get _currentTime {
    int hour;
    if (widget.use24HourFormat) {
      hour = _selectedHour;
    } else {
      hour = _selectedHour % 12;
      if (!_isAM) hour += 12;
      if (hour == 24) hour = 12;
      if (hour == 0 && _isAM) hour = 0;
    }
    return TimeOfDay(hour: hour, minute: _selectedMinute);
  }

  void _onHourChanged(int index) {
    final hourMax = widget.use24HourFormat ? 24 : 12;
    final hourMin = widget.use24HourFormat ? 0 : 1;
    setState(() {
      _selectedHour = (index % hourMax) + hourMin;
      if (!widget.use24HourFormat && _selectedHour > 12) {
        _selectedHour = _selectedHour - 12;
      }
    });
    widget.onTimeChanged?.call(_currentTime);
  }

  void _onMinuteChanged(int index) {
    final newMinute = index % 60;
    final oldMinute = _selectedMinute;
    
    setState(() {
      _selectedMinute = newMinute;
    });
    
    // Handle hour rollover
    if (oldMinute == 59 && newMinute == 0) {
      // Scrolled forward past 59
      _incrementHour();
    } else if (oldMinute == 0 && newMinute == 59) {
      // Scrolled backward past 0
      _decrementHour();
    }
    
    widget.onTimeChanged?.call(_currentTime);
  }

  void _incrementHour() {
    final hourMax = widget.use24HourFormat ? 24 : 12;
    final currentIndex = _hourController.selectedItem;
    _hourController.animateToItem(
      currentIndex + 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _decrementHour() {
    final currentIndex = _hourController.selectedItem;
    _hourController.animateToItem(
      currentIndex - 1,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _togglePeriod() {
    setState(() {
      _isAM = !_isAM;
    });
    widget.onTimeChanged?.call(_currentTime);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hour wheel
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 65),
              child: _buildWheel(
                controller: _hourController,
                itemCount: (widget.use24HourFormat ? 24 : 12) * 2000,
                selectedValue: _selectedHour,
                onChanged: _onHourChanged,
                itemBuilder: (index) {
                  final hourMax = widget.use24HourFormat ? 24 : 12;
                  final hourMin = widget.use24HourFormat ? 0 : 1;
                  int hour = (index % hourMax) + hourMin;
                  if (!widget.use24HourFormat && hour > 12) hour -= 12;
                  return hour.toString().padLeft(2, '0');
                },
              ),
            ),
          ),
          
          // Colon separator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              ':',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          
          // Minute wheel
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 65),
              child: _buildWheel(
                controller: _minuteController,
                itemCount: 60 * 2000,
                selectedValue: _selectedMinute,
                onChanged: _onMinuteChanged,
                itemBuilder: (index) => (index % 60).toString().padLeft(2, '0'),
              ),
            ),
          ),
          
          // AM/PM selector (only for 12-hour format)
          if (!widget.use24HourFormat) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _togglePeriod,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isAM ? 'AM' : 'PM',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required int itemCount,
    required int selectedValue,
    required ValueChanged<int> onChanged,
    required String Function(int) itemBuilder,
  }) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 50,
      perspective: 0.005,
      diameterRatio: 1.5,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: itemCount,
        builder: (context, index) {
          final value = itemBuilder(index);
          final isSelected = value == selectedValue.toString().padLeft(2, '0');
          
          return Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white38,
                fontSize: isSelected ? 32 : 22,
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.w300,
              ),
              child: Text(value),
            ),
          );
        },
      ),
    );
  }
              ),
              child: Text(value),
            ),
          );
        },
      ),
    );
  }
}

/// Dialog wrapper for DigitalTimePicker
class _DigitalTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool use24HourFormat;

  const _DigitalTimePickerDialog({
    required this.initialTime,
    required this.use24HourFormat,
  });

  @override
  State<_DigitalTimePickerDialog> createState() => _DigitalTimePickerDialogState();
}

class _DigitalTimePickerDialogState extends State<_DigitalTimePickerDialog> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            const Text(
              'সময় নির্বাচন করুন',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Time Picker
            DigitalTimePicker(
              initialTime: widget.initialTime,
              use24HourFormat: widget.use24HourFormat,
              onTimeChanged: (time) {
                _selectedTime = time;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'বাতিল',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selectedTime),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ঠিক আছে',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline time display with edit functionality
class DigitalTimeDisplay extends StatelessWidget {
  final TimeOfDay time;
  final VoidCallback? onTap;
  final bool showEditIcon;
  final bool isEnabled;

  const DigitalTimeDisplay({
    super.key,
    required this.time,
    this.onTap,
    this.showEditIcon = true,
    this.isEnabled = true,
  });

  String _formatTime() {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isEnabled ? const Color(0xFFD4AF37).withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatTime(),
              style: TextStyle(
                color: isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (showEditIcon && isEnabled) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.edit,
                size: 16,
                color: isEnabled ? const Color(0xFFD4AF37) : Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
