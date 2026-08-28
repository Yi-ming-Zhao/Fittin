import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/agent_memory.dart';
import '../../application/agent_owner_scope.dart';
import '../../data/agent_local_repository.dart';
import '../../domain/models/agent_runtime.dart';
import '../localization/app_strings.dart';
import '../theme/fittin_theme.dart';
import 'fittin_card.dart';

class AgentLocalSettings extends ConsumerWidget {
  const AgentLocalSettings({
    super.key,
    required this.theme,
    required this.strings,
  });
  final FittinTheme theme;
  final AppStrings strings;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    AgentMemoryItem item,
  ) async {
    final owner = ref.read(agentOwnerScopeProvider).epoch;
    final input = TextEditingController(text: item.value);
    String? error;
    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          backgroundColor: theme.surfaceSolid,
          title: Text(
            strings.isChinese ? '编辑训练偏好' : 'Edit training preference',
            style: theme.uiStyle(18, theme.fg),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: input,
              minLines: 1,
              maxLines: 4,
              maxLength: 160,
              style: theme.uiStyle(14, theme.fg),
              decoration: InputDecoration(errorText: error),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.isChinese ? '取消' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (owner != ref.read(agentOwnerScopeProvider).epoch) {
                  Navigator.pop(context);
                  return;
                }
                try {
                  await ref
                      .read(agentMemoryControllerProvider.notifier)
                      .edit(item, input.text);
                  if (context.mounted) Navigator.pop(context);
                } catch (_) {
                  update(
                    () => error = strings.isChinese
                        ? '请保留明确的频率、时间、器材、单位或动作偏好格式。'
                        : 'Use an explicit schedule, time, equipment, unit or exercise preference.',
                  );
                }
              },
              child: Text(strings.isChinese ? '保存' : 'Save'),
            ),
          ],
        ),
      ),
    );
    input.dispose();
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final scope = ref.read(agentOwnerScopeProvider);
    final rows = await ref
        .read(agentLocalRepositoryProvider)
        .listDocuments(
          'diagnostic',
          ownerUserId: scope.ownerUserId,
          limit: 200,
        );
    if (!context.mounted ||
        scope.epoch != ref.read(agentOwnerScopeProvider).epoch) {
      return;
    }
    // Reconstruct the typed metadata; never export arbitrary stored fields.
    final bundle = jsonEncode({
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'events': rows
          .map((row) => AgentRunEvent.fromJson(row).toJson())
          .toList(),
    });
    await Clipboard.setData(ClipboardData(text: bundle));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isChinese
                ? '脱敏诊断 JSON 已复制，可粘贴导出。'
                : 'Sanitized diagnostic JSON copied for export.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(agentMemoryControllerProvider);
    final controller = ref.read(agentMemoryControllerProvider.notifier);
    return FittinCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.isChinese ? '本机训练偏好' : 'Local training preferences',
            style: theme.displayStyle(22, theme.fg),
          ),
          const SizedBox(height: 8),
          Text(
            strings.isChinese
                ? '只记住你明确表达的器材、频率、时间、单位和动作偏好，不保存身体数据或健康推断。按账号隔离，不云同步。'
                : 'Only explicit equipment, schedule, time, units and exercise preferences. No measurements or health inferences. Account-scoped; never cloud-synced.',
            style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.5),
          ),
          SwitchListTile.adaptive(
            key: const ValueKey('agent-memory-enabled'),
            contentPadding: EdgeInsets.zero,
            activeTrackColor: theme.accent,
            title: Text(
              strings.isChinese ? '自动记住训练偏好' : 'Remember explicit preferences',
              style: theme.uiStyle(13, theme.fg),
            ),
            subtitle: Text(
              '${state.items.length}/50',
              style: theme.uiStyle(11, theme.fgMuted),
            ),
            value: state.enabled,
            onChanged: state.loading ? null : controller.setEnabled,
          ),
          if (state.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                strings.isChinese
                    ? '尚无偏好。例如：“我每周训练3天”。'
                    : 'No preferences yet. Try: “I train 3 days a week”.',
                style: theme.uiStyle(12, theme.fgMuted),
              ),
            ),
          for (final item in state.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _edit(context, ref, item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          item.value,
                          style: theme.uiStyle(13, theme.fg),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.edit,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: () => _edit(context, ref, item),
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: theme.fgMuted,
                    ),
                  ),
                  IconButton(
                    tooltip: strings.delete,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: () => controller.remove(item.id),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.fgMuted,
                    ),
                  ),
                ],
              ),
            ),
          if (state.items.isNotEmpty)
            TextButton(
              onPressed: controller.clear,
              child: Text(
                strings.isChinese ? '清除全部偏好' : 'Clear all preferences',
                style: theme.uiStyle(12, theme.danger),
              ),
            ),
          Divider(color: theme.border),
          Text(
            strings.isChinese
                ? '诊断只保留最近200条状态、耗时、工具名和用量，不含对话、训练数据或密钥。'
                : 'Diagnostics retain the latest 200 status, timing, tool and usage events. No conversations, training data or keys.',
            style: theme.uiStyle(11, theme.fgMuted).copyWith(height: 1.5),
          ),
          TextButton.icon(
            onPressed: () => _export(context, ref),
            icon: Icon(Icons.copy_outlined, size: 18, color: theme.accent),
            label: Text(
              strings.isChinese
                  ? '导出脱敏诊断（复制 JSON）'
                  : 'Export sanitized diagnostics (copy JSON)',
              style: theme.uiStyle(12, theme.accent),
            ),
          ),
        ],
      ),
    );
  }
}
