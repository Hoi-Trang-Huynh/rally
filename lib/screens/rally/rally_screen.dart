import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/rally_join_response.dart';
import 'package:rally/providers/current_rally_provider.dart';
import 'package:rally/utils/date_time_utils.dart';
import 'package:rally/utils/rally_status_helpers.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/rally_rich_text_viewer.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/shimmer_loading.dart';
import 'package:rally/widgets/rally/rally_map_view.dart';
import 'package:rally/widgets/navigation/rally_shell.dart';
import 'package:rally/widgets/rally/rally_participants_tab.dart';
import 'package:rally/widgets/rally/rally_timeline_tab.dart';

/// Screen for viewing a single rally's details.
///
/// Subscribes to [currentRallyProvider] for the active rally data.
/// Navigating here loads the rally by ID; in the future this will
/// be a live-updating stream.
class RallyScreen extends ConsumerStatefulWidget {
  /// The ID of the rally to display.
  final String rallyId;

  /// Creates a new [RallyScreen].
  const RallyScreen({super.key, required this.rallyId});

  @override
  ConsumerState<RallyScreen> createState() => _RallyScreenState();
}

class _RallyScreenState extends ConsumerState<RallyScreen> {
  @override
  void initState() {
    super.initState();
    // Load the rally data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentRallyProvider.notifier).loadRally(widget.rallyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<RallyJoinResponse> rallyAsync = ref.watch(currentRallyProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    // Get rally data safely for the header
    final RallyJoinResponse? rally = rallyAsync.valueOrNull;
    final String rallyName = rally?.name ?? '';
    final String dateRange =
        (rally?.startDate != null && rally?.endDate != null)
            ? DateTimeUtils.formatDateRange(rally!.startDate!, rally.endDate!)
            : t.rally.common.noDates;

    return DefaultTabController(
      length: 4,
      child: RallyShell(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              rallyName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              dateRange,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: Responsive.w(context, 12),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (rally != null) ...<Widget>[
            _buildStatusBadge(context, rally.status, t),
            SizedBox(width: Responsive.w(context, 8)),
          ],
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurface,
              size: Responsive.w(context, 24),
            ),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
        bottom: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          dividerColor: Colors.transparent,
          tabs: <Widget>[
            Tab(text: t.rally.common.overview),
            Tab(text: t.rally.common.timeline),
            Tab(text: t.rally.common.participants),
            Tab(text: t.rally.common.media),
          ],
        ),
        body: rallyAsync.when(
          data: (RallyJoinResponse rallyData) {
            return TabBarView(
              children: <Widget>[
                // Overview Tab - Map with persistent bottom sheet
                _buildOverviewTab(context, rallyData, colorScheme, textTheme, t),

                // Timeline Tab
                RallyTimelineTab(
                  startDate: rallyData.startDate ?? DateTime.now(),
                  endDate: rallyData.endDate ?? DateTime.now().add(const Duration(days: 7)),
                ),

                // Participants Tab
                RallyParticipantsTab(rallyId: widget.rallyId),

                // Media Tab (TODO)
                _buildPlaceholderTab(context, t.rally.common.media),
              ],
            );
          },
          loading: () => _buildLoadingState(context),
          error: (Object error, StackTrace stack) => _buildErrorState(context, error, t),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
    BuildContext context,
    RallyJoinResponse rallyData,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    return Stack(
      children: <Widget>[
        const Positioned.fill(
          child: RallyMapView(),
        ),
        AppBottomSheet.persistent(
          title: t.rally.common.overview,
          initialChildSize: 0.4,
          snapSizes: const <double>[0.15, 0.4],
          bodyBuilder: (ScrollController _) {
            return <Widget>[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(Responsive.w(context, 24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (rallyData.coverImageUrl != null &&
                          rallyData.coverImageUrl!.isNotEmpty) ...<Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              rallyData.coverImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Container(
                                    color: colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: Responsive.w(context, 48),
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 20)),
                      ],
                      if (rallyData.description != null &&
                          rallyData.description!.isNotEmpty)
                        RallyRichTextViewer(
                          content: rallyData.description!,
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        )
                      else
                        Text(
                          t.rally.common.unknown,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context, RallyStatus status, Translations t) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Design shows a simple pill with "Draft" or similar.
    // Usually we use status colors, but design snippet shows 'Daft' (Draft) in grey/neutral.
    // I will stick to the helper's text but maybe use neutral background if desired,
    // but better to stick to the system status colors for consistency unless told otherwise.
    // The user said "overview will be the description design however you want", but header?
    // "use this header" - implies visually similar.
    // The design badge is greyish.
    // I'll stick to the Helper for logic but maybe adjust style if needed.
    // For now, I'll use the Helper's color logic as it's safer for "active", "completed" etc.

    final Color autoBadgeBg = RallyStatusHelper.statusColor(status, colorScheme);
    final Color autoBadgeFg = RallyStatusHelper.statusTextColor(status, colorScheme);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 6),
      ),
      decoration: BoxDecoration(
        color: autoBadgeBg.withValues(alpha: 0.2), // Softer look
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)), // More pill-like
      ),
      child: Text(
        RallyStatusHelper.statusLabel(
          status,
          t,
        ), // Not uppercase in design? "Daft" looks Title Case
        style: textTheme.labelSmall?.copyWith(
          color: autoBadgeFg,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(BuildContext context, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.construction,
            size: Responsive.w(context, 48),
            color: Theme.of(context).colorScheme.outline,
          ),
          SizedBox(height: Responsive.h(context, 16)),
          Text(
            '$title - TODO',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, 24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ShimmerLoading(
            width: double.infinity,
            height: Responsive.h(context, 200),
            borderRadius: Responsive.w(context, 16),
          ),
          SizedBox(height: Responsive.h(context, 20)),
          ShimmerLoading(
            width: double.infinity,
            height: Responsive.h(context, 100),
            borderRadius: Responsive.w(context, 8),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error, Translations t) {
    // ... keep existing implementation ...
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            SizedBox(height: Responsive.h(context, 16)),
            Text(t.rally.common.errorLoadingRally, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: Responsive.h(context, 8)),
            Text(
              error.toString(),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.h(context, 16)),
            FilledButton.icon(
              onPressed: () => ref.read(currentRallyProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: Text(t.common.retry),
            ),
          ],
        ),
      ),
    );
  }
}
