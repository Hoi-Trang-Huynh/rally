import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';

/// Screen to test authentication state.
class AuthTestScreen extends ConsumerStatefulWidget {
  /// Creates a new [AuthTestScreen].
  const AuthTestScreen({super.key});

  @override
  ConsumerState<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends ConsumerState<AuthTestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _errorMessage;
  bool _isLogin = true;

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await ref.read(authRepositoryProvider).signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      if (_isLogin) {
        await ref
            .read(authRepositoryProvider)
            .signInWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      } else {
        await ref
            .read(authRepositoryProvider)
            .createUserWithEmailAndPassword(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AppUser?> authState = ref.watch(appUserProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Sign In Test' : 'Create Account Test')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: authState.when(
            data: (AppUser? user) {
              if (user == null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _isLogin ? 'Sign In' : 'Create Account',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null) ...<Widget>[
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? 'Sign In' : 'Create Account'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Need an account? Create one' : 'Have an account? Sign in',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _signInWithGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Sign in with Google'),
                    ),
                  ],
                );
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (user.photoUrl != null)
                    CircleAvatar(backgroundImage: NetworkImage(user.photoUrl!)),
                  const SizedBox(height: 10),
                  Text('Signed in as: ${user.displayName ?? "No Name"}'),
                  Text('Email: ${user.email ?? "No Email"}'),
                  Text('UID: ${user.uid}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      await _googleSignIn.signOut();
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (Object error, StackTrace stack) => Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
