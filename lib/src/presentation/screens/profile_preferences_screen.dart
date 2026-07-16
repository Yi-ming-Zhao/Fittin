import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/home_dashboard_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class ProfilePreferencesScreen extends ConsumerStatefulWidget {
  const ProfilePreferencesScreen({super.key});

  @override
  ConsumerState<ProfilePreferencesScreen> createState() =>
      _ProfilePreferencesScreenState();
}

class _ProfilePreferencesScreenState
    extends ConsumerState<ProfilePreferencesScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final preference = ref.watch(homeDisplayNamePreferenceProvider);
    final currentValue = preference.valueOrNull ?? '';
    if (_controller.text != currentValue) {
      _controller.value = TextEditingValue(
        text: currentValue,
        selection: TextSelection.collapsed(offset: currentValue.length),
      );
    }

    return Scaffold(
      backgroundColor: theme.bg,
      body: DashboardPageScaffold(
        bottomPadding: 40,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.profile,
            title: strings.profilePreferences,
            subtitle: strings.profilePreferencesSubtitle,
            showBackButton: true,
          ),
          const SizedBox(height: 24),
          DashboardSurfaceCard(
            radius: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.displayName,
                  style: theme
                      .uiStyle(16, theme.fg)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  strings.homeDisplayNameHint,
                  style: theme.uiStyle(14, theme.fgDim),
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const ValueKey('profile-display-name-field'),
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: strings.displayName,
                    hintText: strings.displayNamePlaceholder,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('save-profile-display-name'),
                        onPressed: () async {
                          await ref
                              .read(homeDisplayNamePreferenceProvider.notifier)
                              .save(_controller.text);
                        },
                        child: Text(strings.save),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonal(
                        key: const ValueKey('clear-profile-display-name'),
                        onPressed: () async {
                          await ref
                              .read(homeDisplayNamePreferenceProvider.notifier)
                              .clear();
                        },
                        child: Text(strings.clearDisplayName),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
