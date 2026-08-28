import 'dart:convert';
import 'package:flutter/material.dart';
import '../../domain/models/agent_models.dart';
import '../../domain/models/agent_runtime.dart';
import '../localization/app_strings.dart';
import '../theme/fittin_theme.dart';

String agentPhaseLabel(AgentRunPhase phase, bool zh) => switch (phase) {
  AgentRunPhase.idle => zh ? '准备就绪' : 'Ready',
  AgentRunPhase.queued ||
  AgentRunPhase.connecting => zh ? '连接模型' : 'Connecting',
  AgentRunPhase.streaming => zh ? '模型生成' : 'Generating',
  AgentRunPhase.usingTools => zh ? '读取与校验' : 'Reading and validating',
  AgentRunPhase.awaitingApproval => zh ? '等待你确认' : 'Awaiting approval',
  AgentRunPhase.resuming => zh ? '继续任务' : 'Resuming',
  AgentRunPhase.compacting => zh ? '整理上下文' : 'Compacting context',
  AgentRunPhase.completed => zh ? '任务完成' : 'Completed',
  AgentRunPhase.failed => zh ? '运行出错' : 'Failed',
  AgentRunPhase.interrupted => zh ? '已保存，可继续' : 'Saved; ready to resume',
  AgentRunPhase.cancelled => zh ? '已停止' : 'Stopped',
};

class AgentRunTimeline extends StatelessWidget {
  const AgentRunTimeline({
    super.key,
    required this.events,
    required this.theme,
    required this.strings,
  });
  final List<AgentRunEvent> events;
  final FittinTheme theme;
  final AppStrings strings;
  @override
  Widget build(BuildContext context) {
    final steps = <AgentRunEvent>[];
    for (final event in events) {
      if (steps.isNotEmpty &&
          steps.last.phase == event.phase &&
          steps.last.toolName == event.toolName) {
        steps[steps.length - 1] = event;
      } else {
        steps.add(event);
      }
    }
    if (steps.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        key: const ValueKey('agent-run-timeline'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(left: 6, bottom: 8),
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: theme.fgMuted,
        collapsedIconColor: theme.fgMuted,
        title: Text(
          strings.isChinese ? '任务时间线' : 'Run timeline',
          style: theme.uiStyle(12, theme.fgDim, FontWeight.w700),
        ),
        subtitle: Text(
          agentPhaseLabel(steps.last.phase, strings.isChinese),
          style: theme.uiStyle(11, theme.fgMuted),
        ),
        children: [
          for (final step in steps.skip(
            steps.length > 20 ? steps.length - 20 : 0,
          ))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3, right: 12),
                    child: Icon(
                      step.phase == AgentRunPhase.failed
                          ? Icons.error_outline
                          : Icons.circle,
                      size: 10,
                      color: step.phase == AgentRunPhase.failed
                          ? theme.danger
                          : theme.accent,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${agentPhaseLabel(step.phase, strings.isChinese)}${step.toolName == null ? '' : ' · ${step.toolName}'}',
                      style: theme.uiStyle(12, theme.fgDim),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${((step.elapsedMs ?? 0) / 1000).toStringAsFixed(1)}s',
                    style: theme.uiStyle(10, theme.fgMuted),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AgentDecisionNotice extends StatelessWidget {
  const AgentDecisionNotice({
    super.key,
    required this.message,
    required this.theme,
    required this.strings,
  });
  final AgentMessage message;
  final FittinTheme theme;
  final AppStrings strings;
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data;
    try {
      data = (jsonDecode(message.content) as Map).cast();
    } catch (_) {
      return const SizedBox.shrink();
    }
    final status = data['status'];
    if (!['committed', 'rejected', 'conflicted'].contains(status)) {
      return const SizedBox.shrink();
    }
    final changes = (data['actualChanges'] as List? ?? [])
        .map((c) => AgentMutationChange.fromJson((c as Map).cast()))
        .toList();
    final label = switch (status) {
      'committed' => strings.isChinese ? '已确认并提交' : 'Approved and committed',
      'rejected' => strings.isChinese ? '已拒绝 · 未修改数据' : 'Rejected · no changes',
      _ => strings.isChinese ? '数据冲突 · 未执行' : 'Conflict · not applied',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: status == 'conflicted' ? theme.warning : theme.accent,
            width: 2,
          ),
        ),
      ),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(label, style: theme.uiStyle(12, theme.fg, FontWeight.w700)),
        subtitle: data['version'] == null
            ? null
            : Text(
                'v${data['version']}',
                style: theme.uiStyle(10, theme.fgMuted),
              ),
        children: [
          for (final change in changes)
            AgentDiffField(change: change, theme: theme, strings: strings),
          if (data['progressionEffect'] is String)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                data['progressionEffect'] as String,
                style: theme.uiStyle(12, theme.fgDim),
              ),
            ),
        ],
      ),
    );
  }
}

class AgentDiffField extends StatelessWidget {
  const AgentDiffField({
    super.key,
    required this.change,
    required this.theme,
    required this.strings,
  });
  final AgentMutationChange change;
  final FittinTheme theme;
  final AppStrings strings;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          change.path,
          style: theme.uiStyle(11, theme.fgMuted, FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          '${strings.agentBefore}  ${change.before}',
          style: theme.uiStyle(12, theme.fgDim).copyWith(height: 1.5),
        ),
        Text(
          '${strings.agentAfter}  ${change.after}',
          style: theme.uiStyle(12, theme.fg).copyWith(height: 1.5),
        ),
      ],
    ),
  );
}
