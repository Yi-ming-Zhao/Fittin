import 'package:flutter/material.dart';

class SetInputRow extends StatefulWidget {
  final int setIndex;
  final String role;
  final int targetReps;
  final int completedReps;
  final double targetWeight;
  final double currentWeight;
  final bool isAmrap;
  final bool isCompleted;
  final void Function(int) onRepsChanged;
  final void Function(double) onWeightChanged;
  final VoidCallback onToggleComplete;

  const SetInputRow({
    super.key,
    required this.setIndex,
    required this.role,
    required this.targetReps,
    required this.completedReps,
    required this.targetWeight,
    required this.currentWeight,
    required this.isAmrap,
    required this.isCompleted,
    required this.onRepsChanged,
    required this.onWeightChanged,
    required this.onToggleComplete,
  });

  @override
  State<SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends State<SetInputRow> {
  late int _currentReps;
  late double _currentWeight;
  late bool _isCompleted;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _syncFromWidget();
  }

  @override
  void didUpdateWidget(covariant SetInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completedReps != widget.completedReps ||
        oldWidget.currentWeight != widget.currentWeight ||
        oldWidget.isCompleted != widget.isCompleted) {
      _syncFromWidget();
    }
  }

  void _syncFromWidget() {
    _currentReps = widget.completedReps;
    _currentWeight = widget.currentWeight;
    _isCompleted = widget.isCompleted;
  }

  void _handleRepsPan(DragUpdateDetails details) {
    if (_isCompleted) return;

    // Simple gesture threshold processing: swipe right to increase, left to decrease
    if (details.delta.dx > 1.0) {
      setState(() => _currentReps++);
    } else if (details.delta.dx < -1.0 && _currentReps > 0) {
      setState(() => _currentReps--);
    }
  }

  void _handleRepsPanEnd(DragEndDetails details) {
    if (!_isCompleted) {
      widget.onRepsChanged(_currentReps);
    }
  }

  void _handleWeightPan(DragUpdateDetails details) {
    if (_isCompleted) return;

    if (details.delta.dx > 1.0) {
      setState(() => _currentWeight += 2.5);
    } else if (details.delta.dx < -1.0 && _currentWeight > 0) {
      setState(() {
        final updatedWeight = _currentWeight - 2.5;
        _currentWeight = updatedWeight < 0 ? 0 : updatedWeight;
      });
    }
  }

  void _handleWeightPanEnd(DragEndDetails details) {
    if (!_isCompleted) {
      widget.onWeightChanged(_currentWeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _isCompleted
              ? colorScheme.primary.withOpacity(0.08)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.role == 'warmup'
                ? colorScheme.secondary.withOpacity(0.16)
                : colorScheme.primary.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.role == 'warmup'
                        ? colorScheme.secondary.withOpacity(0.12)
                        : colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.setIndex + 1}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _isCompleted
                          ? colorScheme.primary
                          : colorScheme.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.role == 'warmup' ? 'Warm-up Set' : 'Working Set',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: widget.role == 'warmup'
                              ? colorScheme.secondary
                              : colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.targetWeight.toStringAsFixed(widget.targetWeight.truncateToDouble() == widget.targetWeight ? 0 : 1)} kg • ${widget.targetReps} reps${widget.isAmrap ? '+' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.74),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isCompleted = !_isCompleted);
                    widget.onToggleComplete();
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _isCompleted
                        ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('checked'),
                            color: colorScheme.primary,
                            size: 32,
                          )
                        : Icon(
                            Icons.circle_outlined,
                            key: const ValueKey('unchecked'),
                            color: colorScheme.outline.withOpacity(0.5),
                            size: 32,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onPanUpdate: _handleWeightPan,
                    onPanEnd: _handleWeightPanEnd,
                    child: _ValueCard(
                      label: 'Weight',
                      value:
                          '${_currentWeight.toStringAsFixed(_currentWeight.truncateToDouble() == _currentWeight ? 0 : 1)} kg',
                      muted: _isCompleted,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Listener(
                    onPointerDown: (_) => setState(() => _isPressed = true),
                    onPointerUp: (_) => setState(() => _isPressed = false),
                    onPointerCancel: (_) => setState(() => _isPressed = false),
                    child: GestureDetector(
                      onPanUpdate: _handleRepsPan,
                      onPanEnd: _handleRepsPanEnd,
                      child: AnimatedScale(
                        scale: _isPressed ? 0.97 : 1.0,
                        duration: const Duration(milliseconds: 120),
                        child: _ValueCard(
                          label: widget.isAmrap ? 'Reps (AMRAP)' : 'Reps',
                          value: '$_currentReps',
                          accent: widget.isAmrap && !_isCompleted,
                          muted: _isCompleted,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.label,
    required this.value,
    this.accent = false,
    this.muted = false,
  });

  final String label;
  final String value;
  final bool accent;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: muted
            ? colorScheme.primary.withOpacity(0.08)
            : colorScheme.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: accent ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
