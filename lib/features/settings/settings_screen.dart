import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_preferences.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final notifier = ref.read(preferencesProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const _SectionHeader('Scripture'),
          RadioGroup<ScriptureChoice>(
            groupValue: prefs.scriptureChoice,
            onChanged: (value) =>
                notifier.update((p) => p.copyWith(scriptureChoice: value)),
            child: Column(
              children: [
                for (final choice in ScriptureChoice.values)
                  RadioListTile<ScriptureChoice>(
                    title: Text(choice.label),
                    subtitle: choice == ScriptureChoice.random
                        ? const Text(
                            'A verse from any scripture, chosen for the day',
                          )
                        : null,
                    value: choice,
                  ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader('Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (selection) => notifier.update(
                (p) => p.copyWith(themeMode: selection.first),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Accent colour',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final accent in AccentPalette.values)
                  _AccentSwatch(
                    accent: accent,
                    selected: accent == prefs.accent,
                    onTap: () =>
                        notifier.update((p) => p.copyWith(accent: accent)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const _SectionHeader('Widget'),
          ListTile(
            title: const Text('Style'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<WidgetStyle>(
                segments: [
                  for (final style in WidgetStyle.values)
                    ButtonSegment(value: style, label: Text(style.label)),
                ],
                selected: {prefs.widgetStyle},
                onSelectionChanged: (selection) => notifier.update(
                  (p) => p.copyWith(widgetStyle: selection.first),
                ),
              ),
            ),
          ),
          ListTile(
            title: const Text('Text size'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SegmentedButton<WidgetTextSize>(
                segments: [
                  for (final size in WidgetTextSize.values)
                    ButtonSegment(value: size, label: Text(size.label)),
                ],
                selected: {prefs.widgetTextSize},
                onSelectionChanged: (selection) => notifier.update(
                  (p) => p.copyWith(widgetTextSize: selection.first),
                ),
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader('About'),
          ListTile(
            leading: Icon(Icons.menu_book_rounded, color: scheme.primary),
            title: const Text('Sources'),
            subtitle: const Text(
              'Bible: King James Version (public domain).\n'
              'Bhagavad Gita: English renderings based on public-domain '
              'translations (Swami Swarupananda, 1909; Edwin Arnold, 1885).',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AccentPalette accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: accent.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accent.color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
