import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/screens/auth/auth_screen.dart';
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

  List<Map<String, String>> _getPages() {
    return <Map<String, String>>[
      <String, String>{'title': t.onboarding.page1.title, 'subtitle': t.onboarding.page1.subtitle},
      <String, String>{'title': t.onboarding.page2.title, 'subtitle': t.onboarding.page2.subtitle},
      <String, String>{'title': t.onboarding.page3.title, 'subtitle': t.onboarding.page3.subtitle},
    ];
  }

  Future<void> _completeOnboarding() async {
    await ref.read(sharedPrefsServiceProvider).setBool(SharedPrefKeys.onboardingSeen, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AuthScreen(initialIsLogin: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<Map<String, String>> pages = _getPages();

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
                itemCount: pages.length,
                itemBuilder: (BuildContext context, int index) {
                  // Different icons for each page
                  final List<IconData> pageIcons = <IconData>[
                    Icons.group_rounded,
                    Icons.route_rounded,
                    Icons.celebration_rounded,
                  ];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Gradient accent container with icon
                        Container(
                          height: 220,
                          width: 220,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(pageIcons[index], size: 80, color: colorScheme.onPrimary),
                        ),
                        const SizedBox(height: 64),
                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pages[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.6,
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
                      pages.length,
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
                      if (_currentPage == pages.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    text: _currentPage == pages.length - 1 ? t.common.getStarted : t.common.next,
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
