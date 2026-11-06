import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/verse.dart';
import '../../providers/providers.dart';
import '../settings/settings_screen.dart';
import 'widget_preview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The widget's "next verse" button may have changed today's verse while
    // the app was in the background; re-read it when we come back.
    if (state == AppLifecycleState.resumed) {
      ref.read(todayVerseProvider.notifier).refresh();
    }
  }

  Future<void> _copy(Verse verse) async {
    await Clipboard.setData(
      ClipboardData(text: '"${verse.text}"\n— ${verse.displayReference}'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verse copied')));
  }

  Future<void> _addWidget() async {
    final supported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
    if (!mounted) return;
    if (supported) {
      await HomeWidget.requestPinWidget(
        androidName: AppConstants.androidWidgetName,
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add the widget'),
        content: Text(
          Platform.isIOS
              ? 'Long-press your home screen, tap the + button, search for '
                    '"Reversed" and choose a size.'
              : 'Long-press your home screen, choose Widgets, find '
                    '"Reversed" and drag it onto the screen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verseAsync = ref.watch(todayVerseProvider);
    final preferences = ref.watch(preferencesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reversed'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: verseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load a verse.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (verse) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Today\'s verse',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: scheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(verse.scripture.title),
                      visualDensity: VisualDensity.compact,
                      side: BorderSide.none,
                      backgroundColor: scheme.primaryContainer,
                      labelStyle: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    Text(verse.text, style: AppTheme.verseStyle(context)),
                    const SizedBox(height: 16),
                    Text(
                      verse.displayReference,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: scheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: verseAsync.isLoading
                        ? null
                        : () => ref.read(todayVerseProvider.notifier).shuffle(),
                    icon: const Icon(Icons.shuffle_rounded),
                    label: const Text('New verse'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copy(verse),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Home screen widget',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            WidgetPreview(verse: verse, preferences: preferences),
            const SizedBox(height: 12),
            Text(
              'The widget shows a new verse every day and updates when you '
              'change scripture or style. Tap the shuffle icon on the widget '
              'for a different verse.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _addWidget,
              icon: const Icon(Icons.add_to_home_screen_rounded),
              label: const Text('Add widget to home screen'),
            ),
          ],
        ),
      ),
    );
  }
}
