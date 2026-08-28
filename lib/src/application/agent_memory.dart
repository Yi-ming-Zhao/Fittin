import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/agent_local_repository.dart';
import '../domain/models/agent_models.dart';
import 'agent_owner_scope.dart';

class AgentMemoryItem {
  const AgentMemoryItem({
    required this.id,
    required this.category,
    required this.value,
    required this.sourceConversationId,
    required this.sourceQuote,
    required this.updatedAt,
  });
  final String id;
  final String category;
  final String value;
  final String sourceConversationId;
  final String sourceQuote;
  final DateTime updatedAt;
  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'value': value,
    'sourceConversationId': sourceConversationId,
    'sourceQuote': sourceQuote,
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };
  factory AgentMemoryItem.fromJson(Map<String, dynamic> j) => AgentMemoryItem(
    id: j['id'] as String,
    category: j['category'] as String,
    value: j['value'] as String,
    sourceConversationId: j['sourceConversationId'] as String,
    sourceQuote: j['sourceQuote'] as String,
    updatedAt: DateTime.parse(j['updatedAt'] as String),
  );
}

abstract final class AgentPreferenceExtractor {
  static final _rules = <String, RegExp>{
    'schedule': RegExp(
      r'(?:我)?每周(?:可以|只能|想)?(?:训练|练)([1-7一二三四五六七])(?:次|天)|I (?:can |want to )?train ([1-7]) days? (?:a|per) week',
      caseSensitive: false,
    ),
    'time': RegExp(
      r'(?:我)?每次(?:训练)?(?:只有|最多|可以|控制在)(\d{1,3})分钟|I (?:only )?have (\d{1,3}) minutes? (?:per workout|to train)',
      caseSensitive: false,
    ),
    'equipment': RegExp(
      r'我(?:家里)?(?:只有|只能用|使用)(哑铃|杠铃|弹力带|自重|器械)|I (?:only have|use) (dumbbells|a barbell|resistance bands|bodyweight|machines)',
      caseSensitive: false,
    ),
    'units': RegExp(
      r'(?:我)?(?:使用|习惯用|请用)(公斤|千克|磅)(?:作为单位)?|(?:I use|please use) (kg|kilograms|lb|pounds)',
      caseSensitive: false,
    ),
    'exercise': RegExp(
      r'我(?:希望|想要|想)?(避免|不要做|多做)(卧推|深蹲|硬拉|引体向上|双杠臂屈伸|跑步|肩推)|I (?:want to |prefer to )?(avoid|do more) (bench press|squats|deadlifts|pull-ups|dips|running|overhead press)',
      caseSensitive: false,
    ),
  };

