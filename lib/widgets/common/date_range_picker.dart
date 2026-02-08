import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/utils/responsive.dart';

/// A custom date range picker with:
/// - Visual range highlighting between start and end dates.
/// - A dot indicator below "Today" instead of a full circle.
/// - Dark header with localized title.
/// - Footer with "Today" quick-select and "Cancel" actions.
class DateRangePicker extends StatefulWidget {
  /// Creates a new [DateRangePicker].
  const DateRangePicker({
    required this.startDate,
    required this.endDate,
    required this.firstDate,
    required this.lastDate,
    required this.isSelectingStart,
    required this.onDateSelected,
    required this.onCancel,
    required this.onTodayPressed,
    super.key,
  });

  /// The currently selected start date.
  final DateTime? startDate;

  /// The currently selected end date.
  final DateTime? endDate;

  /// The earliest selectable date.
  final DateTime firstDate;

  /// The latest selectable date.
  final DateTime lastDate;

  /// Whether we are currently selecting the start date (true) or end date (false).
  final bool isSelectingStart;

  /// Callback when a date is selected.
  final ValueChanged<DateTime> onDateSelected;

  /// Callback when the cancel button is pressed.
  final VoidCallback onCancel;

  /// Callback when the "Today" button is pressed.
  final VoidCallback onTodayPressed;

  @override
  State<DateRangePicker> createState() => _DateRangePickerState();
}

class _DateRangePickerState extends State<DateRangePicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    // Initialize displayed month based on the relevant selected date or today.
    if (widget.isSelectingStart && widget.startDate != null) {
      _displayedMonth = DateTime(widget.startDate!.year, widget.startDate!.month);
    } else if (!widget.isSelectingStart && widget.endDate != null) {
      _displayedMonth = DateTime(widget.endDate!.year, widget.endDate!.month);
    } else {
      _displayedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    }
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  List<DateTime?> _generateDaysInMonth() {
    final int year = _displayedMonth.year;
    final int month = _displayedMonth.month;

    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int daysInMonth = DateTime(year, month + 1, 0).day;

    // Weekday of first day (0 = Sunday in our grid)
    final int startWeekday = firstDayOfMonth.weekday % 7;

    final List<DateTime?> days = <DateTime?>[];

    // Add empty cells for days before the first of the month
    for (int i = 0; i < startWeekday; i++) {
      days.add(null);
    }

    // Add actual days
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(year, month, day));
    }

    return days;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isInRange(DateTime day) {
    if (widget.startDate == null || widget.endDate == null) return false;
    return day.isAfter(widget.startDate!) && day.isBefore(widget.endDate!);
  }

  bool _isDisabled(DateTime day) {
    final DateTime dayOnly = DateTime(day.year, day.month, day.day);
    final DateTime firstOnly = DateTime(
      widget.firstDate.year,
      widget.firstDate.month,
      widget.firstDate.day,
    );
    final DateTime lastOnly = DateTime(
      widget.lastDate.year,
      widget.lastDate.month,
      widget.lastDate.day,
    );
    return dayOnly.isBefore(firstOnly) || dayOnly.isAfter(lastOnly);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    final List<String> weekdays = <String>['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final List<DateTime?> days = _generateDaysInMonth();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Responsive.h(context, 12),
              horizontal: Responsive.w(context, 16),
            ),
            color: colorScheme.onSurface,
            child: Text(
              widget.isSelectingStart
                  ? t.rally.createRally.duration.selectDateHeaderStart
                  : t.rally.createRally.duration.selectDateHeaderEnd,
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.surface,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // Month Navigation
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 8),
              vertical: Responsive.h(context, 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: _previousMonth,
                  icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                ),
                Text(
                  _getMonthYearString(_displayedMonth),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),

          // Weekday Headers
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  weekdays.map((String day) {
                    return SizedBox(
                      width: Responsive.w(context, 40),
                      child: Center(
                        child: Text(
                          day,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

          SizedBox(height: Responsive.h(context, 8)),

          // Day Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 8)),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: days.length,
              itemBuilder: (BuildContext context, int index) {
                final DateTime? day = days[index];
                if (day == null) {
                  return const SizedBox.shrink();
                }

                final bool isToday = _isSameDay(day, DateTime.now());
                final bool isStartDate = _isSameDay(day, widget.startDate);
                final bool isEndDate = _isSameDay(day, widget.endDate);
                final bool isSelected = isStartDate || isEndDate;
                final bool inRange = _isInRange(day);
                final bool disabled = _isDisabled(day);

                return _DayCell(
                  day: day,
                  isToday: isToday,
                  isSelected: isSelected,
                  inRange: inRange,
                  disabled: disabled,
                  isRangeStart: isStartDate,
                  isRangeEnd: isEndDate,
                  onTap: disabled ? null : () => widget.onDateSelected(day),
                );
              },
            ),
          ),

          SizedBox(height: Responsive.h(context, 8)),

          // Footer Actions
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 16),
              vertical: Responsive.h(context, 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: widget.onTodayPressed,
                  child: Text(
                    t.rally.createRally.duration.today,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    t.rally.createRally.actions.cancel,
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

/// A single day cell in the calendar grid.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.inRange,
    required this.disabled,
    required this.isRangeStart,
    required this.isRangeEnd,
    this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final bool inRange;
  final bool disabled;
  final bool isRangeStart;
  final bool isRangeEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Color textColor = colorScheme.onSurface;
    Color? backgroundColor;
    BorderRadius? borderRadius;

    // Determine styling based on state
    if (disabled) {
      textColor = colorScheme.onSurface.withValues(alpha: 0.3);
    } else if (isRangeStart && isRangeEnd) {
      // Single day range (same start and end)
      backgroundColor = colorScheme.primary;
      borderRadius = BorderRadius.circular(Responsive.w(context, 20));
    } else if (isRangeStart) {
      // Start date: rounded left, flat right
      backgroundColor = colorScheme.primary;
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(Responsive.w(context, 20)),
        bottomLeft: Radius.circular(Responsive.w(context, 20)),
      );
    } else if (isRangeEnd) {
      // End date: flat left, rounded right
      backgroundColor = colorScheme.primary;
      borderRadius = BorderRadius.only(
        topRight: Radius.circular(Responsive.w(context, 20)),
        bottomRight: Radius.circular(Responsive.w(context, 20)),
      );
    } else if (inRange) {
      // In between: full fill, no rounding
      backgroundColor = colorScheme.primary;
      borderRadius = BorderRadius.zero;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin:
            backgroundColor != null
                ? EdgeInsets.symmetric(vertical: Responsive.h(context, 4))
                : null,
        decoration:
            backgroundColor != null
                ? BoxDecoration(color: backgroundColor, borderRadius: borderRadius)
                : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${day.day}',
              style: textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: (isRangeStart || isRangeEnd) ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Today dot indicator (only if not selected)
            if (isToday && !isRangeStart && !isRangeEnd)
              Container(
                margin: EdgeInsets.only(top: Responsive.h(context, 2)),
                width: Responsive.w(context, 4),
                height: Responsive.w(context, 4),
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
