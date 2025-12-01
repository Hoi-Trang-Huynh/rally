import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/app_user.dart';
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
/// This provider transforms the Firebase [User] into an [AppUser].
/// It returns null if the user is not signed in.
final StreamProvider<AppUser?> appUserProvider = StreamProvider<AppUser?>((Ref ref) {
  final AsyncValue<User?> authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data: (User? user) {
      if (user == null) {
        return Stream<AppUser?>.value(null);
      }
      return Stream<AppUser?>.value(AppUser.fromFirebaseUser(user));
    },
    loading: () => const Stream<AppUser?>.empty(),
    error: (_, __) => const Stream<AppUser?>.empty(),
  );
});
