import 'dart:math' as math;

import 'package:fittin_v2/src/domain/exercise_library.dart';
import 'package:fittin_v2/src/domain/models/custom_exercise.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:flutter/material.dart';

class ExerciseCatalogSheet extends StatefulWidget {
  const ExerciseCatalogSheet({
    super.key,
    required this.theme,
    required this.strings,
    required this.localeCode,
    required this.items,
    required this.onSelected,
    this.selectedId,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String localeCode;
  final List<ExerciseCatalogItem> items;
  final ValueChanged<ExerciseCatalogItem> onSelected;
  final String? selectedId;

  @override
  State<ExerciseCatalogSheet> createState() => _ExerciseCatalogSheetState();
}

class _ExerciseCatalogSheetState extends State<ExerciseCatalogSheet> {
  final _searchController = TextEditingController();
  ExerciseEquipment? _equipment;
  ExerciseMuscle? _muscle;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final availableHeight = math.max(
      0.0,
      media.size.height - media.viewInsets.bottom - media.padding.bottom,
    );
    final sheetHeight = math.min(media.size.height * 0.82, availableHeight);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.items
        .where((item) {
          if (_equipment != null && item.equipment != _equipment) return false;
          if (_muscle != null &&
              !item.primaryMuscles.contains(_muscle) &&
              !item.secondaryMuscles.contains(_muscle)) {
            return false;
          }
          if (query.isEmpty) return true;
          final haystack = [
            item.nameEn,
            item.nameZhCn,
            item.movement.name,
            item.equipment.name,
            ...item.tags,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: SizedBox(
          key: const ValueKey('exercise-catalog-sheet-frame'),
          height: sheetHeight,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: widget.theme.borderHi,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.strings.replaceExerciseTitle,
                        style: widget.theme.displayStyle(24),
                      ),
                    ),
                    IconButton(
                      tooltip: widget.strings.close,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: widget.strings.replaceExerciseSearch,
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  key: const ValueKey('exercise-catalog-scroll'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(top: 10, bottom: 24),
                  itemCount: filtered.isEmpty ? 3 : filtered.length + 2,
                  separatorBuilder: (_, index) => SizedBox(
                    height: index == 0
                        ? 6
                        : index == 1
                        ? 12
                        : 8,
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _FilterPill(
                              label: widget.strings.isChinese
                                  ? '全部器械'
                                  : 'All equipment',
                              selected: _equipment == null,
                              onTap: () => setState(() => _equipment = null),
                            ),
                            for (final equipment in ExerciseEquipment.values)
                              if (equipment != ExerciseEquipment.selection)
                                _FilterPill(
                                  label: _equipmentLabel(
                                    equipment,
                                    widget.strings,
                                  ),
                                  selected: _equipment == equipment,
                                  onTap: () =>
                                      setState(() => _equipment = equipment),
                                ),
                          ],
                        ),
                      );
                    }
                    if (index == 1) {
                      return SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _FilterPill(
                              label: widget.strings.isChinese
                                  ? '全部肌群'
                                  : 'All muscles',
                              selected: _muscle == null,
                              onTap: () => setState(() => _muscle = null),
                            ),
                            for (final muscle in ExerciseMuscle.values)
                              _FilterPill(
                                label: _muscleLabel(muscle, widget.strings),
                                selected: _muscle == muscle,
                                onTap: () => setState(() => _muscle = muscle),
                              ),
                          ],
                        ),
                      );
                    }
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Center(
                          child: Text(
                            widget.strings.noExerciseMatches,
                            style: widget.theme.uiStyle(
                              14,
                              widget.theme.fgMuted,
                            ),
                          ),
                        ),
                      );
                    }

                    final item = filtered[index - 2];
                    final selected = item.id == widget.selectedId;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: item.displayName(widget.localeCode),
                        child: Material(
                          color: selected
                              ? widget.theme.surfaceSelected
                              : widget.theme.surfaceSolid,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => widget.onSelected(item),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 64),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: widget.theme.surfaceHi,
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        _equipmentIcon(item.equipment),
                                        size: 20,
                                        color: widget.theme.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.displayName(widget.localeCode),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: widget.theme.uiStyle(
                                              14,
                                              widget.theme.fg,
                                              FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${_equipmentLabel(item.equipment, widget.strings)} · ${item.primaryMuscles.map((value) => _muscleLabel(value, widget.strings)).join(' / ')}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: widget.theme.uiStyle(
                                              11,
                                              widget.theme.fgMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!item.isBuiltIn)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Text(
                                          widget.strings.custom,
                                          style: widget.theme.uiStyle(
                                            10,
                                            widget.theme.accent,
                                            FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    if (selected)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.check_rounded,
                                          color: widget.theme.accent,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

String _equipmentLabel(ExerciseEquipment value, AppStrings strings) {
  const zh = {
    ExerciseEquipment.barbell: '杠铃',
    ExerciseEquipment.dumbbell: '哑铃',
    ExerciseEquipment.cable: '绳索',
    ExerciseEquipment.machine: '器械',
    ExerciseEquipment.bodyweight: '自重',
    ExerciseEquipment.band: '弹力带',
    ExerciseEquipment.mixed: '组合',
    ExerciseEquipment.selection: '选择',
  };
  return strings.isChinese ? zh[value]! : value.name;
}

String _muscleLabel(ExerciseMuscle value, AppStrings strings) {
  const zh = {
    ExerciseMuscle.chest: '胸',
    ExerciseMuscle.anteriorDeltoids: '三角肌前束',
    ExerciseMuscle.lateralDeltoids: '三角肌中束',
    ExerciseMuscle.rearDeltoids: '三角肌后束',
    ExerciseMuscle.triceps: '肱三头肌',
    ExerciseMuscle.biceps: '肱二头肌',
    ExerciseMuscle.forearms: '前臂',
    ExerciseMuscle.lats: '背阔肌',
    ExerciseMuscle.upperBack: '上背',
    ExerciseMuscle.lowerBack: '下背',
    ExerciseMuscle.core: '核心',
    ExerciseMuscle.glutes: '臀',
    ExerciseMuscle.quadriceps: '股四头肌',
    ExerciseMuscle.hamstrings: '腘绳肌',
    ExerciseMuscle.calves: '小腿',
    ExerciseMuscle.adductors: '内收肌',
  };
  return strings.isChinese ? zh[value]! : value.name;
}

IconData _equipmentIcon(ExerciseEquipment value) => switch (value) {
  ExerciseEquipment.barbell => Icons.fitness_center_rounded,
  ExerciseEquipment.dumbbell => Icons.fitness_center_outlined,
  ExerciseEquipment.cable ||
  ExerciseEquipment.machine => Icons.settings_rounded,
  ExerciseEquipment.bodyweight => Icons.accessibility_new_rounded,
  ExerciseEquipment.band => Icons.horizontal_rule_rounded,
  ExerciseEquipment.mixed ||
  ExerciseEquipment.selection => Icons.grid_view_rounded,
};
