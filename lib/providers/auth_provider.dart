import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/app_user.dart';
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

    try {
      // Fetch profile from backend
      final Map<String, dynamic> profileData =
          await ref.read(userRepositoryProvider).getMyProfile();
      return AppUser.fromBackendProfile(firebaseUid: firebaseUser.uid, profileData: profileData);
    } catch (e) {
      // Fallback to Firebase user if backend fetch fails
      // This can happen if user just registered and profile isn't synced yet
      return AppUser.fromFirebaseUser(firebaseUser);
    }
  });
});
