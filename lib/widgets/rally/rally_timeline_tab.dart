import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rally/utils/responsive.dart';

/// POC Timeline tab for a rally screen.
///
/// Displays a horizontal date selector spanning the rally date range,
/// time-of-day sections (Morning, Afternoon, Evening) with hardcoded
/// event cards, and a "Create Event Card" button.
class RallyTimelineTab extends StatefulWidget {
  /// Creates a new [RallyTimelineTab].
  const RallyTimelineTab({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  /// Rally start date.
  final DateTime startDate;

  /// Rally end date.
  final DateTime endDate;

  @override
  State<RallyTimelineTab> createState() => _RallyTimelineTabState();
}

class _RallyTimelineTabState extends State<RallyTimelineTab> {
  late List<DateTime> _dates;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _dates = _generateDateRange(widget.startDate, widget.endDate);
    _selectedIndex = 0;
  }

  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final List<DateTime> dates = <DateTime>[];
    DateTime current = DateTime(start.year, start.month, start.day);
    final DateTime last = DateTime(end.year, end.month, end.day);
    while (!current.isAfter(last)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      children: <Widget>[
        // ── Date slider ──
        _buildDateSlider(colorScheme, textTheme),

        // ── Day header ──
        _buildDayHeader(colorScheme, textTheme),

        // ── Event list with floating create button ──
        Expanded(
          child: Stack(
            children: <Widget>[
              ListView(
                padding: EdgeInsets.only(
                  bottom: Responsive.h(context, 80) +
                      MediaQuery.of(context).padding.bottom,
                ),
                children: <Widget>[
                  _buildTimeSection(
                    colorScheme,
                    textTheme,
                    label: 'Morning',
                    icon: Icons.wb_sunny_outlined,
                    events: <_MockEvent>[
                      _MockEvent(
                        title: 'Cultural & city landmarks',
                        time: '8:00 – 11:00',
                        description:
                            'Lorem ipsum dolor sit amet consectetur. Nunc vestibulum suspendisse et non at s...',
                        icon: Icons.directions_walk_rounded,
                      ),
                    ],
                  ),
                  _buildTimeSection(
                    colorScheme,
                    textTheme,
                    label: 'Afternoon',
                    icon: Icons.wb_sunny_outlined,
                    events: <_MockEvent>[
                      _MockEvent(
                        title: 'History & local life',
                        time: '13:00 – 16:00',
                        description:
                            'Lorem ipsum dolor sit amet consectetur. Nunc vestibulum suspendisse et non at s...',
                        icon: Icons.directions_walk_rounded,
                      ),
                    ],
                  ),
                  _buildTimeSection(
                    colorScheme,
                    textTheme,
                    label: 'Evening',
                    icon: Icons.nightlight_outlined,
                    events: <_MockEvent>[
                      _MockEvent(
                        title: 'Hotel Check-in',
                        time: '18:00 – 21:00',
                        description:
                            'Lorem ipsum dolor sit amet consectetur. Nunc vestibulum suspendisse et non at s...',
                        icon: Icons.directions_walk_rounded,
                      ),
                    ],
                  ),
                ],
              ),

              // ── Floating Create Event Card button ──
              Positioned(
                left: Responsive.w(context, 20),
                right: Responsive.w(context, 20),
                bottom: Responsive.h(context, 16) +
                    MediaQuery.of(context).padding.bottom,
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Navigate to create event
                  },
                  icon: Icon(
                    Icons.add_rounded,
                    size: Responsive.w(context, 20),
                  ),
                  label: Text(
                    'Create Event Card',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    minimumSize: Size(
                      double.infinity,
                      Responsive.h(context, 52),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 26),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Date slider ──

  Widget _buildDateSlider(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      height: Responsive.h(context, 72),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 12),
        ),
        itemCount: _dates.length,
        itemBuilder: (BuildContext context, int index) {
          final DateTime date = _dates[index];
          final bool isSelected = index == _selectedIndex;
          final bool isToday = _isToday(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: Container(
              width: Responsive.w(context, 52),
              margin: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 4),
                vertical: Responsive.h(context, 8),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(
                  Responsive.w(context, 12),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 2)),
                  Text(
                    date.day.toString(),
                    style: textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (isToday)
                    Container(
                      margin: EdgeInsets.only(top: Responsive.h(context, 2)),
                      width: Responsive.w(context, 5),
                      height: Responsive.w(context, 5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Day header ──

  Widget _buildDayHeader(ColorScheme colorScheme, TextTheme textTheme) {
    final int dayNumber = _selectedIndex + 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 20),
        Responsive.h(context, 14),
        Responsive.w(context, 20),
        Responsive.h(context, 8),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Day $dayNumber : City Name',
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  // ── Time-of-day section ──

  Widget _buildTimeSection(
    ColorScheme colorScheme,
    TextTheme textTheme, {
    required String label,
    required IconData icon,
    required List<_MockEvent> events,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Section header
          Padding(
            padding: EdgeInsets.only(
              top: Responsive.h(context, 12),
              bottom: Responsive.h(context, 8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  icon,
                  size: Responsive.w(context, 18),
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),

          // Event cards
          ...events.map(
            (_MockEvent event) => _buildEventCard(
              colorScheme,
              textTheme,
              event,
            ),
          ),
        ],
      ),
    );
  }

  // ── Event card ──

  Widget _buildEventCard(
    ColorScheme colorScheme,
    TextTheme textTheme,
    _MockEvent event,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: Responsive.h(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Left icon
          CircleAvatar(
            radius: Responsive.w(context, 18),
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Icon(
              event.icon,
              size: Responsive.w(context, 18),
              color: colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(width: Responsive.w(context, 12)),

          // Card content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(Responsive.w(context, 14)),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  Responsive.w(context, 12),
                ),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 6)),
                  // Time chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.w(context, 8),
                      vertical: Responsive.h(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.access_time_rounded,
                          size: Responsive.w(context, 13),
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(width: Responsive.w(context, 4)),
                        Text(
                          event.time,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.h(context, 8)),
                  Text(
                    event.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// Hardcoded mock event for the POC.
class _MockEvent {
  _MockEvent({
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
  });

  final String title;
  final String time;
  final String description;
  final IconData icon;
}
