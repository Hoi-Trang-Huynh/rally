import 'package:flutter/material.dart';
import 'package:rally/utils/responsive.dart';
import 'package:rally/widgets/common/scale_button.dart';

import '../../../../i18n/generated/translations.g.dart';

/// A reusable widget to display user bio.
class ProfileBio extends StatelessWidget {
  /// The bio text to display.
  final String? bioText;

  /// Callback when the edit button is tapped.
  /// If null, the edit button is hidden.
  final VoidCallback? onEdit;

  /// Whether the bio is currently loading.
  final bool isLoading;

  /// Creates a new [ProfileBio].
  const ProfileBio({super.key, this.bioText, this.onEdit, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      // Return a shim or loading indicator here if strictly needed,
      // but commonly the parent handles specific loading layout.
      // For now, we'll just render nothing or simple text.
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);
    final bool hasBio = bioText != null && bioText!.isNotEmpty;
    final bool canEdit = onEdit != null;

    if (!hasBio && !canEdit) {
      return const SizedBox.shrink(); // Don't show anything if no bio and can't edit
    }

    return ScaleButton(
      onTap: onEdit,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 16),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                hasBio ? bioText! : (canEdit ? t.profile.addBio : ''),
                style: textTheme.bodyMedium?.copyWith(
                  color:
                      hasBio ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: hasBio ? FontStyle.normal : FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (canEdit) ...<Widget>[
              SizedBox(width: Responsive.w(context, 4)),
              Icon(
                Icons.edit_outlined,
                size: Responsive.w(context, 14),
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
