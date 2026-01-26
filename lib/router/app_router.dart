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
import 'package:rally/screens/loading/app_loading.dart';
import 'package:rally/screens/onboarding/onboarding_screen.dart';
import 'package:rally/screens/profile/edit_profile_screen.dart';
import 'package:rally/screens/profile/feedback_screen.dart';
import 'package:rally/screens/profile/profile_screen.dart';
import 'package:rally/screens/profile/settings_screen.dart';
import 'package:rally/screens/profile/user_profile_screen.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Route names for the app.
class AppRoutes {
  /// Splash screen route (shown during app initialization).
  static const String splash = '/splash';

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
  static const String chat = '/home/chat';

  /// Explore tab route.
  static const String explore = '/home/explore';

  /// Profile tab route.
  static const String profile = '/home/profile';

  /// User profile route (standalone, pushes onto stack).
  static const String userProfilePath = '/user/:userId';

  /// Helper to build user profile route path.
  static String userProfile(String userId) => '/user/$userId';

  /// Settings route (full screen, no shell).
  static const String settings = '/settings';

  /// Edit profile route (full screen, no shell).
  static const String editProfile = '/edit-profile';

  /// Feedback route (full screen, no shell).
  static const String feedback = '/feedback';
}

/// Notifier that triggers router refresh when auth state changes.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(this._ref) {
    _ref.listen(appUserProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

/// Provider for the auth change notifier.
final Provider<_AuthChangeNotifier> _authChangeNotifierProvider =
    Provider<_AuthChangeNotifier>((Ref ref) {
  return _AuthChangeNotifier(ref);
});

/// Provider for the go_router instance.
final Provider<GoRouter> goRouterProvider = Provider<GoRouter>((Ref ref) {
  final _AuthChangeNotifier authChangeNotifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authChangeNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      // Read (not watch) auth state in redirect to avoid router recreation
      final AsyncValue<AppUser?> authState = ref.read(appUserProvider);
      final bool isLoading = authState.isLoading;
      final bool isLoggedIn = authState.valueOrNull != null;
      final bool needsProfileCompletion =
          authState.valueOrNull?.needsProfileCompletion ?? false;

      final bool isOnSplash = state.matchedLocation == AppRoutes.splash;
      final bool isOnAuthRoute =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/signup') ||
          state.matchedLocation.startsWith('/onboarding') ||
          state.matchedLocation.startsWith('/profile-completion');

      // While auth is loading, show splash screen (only during initial boot)
      // If already on auth routes (login/signup), stay there during login process
      if (isLoading) {
        if (isOnSplash || isOnAuthRoute) {
          return null; // Stay on current screen
        }
        return AppRoutes.splash;
      }

      // Auth finished loading - redirect away from splash
      if (isOnSplash) {
        if (isLoggedIn) {
          return needsProfileCompletion ? AppRoutes.profileCompletion : AppRoutes.home;
        } else {
          final SharedPreferences? prefs = ref.read(sharedPrefsServiceProvider);
          final bool onboardingSeen = prefs?.getBool(SharedPrefKeys.onboardingSeen) ?? false;
          return onboardingSeen ? AppRoutes.login : AppRoutes.onboarding;
        }
      }

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
      // Splash screen (shown during app initialization)
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) => const AppLoadingScreen(),
      ),
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
      // Feedback (full screen, outside shell)
      GoRoute(
        path: AppRoutes.feedback,
        builder: (BuildContext context, GoRouterState state) => const FeedbackScreen(),
      ),
      // User Profile (full screen, outside shell - pushes onto stack)
      GoRoute(
        path: AppRoutes.userProfilePath,
        builder: (BuildContext context, GoRouterState state) {
          final String userId = state.pathParameters['userId'] ?? '';
          return UserProfileScreen(userId: userId);
        },
      ),

      // Main app with bottom navigation (ShellRoute)
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShell(child: child);
        },
        routes: <RouteBase>[
          // Home is the parent route for the shell content
          GoRoute(
            path: AppRoutes.home,
            pageBuilder:
                (BuildContext context, GoRouterState state) =>
                    const NoTransitionPage<void>(child: HomeScreen()),
            routes: <RouteBase>[
              // Chat sub-route
              GoRoute(
                path: 'chat', // /home/chat
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: ChatScreen()),
              ),
              // Explore sub-route
              GoRoute(
                path: 'explore', // /home/explore
                pageBuilder:
                    (BuildContext context, GoRouterState state) =>
                        const NoTransitionPage<void>(child: DiscoveryScreen()),
              ),
              // Profile sub-route
              GoRoute(
                path: 'profile', // /home/profile
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
