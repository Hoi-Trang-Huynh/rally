import 'package:firebase_auth/firebase_auth.dart';

/// Repository for handling authentication via Firebase.
class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  /// Creates a new [AuthRepository].
  AuthRepository(this._firebaseAuth);

  /// Stream of authentication state changes.
  ///
  /// Emits [User] when a user is signed in, and null when signed out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Returns the current user, or null if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Creates a new account with email and password.
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Gets the ID token for the current user.
  ///
  /// This token is used to authenticate requests to the backend API.
  /// If [forceRefresh] is true, the token will be refreshed.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _firebaseAuth.currentUser?.getIdToken(forceRefresh);
  }

  /// Signs in with the given [credential].
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Sends email verification to the current user.
  ///
  /// The user must be signed in before calling this method.
  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  /// Reloads the current user and returns whether email is verified.
  ///
  /// This should be called after the user clicks the verification link.
  Future<bool> isEmailVerified() async {
    await _firebaseAuth.currentUser?.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }
}
