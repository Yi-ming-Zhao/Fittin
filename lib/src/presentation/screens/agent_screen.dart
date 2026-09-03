import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/agent_provider_settings_provider.dart';
import '../../application/fittin_theme_provider.dart';
import '../../domain/models/agent_models.dart';
import '../agent_ui_adapter.dart';
import '../localization/app_strings.dart';
import '../theme/fittin_theme.dart';
import '../widgets/fittin_card.dart';
import '../widgets/agent_markdown.dart';
import '../widgets/agent_run_timeline.dart';
import '../widgets/fittin_primitives.dart';
import 'agent_settings_screen.dart';

class AgentScreen extends ConsumerStatefulWidget {
  const AgentScreen({super.key});

  @override
  ConsumerState<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends ConsumerState<AgentScreen> {
  final _composerController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit([String? suggestion]) async {
    final prompt = (suggestion ?? _composerController.text).trim();
    if (prompt.isEmpty) return;
    _composerController.clear();
    await ref.read(agentUiBridgeProvider).submit(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(resolvedFittinThemeProvider);
    final strings = AppStrings.of(context, ref);
    final state = ref.watch(agentUiStateProvider);
    final providerSettings = ref.watch(agentProviderSettingsControllerProvider);
    final configured = providerSettings.isReady;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.bgDeep, theme.bg, theme.bgDeep],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  _AgentHeader(
                    theme: theme,
                    strings: strings,
                    config: providerSettings.config,
                    ready: providerSettings.isReady,
                    onHistory: () => _showConversationHistory(
                      context,
                      state,
                      theme,
                      strings,
                    ),
                    onNew: () =>
                        ref.read(agentUiBridgeProvider).newConversation(),
                    onSettings: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AgentSettingsScreen(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: configured
                        ? _ConversationBody(
                            controller: _scrollController,
                            state: state,
                            theme: theme,
                            strings: strings,
                            onSuggestion: _submit,
                            bridge: ref.read(agentUiBridgeProvider),
                          )
                        : _AgentConfigurationEmptyState(
                            theme: theme,
                            strings: strings,
                            onConfigure: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AgentSettingsScreen(),
                              ),
                            ),
                          ),
                  ),
                  if (configured)
                    _AgentComposer(
                      controller: _composerController,
                      theme: theme,
                      strings: strings,
                      isBusy: state.runState.isBusy,
                      onSubmit: _submit,
                      onStop: () => ref.read(agentUiBridgeProvider).stop(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showConversationHistory(
    BuildContext context,
    AgentUiState state,
    FittinTheme theme,
    AppStrings strings,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: theme.surfaceSolid,
      barrierColor: theme.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(theme.radius)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(agentUiStateProvider);
          return ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.borderHi,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    strings.agentConversationHistory,
                    style: theme.displayStyle(24, theme.fg),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.conversations.isEmpty
                        ? Center(
                            child: Text(
                              strings.agentNoHistory,
                              style: theme.uiStyle(14, theme.fgDim),
                            ),
                          )
                        : ListView.separated(
                            itemCount:
                                state.conversations.length +
                                (state.hasMoreHistory ? 1 : 0),
                            separatorBuilder: (_, __) =>
                                Divider(height: 1, color: theme.divider),
                            itemBuilder: (context, index) {
                              if (index == state.conversations.length) {
                                return TextButton(
                                  onPressed: () => ref
                                      .read(agentUiBridgeProvider)
                                      .loadMoreHistory(),
                                  child: Text(
                                    strings.isChinese
                                        ? '加载更早记录'
                                        : 'Load older history',
                                  ),
                                );
                              }
                              final conversation = state.conversations[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                minTileHeight: 56,
                                title: Text(
                                  conversation.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.uiStyle(14, theme.fg),
                                ),
                                subtitle: Text(
                                  _formatDate(conversation.updatedAt),
                                  style: theme.uiStyle(11, theme.fgMuted),
                                ),
                                trailing: IconButton(
                                  tooltip: strings.delete,
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: theme.fgMuted,
                                  ),
                                  onPressed: () => ref
                                      .read(agentUiBridgeProvider)
                                      .deleteConversation(conversation.id),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  ref
                                      .read(agentUiBridgeProvider)
                                      .openConversation(conversation.id);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AgentHeader extends StatelessWidget {
  const _AgentHeader({
    required this.theme,
    required this.strings,
    required this.config,
    required this.ready,
    required this.onHistory,
    required this.onNew,
    required this.onSettings,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final AgentProviderConfig config;
  final bool ready;
  final VoidCallback onHistory;
  final VoidCallback onNew;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final identity = Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: ready ? theme.accentDim : theme.surfaceHi,
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  border: Border.all(color: theme.borderHi, width: 0.75),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: ready ? theme.accent : theme.fgMuted,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.agentPageTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.displayStyle(21, theme.fg),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ready ? theme.success : theme.fgFaint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            ready ? config.model : strings.agentNotConfigured,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.uiStyle(11, theme.fgMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderAction(
                key: const ValueKey('agent-history'),
                theme: theme,
                tooltip: strings.agentConversationHistory,
                icon: Icons.history_rounded,
                onTap: onHistory,
              ),
              _HeaderAction(
                key: const ValueKey('agent-new-conversation'),
                theme: theme,
                tooltip: strings.agentNewConversation,
                icon: Icons.add_comment_outlined,
                onTap: onNew,
              ),
              _HeaderAction(
                key: const ValueKey('agent-open-settings'),
                theme: theme,
                tooltip: strings.agentSettings,
                icon: Icons.tune_rounded,
                onTap: onSettings,
              ),
            ],
          );

          if (constraints.maxWidth < 330) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: 4),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: identity),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    super.key,
    required this.theme,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final FittinTheme theme;
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        maximumSize: const Size.square(44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, color: theme.fgDim, size: 20),
      onPressed: onTap,
    );
  }
}

class _AgentConfigurationEmptyState extends StatelessWidget {
  const _AgentConfigurationEmptyState({
    required this.theme,
    required this.strings,
    required this.onConfigure,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onConfigure;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: FittinCard(
        key: const ValueKey('agent-configuration-empty-state'),
        theme: theme,
        padding: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittinEyebrow(theme, strings.agentPageEyebrow),
            const SizedBox(height: 16),
            Text(
              strings.agentConfigureTitle,
              style: theme.displayStyle(30, theme.fg).copyWith(height: 1),
            ),
            const SizedBox(height: 12),
            Text(
              strings.agentConfigureDetail,
              style: theme.uiStyle(14, theme.fgDim).copyWith(height: 1.5),
            ),
            const SizedBox(height: 22),
            FittinBtn(
              theme,
              strings.agentConfigureAction,
              key: const ValueKey('agent-configure-action'),
              icon: Icons.arrow_forward_rounded,
              onPressed: onConfigure,
            ),
            const SizedBox(height: 24),
            Divider(color: theme.divider),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, color: theme.info, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.agentPrivacyDetail,
                    style: theme
                        .uiStyle(12, theme.fgMuted)
                        .copyWith(height: 1.45),
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

class _ConversationBody extends StatefulWidget {
  const _ConversationBody({
    required this.controller,
    required this.state,
    required this.theme,
    required this.strings,
    required this.onSuggestion,
    required this.bridge,
  });

  final ScrollController controller;
  final AgentUiState state;
  final FittinTheme theme;
  final AppStrings strings;
  final ValueChanged<String> onSuggestion;
  final AgentUiBridge bridge;

  @override
  State<_ConversationBody> createState() => _ConversationBodyState();
}

class _ConversationBodyState extends State<_ConversationBody> {
  static const _nearBottomDistance = 72.0;

  late int _contentRevision;
  bool _followingLatest = true;
  bool _showJumpToLatest = false;
  bool _movingToLatest = false;

  @override
  void initState() {
    super.initState();
    _contentRevision = _revisionOf(widget.state);
    widget.controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant _ConversationBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleScroll);
      widget.controller.addListener(_handleScroll);
    }
    final nextRevision = _revisionOf(widget.state);
    if (nextRevision == _contentRevision) return;
    _contentRevision = nextRevision;
    final conversationChanged =
        oldWidget.state.runState.conversation?.id !=
        widget.state.runState.conversation?.id;
    if (conversationChanged) {
      _followingLatest = true;
      _showJumpToLatest = false;
    }
    _followAfterLayout(force: conversationChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  int _revisionOf(AgentUiState state) {
    final messages = state.runState.conversation?.messages;
    final lastMessage = messages == null || messages.isEmpty
        ? null
        : messages.last;
    final lastEvent = state.events.isEmpty ? null : state.events.last;
    final lastAction = state.actions.isEmpty ? null : state.actions.last;
    return Object.hash(
      state.runState.conversation?.id,
      messages?.length,
      lastMessage?.id,
      lastMessage?.content.hashCode,
      lastMessage?.isPartial,
      state.events.length,
      lastEvent?.phase,
      lastEvent?.toolName,
      state.runState.phase,
      state.runState.activeToolName,
      state.runState.pendingProposal?.operationId,
      state.runState.errorMessage,
      state.actions.length,
      lastAction?.id,
      lastAction?.status,
    );
  }

  void _handleScroll() {
    if (_movingToLatest || !widget.controller.hasClients) return;
    final position = widget.controller.position;
    final nearBottom =
        position.maxScrollExtent - position.pixels <= _nearBottomDistance;
    if (nearBottom == _followingLatest && _showJumpToLatest == !nearBottom) {
      return;
    }
    setState(() {
      _followingLatest = nearBottom;
      _showJumpToLatest = !nearBottom;
    });
  }

  void _followAfterLayout({bool force = false}) {
    final shouldFollow = force || _followingLatest;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.controller.hasClients) return;
      if (shouldFollow) {
        _jumpToLatest();
      } else if (!_showJumpToLatest) {
        setState(() => _showJumpToLatest = true);
      }
    });
  }

  void _jumpToLatest() {
    if (!widget.controller.hasClients) return;
    _movingToLatest = true;
    widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
    _movingToLatest = false;
    if (!mounted) return;
    setState(() {
      _followingLatest = true;
      _showJumpToLatest = false;
    });
  }

  Future<void> _animateToLatest() async {
    if (!widget.controller.hasClients) return;
    _movingToLatest = true;
    try {
      await widget.controller.animateTo(
        widget.controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _movingToLatest = false;
      if (mounted) {
        if (widget.controller.hasClients) {
          widget.controller.jumpTo(widget.controller.position.maxScrollExtent);
        }
        setState(() {
          _followingLatest = true;
          _showJumpToLatest = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = widget.theme;
    final strings = widget.strings;
    final bridge = widget.bridge;
    final conversation = state.runState.conversation;
    final messages = conversation?.messages ?? const <AgentMessage>[];
    final isInitial = messages.isEmpty;

    return Stack(
      children: [
        ListView(
          key: const ValueKey('agent-conversation-list'),
          controller: widget.controller,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          children: [
            if (isInitial)
              _SuggestedPromptPanel(
                theme: theme,
                strings: strings,
                onSuggestion: widget.onSuggestion,
              ),
            for (final message in messages)
              if (message.role == AgentMessageRole.user ||
                  (message.role == AgentMessageRole.assistant &&
                      message.content.trim().isNotEmpty))
                _AgentMessageCard(message: message, theme: theme)
              else if (message.role == AgentMessageRole.tool)
                AgentDecisionNotice(
                  message: message,
                  theme: theme,
                  strings: strings,
                ),
            if (state.events.isNotEmpty)
              AgentRunTimeline(
                events: state.events,
                theme: theme,
                strings: strings,
              ),
            if (state.runState.phase == AgentRunPhase.usingTools ||
                state.runState.activeToolName != null)
              _AgentToolActivityCard(
                theme: theme,
                label: state.runState.activeToolName == null
                    ? strings.agentToolWorking
                    : strings.agentToolWorkingNamed(
                        state.runState.activeToolName!,
                      ),
              ),
            if (state.runState.phase == AgentRunPhase.streaming)
              _AgentToolActivityCard(
                theme: theme,
                label: strings.agentStreaming,
                streaming: true,
              ),
            if (state.runState.pendingProposal case final proposal?)
              _AgentMutationCard(
                proposal: proposal,
                theme: theme,
                strings: strings,
                onConfirm: () => bridge.confirmProposal(proposal.operationId),
                onReject: () => bridge.rejectProposal(proposal.operationId),
              ),
            if (state.runState.phase == AgentRunPhase.failed)
              _AgentErrorCard(
                theme: theme,
                strings: strings,
                message: state.runState.errorMessage,
                onRetry: bridge.retry,
                code: state.runState.errorCode,
              ),
            if ({
                  AgentRunPhase.interrupted,
                  AgentRunPhase.cancelled,
                }.contains(state.runState.phase) &&
                state.runState.pendingProposal == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      strings.isChinese
                          ? '任务已保存在本机。点击继续才会再次调用模型；已提交的修改不会重复执行。'
                          : 'This task is saved locally. Resume to contact the model; committed changes will not be replayed.',
                      style: theme
                          .uiStyle(12, theme.fgDim)
                          .copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 10),
                    FittinBtn(
                      theme,
                      strings.isChinese ? '继续任务' : 'Resume task',
                      key: const ValueKey('agent-resume'),
                      block: true,
                      onPressed: bridge.retry,
                    ),
                  ],
                ),
              ),
            if (state.actions.isNotEmpty)
              _AgentActionHistory(
                actions: state.actions,
                theme: theme,
                strings: strings,
                onUndo: bridge.undoAction,
              ),
          ],
        ),
        if (_showJumpToLatest)
          Positioned(
            right: 20,
            bottom: 8,
            child: Semantics(
              button: true,
              label: strings.isChinese ? '回到最新消息' : 'Jump to latest message',
              child: Material(
                color: theme.surfaceSolid,
                shape: StadiumBorder(side: BorderSide(color: theme.borderHi)),
                elevation: 2,
                shadowColor: theme.shadowSoft,
                child: InkWell(
                  key: const ValueKey('agent-jump-to-latest'),
                  customBorder: const StadiumBorder(),
                  onTap: _animateToLatest,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 17,
                            color: theme.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.isChinese ? '最新' : 'Latest',
                            style: theme.uiStyle(12, theme.fg, FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SuggestedPromptPanel extends StatelessWidget {
  const _SuggestedPromptPanel({
    required this.theme,
    required this.strings,
    required this.onSuggestion,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final ValueChanged<String> onSuggestion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittinEyebrow(theme, strings.agentSuggestedPrompts),
          const SizedBox(height: 14),
          for (final suggestion in strings.agentPromptSuggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Semantics(
                button: true,
                child: FittinCard(
                  theme: theme,
                  padding: 16,
                  onTap: () => onSuggestion(suggestion),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_outward_rounded,
                        color: theme.accent,
                        size: 17,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          suggestion,
                          style: theme
                              .uiStyle(14, theme.fg)
                              .copyWith(height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgentMessageCard extends StatelessWidget {
  const _AgentMessageCard({required this.message, required this.theme});

  final AgentMessage message;
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AgentMessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        key: ValueKey('agent-message-${message.id}'),
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: isUser ? theme.accentDim : theme.surfaceHi,
          borderRadius: BorderRadius.circular(theme.radiusSm),
          border: Border.all(
            color: isUser ? theme.accentPressed : theme.border,
            width: 0.75,
          ),
        ),
        child: isUser
            ? Text(
                message.content,
                style: theme.uiStyle(14, theme.fg).copyWith(height: 1.5),
              )
            : AgentMarkdown(data: message.content, theme: theme),
      ),
    );
  }
}

class _AgentToolActivityCard extends StatelessWidget {
  const _AgentToolActivityCard({
    required this.theme,
    required this.label,
    this.streaming = false,
  });

  final FittinTheme theme;
  final String label;
  final bool streaming;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(streaming ? 'agent-streaming-status' : 'agent-tool-status'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: theme.info, width: 2)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: theme.info,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(label, style: theme.uiStyle(12, theme.fgDim))),
        ],
      ),
    );
  }
}

class _AgentMutationCard extends StatelessWidget {
  const _AgentMutationCard({
    required this.proposal,
    required this.theme,
    required this.strings,
    required this.onConfirm,
    required this.onReject,
  });

  final AgentMutationProposal proposal;
  final FittinTheme theme;
  final AppStrings strings;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FittinCard(
        key: const ValueKey('agent-mutation-proposal'),
        theme: theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittinEyebrow(theme, strings.agentChangePreview),
            const SizedBox(height: 5),
            Text(
              strings.agentAwaitingConfirmation,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.uiStyle(10, theme.warning, FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(proposal.title, style: theme.displayStyle(22, theme.fg)),
            if (proposal.summary.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                proposal.summary,
                style: theme.uiStyle(13, theme.fgDim).copyWith(height: 1.4),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              proposal.expectedVersion == null
                  ? (strings.isChinese
                        ? '确认时会重新校验数据摘要'
                        : 'Content will be checked again at commit')
                  : (strings.isChinese
                        ? '基于数据版本 v${proposal.expectedVersion}'
                        : 'Based on data version v${proposal.expectedVersion}'),
              style: theme.uiStyle(10, theme.fgMuted),
            ),
            if (proposal.changes.length <= 4)
              for (final change in proposal.changes)
                _MutationDiffRow(change: change, theme: theme, strings: strings)
            else
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  strings.isChinese
                      ? '查看全部 ${proposal.changes.length} 项变化'
                      : 'Review all ${proposal.changes.length} changes',
                  style: theme.uiStyle(13, theme.fg, FontWeight.w700),
                ),
                children: [
                  for (final change in proposal.changes)
                    AgentDiffField(
                      change: change,
                      theme: theme,
                      strings: strings,
                    ),
                ],
              ),
            if (proposal.progressionEffect case final effect?) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.warningSubtle,
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                ),
                child: Text(
                  effect,
                  style: theme.uiStyle(12, theme.fg).copyWith(height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FittinBtn(
                    theme,
                    strings.agentReject,
                    key: const ValueKey('agent-reject-proposal'),
                    variant: 'secondary',
                    block: true,
                    onPressed: onReject,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FittinBtn(
                    theme,
                    strings.agentConfirm,
                    key: const ValueKey('agent-confirm-proposal'),
                    block: true,
                    onPressed: onConfirm,
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

class _MutationDiffRow extends StatelessWidget {
  const _MutationDiffRow({
    required this.change,
    required this.theme,
    required this.strings,
  });

  final AgentMutationChange change;
  final FittinTheme theme;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            change.path,
            style: theme.uiStyle(11, theme.fgMuted, FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _DiffValue(
                  label: strings.agentBefore,
                  value: change.before,
                  color: theme.danger,
                  theme: theme,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 17,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.fgMuted,
                  size: 16,
                ),
              ),
              Expanded(
                child: _DiffValue(
                  label: strings.agentAfter,
                  value: change.after,
                  color: theme.success,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiffValue extends StatelessWidget {
  const _DiffValue({
    required this.label,
    required this.value,
    required this.color,
    required this.theme,
  });

  final String label;
  final String value;
  final Color color;
  final FittinTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.uiStyle(9, color, FontWeight.w700)),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: theme.uiStyle(12, theme.fg).copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _AgentActionHistory extends StatelessWidget {
  const _AgentActionHistory({
    required this.actions,
    required this.theme,
    required this.strings,
    required this.onUndo,
    this.showAll = false,
  });

  final List<AgentActionRecord> actions;
  final FittinTheme theme;
  final AppStrings strings;
  final ValueChanged<String> onUndo;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittinEyebrow(theme, strings.agentActionHistory),
          const SizedBox(height: 10),
          for (final action in actions.take(showAll ? actions.length : 5))
            Container(
              key: ValueKey('agent-action-${action.id}'),
              constraints: const BoxConstraints(minHeight: 56),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.divider)),
              ),
              child: Row(
                children: [
                  Icon(
                    action.status == AgentActionStatus.conflicted
                        ? Icons.sync_problem_rounded
                        : Icons.check_circle_outline_rounded,
                    color: action.status == AgentActionStatus.conflicted
                        ? theme.warning
                        : theme.success,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.uiStyle(13, theme.fg),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          action.status == AgentActionStatus.undone
                              ? strings.agentUndone
                              : action.status == AgentActionStatus.conflicted
                              ? strings.agentConflict
                              : _formatDate(action.createdAt),
                          style: theme.uiStyle(10, theme.fgMuted),
                        ),
                      ],
                    ),
                  ),
                  if (action.status == AgentActionStatus.applied)
                    TextButton(
                      onPressed: () => onUndo(action.id),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.accent,
                        minimumSize: const Size(44, 44),
                      ),
                      child: Text(strings.agentUndo),
                    ),
                ],
              ),
            ),
          if (!showAll && actions.length > 5)
            TextButton(
              child: Text(strings.isChinese ? '查看全部操作' : 'View all actions'),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: theme.surfaceSolid,
                builder: (context) => FractionallySizedBox(
                  heightFactor: .75,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(agentUiStateProvider);
                      final bridge = ref.watch(agentUiBridgeProvider);
                      return ListView(
                        padding: const EdgeInsets.all(20),
                        children: [
                          _AgentActionHistory(
                            actions: state.actions,
                            theme: theme,
                            strings: strings,
                            onUndo: bridge.undoAction,
                            showAll: true,
                          ),
                          if (state.hasMoreHistory)
                            TextButton(
                              onPressed: bridge.loadMoreHistory,
                              child: Text(
                                strings.isChinese
                                    ? '加载更早记录'
                                    : 'Load older history',
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AgentErrorCard extends StatelessWidget {
  const _AgentErrorCard({
    required this.theme,
    required this.strings,
    required this.message,
    required this.onRetry,
    this.code,
  });

  final FittinTheme theme;
  final AppStrings strings;
  final String? message;
  final VoidCallback onRetry;
  final String? code;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('agent-error-card'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.dangerSubtle,
        borderRadius: BorderRadius.circular(theme.radiusSm),
        border: Border.all(color: theme.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.danger),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.agentErrorTitle,
                  style: theme.uiStyle(13, theme.fg, FontWeight.w700),
                ),
                if (message?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(message!, style: theme.uiStyle(11, theme.fgDim)),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              code == 'checkpoint_failed'
                  ? (strings.isChinese ? '核对并继续' : 'Reconcile')
                  : code == 'provider_auth_failed'
                  ? (strings.isChinese ? '更新配置后重试' : 'Retry after setup')
                  : (strings.isChinese ? '继续任务' : 'Resume'),
              style: theme.uiStyle(11, theme.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentComposer extends StatefulWidget {
  const _AgentComposer({
    required this.controller,
    required this.theme,
    required this.strings,
    required this.isBusy,
    required this.onSubmit,
    required this.onStop,
  });

  final TextEditingController controller;
  final FittinTheme theme;
  final AppStrings strings;
  final bool isBusy;
  final VoidCallback onSubmit;
  final VoidCallback onStop;

  @override
  State<_AgentComposer> createState() => _AgentComposerState();
}

class _AgentComposerState extends State<_AgentComposer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant _AgentComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final canSend = widget.controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Container(
        key: const ValueKey('agent-composer'),
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.fromLTRB(14, 5, 5, 5),
        decoration: BoxDecoration(
          color: widget.theme.surfaceSolid,
          borderRadius: BorderRadius.circular(widget.theme.radius),
          border: Border.all(color: widget.theme.borderHi, width: 0.75),
          boxShadow: [
            BoxShadow(
              color: widget.theme.shadowSoft,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                key: const ValueKey('agent-composer-field'),
                controller: widget.controller,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                style: widget.theme.uiStyle(14, widget.theme.fg),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.strings.agentComposerHint,
                  hintStyle: widget.theme.uiStyle(14, widget.theme.fgMuted),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (widget.isBusy && canSend)
              IconButton(
                key: const ValueKey('agent-steer'),
                tooltip: widget.strings.isChinese
                    ? '追加纠正，在下一安全步骤生效'
                    : 'Steer at the next safe step',
                onPressed: widget.onSubmit,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(
                  Icons.subdirectory_arrow_right,
                  color: widget.theme.accent,
                ),
              ),
            Semantics(
              button: true,
              label: widget.isBusy
                  ? widget.strings.agentStop
                  : widget.strings.agentSend,
              child: Material(
                color: widget.isBusy
                    ? widget.theme.danger
                    : canSend
                    ? widget.theme.accent
                    : widget.theme.surfaceHi,
                borderRadius: BorderRadius.circular(widget.theme.radiusSm),
                child: InkWell(
                  key: ValueKey(widget.isBusy ? 'agent-stop' : 'agent-send'),
                  onTap: widget.isBusy
                      ? widget.onStop
                      : canSend
                      ? widget.onSubmit
                      : null,
                  borderRadius: BorderRadius.circular(widget.theme.radiusSm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      widget.isBusy
                          ? Icons.stop_rounded
                          : Icons.arrow_upward_rounded,
                      color: widget.isBusy
                          ? widget.theme.fgInverse
                          : canSend
                          ? widget.theme.accentInk
                          : widget.theme.fgFaint,
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

String _formatDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
