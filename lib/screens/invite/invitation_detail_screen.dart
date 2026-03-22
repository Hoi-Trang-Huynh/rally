import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/requests/participant_requests.dart';
import 'package:rally/models/responses/pending_invitation_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/user_provider.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/services/rally_repository.dart';
import 'package:rally/utils/delta_utils.dart';
import 'package:rally/utils/participant_role_helper.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/utils/ui_helpers.dart';

/// Screen shown when a user taps a pending in-app invitation.
///
/// Fetches the invitation from [pendingInvitationsProvider] using the
/// [rallyId] and [participantId] path parameters.
class InvitationDetailScreen extends ConsumerStatefulWidget {
  /// Creates a new [InvitationDetailScreen].
  const InvitationDetailScreen({
    required this.rallyId,
    required this.participantId,
    super.key,
  });

  /// The rally ID from the route.
  final String rallyId;

  /// The participant record ID from the route.
  final String participantId;

  @override
  ConsumerState<InvitationDetailScreen> createState() =>
      _InvitationDetailScreenState();
}

class _InvitationDetailScreenState
    extends ConsumerState<InvitationDetailScreen> {
  bool _isAccepting = false;
  bool _isDeclining = false;

  bool get _isBusy => _isAccepting || _isDeclining;

  Future<void> _accept() async {
    if (_isBusy) return;
    setState(() => _isAccepting = true);

    final Translations t = Translations.of(context);
    try {
      final RallyRepository rallyRepo = ref.read(rallyRepositoryProvider);
      await rallyRepo.updateParticipant(
        widget.rallyId,
        widget.participantId,
        const UpdateParticipantRequest(status: ParticipationStatus.joined),
      );
      ref.invalidate(pendingInvitationsProvider);
      if (mounted) {
        showSuccessSnackBar(context, t.notifications.invitations.acceptSuccess);
        context.go(AppRoutes.rally(widget.rallyId));
      }
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(context, t.notifications.invitations.acceptError);
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _decline() async {
    if (_isBusy) return;
    setState(() => _isDeclining = true);

    final Translations t = Translations.of(context);
    try {
      final RallyRepository rallyRepo = ref.read(rallyRepositoryProvider);
      await rallyRepo.updateParticipant(
        widget.rallyId,
        widget.participantId,
        const UpdateParticipantRequest(status: ParticipationStatus.declined),
      );
      ref.invalidate(pendingInvitationsProvider);
      if (mounted) {
        showSuccessSnackBar(
          context,
          t.notifications.invitations.declineSuccess,
        );
        context.go(AppRoutes.home);
      }
    } catch (_) {
      if (mounted) {
        showErrorSnackBar(context, 'Failed to decline invitation');
        setState(() => _isDeclining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);
    final AsyncValue<PendingInvitationsResponse> invitationsAsync = ref.watch(
      pendingInvitationsProvider,
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body: invitationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (Object error, StackTrace stack) => Center(
              child: Text(
                t.notifications.invitations.acceptError,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        data: (PendingInvitationsResponse data) {
          final PendingInvitationItem? inv = _findInvitation(data);
          if (inv == null) {
            return Center(
              child: Text(
                t.notifications.invitations.noInvitations,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return _buildContent(context, inv, colorScheme, textTheme, t);
        },
      ),
    );
  }

  PendingInvitationItem? _findInvitation(PendingInvitationsResponse data) {
    for (final PendingInvitationItem inv in data.invitations) {
      if (inv.participantId == widget.participantId &&
          inv.rallyId == widget.rallyId) {
        return inv;
      }
    }
    return null;
  }

  Widget _buildContent(
    BuildContext context,
    PendingInvitationItem inv,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    final String ownerName =
        inv.invitedBy != null ? inv.invitedBy!.displayName : '';
    final double coverHeight = Responsive.h(context, 260);
    final double overlap = Responsive.h(context, 80);

    return Column(
      children: <Widget>[
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            child: Stack(
              children: <Widget>[
                // ── Cover image with rounded bottom ──
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(Responsive.w(context, 32)),
                    bottomRight: Radius.circular(Responsive.w(context, 32)),
                  ),
                  child: inv.coverImageUrl != null
                      ? Image.network(
                          inv.coverImageUrl!,
                          height: coverHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext ctx, Object error,
                                  StackTrace? stack) =>
                              _buildCoverPlaceholder(
                                  coverHeight, colorScheme),
                        )
                      : _buildCoverPlaceholder(coverHeight, colorScheme),
                ),

                // ── Content cards overlapping the cover ──
                Padding(
                  padding: EdgeInsets.only(
                    top: coverHeight - overlap,
                    left: Responsive.w(context, 16),
                    right: Responsive.w(context, 16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Rally info card
                      _buildInfoCard(
                          inv, ownerName, colorScheme, textTheme, t),

                      SizedBox(height: Responsive.h(context, 12)),

                      // About section
                      if (inv.description != null &&
                          inv.description!.trim().isNotEmpty)
                        _buildAboutCard(inv, colorScheme, textTheme, t),

                      SizedBox(height: Responsive.h(context, 24)),
                    ],
                  ),
                ),

                // ── Back button ──
                Positioned(
                  top: MediaQuery.of(context).padding.top +
                      Responsive.h(context, 8),
                  left: Responsive.w(context, 8),
                  child: IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: inv.coverImageUrl != null
                          ? Colors.white
                          : colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.surface.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Bottom action buttons ──
        _buildBottomActions(colorScheme, textTheme, t),
      ],
    );
  }

  Widget _buildCoverPlaceholder(double height, ColorScheme colorScheme) {
    return Container(
      height: height,
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.flag_rounded,
          size: Responsive.w(context, 64),
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    PendingInvitationItem inv,
    String ownerName,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    final ParticipantRole role = inv.role;

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Rally name + role badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  inv.rallyName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 8),
                  vertical: Responsive.h(context, 3),
                ),
                decoration: BoxDecoration(
                  color: ParticipantRoleHelper.roleColor(role, colorScheme),
                  borderRadius: BorderRadius.circular(Responsive.w(context, 6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.badge_outlined,
                      size: Responsive.w(context, 12),
                      color: ParticipantRoleHelper.roleTextColor(role, colorScheme),
                    ),
                    SizedBox(width: Responsive.w(context, 4)),
                    Text(
                      ParticipantRoleHelper.roleLabel(role, t),
                      style: textTheme.labelSmall?.copyWith(
                        color: ParticipantRoleHelper.roleTextColor(role, colorScheme),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Trip dates row
          if (inv.startDate != null) ...<Widget>[
            SizedBox(height: Responsive.h(context, 20)),
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: Responsive.w(context, 20),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.calendar_today_rounded,
                    size: Responsive.w(context, 18),
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        t.rally.rallyInvite.joinViaLink.tripDates,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 2)),
                      Text(
                        _formatDateRange(inv.startDate!, inv.endDate),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (inv.startDate != null && inv.endDate != null)
                        Text(
                          _formatDaysNights(inv.startDate!, inv.endDate!, t),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          // Organizer row
          if (ownerName.isNotEmpty) ...<Widget>[
            SizedBox(height: Responsive.h(context, 16)),
            Row(
              children: <Widget>[
                CircleAvatar(
                  radius: Responsive.w(context, 20),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage:
                      inv.invitedBy?.avatarUrl != null
                          ? NetworkImage(inv.invitedBy!.avatarUrl!)
                          : null,
                  child:
                      inv.invitedBy?.avatarUrl == null
                          ? Text(
                            ownerName.isNotEmpty
                                ? ownerName[0].toUpperCase()
                                : '?',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          )
                          : null,
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        t.rally.rallyInvite.joinViaLink.organizedBy.replaceAll(
                          '{name}',
                          '',
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: Responsive.h(context, 2)),
                      Text(
                        ownerName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        t.rally.rallyInvite.joinViaLink.participantsJoined
                            .replaceAll('{count}', inv.memberCount.toString()),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

        ],
      ),
    );
  }

  Widget _buildAboutCard(
    PendingInvitationItem inv,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 20)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            t.rally.rallyInvite.joinViaLink.aboutThisRally,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: Responsive.h(context, 12)),
          Text(
            deltaToPlainText(inv.description!),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: Responsive.w(context, 16),
        right: Responsive.w(context, 16),
        top: Responsive.h(context, 12),
        bottom:
            Responsive.h(context, 12) + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: <Widget>[
          // Decline Rally
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isBusy ? null : _decline,
              icon:
                  _isDeclining
                      ? SizedBox(
                        width: Responsive.w(context, 14),
                        height: Responsive.w(context, 14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.error,
                        ),
                      )
                      : Icon(
                        Icons.close_rounded,
                        size: Responsive.w(context, 14),
                      ),
              label: Text(
                t.rally.rallyInvite.joinViaLink.declineRally,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                minimumSize: Size(0, Responsive.h(context, 48)),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 24),
                  ),
                ),
                side: BorderSide(
                  color: colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),

          SizedBox(width: Responsive.w(context, 8)),

          // Join Rally
          Expanded(
            child: FilledButton.icon(
              onPressed: _isBusy ? null : _accept,
              icon:
                  _isAccepting
                      ? SizedBox(
                        width: Responsive.w(context, 14),
                        height: Responsive.w(context, 14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : Icon(
                        Icons.group_add_rounded,
                        size: Responsive.w(context, 14),
                      ),
              label: Text(
                t.rally.rallyInvite.joinViaLink.joinRally,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimary,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: Size(0, Responsive.h(context, 48)),
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  String _formatDateRange(DateTime start, DateTime? end) {
    if (end != null) {
      if (start.month == end.month && start.year == end.year) {
        // Same month: "24-27 July, 2026"
        return '${DateFormat('d').format(start)}-${DateFormat('d MMMM, y').format(end)}';
      }
      // Different months: "29 Jun - 3 Jul, 2026"
      return '${DateFormat('d MMM').format(start)} - ${DateFormat('d MMM, y').format(end)}';
    }
    return DateFormat('d MMMM, y').format(start);
  }

  String _formatDaysNights(DateTime start, DateTime end, Translations t) {
    final int days = end.difference(start).inDays + 1;
    final int nights = days - 1;
    return t.rally.rallyInvite.joinViaLink.daysNights
        .replaceAll('{days}', days.toString())
        .replaceAll('{nights}', nights.toString());
  }
}
