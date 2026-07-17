import 'dart:math' as math;

import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';
import 'package:flutter/material.dart';

class StartupSplashScreen extends StatefulWidget {
  const StartupSplashScreen({
    super.key,
    required this.theme,
    required this.strings,
    this.hasError = false,
    this.onRetry,
    this.onContinueLocally,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final bool hasError;
  final VoidCallback? onRetry;
  final VoidCallback? onContinueLocally;

  @override
  State<StartupSplashScreen> createState() => _StartupSplashScreenState();
}

class _StartupSplashScreenState extends State<StartupSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _motionEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      value: 0.55,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.maybeOf(context);
    final shouldAnimate =
        !widget.hasError &&
        !(media?.disableAnimations ?? false) &&
        !(media?.accessibleNavigation ?? false);
    if (shouldAnimate == _motionEnabled) {
      return;
    }
    _motionEnabled = shouldAnimate;
    if (_motionEnabled) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0.55;
    }
  }

  @override
  void didUpdateWidget(covariant StartupSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hasError != widget.hasError) {
      _motionEnabled = !widget.hasError;
      if (_motionEnabled) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 0.55;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final strings = widget.strings;
    return Scaffold(
      key: const ValueKey('startup-splash'),
      backgroundColor: theme.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: math.max(theme.pad, 24),
                  vertical: 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    key: const ValueKey('startup-content'),
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => Semantics(
                            label: strings.startupLoadingSemantics,
                            image: true,
                            child: CustomPaint(
                              key: const ValueKey('startup-barbell-mark'),
                              size: const Size(176, 72),
                              painter: _StartupBarbellPainter(
                                theme: theme,
                                progress: widget.hasError
                                    ? 0.55
                                    : Curves.easeInOutCubic.transform(
                                        _controller.value,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          'FITTIN',
                          style: theme
                              .displayStyle(28, theme.fg)
                              .copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 5.4,
                              ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          widget.hasError
                              ? strings.startupLoadFailed
                              : strings.startupPreparing,
                          textAlign: TextAlign.center,
                          style: theme
                              .uiStyle(17, theme.fg, FontWeight.w700)
                              .copyWith(height: 1.25),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.hasError
                              ? strings.startupLoadFailedDetail
                              : strings.startupPreparingDetail,
                          textAlign: TextAlign.center,
                          style: theme
                              .uiStyle(13, theme.fgDim)
                              .copyWith(height: 1.5),
                        ),
                        if (widget.hasError) ...[
                          const SizedBox(height: 26),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (widget.onRetry != null)
                                FittinBtn(
                                  theme,
                                  strings.retry,
                                  key: const ValueKey('startup-retry'),
                                  icon: Icons.refresh_rounded,
                                  onPressed: widget.onRetry,
                                ),
                              if (widget.onContinueLocally != null)
                                FittinBtn(
                                  theme,
                                  strings.continueLocally,
                                  key: const ValueKey('startup-continue-local'),
                                  variant: 'ghost',
                                  onPressed: widget.onContinueLocally,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupBarbellPainter extends CustomPainter {
  const _StartupBarbellPainter({required this.theme, required this.progress});

  final FittinTheme theme;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final travel = 3.5 * (progress - 0.5);
    final barPaint = Paint()
      ..color = theme.fgDim
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(12, center.dy),
      Offset(size.width - 12, center.dy),
      barPaint,
    );

    final collarPaint = Paint()..color = theme.fg;
    for (final side in [-1.0, 1.0]) {
      final collarX = center.dx + side * 42;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(collarX, center.dy),
            width: 7,
            height: 25,
          ),
          const Radius.circular(3),
        ),
        collarPaint,
      );

      final direction = side < 0 ? -1.0 : 1.0;
      final innerX = center.dx + side * (53 + travel);
      _drawPlate(
        canvas,
        Offset(innerX, center.dy),
        width: 10,
        height: 39,
        color: theme.accent,
      );
      _drawPlate(
        canvas,
        Offset(innerX + direction * 11, center.dy),
        width: 8,
        height: 31,
        color: theme.chartSeries[1],
      );
      _drawPlate(
        canvas,
        Offset(innerX + direction * 20, center.dy),
        width: 6,
        height: 23,
        color: theme.fgDim,
      );
    }
  }

  void _drawPlate(
    Canvas canvas,
    Offset center, {
    required double width,
    required double height,
    required Color color,
  }) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        Radius.circular(width / 2),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _StartupBarbellPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.theme != theme;
  }
}