  static List<AgentMemoryItem> extract(String text, String conversationId) {
    final result = <AgentMemoryItem>[];
    // Never interpret pasted role/system instructions or secrets as memory.
    if (RegExp(
      r'api[_ -]?key|sk-[a-z0-9]|password|密码|bearer\s|<system|ignore previous',
      caseSensitive: false,
    ).hasMatch(text)) {
      return result;
    }
    // Only complete first-person statements count. Quoted examples, questions,
    // conditional clauses and third-party descriptions must not become memory.
    final statements = text.split(RegExp(r'[。！？!?;；\n，,]'));
    for (final raw in statements) {
      final statement = raw
          .trim()
          .replaceFirst(
            RegExp(
              r'^(?:请记住[：:]?|记住[：:]?|remember[：:]?\s+)',
              caseSensitive: false,
            ),
            '',
          )
          .trim()
          .replaceFirst(RegExp(r'\.$'), '');
      for (final rule in _rules.entries) {
        final match = rule.value.firstMatch(statement);
        if (match == null ||
            match.start != 0 ||
            match.end != statement.length) {
          continue;
        }
        // Question punctuation was removed by splitting, so check its source.
        if (text.contains('$raw?') || text.contains('$raw？')) continue;
        final value = match.group(0)!;
        if (!isAllowed(rule.key, value)) continue;
        result.add(
          AgentMemoryItem(
            id: rule.key == 'exercise'
                ? agentPayloadDigest(value.toLowerCase()).substring(7, 31)
                : rule.key,
            category: rule.key,
            value: value,
            sourceConversationId: conversationId,
            sourceQuote: value,
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
    return result;
  }

  static bool isAllowed(String category, String value) {
    if (value.length > 160 || !_rules.containsKey(category)) return false;
    final match = _rules[category]!.firstMatch(value);
    if (match == null || match.start != 0 || match.end != value.length) {
      return false;
    }
    if (category == 'time') {
      final number =
          int.tryParse(RegExp(r'\d+').firstMatch(value)?.group(0) ?? '') ?? 0;
      return number >= 5 && number <= 240;
    }
    return true;
  }
}

class AgentMemoryState {
  const AgentMemoryState({
    this.items = const [],
    this.enabled = true,
    this.loading = true,
  });
  final List<AgentMemoryItem> items;
  final bool enabled;
  final bool loading;
}

class AgentMemoryController extends StateNotifier<AgentMemoryState> {
  AgentMemoryController(this.repository, this.owner)
    : super(const AgentMemoryState()) {
    initialized = reload();
  }
  final AgentLocalRepository repository;
  final String? owner;
  late final Future<void> initialized;
  Future<void> reload() async {
    final config = await repository.readDocument(
      'preference',
      'config',
      ownerUserId: owner,
    );
    final rows = await repository.listDocuments('memory', ownerUserId: owner);
    if (mounted) {
      state = AgentMemoryState(
        items: rows.map(AgentMemoryItem.fromJson).toList(),
        enabled: config?['enabled'] != false,
        loading: false,
      );
    }
  }

  Future<void> capture(String text, String conversationId) async {
    await initialized;
    if (!mounted || !state.enabled) return;
    for (final item in AgentPreferenceExtractor.extract(text, conversationId)) {
      if (!mounted || !state.enabled) return;
      await repository.saveDocument(
        'memory',
        item.id,
        item.toJson(),
        ownerUserId: owner,
      );
    }
    if (mounted) await reload();
  }

  Future<void> setEnabled(bool enabled) async {
    if (!mounted) return;
    state = AgentMemoryState(
      items: state.items,
      enabled: enabled,
      loading: state.loading,
    );
    await repository.saveDocument('preference', 'config', {
      'enabled': enabled,
    }, ownerUserId: owner);
    if (mounted) await reload();
  }

  Future<void> remove(String id) async {
    if (!mounted) return;
    await repository.deleteDocument('memory', id, ownerUserId: owner);
    if (mounted) await reload();
  }

  Future<void> clear() async {
    if (!mounted) return;
    for (final item in state.items) {
      await repository.deleteDocument('memory', item.id, ownerUserId: owner);
    }
    if (mounted) await reload();
  }

  Future<void> edit(AgentMemoryItem original, String value) async {
    if (!mounted ||
        !state.items.any(
          (item) =>
              item.id == original.id &&
              item.sourceConversationId == original.sourceConversationId,
        )) {
      return;
    }
    if (!AgentPreferenceExtractor.isAllowed(original.category, value.trim())) {
      throw const FormatException(
        'Use an explicit equipment, schedule, time, unit or exercise preference.',
      );
    }
    final item = AgentMemoryItem(
      id: original.id,
      category: original.category,
      value: value.trim(),
      sourceConversationId: original.sourceConversationId,
      sourceQuote: value.trim(),
      updatedAt: DateTime.now(),
    );
    await repository.saveDocument(
      'memory',
      item.id,
      item.toJson(),
      ownerUserId: owner,
    );
    if (mounted) await reload();
  }
}

final agentMemoryControllerProvider =
    StateNotifierProvider<AgentMemoryController, AgentMemoryState>(
      (ref) => AgentMemoryController(
        ref.watch(agentLocalRepositoryProvider),
        ref.watch(agentOwnerScopeProvider).ownerUserId,
      ),
    );
