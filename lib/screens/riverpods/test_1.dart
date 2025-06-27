import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rally/providers/theme_provider.dart';
import 'package:rally/themes/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TestApp()));
}

class TestApp extends ConsumerWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeNotifier.MaterialThemeMode,
      home: const ParentWidget(title: 'Rally Demo'),
    );
  }
}

class ParentWidget extends ConsumerWidget {
  const ParentWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final next =
                  currentTheme == AppThemeMode.light
                      ? AppThemeMode.dark
                      : AppThemeMode.light;
              themeNotifier.setThemeMode(next);
            },
          ),
        ],
      ),
      body: const Center(child: ChildrenWidget()),
    );
  }
}

class ChildrenWidget extends StatelessWidget {
  const ChildrenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    print('Child built');
    return const Text('I am a child');
  }
}
