import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_theme.dart';
import 'features/home/home_screen.dart';
import 'providers/providers.dart';

class ReversedApp extends ConsumerWidget {
  const ReversedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    return MaterialApp(
      title: 'Reversed',
      debugShowCheckedModeBanner: false,
      themeMode: preferences.themeMode,
      theme: AppTheme.light(preferences.accent),
      darkTheme: AppTheme.dark(preferences.accent),
      home: const HomeScreen(),
    );
  }
}
