import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/application/services/export_service.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';
import 'package:fittin_v2/src/presentation/theme/domain_color_palettes.dart';
import 'package:fittin_v2/src/presentation/widgets/dashboard_primitives.dart';
import 'package:fittin_v2/src/presentation/widgets/fittin_primitives.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key, required this.planTemplate});

  static const _maxQrBytePayload = 2953;

  final PlanTemplate planTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);
    final sharePayload = ExportService.exportTemplateToSharePayload(
      planTemplate,
    );
    final qrValidation = sharePayload.length <= _maxQrBytePayload
        ? QrValidator.validate(
            data: sharePayload,
            version: QrVersions.auto,
            errorCorrectionLevel: QrErrorCorrectLevel.L,
          )
        : null;
    final canPop = Navigator.of(context).canPop();

    return DashboardPageScaffold(
      bottomPadding: 40,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.planLibrary,
          title: strings.shareTrainingPlan,
          subtitle: localizedTemplateName(planTemplate, locale),
          showBackButton: canPop,
        ),
        const SizedBox(height: 24),
        DashboardSurfaceCard(
          radius: 32,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          highlight: true,
          child: Column(
            children: [
              Text(
                strings.qrContainsPlan,
                textAlign: TextAlign.center,
                style: fittinTheme
                    .uiStyle(14, fittinTheme.fgDim)
                    .copyWith(height: 1.45),
              ),
              const SizedBox(height: 20),
              if (qrValidation?.isValid ?? false)
                Container(
                  key: const ValueKey('plan-share-qr'),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: ExportPalette.canvas,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: ExportPalette.ink.withValues(alpha: 0.26),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: QrImageView.withQr(
                    qr: qrValidation!.qrCode!,
                    size: 260,
                    backgroundColor: ExportPalette.qrBackground,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle,
                      color: ExportPalette.qrForeground,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: ExportPalette.qrForeground,
                    ),
                  ),
                )
              else
                Container(
                  key: const ValueKey('plan-share-too-large'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: fittinTheme.surfaceHi,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: fittinTheme.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.data_object_rounded,
                        color: fittinTheme.accent,
                        size: 30,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.planTooLargeForQr,
                        textAlign: TextAlign.center,
                        style: fittinTheme.uiStyle(
                          16,
                          fittinTheme.fg,
                          FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.planTooLargeForQrDetail,
                        textAlign: TextAlign.center,
                        style: fittinTheme
                            .uiStyle(13, fittinTheme.fgDim)
                            .copyWith(height: 1.45),
                      ),
                      const SizedBox(height: 16),
                      FittinBtn(
                        fittinTheme,
                        strings.copyPlanData,
                        key: const ValueKey('copy-plan-share-payload'),
                        icon: Icons.copy_rounded,
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: sharePayload),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.planDataCopied),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                strings.payloadSize(sharePayload.length),
                style: fittinTheme.uiStyle(11, fittinTheme.fgMuted),
              ),
              const SizedBox(height: 22),
              FittinBtn(
                fittinTheme,
                strings.scanPlanQr,
                icon: Icons.qr_code_scanner_rounded,
                onPressed: () async {
                  final importedTemplate = await Navigator.of(context)
                      .push<PlanTemplate>(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const QRScannerScreen(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                        ),
                      );

                  if (!context.mounted || importedTemplate == null) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.importedTemplate(
                          localizedTemplateName(importedTemplate, locale),
                        ),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final fittinTheme = ref.watch(resolvedFittinThemeProvider);

    return Scaffold(
      backgroundColor: fittinTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) async {
                if (_isProcessing) {
                  return;
                }

                String? code;
                for (final barcode in capture.barcodes) {
                  final rawValue = barcode.rawValue;
                  if (rawValue != null && rawValue.isNotEmpty) {
                    code = rawValue;
                    break;
                  }
                }
                if (code == null) {
                  return;
                }

                setState(() => _isProcessing = true);

                try {
                  final importedTemplate = await ref
                      .read(todayWorkoutGatewayProvider)
                      .importSharedTemplate(
                        ExportService.importTemplateFromSharePayload(code),
                      );

                  if (!context.mounted) {
                    return;
                  }

                  Navigator.of(context).pop(importedTemplate);
                } catch (_) {
                  if (!context.mounted) {
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.invalidPlanQr),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Future<void>.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isProcessing = false);
                    }
                  });
                }
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(fittinTheme.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DashboardBackButton(
                    theme: fittinTheme,
                    label: strings.shareTrainingPlan,
                  ),
                  const Spacer(),
                  DashboardSurfaceCard(
                    radius: 26,
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      strings.scanPlanQr,
                      style: fittinTheme
                          .uiStyle(15, fittinTheme.fg)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
