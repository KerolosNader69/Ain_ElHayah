import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../screens/doctors_screen.dart';
import '../models/time_slot.dart';
import '../providers/appointment_provider.dart';

class TimeSlotSelectionScreen extends StatefulWidget {
  final Doctor doctor;
  final Function(DateTime selectedDateTime) onTimeSlotSelected;

  const TimeSlotSelectionScreen({
    super.key,
    required this.doctor,
    required this.onTimeSlotSelected,
  });

  @override
  State<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  TimeSlot? _selectedTimeSlot;
  List<TimeSlot> _availableSlots = [];

  @override
  void initState() {
    super.initState();
    // Set initial selected day to today
    _selectedDay = DateTime.now();
    _loadAvailableSlots();
  }

  void _loadAvailableSlots() {
    if (_selectedDay != null) {
      final provider = context.read<AppointmentProvider>();
      setState(() {
        _availableSlots = provider.getAvailableSlots(widget.doctor, _selectedDay!);
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedTimeSlot = null; // Reset time slot selection
    });
    _loadAvailableSlots();
  }

  void _onTimeSlotTapped(TimeSlot slot) {
    if (slot.isAvailable) {
      setState(() {
        _selectedTimeSlot = slot;
      });
    }
  }

  void _onContinue() {
    if (_selectedTimeSlot != null) {
      widget.onTimeSlotSelected(_selectedTimeSlot!.dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isPhone = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isPhone ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Select Date & Time',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Choose your preferred appointment date and time',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Calendar
          _buildCalendar(context, theme),
          
          const SizedBox(height: 24),
          
          // Selected Date Display
          if (_selectedDay != null) ...[
            Text(
              'Available Times',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Time Slots Grid
            _buildTimeSlotsGrid(context, theme),
            
            const SizedBox(height: 24),
            
            // Timezone Info
            _buildTimezoneInfo(context, theme),
            
            const SizedBox(height: 24),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTimeSlot != null ? _onContinue : null,
                style: AppTheme.getPrimaryButtonStyle(context).copyWith(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, ThemeData theme) {
    final now = DateTime.now();
    final firstDay = now;
    final lastDay = now.add(const Duration(days: 30));

    return Container(
      decoration: AppTheme.getCardDecoration(context),
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: firstDay,
        lastDay: lastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ) ?? const TextStyle(),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppTheme.getTextColor(context),
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.getTextColor(context),
          ),
        ),
        calendarStyle: CalendarStyle(
          // Today
          todayDecoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(
            color: AppTheme.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
          // Selected
          selectedDecoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          // Default
          defaultTextStyle: TextStyle(
            color: AppTheme.getTextColor(context),
          ),
          // Weekend
          weekendTextStyle: TextStyle(
            color: AppTheme.getTextColor(context),
          ),
          // Outside month
          outsideTextStyle: TextStyle(
            color: AppTheme.getTextColor(context, isDescription: true),
          ),
          // Disabled
          disabledTextStyle: TextStyle(
            color: AppTheme.getTextColor(context, isDescription: true)
                .withOpacity(0.5),
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppTheme.getTextColor(context, isDescription: true),
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: AppTheme.getTextColor(context, isDescription: true),
            fontWeight: FontWeight.w600,
          ),
        ),
        enabledDayPredicate: (day) {
          // Only enable dates from today onwards
          return day.isAfter(now.subtract(const Duration(days: 1)));
        },
      ),
    );
  }

  Widget _buildTimeSlotsGrid(BuildContext context, ThemeData theme) {
    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: AppTheme.getCardDecoration(context),
        child: Center(
          child: Text(
            'No available time slots for this date',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextColor(context, isDescription: true),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isPhone = constraints.maxWidth < 600;
        final crossAxisCount = isPhone ? 3 : 4;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: _availableSlots.length,
          itemBuilder: (context, index) {
            final slot = _availableSlots[index];
            final isSelected = _selectedTimeSlot?.dateTime == slot.dateTime;
            
            return _buildTimeSlotButton(
              context,
              theme,
              slot,
              isSelected,
            );
          },
        );
      },
    );
  }

  Widget _buildTimeSlotButton(
    BuildContext context,
    ThemeData theme,
    TimeSlot slot,
    bool isSelected,
  ) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (!slot.isAvailable) {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context, isDescription: true)
          .withOpacity(0.5);
      borderColor = AppTheme.getBorderColor(context).withOpacity(0.5);
    } else if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
      borderColor = AppTheme.primaryColor;
    } else {
      backgroundColor = AppTheme.getMutedBackgroundColor(context);
      textColor = AppTheme.getTextColor(context);
      borderColor = AppTheme.getBorderColor(context);
    }

    return InkWell(
      onTap: slot.isAvailable ? () => _onTimeSlotTapped(slot) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            slot.displayTime,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimezoneInfo(BuildContext context, ThemeData theme) {
    final timezone = DateTime.now().timeZoneName;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'All times shown in $timezone timezone',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
