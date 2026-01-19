import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/generated/translations.g.dart';
import '../../models/app_user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../router/app_router.dart';
import '../../utils/responsive.dart';
import 'language_screen.dart';
import 'widgets/modern_settings_tile.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/settings_group.dart';

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
    final LocaleState localeState = ref.watch(localeProvider);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Translations t = Translations.of(context);

    String languageName = t.common.language.english;
    if (localeState.locale == AppLocale.vi) {
      languageName = t.common.language.vietnamese;
    }

    return userAsync.when(
      data: (AppUser? user) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              t.settings.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          body: AnimationLimiter(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: Responsive.h(context, 32)),
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
                    // 1. Profile section
                    _buildProfileSection(context, user, t),

                    Divider(height: Responsive.h(context, 32)),

                    // 2. Account Settings
                    SettingsGroup(
                      title: t.settings.account,
                      children: <Widget>[
                        ModernSettingsTile(
                          icon: Icons.shield_outlined,
                          title: t.settings.privacy,
                          onTap: () {},
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.h(context, 24)),

                    // 3. Preferences (Language & Theme)
                    SettingsGroup(
                      title: t.settings.preferences,
                      children: <Widget>[
                        ModernSettingsTile(
                          icon: Icons.language,
                          title: t.settings.language,
                          subtitle: languageName,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (BuildContext context) => const LanguageScreen(),
                              ),
                            );
                          },
                        ),
                        _buildThemeTile(context, themeState, themeNotifier, t),
                      ],
                    ),

                    SizedBox(height: Responsive.h(context, 24)),

                    // 4. Support
                    SettingsGroup(
                      title: t.settings.support,
                      children: <Widget>[
                        ModernSettingsTile(
                          icon: Icons.help_outline,
                          title: t.settings.helpFeedback,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push(AppRoutes.feedback);
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.h(context, 32)),

                    // 5. Logout
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
                      child: Column(
                        children: <Widget>[
                          TextButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();
                              await ref.read(authRepositoryProvider).signOut();
                              if (context.mounted) {
                                Navigator.of(
                                  context,
                                ).popUntil((Route<dynamic> route) => route.isFirst);
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              padding: EdgeInsets.symmetric(
                                vertical: Responsive.h(context, 12),
                                horizontal: Responsive.w(context, 24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.logout, size: Responsive.w(context, 20)),
                                SizedBox(width: Responsive.w(context, 8)),
                                Text(
                                  t.settings.logout,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Responsive.h(context, 8)),
                          Text(
                            'Version 1.0.0', // TODO: Get actual version
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
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
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 24),
        vertical: Responsive.h(context, 16),
      ),
      child: Row(
        children: <Widget>[
          // Avatar with online indicator
          ProfileAvatar(
            avatarUrl: user?.avatarUrl,
            baseSize: 56,
            showOnlineIndicator: true,
            isOnline: true,
          ),

          SizedBox(width: Responsive.w(context, 16)),

          // Username
          Expanded(
            child: Text(
              '@${user?.username ?? 'username'}',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          SizedBox(width: Responsive.w(context, 16)),

          // Edit button
          OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push(AppRoutes.editProfile);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.h(context, 4),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colorScheme.outline),
            ),
            child: Text(t.settings.edit, style: textTheme.labelMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(
    BuildContext context,
    ThemeState themeState,
    ThemeNotifier themeNotifier,
    Translations t,
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = themeState.mode == AppThemeMode.dark;

    return ModernSettingsTile(
      icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
      title: t.settings.mode,
      subtitle: isDarkMode ? t.settings.darkMode : t.settings.lightMode,
      trailing: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            if (isDarkMode) {
              themeNotifier.setThemeMode(AppThemeMode.light);
            } else {
              themeNotifier.setThemeMode(AppThemeMode.dark);
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildThemeIndicator(context, icon: Icons.light_mode, isSelected: !isDarkMode),
              _buildThemeIndicator(context, icon: Icons.dark_mode, isSelected: isDarkMode),
            ],
          ),
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
}
