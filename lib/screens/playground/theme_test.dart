import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/theme_provider.dart';

// --- Assumed Provider (based on your code snippet) ---
// We're assuming 'theme_provider.dart' exists and provides:
// 1. final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>(...)
// 2. class ThemeState { final bool isDarkMode; ... }
// 3. class ThemeNotifier extends StateNotifier<ThemeState> { void toggleTheme(); ... }
//
// If your provider is set up differently, you may need to adjust
// the 'onPressed' logic in the AppBar.
//
// You'll need to import your actual provider file here:
// import 'path/to/your/theme_provider.dart';
// ---

/// A helper function to convert a Color object to a hex string.
String toHex(Color c) =>
    '#${c.value.toRadixString(16).substring(2).toUpperCase()}';

class ThemeTestScreen extends ConsumerWidget {
  const ThemeTestScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- Assumed Theme Provider Logic ---
    // This logic is based on your provided snippet.
    // If your provider is named differently or doesn't expose 'ThemeState'
    // or 'ThemeNotifier', you will need to adjust this.
    //
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    // ---

    // Get the currently active color scheme.
    // This will be light or dark based on the active theme.
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final AppThemeMode next =
                  themeState.mode == AppThemeMode.light
                      ? AppThemeMode.dark
                      : AppThemeMode.light;
              themeNotifier.setThemeMode(next);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Main Roles', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Primary',
                      color: colorScheme.primary,
                      onColor: colorScheme.onPrimary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Secondary',
                      color: colorScheme.secondary,
                      onColor: colorScheme.onSecondary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Tertiary',
                      color: colorScheme.tertiary,
                      onColor: colorScheme.onTertiary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Error',
                      color: colorScheme.error,
                      onColor: colorScheme.onError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Primary',
                      color: colorScheme.onPrimary,
                      onColor: colorScheme.primary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Secondary',
                      color: colorScheme.onSecondary,
                      onColor: colorScheme.secondary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Tertiary',
                      color: colorScheme.onTertiary,
                      onColor: colorScheme.tertiary,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Error',
                      color: colorScheme.onError,
                      onColor: colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Primary Container',
                      color: colorScheme.primaryContainer,
                      onColor: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Secondary Container',
                      color: colorScheme.secondaryContainer,
                      onColor: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Tertiary Container',
                      color: colorScheme.tertiaryContainer,
                      onColor: colorScheme.onTertiaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Error Container',
                      color: colorScheme.errorContainer,
                      onColor: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Primary Container',
                      color: colorScheme.onPrimaryContainer,
                      onColor: colorScheme.primaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Secondary Container',
                      color: colorScheme.onSecondaryContainer,
                      onColor: colorScheme.secondaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Tertiary Container',
                      color: colorScheme.onTertiaryContainer,
                      onColor: colorScheme.tertiaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Error Container',
                      color: colorScheme.onErrorContainer,
                      onColor: colorScheme.errorContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Surface Roles', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surface Dim',
                      color: colorScheme.surfaceDim,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surface',
                      color: colorScheme.surface,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surface Bright',
                      color: colorScheme.surfaceBright,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surf. Container Lowest',
                      color: colorScheme.surfaceContainerLowest,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surf. Container Low',
                      color: colorScheme.surfaceContainerLow,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surf. Container',
                      color: colorScheme.surfaceContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surf. Container High',
                      color: colorScheme.surfaceContainerHigh,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surf. Container Highest',
                      color: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Other Roles', style: textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Surface',
                      color: colorScheme.onSurface,
                      onColor: colorScheme.surface,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Surface Variant',
                      color: colorScheme.onSurfaceVariant,
                      onColor: colorScheme.surfaceContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Outline',
                      color: colorScheme.outline,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Outline Variant',
                      color: colorScheme.outlineVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Inverse Surface',
                      color: colorScheme.inverseSurface,
                      onColor: colorScheme.onInverseSurface,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'On Inverse Surface',
                      color: colorScheme.onInverseSurface,
                      onColor: colorScheme.inverseSurface,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Inverse Primary',
                      color: colorScheme.inversePrimary,
                      onColor: colorScheme.primaryContainer,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Surface Tint',
                      color: colorScheme.surfaceTint,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Shadow',
                      color: colorScheme.shadow,
                    ),
                  ),
                  Expanded(
                    child: ColorRoleSwatch(
                      label: 'Scrim',
                      color: colorScheme.scrim,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A helper widget to display a color swatch.
///
/// It shows the color, its label, and its hex code.
/// It automatically calculates a contrasting text color if no 'onColor' is given.
class ColorRoleSwatch extends StatelessWidget {
  const ColorRoleSwatch({
    super.key,
    required this.label,
    required this.color,
    this.onColor,
  });

  final String label;
  final Color color;
  final Color? onColor;

  @override
  Widget build(BuildContext context) {
    // Determine the best text color for readability
    final Color textColor =
        onColor ??
        (color.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    return SizedBox(
      height: 100,
      child: Card(
        color: color,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                toHex(color),
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
