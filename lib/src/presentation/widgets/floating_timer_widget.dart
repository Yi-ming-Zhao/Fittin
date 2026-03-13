import 'package:flutter/material.dart';

class FloatingTimerWidget extends StatefulWidget {
  final Future<void> Function()? onTimerEnd;

  const FloatingTimerWidget({super.key, this.onTimerEnd});

  @override
  State<FloatingTimerWidget> createState() => FloatingTimerWidgetState();
}

class FloatingTimerWidgetState extends State<FloatingTimerWidget> {
  // Simplified for prototype:
  String _timeRemaining = "02:00";
  bool _isActive = false;

  void startTimer([int seconds = 120]) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    _timeRemaining =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    setState(() => _isActive = true);
    // In a real app we would use Timer.periodic
  }

  @override
  Widget build(BuildContext context) {
    if (!_isActive) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              "休息倒计时 — $_timeRemaining",
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
