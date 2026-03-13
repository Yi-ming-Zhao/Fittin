import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/plan_library_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/domain/models/training_max.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/screens/plan_editor_screen.dart';

class PlanLibraryScreen extends ConsumerWidget {
  const PlanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(planLibraryItemsProvider);
    final actionState = ref.watch(planLibraryActionProvider);
    final actionNotifier = ref.read(planLibraryActionProvider.notifier);
    final theme = Theme.of(context);
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);

    if (actionState.infoMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.infoMessage!)));
        actionNotifier.dismissMessages();
      });
    } else if (actionState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(actionState.errorMessage!)));
        actionNotifier.dismissMessages();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.planLibrary), centerTitle: true),
      body: templatesAsync.when(
        data: (templates) => ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: templates.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = templates[index];
            final record = item.record;
            final preview = record.template.workouts
                .take(3)
                .map((workout) => localizedWorkoutName(workout, locale))
                .join(' · ');
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: item.isActive
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.04),
                border: Border.all(
                  color: item.isActive
                      ? theme.colorScheme.primary.withValues(alpha: 0.18)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizedTemplateName(record.template, locale),
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (record.isBuiltIn)
                        _MetaPill(
                          label: strings.builtIn,
                          color: theme.colorScheme.primary,
                        )
                      else
                        _MetaPill(
                          label: strings.custom,
                          color: theme.colorScheme.secondary,
                        ),
                      if (item.isActive) ...[
                        const SizedBox(width: 8),
                        _MetaPill(
                          label: strings.active,
                          color: theme.colorScheme.tertiary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizedTemplateDescription(record.template, locale),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    preview,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.calendar_view_week_rounded,
                        label: strings.workoutsCount(record.template.workouts.length),
                      ),
                      _StatChip(
                        icon: Icons.fitness_center_rounded,
                        label: strings.exercisesCount(
                          record.template.workouts.fold<int>(
                            0,
                            (sum, workout) => sum + workout.exercises.length,
                          ),
                        ),
                      ),
                      _StatChip(
                        icon: Icons.play_circle_outline_rounded,
                        label: strings.activeInstancesCount(record.instanceCount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed:
                              item.isActive ||
                                  (actionState.isSwitching &&
                                      actionState.switchingTemplateId ==
                                          record.template.id)
                              ? null
                              : () async {
                                  final trainingMaxProfile =
                                      await _resolveTrainingMaxProfile(
                                        context,
                                        record,
                                      );
                                  if (!context.mounted ||
                                      trainingMaxProfile == null) {
                                    return;
                                  }
                                  await actionNotifier.activateTemplate(
                                    record,
                                    trainingMaxProfile: trainingMaxProfile,
                                  );
                                },
                          icon:
                              actionState.isSwitching &&
                                  actionState.switchingTemplateId ==
                                      record.template.id
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  item.isActive
                                      ? Icons.check_circle_rounded
                                      : Icons.play_circle_fill_rounded,
                                ),
                          label: Text(item.isActive ? strings.current : strings.switchPlan),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlanEditorScreen(
                                  templateId: record.template.id,
                                ),
                              ),
                            );
                            ref.invalidate(planLibraryItemsProvider);
                          },
                          icon: const Icon(Icons.edit_outlined),
                          label: Text(strings.edit),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PlanEditorScreen()));
          ref.invalidate(planLibraryItemsProvider);
        },
        icon: const Icon(Icons.add_rounded),
        label: Text(strings.newPlan),
      ),
    );
  }
}

Future<TrainingMaxProfile?> _resolveTrainingMaxProfile(
  BuildContext context,
  StoredTemplateRecord record,
) async {
  if (record.instanceCount > 0 ||
      record.template.requiredTrainingMaxKeys.isEmpty) {
    return TrainingMaxProfile.empty;
  }

  return showDialog<TrainingMaxProfile>(
    context: context,
    builder: (_) => _TrainingMaxSetupDialog(template: record.template),
  );
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _TrainingMaxSetupDialog extends StatefulWidget {
  const _TrainingMaxSetupDialog({required this.template});

  final PlanTemplate template;

  @override
  State<_TrainingMaxSetupDialog> createState() => _TrainingMaxSetupDialogState();
}

class _TrainingMaxSetupDialogState extends State<_TrainingMaxSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {
      for (final key in widget.template.requiredTrainingMaxKeys)
        key: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final locale = container.read(appLocaleProvider);
    final strings = AppStrings.fromLocale(locale);
    return AlertDialog(
      title: Text(strings.setTrainingMaxes),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizedTemplateName(widget.template, locale),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (final liftKey in widget.template.requiredTrainingMaxKeys) ...[
                TextFormField(
                  controller: _controllers[liftKey],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: liftLabelFor(liftKey),
                    hintText: 'kg',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse((value ?? '').trim());
                    if (parsed == null || parsed <= 0) {
                      return strings.enterValidMax;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              return;
            }
            Navigator.of(context).pop(
              TrainingMaxProfile({
                for (final entry in _controllers.entries)
                  entry.key: double.parse(entry.value.text.trim()),
              }),
            );
          },
          child: Text(strings.startPlan),
        ),
      ],
    );
  }
}
