import 'package:flutter/material.dart';

/// A screen that displays a loading indicator.
///
/// This screen is shown while the app is initializing providers or performing
/// other startup tasks.
class AppLoadingScreen extends StatelessWidget {
  /// Creates a new [AppLoadingScreen].
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.blueAccent,
        ), // Replace with logo or animation later
      ),
    );
  }
}
