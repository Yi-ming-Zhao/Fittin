import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/agent_provider_settings_provider.dart';
import '../../application/fittin_theme_provider.dart';
import '../localization/app_strings.dart';
import '../theme/fittin_theme.dart';
import '../widgets/dashboard_primitives.dart';
import '../widgets/fittin_card.dart';
import '../widgets/fittin_primitives.dart';
import '../widgets/agent_local_settings.dart';

class AgentSettingsScreen extends ConsumerStatefulWidget {
  const AgentSettingsScreen({super.key});

  @override
  ConsumerState<AgentSettingsScreen> createState() =>
      _AgentSettingsScreenState();
}

class _AgentSettingsScreenState extends ConsumerState<AgentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController();
  final _modelController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _contextController = TextEditingController(text: '32768');
  bool _obscureKey = true;
  bool _seeded = false;

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  void _seed(AgentProviderSettingsState state) {
    if (_seeded || state.isLoading) return;
    _seeded = true;
    _baseUrlController.text = state.config.baseUrl;
    _modelController.text = state.config.model;
    _contextController.text = '${state.config.contextWindowTokens}';
  }

  Future<void> _save(AppStrings strings) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await ref
        .read(agentProviderSettingsControllerProvider.notifier)
        .save(
          baseUrl: _baseUrlController.text,
          model: _modelController.text,
          apiKey: _apiKeyController.text,
          contextWindowTokens: int.tryParse(_contextController.text),
        );
    if (!mounted || !saved) return;
    _apiKeyController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.agentConfigurationSaved)));
  }

  Future<void> _test(AppStrings strings) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref
        .read(agentProviderSettingsControllerProvider.notifier)
        .testConnection(
          contextWindowTokens: int.tryParse(_contextController.text),
          baseUrl: _baseUrlController.text,
          model: _modelController.text,
          apiKey: _apiKeyController.text,
        );
    if (mounted) _apiKeyController.clear();
  }

  Future<void> _clear() async {
    await ref.read(agentProviderSettingsControllerProvider.notifier).clear();
    if (!mounted) return;
    _baseUrlController.clear();
    _modelController.clear();
    _apiKeyController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context, ref);
    final theme = ref.watch(resolvedFittinThemeProvider);
    final state = ref.watch(agentProviderSettingsControllerProvider);
    _seed(state);
    final working = state.isLoading || state.isSaving || state.isTesting;

    return DashboardPageScaffold(
      topPadding: 24,
      bottomPadding: 40,
      children: [
        DashboardScreenHeader(
          eyebrow: strings.agentSection,
          title: strings.agentSettings,
          subtitle: strings.agentSettingsSubtitle,
          showBackButton: true,
        ),
        const SizedBox(height: 26),
        DashboardSectionLabel(label: strings.agentProviderSection),
        const SizedBox(height: 10),
        FittinCard(
          theme: theme,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AgentSettingsField(
                  key: const ValueKey('agent-base-url-field'),
                  theme: theme,
                  controller: _baseUrlController,
                  label: strings.agentBaseUrl,
                  hint: strings.agentBaseUrlHint,
                  keyboardType: TextInputType.url,
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? strings.agentBaseUrlRequired
                      : null,
                ),
                const SizedBox(height: 16),
                _AgentSettingsField(
                  key: const ValueKey('agent-model-field'),
                  theme: theme,
                  controller: _modelController,
                  label: strings.agentModelId,
                  hint: strings.agentModelHint,
                  validator: (value) => value?.trim().isEmpty ?? true
                      ? strings.agentModelRequired
                      : null,
                ),
                const SizedBox(height: 16),
                _AgentSettingsField(
                  key: const ValueKey('agent-api-key-field'),
                  theme: theme,
                  controller: _apiKeyController,
                  label: strings.agentApiKey,
                  hint: state.config.hasApiKey
                      ? strings.agentApiKeyStored
                      : strings.agentApiKeyHint,
                  obscureText: _obscureKey,
                  validator: (value) {
                    if (state.config.hasApiKey) return null;
                    return value?.trim().isEmpty ?? true
                        ? strings.agentApiKeyRequired
                        : null;
                  },
                  suffix: IconButton(
                    tooltip: _obscureKey
                        ? strings.agentShowApiKey
                        : strings.agentHideApiKey,
                    constraints: const BoxConstraints.tightFor(
                      width: 44,
                      height: 44,
                    ),
                    icon: Icon(
                      _obscureKey
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: theme.fgMuted,
                      size: 19,
                    ),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
                const SizedBox(height: 12),
                _AgentSettingsField(
                  theme: theme,
                  controller: _contextController,
                  label: strings.isChinese
                      ? '上下文窗口（令牌数）'
                      : 'Context window (tokens)',
                  hint: '32768',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final n = int.tryParse(value ?? '');
                    return n == null || n < 8192 || n > 262144
                        ? (strings.isChinese
                              ? '请输入8192至262144'
                              : 'Enter 8192–262144')
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  kIsWeb
                      ? strings.agentWebKeyStorage
                      : strings.agentNativeKeyStorage,
                  style: theme
                      .uiStyle(11, theme.fgMuted)
                      .copyWith(height: 1.45),
                ),
                if (state.errorMessage case final error?) ...[
                  const SizedBox(height: 14),
                  _SettingsStatus(
                    key: const ValueKey('agent-settings-error'),
                    theme: theme,
                    icon: Icons.error_outline_rounded,
                    color: theme.danger,
                    message: error,
                  ),
                ],
                if (state.lastTest case final result?
                    when result.succeeded) ...[
                  const SizedBox(height: 14),
                  _SettingsStatus(
                    key: const ValueKey('agent-test-result'),
                    theme: theme,
                    icon: result.toolCallingSupported
                        ? Icons.verified_rounded
                        : Icons.info_outline_rounded,
                    color: result.toolCallingSupported
                        ? theme.success
                        : theme.warning,
                    message: result.toolCallingSupported
                        ? strings.agentConnectionVerified
                        : strings.agentConnectionChatOnly,
                  ),
                ],
                if (state.config.capabilities case final profile?) ...[
                  const SizedBox(height: 10),
                  Text(
                    strings.isChinese
                        ? '实测：${profile.streaming == true
                              ? '流式'
                              : profile.streaming == false
                              ? 'JSON 回退'
                              : '流式未知'} · 函数调用${profile.functionCalling ? '通过' : '未通过'}\n并行工具与最大上下文未探测时不作保证。'
                        : 'Observed: ${profile.streaming == true
                              ? 'streaming'
                              : profile.streaming == false
                              ? 'JSON fallback'
                              : 'streaming unknown'} · tools ${profile.functionCalling ? 'verified' : 'unverified'}\nParallel tools and maximum context remain unknown unless measured.',
                    style: theme
                        .uiStyle(11, theme.fgMuted)
                        .copyWith(height: 1.5),
                  ),
                ],
                const SizedBox(height: 20),
                FittinBtn(
                  theme,
                  state.isSaving
                      ? strings.agentSavingConfiguration
                      : strings.agentSaveConfiguration,
                  key: const ValueKey('agent-save-settings'),
                  block: true,
                  onPressed: working ? null : () => _save(strings),
                ),
                const SizedBox(height: 10),
                FittinBtn(
                  theme,
                  state.isTesting
                      ? strings.agentTestingConnection
                      : strings.agentTestConnection,
                  key: const ValueKey('agent-test-connection'),
                  variant: 'secondary',
                  icon: Icons.network_check_rounded,
                  block: true,
                  onPressed: working ? null : () => _test(strings),
                ),
                const SizedBox(height: 8),
                FittinBtn(
                  theme,
                  strings.agentClearConfiguration,
                  key: const ValueKey('agent-clear-settings'),
                  variant: 'ghost',
                  block: true,
                  onPressed: working ? null : _clear,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _DisclosureCard(
          theme: theme,
          icon: Icons.receipt_long_outlined,
          title: strings.agentTestConnection,
          detail: strings.agentProviderCostDisclosure,
        ),
        const SizedBox(height: 24),
        AgentLocalSettings(theme: theme, strings: strings),
        const SizedBox(height: 24),
        DashboardSectionLabel(label: strings.agentPrivacyTitle),
        const SizedBox(height: 10),
        _DisclosureCard(
          key: const ValueKey('agent-privacy-disclosure'),
          theme: theme,
          icon: Icons.shield_outlined,
          title: strings.agentPrivacyTitle,
          detail: strings.agentPrivacyDetail,
        ),
      ],
    );
  }
}

