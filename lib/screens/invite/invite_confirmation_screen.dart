import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/responses/join_via_link_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/router/app_router.dart';
import 'package:rally/utils/delta_utils.dart';
import 'package:rally/utils/participant_role_helper.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/utils/ui_helpers.dart';

/// Screen shown when the user opens an invite deep link.
///
/// It fetches a preview of the rally, shows the details, and lets the
/// user accept or decline the invitation.
class InviteConfirmationScreen extends ConsumerStatefulWidget {
  /// Creates a new [InviteConfirmationScreen].
  const InviteConfirmationScreen({required this.token, super.key});

  /// The invite link token extracted from the deep link URL.
  final String token;

  @override
  ConsumerState<InviteConfirmationScreen> createState() =>
      _InviteConfirmationScreenState();
}

class _InviteConfirmationScreenState
    extends ConsumerState<InviteConfirmationScreen> {
  InvitePreviewResponse? _preview;
  bool _isLoadingPreview = true;
  bool _isAccepting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  Future<void> _loadPreview() async {
    try {
      final InvitePreviewResponse preview = await ref
          .read(rallyRepositoryProvider)
          .getInvitePreview(widget.token);

      // If user is already joined, skip preview and go straight to the rally
      if (preview.participantStatus == 'joined') {
        if (mounted) {
          context.go(AppRoutes.rally(preview.rallyId));
        }
        return;
      }

      if (mounted) {
        setState(() {
          _preview = preview;
          _isLoadingPreview = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoadingPreview = false;
        });
      }
    }
  }

  Future<void> _acceptInvitation() async {
    if (_isAccepting || _preview == null) return;
    setState(() => _isAccepting = true);

    final Translations t = Translations.of(context);
    try {
      final JoinViaLinkResponse result = await ref
          .read(rallyRepositoryProvider)
          .joinViaLink(widget.token);

      if (!mounted) return;

      if (result.success) {
        showSuccessSnackBar(
          context,
          t.rally.rallyInvite.joinViaLink.acceptSuccess,
        );
        context.go(AppRoutes.rally(result.rallyId));
      } else {
        showErrorSnackBar(context, result.message);
        setState(() => _isAccepting = false);
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.joinViaLink.acceptError);
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _decline() async {
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      body:
          _isLoadingPreview
              ? _buildLoading(colorScheme, t)
              : _buildContent(colorScheme, textTheme, t),
    );
  }

  Widget _buildLoading(ColorScheme colorScheme, Translations t) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CircularProgressIndicator(color: colorScheme.primary),
          SizedBox(height: Responsive.h(context, 16)),
          Text(
            t.rally.rallyInvite.joinViaLink.loading,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    if (_error != null || _preview == null) {
      return _buildError(colorScheme, textTheme, t);
    }

    final InvitePreviewResponse preview = _preview!;
    final String ownerName =
        '${preview.owner.firstName} ${preview.owner.lastName}'.trim().isNotEmpty
            ? '${preview.owner.firstName} ${preview.owner.lastName}'.trim()
            : '@${preview.owner.username}';

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
                  child: preview.coverImageUrl != null
                      ? Image.network(
                          preview.coverImageUrl!,
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
                        preview, ownerName, colorScheme, textTheme, t,
                      ),

                      SizedBox(height: Responsive.h(context, 12)),

                      // About section
                      if (preview.description != null &&
                          preview.description!.trim().isNotEmpty)
                        _buildAboutCard(preview, colorScheme, textTheme, t),

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
                      color: preview.coverImageUrl != null
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
        _buildBottomActions(preview, colorScheme, textTheme, t),
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
    InvitePreviewResponse preview,
    String ownerName,
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    final ParticipantRole role = ParticipantRole.fromString(
      preview.roleOffered,
    );

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
                  preview.rallyName,
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
          if (preview.startDate != null) ...<Widget>[
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
                        _formatDateRange(preview.startDate!, preview.endDate),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (preview.endDate != null)
                        Text(
                          _formatDaysNights(
                            preview.startDate!,
                            preview.endDate!,
                            t,
                          ),
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
          SizedBox(height: Responsive.h(context, 16)),
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: Responsive.w(context, 20),
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage:
                    preview.owner.avatarUrl != null
                        ? NetworkImage(preview.owner.avatarUrl!)
                        : null,
                child:
                    preview.owner.avatarUrl == null
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
                          .replaceAll(
                            '{count}',
                            preview.memberCount.toString(),
                          ),
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
      ),
    );
  }

  Widget _buildAboutCard(
    InvitePreviewResponse preview,
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
            deltaToPlainText(preview.description!),
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
    InvitePreviewResponse preview,
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
              onPressed: _isAccepting ? null : _decline,
              icon: Icon(Icons.close_rounded, size: Responsive.w(context, 14)),
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
              onPressed: _isAccepting ? null : _acceptInvitation,
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

  Widget _buildError(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Translations t,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.w(context, 32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.link_off_rounded,
              size: Responsive.w(context, 64),
              color: colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: Responsive.h(context, 16)),
            Text(
              t.rally.rallyInvite.joinViaLink.invalidLink,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: Responsive.h(context, 24)),
            ElevatedButton(
              onPressed: _decline,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(t.rally.rallyInvite.joinViaLink.declineButton),
            ),
          ],
        ),
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
