import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/agent_provider_settings_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/fittin_theme_provider.dart';
import 'package:fittin_v2/src/domain/models/agent_models.dart';
import 'package:fittin_v2/src/presentation/agent_ui_adapter.dart';
import 'package:fittin_v2/src/presentation/screens/agent_screen.dart';
import 'package:fittin_v2/src/presentation/screens/agent_settings_screen.dart';
import 'package:fittin_v2/src/presentation/theme/fittin_theme.dart';
import 'package:fittin_v2/src/presentation/widgets/glass_bottom_nav.dart';

import '../support/in_memory_database_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final viewport in const [
    Size(390, 844),
    Size(390, 926),
    Size(390, 568),
    Size(320, 568),
  ]) {
    testWidgets('Agent long-content layout stays bounded at '
        '${viewport.width.toInt()}x${viewport.height.toInt()}', (tester) async {
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      for (final locale in AppLocale.values) {
        for (final paletteId in FittinPaletteRegistry.ids) {
          final repository = InMemoryDatabaseRepository();
          await repository.saveAppLocale(locale);
          final palette = FittinPaletteRegistry.themeOf(paletteId);
          await tester.pumpWidget(
            ProviderScope(
              key: ValueKey(
                'agent-${viewport.width}-${viewport.height}-${locale.code}-${paletteId.storageKey}',
              ),
              overrides: [
                databaseRepositoryProvider.overrideWithValue(repository),
                resolvedFittinThemeProvider.overrideWithValue(palette),
                agentProviderSettingsStoreProvider.overrideWithValue(
                  _ReadySettingsStore(),
                ),
                agentUiStateProvider.overrideWithValue(_longAgentState()),
              ],
              child: MaterialApp(
                home: AgentScreen(),
                theme: ThemeData(colorScheme: palette.colorScheme),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 120));

          expect(
            tester.takeException(),
            isNull,
            reason: '${locale.code}/${paletteId.storageKey}/$viewport',
          );
          _expectInsideViewport(
            tester,
            find.byKey(const ValueKey('agent-composer')),
            viewport,
          );
          _expectHorizontallyBounded(
            tester,
            find.byKey(const ValueKey('agent-message-long-assistant')),
            viewport,
          );

          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('agent-confirm-proposal')),
            360,
            scrollable: find
                .descendant(
                  of: find.byKey(const ValueKey('agent-conversation-list')),
                  matching: find.byType(Scrollable),
                )
                .first,
            maxScrolls: 20,
          );
          await tester.pump();
          _expectInsideViewport(
            tester,
            find.byKey(const ValueKey('agent-confirm-proposal')),
            viewport,
          );
          expect(
            find.text(locale == AppLocale.zh ? '确认修改' : 'Confirm change'),
            findsOneWidget,
          );
          final scrollException = tester.takeException();
          expect(
            scrollException,
            isNull,
            reason: 'scrolled ${locale.code}/${paletteId.storageKey}',
          );
        }
      }
    });
  }

  testWidgets(
    'keyboard keeps composer, stop action and six-tab nav reachable',
    (tester) async {
      const viewport = Size(390, 844);
      await tester.binding.setSurfaceSize(viewport);
      addTearDown(() {
        tester.binding.setSurfaceSize(null);
        tester.view.resetViewInsets();
      });
      final repository = InMemoryDatabaseRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseRepositoryProvider.overrideWithValue(repository),
            agentProviderSettingsStoreProvider.overrideWithValue(
              _ReadySettingsStore(),
            ),
            agentUiStateProvider.overrideWithValue(
              AgentUiState(
                runState: AgentRunState(
                  phase: AgentRunPhase.streaming,
                  conversation: AgentConversation(
                    id: 'keyboard-conversation',
                    title: 'Keyboard',
                    createdAt: DateTime(2026, 8, 13),
                    updatedAt: DateTime(2026, 8, 13),
                    messages: [
                      AgentMessage(
                        id: 'keyboard-response',
                        role: AgentMessageRole.assistant,
                        createdAt: DateTime(2026, 8, 13),
                        content: 'Current response remains visible.',
                        isPartial: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: _AgentShellHarness()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('agent-composer-field')));
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey('agent-stop')), findsOneWidget);
      expect(find.byKey(const ValueKey('nav-agent')), findsOneWidget);
      _expectInsideViewport(
        tester,
        find.byKey(const ValueKey('agent-composer')),
        viewport,
      );
      _expectInsideViewport(
        tester,
        find.byKey(const ValueKey('agent-stop')),
        viewport,
      );
      _expectInsideViewport(
        tester,
        find.byKey(const ValueKey('nav-agent')),
        viewport,
      );
      final composer = tester.getRect(
        find.byKey(const ValueKey('agent-composer')),
      );
      final nav = tester.getRect(find.byKey(const ValueKey('nav-agent')));
      expect(composer.bottom, lessThanOrEqualTo(nav.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('settings remain scrollable at narrow width with keyboard', (
    tester,
  ) async {
    const viewport = Size(320, 568);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.view.resetViewInsets();
    });
    final repository = InMemoryDatabaseRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseRepositoryProvider.overrideWithValue(repository),
          agentProviderSettingsStoreProvider.overrideWithValue(
            _ReadySettingsStore(),
          ),
        ],
        child: const MaterialApp(home: AgentSettingsScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final editable = find.descendant(
      of: find.byKey(const ValueKey('agent-api-key-field')),
      matching: find.byType(EditableText),
    );
    await tester.ensureVisible(editable);
    await tester.tap(editable);
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    await tester.pump();
    await Scrollable.ensureVisible(
      tester.element(editable),
      alignment: 0.5,
      duration: Duration.zero,
    );
    await tester.pump();

    _expectInsideViewport(
      tester,
      find.byKey(const ValueKey('agent-api-key-field')),
      viewport,
    );
    expect(find.byType(Scrollable), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agent settings resolve all five palettes in both languages', (
    tester,
  ) async {
    const viewport = Size(390, 844);
    await tester.binding.setSurfaceSize(viewport);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final locale in AppLocale.values) {
      for (final paletteId in FittinPaletteRegistry.ids) {
        final repository = InMemoryDatabaseRepository();
        await repository.saveAppLocale(locale);
        final palette = FittinPaletteRegistry.themeOf(paletteId);
        await tester.pumpWidget(
          ProviderScope(
            key: ValueKey('settings-${locale.code}-${paletteId.storageKey}'),
            overrides: [
              databaseRepositoryProvider.overrideWithValue(repository),
              resolvedFittinThemeProvider.overrideWithValue(palette),
              agentProviderSettingsStoreProvider.overrideWithValue(
                _ReadySettingsStore(),
              ),
            ],
            child: MaterialApp(
              theme: ThemeData(colorScheme: palette.colorScheme),
              home: const AgentSettingsScreen(),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(
          find.text(locale == AppLocale.zh ? 'Agent 设置' : 'Agent Settings'),
          findsOneWidget,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'settings ${locale.code}/${paletteId.storageKey}',
        );
        _expectHorizontallyBounded(
          tester,
          find.byKey(const ValueKey('agent-base-url-field')),
          viewport,
        );
      }
    }
  });
}

void _expectHorizontallyBounded(
  WidgetTester tester,
  Finder finder,
  Size viewport,
) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
}

class _AgentShellHarness extends ConsumerWidget {
  const _AgentShellHarness();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const AgentScreen(),
      bottomNavigationBar: FittinTabBar(
        theme: FittinPaletteRegistry.themeOf(FittinPaletteId.obsidianBrass),
        active: 'agent',
        onChange: (_) {},
      ),
    );
  }
}

AgentUiState _longAgentState() {
  final now = DateTime(2026, 8, 13, 12);
  final longText = List.filled(
    14,
    'Training volume rose steadily while recovery and estimated strength stayed flat.',
  ).join(' ');
  final conversation = AgentConversation(
    id: 'long-conversation',
    title: 'A deliberately long conversation title for narrow layouts',
    createdAt: now,
    updatedAt: now,
    messages: [
      AgentMessage(
        id: 'long-user',
        role: AgentMessageRole.user,
        createdAt: now,
        content: 'Analyze the last twelve weeks and propose a safe adjustment.',
      ),
      AgentMessage(
        id: 'long-assistant',
        role: AgentMessageRole.assistant,
        createdAt: now,
        content: longText,
      ),
    ],
  );
  return AgentUiState(
    runState: AgentRunState(
      phase: AgentRunPhase.awaitingApproval,
      conversation: conversation,
      pendingProposal: AgentMutationProposal(
        operationId: 'long-proposal',
        toolName: 'revise_plan',
        title: 'Reduce fatigue while preserving current progress',
        summary: longText,
        argumentsJson: '{}',
        targetType: 'plan',
        targetId: 'plan',
        expectedDigest: 'digest',
        changes: const [
          AgentMutationChange(
            path: 'Week 5 / Competition squat / Working prescription',
            before: '5 sets of 5 repetitions at 82.5 percent',
            after: '3 sets of 5 repetitions at 67.5 percent',
          ),
          AgentMutationChange(
            path: 'Week 5 / Competition bench press / Working prescription',
            before: '6 sets of 4 repetitions at 80 percent',
            after: '4 sets of 4 repetitions at 65 percent',
          ),
        ],
        progressionEffect: longText,
        createdAt: now,
      ),
    ),
    conversations: [conversation],
    insights: const [
      AgentInsightCardData(
        title: 'Eight-week lower-body volume change',
        value: '+18.4%',
        detail: 'Volume rose faster than strength and recovery markers.',
      ),
    ],
  );
}

class _ReadySettingsStore implements AgentProviderSettingsStore {
  @override
  Future<void> clear() async {}

  @override
  Future<AgentProviderConfig> load() async => const AgentProviderConfig(
    baseUrl: 'https://example.com/v1',
    model: 'model-with-a-long-readable-name',
    hasApiKey: true,
    toolCallingVerified: true,
  );

  @override
  Future<String?> loadApiKey() async => 'secret';

  @override
  Future<AgentProviderConfig> save({
    required String baseUrl,
    required String model,
    String? apiKey,
    bool toolCallingVerified = false,
  }) async => AgentProviderConfig(
    baseUrl: baseUrl,
    model: model,
    hasApiKey: true,
    toolCallingVerified: toolCallingVerified,
  );
}

void _expectInsideViewport(WidgetTester tester, Finder finder, Size viewport) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(viewport.width));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.bottom, lessThanOrEqualTo(viewport.height));
}