class _AgentSettingsField extends StatelessWidget {
  const _AgentSettingsField({
    super.key,
    required this.theme,
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  final FittinTheme theme;
  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(theme.radiusSm),
      borderSide: BorderSide(color: theme.borderHi, width: 0.75),
    );
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      validator: validator,
      style: theme.uiStyle(14, theme.fg),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: theme.uiStyle(13, theme.fgDim),
        hintStyle: theme.uiStyle(13, theme.fgMuted),
        filled: true,
        fillColor: theme.surfaceHi,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        suffixIcon: suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: theme.focusRing, width: 1.25),
        ),
        errorBorder: border.copyWith(
          borderSide: BorderSide(color: theme.danger, width: 1),
        ),
      ),
    );
  }
}

class _SettingsStatus extends StatelessWidget {
  const _SettingsStatus({
    super.key,
    required this.theme,
    required this.icon,
    required this.color,
    required this.message,
  });

  final FittinTheme theme;
  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.uiStyle(12, theme.fg).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclosureCard extends StatelessWidget {
  const _DisclosureCard({
    super.key,
    required this.theme,
    required this.icon,
    required this.title,
    required this.detail,
  });

  final FittinTheme theme;
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return FittinCard(
      theme: theme,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.info, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.uiStyle(14, theme.fg, FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
