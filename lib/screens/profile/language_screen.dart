import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/generated/translations.g.dart';
import '../../providers/locale_provider.dart';

/// Screen for selecting app language.
///
/// Displays available languages with radio selection.
class LanguageScreen extends ConsumerWidget {
  /// Creates a new [LanguageScreen].
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LocaleState localeState = ref.watch(localeProvider);
    final LocaleNotifier localeNotifier = ref.read(localeProvider.notifier);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          t.settings.language,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          _buildLanguageOption(
            context,
            locale: AppLocale.en,
            name: t.common.language.english,
            isSelected: localeState.locale == AppLocale.en,
            onTap: () {
              localeNotifier.setLocale(AppLocale.en);
            },
          ),
          _buildLanguageOption(
            context,
            locale: AppLocale.vi,
            name: t.common.language.vietnamese,
            isSelected: localeState.locale == AppLocale.vi,
            onTap: () {
              localeNotifier.setLocale(AppLocale.vi);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required AppLocale locale,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(
        name,
        style: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing:
          isSelected
              ? Icon(Icons.check_circle, color: colorScheme.primary)
              : Icon(Icons.circle_outlined, color: colorScheme.onSurfaceVariant),
    );
  }
}
