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

/// Provider for the current [AppUser].
///
/// This provider fetches user profile data from the backend API when
/// Firebase auth state changes. Falls back to Firebase user data if
/// backend fetch fails.
final StreamProvider<AppUser?> appUserProvider = StreamProvider<AppUser?>((Ref ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);

  return authRepository.authStateChanges.asyncMap((User? firebaseUser) async {
    if (firebaseUser == null) {
      return null;
    }

    // Retry fetching profile up to 3 times with delay
    // This handles the race condition where the backend user record isn't immediately available
    // after Firebase authentication
    for (int i = 0; i < 3; i++) {
      try {
        final ProfileResponse profile = await ref.read(userRepositoryProvider).getMyProfile();
        return AppUser.fromProfileResponse(firebaseUid: firebaseUser.uid, profile: profile);
      } catch (e) {
        if (i == 2) {
          // If all retries fail, fall back to Firebase user
          return AppUser.fromFirebaseUser(firebaseUser);
        }
        // Wait before retrying (exponential backoff: 500ms, 1000ms, 2000ms)
        await Future<void>.delayed(Duration(milliseconds: 500 * (1 << i)));
      }
    }
    return AppUser.fromFirebaseUser(firebaseUser);
  });
});
