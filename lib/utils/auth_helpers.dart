import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rally/models/responses/profile_response.dart';
import 'package:rally/models/responses/register_response.dart';
import 'package:rally/providers/api_provider.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/services/auth_repository.dart';
import 'package:rally/services/user_repository.dart';
import 'package:rally/utils/ui_helpers.dart';

/// Result of a Google Sign-In operation.
class GoogleSignInResult {
  /// Creates a new [GoogleSignInResult].
  const GoogleSignInResult({required this.userCredential, required this.userId});

  /// The Firebase user credential.
  final UserCredential userCredential;

  /// The MongoDB user ID.
  final String userId;
}

/// Shared authentication helper functions.

/// Signs in with Google and checks if user needs profile completion.
///
/// Returns a [GoogleSignInResult] with user credential and profile status.
/// Returns `null` if the user cancels the Google Sign-In flow.
/// Throws an exception if the sign-in fails.
Future<GoogleSignInResult?> signInWithGoogle({
  required AuthRepository authRepository,
  required UserRepository userRepository,
}) async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Sign out first to force the account picker to show, allowing user to choose a different account
  await googleSignIn.signOut();

  final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  if (googleUser == null) {
    return null; // User cancelled the sign-in
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  final OAuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  // Sign in to Firebase
  final UserCredential userCredential = await authRepository.signInWithCredential(credential);

  // Get Firebase ID token for backend API calls
  final String? idToken = await authRepository.getIdToken();
  if (idToken == null) {
    throw Exception('Failed to get Firebase ID token');
  }

  ProfileResponse profile;

  try {
    // Try to get existing user profile
    profile = await userRepository.getMyProfile();
  } catch (e) {
    // User not found in backend - register them first
    final RegisterResponse registerResponse = await userRepository.register(idToken: idToken);

    // Sync Firebase user data to MongoDB
    final String? newUserId = registerResponse.user.id;
    final User? firebaseUser = userCredential.user;

    if (newUserId != null && firebaseUser != null) {
      await userRepository.updateUserProfile(
        userId: newUserId,
        username: firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
      );
    }

    // Fetch the updated profile after registration
    profile = await userRepository.getMyProfile();
  }

  final String? userId = profile.id;

  return GoogleSignInResult(userCredential: userCredential, userId: userId ?? '');
}

/// Handles Google Sign-In with automatic navigation.
///
/// This is a convenience function that wraps [signInWithGoogle] and handles
/// navigation to the profile completion screen or lets main.dart handle routing.
///
/// [ref] is used to access providers.
/// [context] is used for navigation.
/// [onLoadingChanged] is called when loading state changes.
Future<void> handleGoogleSignInWithNavigation({
  required WidgetRef ref,
  required BuildContext context,
  required void Function(bool isLoading) onLoadingChanged,
}) async {
  onLoadingChanged(true);

  try {
    final GoogleSignInResult? result = await signInWithGoogle(
      authRepository: ref.read(authRepositoryProvider),
      userRepository: ref.read(userRepositoryProvider),
    );

    if (result == null) {
      // User cancelled
      onLoadingChanged(false);
      return;
    }

    if (!context.mounted) return;

    // Invalidate the auth provider to ensure we have the latest user data
    // This is crucial if the user was just registered or their profile updated
    ref.invalidate(appUserProvider);

    // Existing user - main.dart will handle routing via appUserProvider
  } catch (e) {
    if (context.mounted) {
      showErrorSnackBar(context, e.toString());
    }
  } finally {
    onLoadingChanged(false);
  }
}
