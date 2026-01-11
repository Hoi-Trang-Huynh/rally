import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import 'edit_profile_screen.dart';
import 'language_screen.dart';
import 'widgets/profile_avatar.dart';

/// Settings screen displaying user options and preferences.
///
/// Includes profile info, menu items, and logout functionality.
class SettingsScreen extends ConsumerWidget {
  /// Creates a new [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> userAsync = ref.watch(appUserProvider);
    final ThemeState themeState = ref.watch(themeProvider);
    final ThemeNotifier themeNotifier = ref.read(themeProvider.notifier);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Translations t = Translations.of(context);

    return userAsync.when(
      data: (AppUser? user) {
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
              t.settings.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search, color: colorScheme.onSurface),
                onPressed: () {
                  // TODO: Implement search
                },
              ),
            ],
          ),
          body: AnimationLimiter(
            child: SingleChildScrollView(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (Widget widget) {
                    return SlideAnimation(
                      verticalOffset: 50.0,
                      child: FadeInAnimation(child: widget),
                    );
                  },
                  children: <Widget>[
                    // Profile section
                    _buildProfileSection(context, user, t),

                    const Divider(height: 32),

                    // Menu items
                    _buildMenuItem(
                      context,
                      icon: Icons.account_circle_outlined,
                      label: t.settings.account,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.shield_outlined,
                      label: t.settings.privacy,
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.language,
                      label: t.settings.language,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const LanguageScreen(),
                          ),
                        );
                      },
                      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                    ),
                    // Theme toggle
                    _buildThemeToggle(context, themeState, themeNotifier, t),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      label: t.settings.helpFeedback,
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // Logout button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            await ref.read(authRepositoryProvider).signOut();
                            if (context.mounted) {
                              Navigator.of(
                                context,
                              ).popUntil((Route<dynamic> route) => route.isFirst);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(t.settings.logout),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (Object error, StackTrace stack) => Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }

  Widget _buildProfileSection(BuildContext context, AppUser? user, Translations t) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: <Widget>[
          // Avatar with online indicator
          ProfileAvatar(
            avatarUrl: user?.avatarUrl,
            size: 56,
            showOnlineIndicator: true,
            isOnline: true,
          ),

          const SizedBox(width: 16),

          // Username and Edit button
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '@${user?.username ?? 'username'}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(t.settings.edit, style: textTheme.labelMedium),
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    ThemeState themeState,
    ThemeNotifier themeNotifier,
    Translations t,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool isDarkMode = themeState.mode == AppThemeMode.dark;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        // Toggle between light and dark
        if (isDarkMode) {
          themeNotifier.setThemeMode(AppThemeMode.light);
        } else {
          themeNotifier.setThemeMode(AppThemeMode.dark);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                t.settings.mode,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            ),
            // Visual indicator of current mode
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildThemeIndicator(context, icon: Icons.light_mode, isSelected: !isDarkMode),
                  _buildThemeIndicator(context, icon: Icons.dark_mode, isSelected: isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeIndicator(
    BuildContext context, {
    required IconData icon,
    required bool isSelected,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primary : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 20,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(label, style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface)),
      trailing: trailing,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
