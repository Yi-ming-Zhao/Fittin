import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/exercise_library_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/milestone_preferences_provider.dart';
import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';

class MilestoneExerciseSettingsScreen extends ConsumerStatefulWidget {
  const MilestoneExerciseSettingsScreen({super.key});

  @override
  ConsumerState<MilestoneExerciseSettingsScreen> createState() =>
      _MilestoneExerciseSettingsScreenState();
}

class _MilestoneExerciseSettingsScreenState
    extends ConsumerState<MilestoneExerciseSettingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final preferences = ref.watch(milestoneExercisePreferencesProvider);
    final libraryAsync = ref.watch(exerciseLibraryProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      body: DashboardPageScaffold(
        topPadding: 28,
        children: [
          DashboardScreenHeader(
            eyebrow: strings.settings,
            title: strings.milestoneExercises,
            subtitle: strings.milestoneExercisesSubtitle,
            showBackButton: true,
          ),
          const SizedBox(height: 20),
          TextField(
            key: const ValueKey('milestone-exercise-search'),
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: strings.clearSearch,
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
              labelText: strings.searchExercises,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.selectedExerciseCount(preferences.exerciseIds.length),
                  style: theme.uiStyle(12, theme.fgDim, FontWeight.w700),
                ),
              ),
              TextButton(
                key: const ValueKey('reset-milestone-exercises'),
                onPressed: () => ref
                    .read(milestoneExercisePreferencesProvider.notifier)
                    .reset(),
                child: Text(strings.resetBigThree),
              ),
            ],
          ),
          const SizedBox(height: 8),
          libraryAsync.when(
            data: (library) {
              final definitions = _filteredDefinitions(
                library,
                strings.isChinese ? 'zh' : 'en',
              );
              if (definitions.isEmpty) {
                return DashboardSurfaceCard(
                  padding: const EdgeInsets.all(18),
                  child: Text(strings.noExerciseMatches),
                );
              }
              return DashboardSurfaceCard(
                padding: EdgeInsets.zero,
                radius: 24,
                child: Column(
                  children: [
                    for (var index = 0; index < definitions.length; index++)
                      _MilestoneExerciseTile(
                        definition: definitions[index],
                        localeCode: strings.isChinese ? 'zh' : 'en',
                        selected: preferences.exerciseIds.contains(
                          definitions[index].id,
                        ),
                        showDivider: index < definitions.length - 1,
                        onChanged: () => ref
                            .read(milestoneExercisePreferencesProvider.notifier)
                            .toggle(definitions[index].id),
                      ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text(strings.loadError(error)),
          ),
        ],
      ),
    );
  }

  List<ExerciseDefinition> _filteredDefinitions(
    ExerciseLibrary library,
    String localeCode,
  ) {
    final query = normalizeExerciseKey(_query);
    final definitions = library.definitions
        .where((definition) => !definition.isSelectionSlot)
        .where((definition) {
          if (query.isEmpty) {
            return true;
          }
          return [
            definition.id,
            definition.nameEn,
            definition.nameZhCn,
            ...definition.aliases,
          ].any((value) => normalizeExerciseKey(value).contains(query));
        })
        .toList();
    definitions.sort((a, b) {
      if (a.isCompetitionLift != b.isCompetitionLift) {
        return a.isCompetitionLift ? -1 : 1;
      }
      return a.displayName(localeCode).compareTo(b.displayName(localeCode));
    });
    return definitions;
  }
}

class _MilestoneExerciseTile extends StatelessWidget {
  const _MilestoneExerciseTile({
    required this.definition,
    required this.localeCode,
    required this.selected,
    required this.showDivider,
    required this.onChanged,
  });

  final ExerciseDefinition definition;
  final String localeCode;
  final bool selected;
  final bool showDivider;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('milestone-exercise-${definition.id}'),
      onTap: onChanged,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 11, 12, 11),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.displayName(localeCode),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    definition.id,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Checkbox(value: selected, onChanged: (_) => onChanged()),
          ],
        ),
      ),
    );
  }
}
