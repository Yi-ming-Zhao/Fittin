import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/services/export_service.dart';
import 'package:fittin_v2/src/domain/models/training_plan.dart';
import 'package:fittin_v2/src/presentation/localization/app_strings.dart';
import 'package:fittin_v2/src/presentation/localization/plan_text.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key, required this.planTemplate});

  final PlanTemplate planTemplate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = ref.watch(appLocaleProvider);
    final strings = AppStrings.of(context, ref);
    final sharePayload = ExportService.exportTemplateToSharePayload(
      planTemplate,
    );
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        automaticallyImplyLeading: canPop,
        title: Text(
          strings.shareTrainingPlan,
          style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 2.5),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizedTemplateName(planTemplate, locale),
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                strings.qrContainsPlan,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: sharePayload,
                  version: QrVersions.auto,
                  size: 260,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.circle,
                    color: Colors.black87,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.payloadSize(sharePayload.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 36),
              FilledButton.tonalIcon(
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
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text(strings.scanPlanQr),
              ),
            ],
          ),
        ),
      ),
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
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: canPop,
        title: Text(
          AppStrings.of(context, ref).scanPlanQr,
          style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 2.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: MobileScanner(
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
                content: Text(AppStrings.of(context, ref).invalidPlanQr),
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
    );
  }
}
