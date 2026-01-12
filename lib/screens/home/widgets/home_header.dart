import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/models/app_user.dart';
import 'package:rally/providers/auth_provider.dart';
import 'package:rally/utils/responsive.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  String _getGreeting(BuildContext context) {
    final int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppUser?> userAsync = ref.watch(appUserProvider);
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 24),
        vertical: Responsive.h(context, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _getGreeting(context),
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Responsive.h(context, 4)),
          userAsync.when(
            data: (AppUser? user) {
              final String name = user?.displayName ?? user?.username ?? 'Traveler';
              return Text(
                name,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              );
            },
            loading:
                () => SizedBox(
                  width: Responsive.w(context, 150),
                  height: Responsive.h(context, 32),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(Responsive.w(context, 8)),
                    ),
                  ),
                ),
            error:
                (_, __) => Text(
                  'Traveler',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
