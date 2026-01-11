import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:rally/constants/shared_pref_keys.dart';
import 'package:rally/i18n/generated/translations.g.dart';
import 'package:rally/screens/auth/auth_screen.dart';
import 'package:rally/services/shared_prefs_service.dart';
import 'package:rally/themes/app_colors.dart';
import 'package:rally/widgets/visuals/animated_background.dart';

/// A screen that introduces the user to the application's features.
///
/// This screen is displayed only on the first app launch.
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
    final bool isLastPage = _currentPage == pages.length - 1;
    final bool isFirstPage = _currentPage == 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: <Widget>[
          // 1. Dynamic Background
          const AnimatedBackground(),

          SafeArea(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 16),
                // 2. Top Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/rally_logo_transparent.png',
                        height: 32,
                        // Removed color to show original gradient
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback:
                          (Rect bounds) => const LinearGradient(
                            colors: <Color>[
                              AppColors.brandGradientStart,
                              AppColors.brandGradientEnd,
                            ],
                          ).createShader(bounds),
                      child: Text(
                        'Rally',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Must be white for ShaderMask
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 3. Center Content (PageView)
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: AnimationConfiguration.toStaggeredList(
                            duration: const Duration(milliseconds: 600),
                            childAnimationBuilder:
                                (Widget widget) => SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(child: widget),
                                ),
                            children: <Widget>[
                              // Placeholder Image
                              Container(
                                height: 300,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: colorScheme.outline.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Icon(
                                        Icons.image_outlined,
                                        size: 64,
                                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Illustration Placeholder',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.onSurfaceVariant.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Title
                              Text(
                                pages[index]['title']!,
                                textAlign: TextAlign.center,
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Subtitle
                              Text(
                                pages[index]['subtitle']!,
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 4. Bottom Navigation Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      // Left Button (Skip or Back)
                      SizedBox(
                        width: 80,
                        child: FilledButton(
                          onPressed: () {
                            if (isFirstPage) {
                              _completeOnboarding();
                            } else {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            foregroundColor: colorScheme.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            isFirstPage ? t.common.skip : t.common.back,
                            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      // Indicators
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Widget>.generate(
                          pages.length,
                          (int index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == index ? 24 : 6,
                            decoration: BoxDecoration(
                              color:
                                  _currentPage == index
                                      ? colorScheme.primary
                                      : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),

                      // Right Button (Next or Get Started)
                      SizedBox(
                        width: 80,
                        child: FilledButton(
                          onPressed: () {
                            if (isLastPage) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            isLastPage ? 'Start' : t.common.next,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
