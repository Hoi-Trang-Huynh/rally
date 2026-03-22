import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/participant_list_response.dart';
import 'package:rally/providers/rally_participants_provider.dart';
import 'package:rally/utils/participation_status_helper.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/app_bottom_sheet.dart';
import 'package:rally/widgets/common/collapsible_section.dart';
import 'package:rally/widgets/rally/rally_invite_members_sheet.dart';

/// A tab that displays the list of participants in a rally, grouped by role.
class RallyParticipantsTab extends ConsumerStatefulWidget {
  /// Creates a new [RallyParticipantsTab].
  const RallyParticipantsTab({super.key, required this.rallyId});

  /// The ID of the rally to fetch participants for.
  final String rallyId;

  @override
  ConsumerState<RallyParticipantsTab> createState() => _RallyParticipantsTabState();
}

class _RallyParticipantsTabState extends ConsumerState<RallyParticipantsTab> {
  // Expansion states for each role section. Default to expanded.
  bool _isOwnersExpanded = true;
  bool _isEditorsExpanded = true;
  bool _isParticipantsExpanded = true;

  void _showInviteMembersBottomSheet() {
    final Translations t = Translations.of(context);

    showAppBottomSheet<void>(
      context: context,
      sheet: AppBottomSheet.draggable(
        title: t.rally.rallyInvite.title,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        bodyBuilder: (ScrollController scrollController) {
          return <Widget>[
            SliverFillRemaining(
              hasScrollBody: true,
              child: RallyInviteMembersSheet(rallyId: widget.rallyId),
            ),
          ];
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ParticipantListResponse> ownersAsync = ref.watch(
      rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.owner)),
    );
    final AsyncValue<ParticipantListResponse> editorsAsync = ref.watch(
      rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.editor)),
    );
    final AsyncValue<ParticipantListResponse> participantsAsync = ref.watch(
      rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.participant)),
    );

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    // Show a single global spinner while all three are loading for the first time
    final bool isInitialLoading =
        ownersAsync.isLoading &&
        !ownersAsync.hasValue &&
        editorsAsync.isLoading &&
        !editorsAsync.hasValue &&
        participantsAsync.isLoading &&
        !participantsAsync.hasValue;

    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // If all three are done loading and all empty
    final bool isAllLoaded =
        !ownersAsync.isLoading && !editorsAsync.isLoading && !participantsAsync.isLoading;
    final bool hasNoParticipants =
        isAllLoaded &&
        (ownersAsync.valueOrNull?.participants.isEmpty ?? true) &&
        (editorsAsync.valueOrNull?.participants.isEmpty ?? true) &&
        (participantsAsync.valueOrNull?.participants.isEmpty ?? true);

    if (hasNoParticipants) {
      return Center(
        child: Text(
          t.rally.common.noParticipantsYet,
          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.owner)),
        );
        ref.invalidate(
          rallyParticipantsByRoleProvider((rallyId: widget.rallyId, role: ParticipantRole.editor)),
        );
        ref.invalidate(
          rallyParticipantsByRoleProvider((
            rallyId: widget.rallyId,
            role: ParticipantRole.participant,
          )),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Invite button
            FilledButton(
              onPressed: _showInviteMembersBottomSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person_add_alt_1, size: Responsive.w(context, 18)),
                  SizedBox(width: Responsive.w(context, 8)),
                  Text(t.rally.common.inviteMembersButton),
                ],
              ),
            ),
            SizedBox(height: Responsive.h(context, 16)),

            // Owners Section
            _buildRoleSection(
              context: context,
              title: t.rally.common.role.owners,
              role: ParticipantRole.owner,
              asyncData: ownersAsync,
              isExpanded: _isOwnersExpanded,
              onToggle: () => setState(() => _isOwnersExpanded = !_isOwnersExpanded),
            ),
            SizedBox(height: Responsive.h(context, 16)),

            // Editors Section
            _buildRoleSection(
              context: context,
              title: t.rally.common.role.editors,
              role: ParticipantRole.editor,
              asyncData: editorsAsync,
              isExpanded: _isEditorsExpanded,
              onToggle: () => setState(() => _isEditorsExpanded = !_isEditorsExpanded),
            ),
            SizedBox(height: Responsive.h(context, 16)),

            // Participants Section
            _buildRoleSection(
              context: context,
              title: t.rally.common.role.participants,
              role: ParticipantRole.participant,
              asyncData: participantsAsync,
              isExpanded: _isParticipantsExpanded,
              onToggle: () => setState(() => _isParticipantsExpanded = !_isParticipantsExpanded),
            ),
            SizedBox(height: Responsive.h(context, 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection({
    required BuildContext context,
    required String title,
    required ParticipantRole role,
    required AsyncValue<ParticipantListResponse> asyncData,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // If we have data (even if currently loading more pages)
    if (asyncData.hasValue) {
      final ParticipantListResponse response = asyncData.requireValue;
      if (response.participants.isEmpty) {
        return const SizedBox.shrink();
      }

      final bool hasMore = response.participants.length < response.total;
      final bool isLoadingMore = asyncData.isLoading;

      return CollapsibleSection(
        title: '$title (${response.total})',
        isExpanded: isExpanded,
        onToggle: onToggle,
        child: Column(
          children: <Widget>[
            // Participant items
            ...response.participants.map(
              (ParticipantItem p) => Padding(
                padding: EdgeInsets.only(bottom: Responsive.h(context, 8)),
                child: _ParticipantListItem(participant: p),
              ),
            ),
            // "Load more" button or loading indicator
            if (hasMore)
              isLoadingMore
                  ? Padding(
                    padding: EdgeInsets.symmetric(vertical: Responsive.h(context, 8)),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                  : Padding(
                    padding: EdgeInsets.only(top: Responsive.h(context, 4)),
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(
                              rallyParticipantsByRoleProvider((
                                rallyId: widget.rallyId,
                                role: role,
                              )).notifier,
                            )
                            .loadMore();
                      },
                      child: Text(
                        t.rally.common.loadMore,
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
    }

    // Error state
    if (asyncData.hasError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(context, 16)),
          child: Text(asyncData.error.toString(), style: TextStyle(color: colorScheme.error)),
        ),
      );
    }

    // Fallback (should rarely be seen due to global spinner)
    return const SizedBox.shrink();
  }
}

/// A single participant list item.
class _ParticipantListItem extends StatelessWidget {
  const _ParticipantListItem({required this.participant});

  final ParticipantItem participant;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 12)),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: <Widget>[
          // Avatar
          CircleAvatar(
            radius: Responsive.w(context, 22),
            backgroundColor: colorScheme.primaryContainer,
            backgroundImage:
                participant.avatarUrl != null ? NetworkImage(participant.avatarUrl!) : null,
            child:
                participant.avatarUrl == null
                    ? Text(
                      participant.displayName.isNotEmpty
                          ? participant.displayName[0].toUpperCase()
                          : '?',
                      style: textTheme.titleSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                    : null,
          ),

          SizedBox(width: Responsive.w(context, 12)),

          // Name, username, and invited by
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  participant.displayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '@${participant.username}',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                // Invited by info
                if (participant.invitedBy != null)
                  Padding(
                    padding: EdgeInsets.only(top: Responsive.h(context, 4)),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: Responsive.w(context, 8),
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage:
                              participant.invitedBy!.avatarUrl != null
                                  ? NetworkImage(participant.invitedBy!.avatarUrl!)
                                  : null,
                          child:
                              participant.invitedBy!.avatarUrl == null
                                  ? Text(
                                    participant.invitedBy!.displayName.isNotEmpty
                                        ? participant.invitedBy!.displayName[0].toUpperCase()
                                        : '?',
                                    style: textTheme.labelSmall?.copyWith(
                                      fontSize: Responsive.w(context, 7),
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  )
                                  : null,
                        ),
                        SizedBox(width: Responsive.w(context, 4)),
                        Flexible(
                          child: Text(
                            '@${participant.invitedBy!.username} ${t.rally.common.invitedByLabel}',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: Responsive.w(context, 8)),

          // Status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 8),
                  vertical: Responsive.h(context, 4),
                ),
                decoration: BoxDecoration(
                  color: ParticipationStatusHelper.statusColor(participant.status, colorScheme),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
                ),
                child: Text(
                  ParticipationStatusHelper.statusLabel(participant.status, t),
                  style: textTheme.labelSmall?.copyWith(
                    color: ParticipationStatusHelper.statusTextColor(
                      participant.status,
                      colorScheme,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
