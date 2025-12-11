import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';

/// Screen to display current user data from the backend.
class AuthTestScreen extends ConsumerWidget {
  /// Creates a new [AuthTestScreen].
  const AuthTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> authState = ref.watch(appUserProvider);
    final GoogleSignIn googleSignIn = GoogleSignIn();

    return Scaffold(
      appBar: AppBar(title: const Text('Current User Data')),
      body: authState.when(
        data: (AppUser? user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Profile picture
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl == null ? const Icon(Icons.person, size: 50) : null,
                  ),
                ),
                const SizedBox(height: 24),

                // User data fields
                _buildDataRow('Firebase UID', user.uid),
                _buildDataRow('MongoDB ID', user.id ?? 'N/A'),
                _buildDataRow('Email', user.email ?? 'N/A'),
                _buildDataRow('Username', user.username ?? 'N/A'),
                _buildDataRow('First Name', user.firstName ?? 'N/A'),
                _buildDataRow('Last Name', user.lastName ?? 'N/A'),
                _buildDataRow('Avatar URL', user.avatarUrl ?? 'N/A'),
                _buildDataRow('Email Verified', user.isEmailVerified.toString()),
                _buildDataRow('Is Onboarding', user.isOnboarding.toString()),

                const SizedBox(height: 32),

                // Sign out button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authRepositoryProvider).signOut();
                      await googleSignIn.signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }
}
