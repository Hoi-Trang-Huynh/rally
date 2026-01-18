import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/screens/auth/auth_screen.dart';
import 'package:rally/screens/auth/profile_completion_screen.dart';
import 'package:rally/screens/chat/chat_screen.dart';
import 'package:rally/screens/discovery/discovery_screen.dart';
import 'package:rally/screens/home/home_screen.dart';
import 'package:rally/screens/home/main_shell.dart';
import 'package:rally/screens/onboarding/onboarding_screen.dart';
import 'package:rally/screens/profile/edit_profile_screen.dart';
import 'package:rally/screens/profile/profile_screen.dart';
import 'package:rally/screens/profile/settings_screen.dart';
import 'package:rally/screens/profile/user_profile_screen.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Route names for the app.
class AppRoutes {
  /// Onboarding screen route.
  static const String onboarding = '/onboarding';

  /// Login screen route.
  static const String login = '/login';

  /// Signup screen route.
  static const String signup = '/signup';

  /// Profile completion screen route.
  static const String profileCompletion = '/profile-completion';

  /// Home tab route.
  static const String home = '/home';

  /// Chat tab route.
  static const String chat = '/chat';

  /// Explore tab route.
  static const String explore = '/explore';

  /// Profile tab route.
  static const String profile = '/profile';

  /// User profile route (nested under explore).
  static const String userProfile = 'user/:userId';

  /// Settings route (full screen, no shell).
  static const String settings = '/settings';

  /// Edit profile route (full screen, no shell).
  static const String editProfile = '/edit-profile';
}

/// Navigator keys for each shell branch.
/// These allow proper back navigation within nested routes.
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _chatNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chat');
final GlobalKey<NavigatorState> _exploreNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'explore',
);
final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'profile',
);

/// Provider for the go_router instance.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  // Only watch auth state changes (login/logout/profile completion)
  // to avoid rebuilding router on minor user updates (like name/bio changes)
  final bool isLoggedIn = ref.watch(
    appUserProvider.select((AsyncValue<AppUser?> s) => s.valueOrNull != null),
  );
  final bool needsProfileCompletion = ref.watch(
    appUserProvider.select(
      (AsyncValue<AppUser?> s) => s.valueOrNull?.needsProfileCompletion ?? false,
    ),
  );

  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isOnAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/profile-completion');

      // If not logged in and not on auth route, redirect to onboarding/login
      if (!isLoggedIn && !isOnAuthRoute) {
        final SharedPreferences? prefs = ref.read(sharedPrefsServiceProvider);
        final bool onboardingSeen = prefs?.getBool(SharedPrefKeys.onboardingSeen) ?? false;
        return onboardingSeen ? AppRoutes.login : AppRoutes.onboarding;
      }

      // If logged in but needs profile completion
      if (isLoggedIn && needsProfileCompletion) {
        if (!state.matchedLocation.startsWith('/profile-completion')) {
          return AppRoutes.profileCompletion;
        }
      }

      // If logged in and on auth route, redirect to home
      if (isLoggedIn && isOnAuthRoute && !needsProfileCompletion) {
        return AppRoutes.home;
      }

      return null; // No redirect
    },
    routes: <RouteBase>[
      // Auth routes (outside shell)
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext context, GoRouterState state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder:
            (BuildContext context, GoRouterState state) => const AuthScreen(initialIsLogin: true),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder:
            (BuildContext context, GoRouterState state) => const AuthScreen(initialIsLogin: false),
      ),
      GoRoute(
        path: AppRoutes.profileCompletion,
        builder: (BuildContext context, GoRouterState state) => const ProfileCompletionScreen(),
      ),
      // Settings (full screen, outside shell)
      GoRoute(
        path: AppRoutes.settings,
        builder: (BuildContext context, GoRouterState state) => const SettingsScreen(),
      ),
      // Edit Profile (full screen, outside shell)
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (BuildContext context, GoRouterState state) => const EditProfileScreen(),
      ),

      // Main app with bottom navigation (StatefulShellRoute)
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Home branch (index 0)
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: HomeScreen()),
              ),
            ],
          ),

          // Chat branch (index 1)
          StatefulShellBranch(
            navigatorKey: _chatNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chat,
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: ChatScreen()),
              ),
            ],
          ),

          // Explore branch (index 2)
          StatefulShellBranch(
            navigatorKey: _exploreNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.explore,
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: DiscoveryScreen()),
                routes: <RouteBase>[
                  // Nested user profile route
                  GoRoute(
                    path: AppRoutes.userProfile,
                    builder: (BuildContext context, GoRouterState state) {
                      final String userId = state.pathParameters['userId'] ?? '';
                      return UserProfileScreen(userId: userId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Profile branch (index 3)
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
