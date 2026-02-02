import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/services/auth_repository.dart';

/// Provider for the [AuthRepository].
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepository(FirebaseAuth.instance);
});

/// Stream provider for the authentication state changes.
final StreamProvider<User?> authStateChangesProvider = StreamProvider<User?>((Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// Provider for fetching the current user's profile from backend.
///
/// This is separate from auth state so it can be refreshed independently
/// (e.g., after avatar upload) without triggering a full auth reload.
final FutureProvider<ProfileResponse?> myProfileProvider = FutureProvider<ProfileResponse?>((
  Ref ref,
) async {
  final User? firebaseUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (firebaseUser == null) return null;

  // Retry fetching profile up to 3 times with delay
  for (int i = 0; i < 3; i++) {
    try {
      return await ref.read(userRepositoryProvider).getMyProfile();
    } catch (e) {
      if (i == 2) return null; // All retries failed
      await Future<void>.delayed(Duration(milliseconds: 500 * (1 << i)));
    }
  }
  return null;
});

/// Provider for the current [AppUser].
///
/// Combines Firebase auth state with backend profile data.
/// To refresh just the profile (e.g., after avatar update), use:
/// `ref.invalidate(myProfileProvider)` instead of invalidating this provider.
final Provider<AsyncValue<AppUser?>> appUserProvider = Provider<AsyncValue<AppUser?>>((Ref ref) {
  final AsyncValue<User?> authState = ref.watch(authStateChangesProvider);
  final AsyncValue<ProfileResponse?> profileState = ref.watch(myProfileProvider);

  return authState.when(
    data: (User? firebaseUser) {
      if (firebaseUser == null) {
        return const AsyncValue<AppUser?>.data(null);
      }

      return profileState.when(
        data: (ProfileResponse? profile) {
          if (profile != null) {
            return AsyncValue<AppUser?>.data(
              AppUser.fromProfileResponse(firebaseUid: firebaseUser.uid, profile: profile),
            );
          }
          // Fallback to Firebase user if profile fetch failed
          return AsyncValue<AppUser?>.data(AppUser.fromFirebaseUser(firebaseUser));
        },
        loading: () => const AsyncValue<AppUser?>.loading(),
        error: (Object e, StackTrace st) {
          // Fallback to Firebase user on error
          return AsyncValue<AppUser?>.data(AppUser.fromFirebaseUser(firebaseUser));
        },
      );
    },
    loading: () => const AsyncValue<AppUser?>.loading(),
    error: (Object e, StackTrace st) => AsyncValue<AppUser?>.error(e, st),
  );
});
