import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/user_rallies_response.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/screens/profile/widgets/rally_list_item.dart';
import 'package:rally/utils/rally_status_helpers.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/empty_state.dart';
import 'package:rally/widgets/common/shimmer_loading.dart';

/// The rallies tab content shown in the profile screen.
///
/// Includes a search bar, filter/sort controls, and a list of rally items.
class ProfileRalliesTab extends ConsumerStatefulWidget {
  /// The ID of the user whose rallies to display.
  final String userId;

  /// Creates a new [ProfileRalliesTab].
  const ProfileRalliesTab({super.key, required this.userId});

  @override
  ConsumerState<ProfileRalliesTab> createState() => _ProfileRalliesTabState();
}

class _ProfileRalliesTabState extends ConsumerState<ProfileRalliesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  /// Whether the filter row (status chips) is expanded.
  bool _isFilterExpanded = false;

  /// Whether sort is set to latest (true) or oldest (false).
  bool _sortLatest = true;

  /// Currently selected status filter. null means "All".
  RallyStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Statuses available for filtering (excludes archived per design).
  static const List<RallyStatus> _filterStatuses = <RallyStatus>[
    RallyStatus.active,
    RallyStatus.draft,
    RallyStatus.completed,
    RallyStatus.inactive,
  ];

  void _onSearchChanged(String value) {
    // Debounce search to avoid too many API calls
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      if (mounted && _searchController.text == value) {
        setState(() {
          _searchQuery = value.trim();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    // Build params for the provider
    final UserRalliesParams params = UserRalliesParams(
      userId: widget.userId,
      name: _searchQuery.isNotEmpty ? _searchQuery : null,
      status: _selectedStatus?.name,
      sort: _sortLatest ? 'desc' : 'asc',
    );

    // Watch the rallies provider
    final AsyncValue<UserRalliesResponse> ralliesAsync = ref.watch(userRalliesProvider(params));

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 16)),
        child: Column(
          children: <Widget>[
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: t.rally.filter.searchPlaceholder,
                hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 16),
                  vertical: Responsive.h(context, 12),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
            ),
            SizedBox(height: Responsive.h(context, 16)),

            // Filter + Sort Row
            Row(
              children: <Widget>[
                // Filter button (toggles expansion)
                _buildFilterChip(
                  context,
                  label: t.rally.filter.label,
                  icon: Icons.tune,
                  isActive: _isFilterExpanded,
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                ),
                SizedBox(width: Responsive.w(context, 12)),
                // Sort toggle (Latest <-> Oldest)
                _buildFilterChip(
                  context,
                  label: _sortLatest ? t.rally.filter.latest : t.rally.filter.oldest,
                  icon: _sortLatest ? Icons.arrow_downward : Icons.arrow_upward,
                  onTap: () {
                    setState(() {
                      _sortLatest = !_sortLatest;
                    });
                  },
                ),
                const Spacer(),
                ralliesAsync.when(
                  data:
                      (UserRalliesResponse data) => Text(
                        '${data.rallies.length} / ${data.total}',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),

            // Expanded Filter Status Chips
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child:
                  _isFilterExpanded
                      ? Padding(
                        padding: EdgeInsets.only(top: Responsive.h(context, 12)),
                        child: _buildStatusFilterRow(context, t),
                      )
                      : const SizedBox.shrink(),
            ),

            // Rally List Content
            ralliesAsync.when(
              data: (UserRalliesResponse data) {
                if (data.rallies.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 48)),
                    child: EmptyState(
                      icon: Icons.explore_outlined,
                      title: t.profile.noRalliesFound,
                      subtitle: t.profile.noRalliesFoundSubtitle,
                    ),
                  );
                }

                return AnimationLimiter(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.rallies.length,
                    separatorBuilder:
                        (BuildContext context, int index) =>
                            SizedBox(height: Responsive.h(context, 12)),
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: RallyListItem(rally: data.rallies[index])),
                        ),
                      );
                    },
                  ),
                );
              },
              loading:
                  () => Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 16)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, __) => SizedBox(height: Responsive.h(context, 12)),
                      itemBuilder: (BuildContext context, int index) {
                        return ShimmerLoading(
                          width: double.infinity,
                          height: Responsive.h(context, 80),
                          borderRadius: Responsive.w(context, 12),
                        );
                      },
                    ),
                  ),
              error:
                  (Object error, StackTrace stack) => Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 48)),
                    child: EmptyState(
                      icon: Icons.error_outline,
                      title: t.profile.failedToLoadRallies,
                      subtitle: error.toString(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the horizontal row of status filter chips.
  Widget _buildStatusFilterRow(BuildContext context, Translations t) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          // "All" chip
          _buildStatusChip(
            context,
            label: t.rally.filter.all,
            isSelected: _selectedStatus == null,
            selectedColor: colorScheme.error,
            onTap: () {
              setState(() => _selectedStatus = null);
            },
          ),
          SizedBox(width: Responsive.w(context, 8)),
          // Status chips
          ..._filterStatuses.map((RallyStatus status) {
            final bool isSelected = _selectedStatus == status;
            return Padding(
              padding: EdgeInsets.only(right: Responsive.w(context, 8)),
              child: _buildStatusChip(
                context,
                label: RallyStatusHelper.statusLabel(status, t),
                isSelected: isSelected,
                selectedColor: RallyStatusHelper.statusTextColor(status, colorScheme),
                onTap: () {
                  setState(() => _selectedStatus = status);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Builds a single status filter chip.
  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 14),
          vertical: Responsive.h(context, 6),
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          border: Border.all(
            color:
                isSelected
                    ? selectedColor.withValues(alpha: 0.4)
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: isSelected ? selectedColor : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds a filter/sort action chip in the top row.
  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
          border: Border.all(
            color:
                isActive ? colorScheme.primary : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          color: isActive ? colorScheme.primary : colorScheme.surface,
        ),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: Responsive.w(context, 18),
              color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
            SizedBox(width: Responsive.w(context, 8)),
            Text(
              label,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
