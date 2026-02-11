import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/responses/user_rallies_response.dart';
import 'package:rally/utils/date_time_utils.dart';
import 'package:rally/utils/rally_status_helpers.dart';
import 'package:rally/utils/responsive.dart';

/// A single rally item card for the profile rallies list.
class RallyListItem extends StatelessWidget {
  /// The rally data to display.
  final UserRallyItem rally;

  /// Creates a new [RallyListItem].
  const RallyListItem({super.key, required this.rally});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Translations t = Translations.of(context);

    final Color badgeBg = RallyStatusHelper.statusColor(rally.status, colorScheme);
    final Color badgeFg = RallyStatusHelper.statusTextColor(rally.status, colorScheme);
    final String badgeLabel = RallyStatusHelper.statusLabel(rally.status, t).toUpperCase();

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Title + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  rally.name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 8),
                  vertical: Responsive.h(context, 4),
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(Responsive.w(context, 4)),
                ),
                child: Text(
                  badgeLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.h(context, 8)),

          // Date Range + Updated Time on same row
          Row(
            children: <Widget>[
              Icon(
                Icons.calendar_today_outlined,
                size: Responsive.w(context, 16),
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: Responsive.w(context, 6)),
              Text(
                rally.startDate != null && rally.endDate != null
                    ? DateTimeUtils.formatDateRange(rally.startDate!, rally.endDate!)
                    : t.rally.common.noDates,
                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: Responsive.w(context, 16),
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
              SizedBox(width: Responsive.w(context, 4)),
              Text(
                rally.updatedAt != null
                    ? DateTimeUtils.formatRelativeTime(context, rally.updatedAt!)
                    : t.rally.common.unknown,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
