import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/providers/locale_provider.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/utils/responsive.dart';

/// A polished language selector widget that uses a popup menu.
///
/// Replaces the standard dropdown with a clearer "pill" shaped button.
class LanguageSelector extends ConsumerWidget {
  /// Creates a [LanguageSelector].
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    // Watch for theme changes to ensure border color updates
    ref.watch(themeProvider);

    return PopupMenuButton<AppLocale>(
      tooltip: 'Select Language',
      color: colorScheme.surfaceContainerHigh,
      onSelected: (AppLocale locale) {
        localeNotifier.setLocale(locale);
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<AppLocale>>[
            for (final AppLocale locale in AppLocale.values)
              PopupMenuItem<AppLocale>(
                value: locale,
                child: Text(
                  _getLanguageName(locale, t),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      // The trigger button
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.w(context, 12),
          vertical: Responsive.h(context, 8),
        ),
        decoration: BoxDecoration(
          color: Colors.transparent, // User requested transparent
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.onSurface), // Outline style similar to fields
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.language, size: Responsive.w(context, 18), color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Text(
              localeState.locale.languageCode.toUpperCase(),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: Responsive.w(context, 18),
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(AppLocale locale, Translations t) {
    switch (locale.languageCode) {
      case 'en':
        return t.common.language.english;
      case 'vi':
        return t.common.language.vietnamese;
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
