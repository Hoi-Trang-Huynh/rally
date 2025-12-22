import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/screens/auth/signup_screen.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:rally/widgets/auth_primary_button.dart';

/// A screen that introduces the user to the application's features.
///
/// This screen is displayed only on the first app launch (or until the user completes the flow).
/// It uses a [PageView] to cycle through onboarding steps and persists the "seen" state
/// to [SharedPreferences] upon completion.
class OnboardingScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingScreen].
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = <Map<String, String>>[
    <String, String>{
      'title': 'Our Tech in your hand',
      'subtitle': 'You probably own a portable device, such as a smartphone or tablet.',
      // 'image': 'assets/images/onboarding1.png', // Placeholder
    },
    <String, String>{
      'title': 'All Control in your screen',
      'subtitle': 'This represents a great opportunity for your business to generate sales.',
      // 'image': 'assets/images/onboarding2.png', // Placeholder
    },
    <String, String>{
      'title': 'Understand the real benefits',
      'subtitle': 'Our portable technology gives your customers knowledge about you.',
      // 'image': 'assets/images/onboarding3.png', // Placeholder
    },
  ];

  Future<void> _completeOnboarding() async {
    await ref.read(sharedPrefsServiceProvider).setBool(SharedPrefKeys.onboardingSeen, true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const SignupScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(t.common.skip, style: textTheme.titleMedium),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Placeholder Image
                        Container(
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 64), // Increased spacing from image to title
                        Text(
                          _pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _pages[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6, // Slightly increased line height for readability
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: <Widget>[
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(
                      _pages.length,
                      (int index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == index
                                  ? colorScheme.primary
                                  : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  AuthPrimaryButton(
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    text: _currentPage == _pages.length - 1 ? t.common.getStarted : t.common.next,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
