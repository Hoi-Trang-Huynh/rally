import 'package:flutter/material.dart';
import 'package:rally/themes/app_colors.dart';

/// A screen that displays the app logo during startup.
///
/// This screen is shown while the app is initializing providers or performing
/// other startup tasks. It features the Rally logo on a brand gradient background.
class AppLoadingScreen extends StatelessWidget {
  /// Creates a new [AppLoadingScreen].
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.brandGradientStart,
              AppColors.brandGradientEnd,
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/images/rally_logo_light_inverse.png',
            width: 120,
            height: 120,
          ),
        ),
      ),
    );
  }
}
