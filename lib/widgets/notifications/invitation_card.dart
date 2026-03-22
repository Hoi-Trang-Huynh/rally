import 'package:flutter/material.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/models/responses/pending_invitation_response.dart';
import 'package:rally/utils/responsive.dart';

/// A compact card displaying a pending rally invitation with a view action.
class InvitationCard extends StatelessWidget {
  /// Creates an [InvitationCard].
  const InvitationCard({
    super.key,
    required this.invitation,
    required this.onView,
  });

  /// The invitation data to display.
  final PendingInvitationItem invitation;

  /// Called when the user taps the view (eye) icon.
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return InkWell(
      onTap: onView,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 24),
          vertical: Responsive.h(context, 12),
        ),
        child: Row(
          children: <Widget>[
            // Rally cover image or icon
            _buildRallyAvatar(context, colorScheme),
            SizedBox(width: Responsive.w(context, 12)),
            // Rally name + inviter info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    invitation.rallyName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (invitation.invitedBy != null) ...<Widget>[
                    SizedBox(height: Responsive.h(context, 2)),
                    Text(
                      t.notifications.invitations.invitedBy(
                        name: invitation.invitedBy!.displayName,
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            // View (eye) icon
            IconButton(
              onPressed: onView,
              icon: Icon(
                Icons.visibility_rounded,
                color: colorScheme.onSurfaceVariant,
                size: Responsive.w(context, 20),
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(
                minWidth: Responsive.w(context, 36),
                minHeight: Responsive.w(context, 36),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRallyAvatar(BuildContext context, ColorScheme colorScheme) {
    final double size = Responsive.w(context, 40);
    if (invitation.coverImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
        child: Image.network(
          invitation.coverImageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext ctx, Object error, StackTrace? stack) =>
              _buildFallbackIcon(context, colorScheme, size),
        ),
      );
    }
    return _buildFallbackIcon(context, colorScheme, size);
  }

  Widget _buildFallbackIcon(BuildContext context, ColorScheme colorScheme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
      ),
      child: Icon(
        Icons.flag_rounded,
        color: colorScheme.onPrimaryContainer,
        size: Responsive.w(context, 20),
      ),
    );
  }
}
