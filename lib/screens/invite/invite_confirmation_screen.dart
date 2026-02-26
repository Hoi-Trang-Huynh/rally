import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/enums.dart';
import 'package:rally/models/requests/participant_requests.dart';
import 'package:rally/models/responses/join_via_link_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/router/app_router.dart';
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
      // 1. Join the rally first (status 'invited')
      final JoinViaLinkResponse joinResult = await ref
          .read(rallyRepositoryProvider)
          .joinViaLink(widget.token);

      if (!joinResult.success) {
        if (mounted) {
          setState(() {
            _error = joinResult.message;
            _isLoadingPreview = false;
          });
        }
        return;
      }

      // If the user's status is already 'joined', skip the preview and go straight to the rally
      if (joinResult.status == 'joined') {
        if (mounted) {
          context.go(AppRoutes.rally(joinResult.rallyId));
        }
        return;
      }

      // 2. Fetch the preview info using the token
      final InvitePreviewResponse preview = await ref
          .read(rallyRepositoryProvider)
          .getInvitePreview(widget.token);

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
      // 3. Accept by updating the participant status to 'joined'
      await ref
          .read(rallyRepositoryProvider)
          .updateParticipant(
            _preview!.rallyId,
            _preview!.participantId,
            const UpdateParticipantRequest(status: ParticipationStatus.joined),
          );

      if (!mounted) return;

      showSuccessSnackBar(
        context,
        t.rally.rallyInvite.joinViaLink.acceptSuccess,
      );
      // Navigate to the rally detail screen.
      context.go(AppRoutes.rally(_preview!.rallyId));
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, t.rally.rallyInvite.joinViaLink.acceptError);
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _decline() async {
    if (_isAccepting || _preview == null) {
      context.go(AppRoutes.home);
      return;
    }

    setState(() => _isAccepting = true);

    try {
      await ref
          .read(rallyRepositoryProvider)
          .updateParticipant(
            _preview!.rallyId,
            _preview!.participantId,
            const UpdateParticipantRequest(
              status: ParticipationStatus.declined,
            ),
          );

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // Even if declining fails, we still navigate away
      if (mounted) {
        context.go(AppRoutes.home);
      }
    }
  }

  void _close() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(t.rally.rallyInvite.joinViaLink.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _close,
        ),
      ),
      body: SafeArea(
        child:
            _isLoadingPreview
                ? _buildLoading(colorScheme, t)
                : _buildContent(colorScheme, textTheme, t),
      ),
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
    final ParticipantRole role = ParticipantRole.fromString(
      preview.roleOffered,
    );

    return Padding(
      padding: EdgeInsets.all(Responsive.w(context, 24)),
      child: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: Responsive.h(context, 16)),

                  // Cover image or rally icon placeholder
                  if (preview.coverImageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 16),
                      ),
                      child: Image.network(
                        preview.coverImageUrl!,
                        height: Responsive.h(context, 180),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                              BuildContext ctx,
                              Object error,
                              StackTrace? stack,
                            ) => _buildRallyIconPlaceholder(
                              colorScheme,
                              textTheme,
                            ),
                      ),
                    )
                  else
                    _buildRallyIconPlaceholder(colorScheme, textTheme),

                  SizedBox(height: Responsive.h(context, 24)),

                  // Rally name
                  Text(
                    preview.rallyName,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: Responsive.h(context, 8)),

                  // Organized by
                  Text(
                    t.rally.rallyInvite.joinViaLink.organizedBy.replaceAll(
                      '{name}',
                      '${preview.owner.firstName} ${preview.owner.lastName}'
                              .trim()
                              .isNotEmpty
                          ? '${preview.owner.firstName} ${preview.owner.lastName}'
                              .trim()
                          : '@${preview.owner.username}',
                    ),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: Responsive.h(context, 24)),

                  // Info chips row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Participant count
                      _InfoChip(
                        icon: Icons.group_rounded,
                        label: t.rally.rallyInvite.joinViaLink.participantsLabel
                            .replaceAll(
                              '{count}',
                              preview.memberCount.toString(),
                            ),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),

                      SizedBox(width: Responsive.w(context, 12)),

                      // Date range (if present)
                      if (preview.startDate != null)
                        _InfoChip(
                          icon: Icons.calendar_today_rounded,
                          label:
                              preview.endDate != null
                                  ? '${DateFormat.MMMd().format(preview.startDate!)} – ${DateFormat.MMMd().format(preview.endDate!)}'
                                  : DateFormat.yMMMd().format(
                                    preview.startDate!,
                                  ),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                    ],
                  ),

                  SizedBox(height: Responsive.h(context, 32)),

                  // Role invitation card
                  Container(
                    padding: EdgeInsets.all(Responsive.w(context, 20)),
                    decoration: BoxDecoration(
                      color: ParticipantRoleHelper.roleColor(
                        role,
                        colorScheme,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 16),
                      ),
                      border: Border.all(
                        color: ParticipantRoleHelper.roleColor(
                          role,
                          colorScheme,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          t.rally.rallyInvite.joinViaLink.roleLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: Responsive.h(context, 8)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.w(context, 16),
                            vertical: Responsive.h(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: ParticipantRoleHelper.roleColor(
                              role,
                              colorScheme,
                            ),
                            borderRadius: BorderRadius.circular(
                              Responsive.w(context, 12),
                            ),
                          ),
                          child: Text(
                            ParticipantRoleHelper.roleLabel(role, t),
                            style: textTheme.titleMedium?.copyWith(
                              color: ParticipantRoleHelper.roleTextColor(
                                role,
                                colorScheme,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action buttons (pinned at bottom)
          SizedBox(height: Responsive.h(context, 16)),

          // Accept button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isAccepting ? null : _acceptInvitation,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.h(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 14),
                  ),
                ),
              ),
              child:
                  _isAccepting
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                      : Text(
                        t.rally.rallyInvite.joinViaLink.acceptButton,
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
            ),
          ),

          SizedBox(height: Responsive.h(context, 8)),

          // Decline button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isAccepting ? null : _decline,
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding: EdgeInsets.symmetric(
                  vertical: Responsive.h(context, 16),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 14),
                  ),
                ),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                t.rally.rallyInvite.joinViaLink.declineButton,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
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

  Widget _buildRallyIconPlaceholder(
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      height: Responsive.h(context, 140),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      ),
      child: Center(
        child: Icon(
          Icons.flag_rounded,
          size: Responsive.w(context, 56),
          color: colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// A small info chip with an icon and label.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 12),
        vertical: Responsive.h(context, 6),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: Responsive.w(context, 16),
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: Responsive.w(context, 6)),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
