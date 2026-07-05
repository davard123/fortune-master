// lib/features/tarot/tarot_screen.dart
// 塔罗占卜: 选择牌阵 + 可选问题 → 调用 chart-tarot → 展示牌面
// Mirror BaziScreen Riverpod StateNotifier pattern.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/interpret_section.dart';
import '../../data/repositories/fortune_repository.dart';

// ============================================================================
// 表单状态 (Riverpod StateNotifier)
// ============================================================================

class TarotFormState {
  /// 'one' | 'three' | 'celtic' (外部别名 — 与 chart-tarot Edge Function 对齐)
  final String spread;
  final String? question;
  final bool isSubmitting;
  final String? error;
  final Map<String, dynamic>? result;

  // LLM 解读 (镜像 BaziFormState 的解读状态设计)
  final bool isInterpreting;
  final String? interpretError;
  final InterpretResult? briefInterpretation;
  final InterpretResult? detailedInterpretation;

  const TarotFormState({
    this.spread = 'three',
    this.question,
    this.isSubmitting = false,
    this.error,
    this.result,
    this.isInterpreting = false,
    this.interpretError,
    this.briefInterpretation,
    this.detailedInterpretation,
  });

  TarotFormState copyWith({
    String? spread,
    String? question,
    bool? isSubmitting,
    String? error,
    Map<String, dynamic>? result,
    bool? isInterpreting,
    String? interpretError,
    InterpretResult? briefInterpretation,
    InterpretResult? detailedInterpretation,
    bool clearError = false,
    bool clearResult = false,
    bool clearQuestion = false,
    bool clearInterpretError = false,
    bool clearBriefInterpret = false,
    bool clearDetailedInterpret = false,
  }) {
    return TarotFormState(
      spread: spread ?? this.spread,
      question: clearQuestion ? null : (question ?? this.question),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
      isInterpreting: isInterpreting ?? this.isInterpreting,
      interpretError:
          clearInterpretError ? null : (interpretError ?? this.interpretError),
      briefInterpretation: clearBriefInterpret
          ? null
          : (briefInterpretation ?? this.briefInterpretation),
      detailedInterpretation: clearDetailedInterpret
          ? null
          : (detailedInterpretation ?? this.detailedInterpretation),
    );
  }

  bool get isReady => spread.isNotEmpty;
}

class TarotFormNotifier extends StateNotifier<TarotFormState> {
  final FortuneRepository repo;
  TarotFormNotifier(this.repo) : super(const TarotFormState());

  void setSpread(String s) =>
      state = state.copyWith(spread: s, clearResult: true);
  void setQuestion(String? q) =>
      state = state.copyWith(question: q, clearResult: true);

  Future<void> submit() async {
    if (!state.isReady || state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearResult: true,
      clearInterpretError: true,
      clearBriefInterpret: true,
      clearDetailedInterpret: true,
    );
    try {
      final r = await repo.drawTarot(
        spread: state.spread,
        question: state.question,
      );
      state = state.copyWith(result: r, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSubmitting: false);
    }
  }

  /// 调用 LLM 解读. 镜像 BaziFormNotifier.interpret 的升档逻辑
  /// (brief → detailed 时只保留 detailed).
  /// 注意: chart-tarot 返回顶层 {cards, spread, ...}, 不像 chart-bazi 包在
  /// chart_data 里, 所以直接传整个 result.
  Future<void> interpret({required String tier, required String locale}) async {
    if (state.result == null || state.isInterpreting) return;
    state = state.copyWith(isInterpreting: true, clearInterpretError: true);
    try {
      final r = await repo.interpret(
        system: 'tarot',
        tier: tier,
        locale: locale,
        chart: Map<String, dynamic>.from(state.result!),
      );
      if (tier == 'brief') {
        state = state.copyWith(
          briefInterpretation: r,
          isInterpreting: false,
        );
      } else {
        state = state.copyWith(
          detailedInterpretation: r,
          clearBriefInterpret: true,
          isInterpreting: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        interpretError: e.toString(),
        isInterpreting: false,
      );
    }
  }

  void reset() => state = const TarotFormState();
}

final tarotFormProvider =
    StateNotifierProvider<TarotFormNotifier, TarotFormState>((ref) {
  final repo = ref.watch(fortuneRepositoryProvider);
  return TarotFormNotifier(repo);
});

// ============================================================================
// Screen
// ============================================================================

class TarotScreen extends ConsumerWidget {
  const TarotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(tarotFormProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemTarot)),
      body: SafeArea(
        child: state.result == null
            ? _TarotForm(l10n: l10n, state: state)
            : _TarotResult(l10n: l10n, state: state),
      ),
    );
  }
}

// ============================================================================
// 表单视图
// ============================================================================

class _TarotForm extends ConsumerStatefulWidget {
  final AppL10n l10n;
  final TarotFormState state;
  const _TarotForm({required this.l10n, required this.state});

  @override
  ConsumerState<_TarotForm> createState() => _TarotFormState();
}

class _TarotFormState extends ConsumerState<_TarotForm> {
  late final TextEditingController _questionCtrl;

  @override
  void initState() {
    super.initState();
    _questionCtrl = TextEditingController(text: widget.state.question ?? '');
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = widget.state;
    final notifier = ref.read(tarotFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.tarotFormTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.homeScreenSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 牌阵选择
          Text(l10n.tarotSpreadLabel,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'one', label: Text(l10n.tarotSpreadSingle)),
              ButtonSegment(value: 'three', label: Text(l10n.tarotSpreadThree)),
              ButtonSegment(value: 'celtic', label: Text(l10n.tarotSpreadCeltic)),
            ],
            selected: {state.spread},
            onSelectionChanged: (s) => notifier.setSpread(s.first),
          ),
          const SizedBox(height: 24),

          // 问题输入 (可选)
          TextField(
            controller: _questionCtrl,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: l10n.tarotQuestionLabel,
              hintText: l10n.tarotQuestionHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: notifier.setQuestion,
          ),
          const SizedBox(height: 16),

          // 错误
          if (state.error != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${l10n.errorServer}\n${state.error}',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 提交按钮
          FilledButton.icon(
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(state.isSubmitting ? l10n.loading : l10n.actionStartReading),
            onPressed: state.isReady && !state.isSubmitting
                ? notifier.submit
                : null,
          ),
          const SizedBox(height: 24),

          Text(
            l10n.disclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 结果视图
// ============================================================================

class _TarotResult extends ConsumerWidget {
  final AppL10n l10n;
  final TarotFormState state;
  const _TarotResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = state.result!;
    final cards = (chart['cards'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .toList();
    final spread = chart['spread'] as String? ?? 'three';
    final notifier = ref.read(tarotFormProvider.notifier);
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    final spreadLabel = spread == 'one'
        ? l10n.tarotSpreadSingle
        : spread == 'celtic'
            ? l10n.tarotSpreadCeltic
            : l10n.tarotSpreadThree;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(l10n.tarotResultTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(spreadLabel,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 牌面
          if (spread == 'one')
            _SingleCardLayout(cards: cards, isZh: isZh, l10n: l10n)
          else if (spread == 'three')
            _ThreeCardLayout(cards: cards, isZh: isZh, l10n: l10n)
          else
            _CelticCrossLayout(cards: cards, isZh: isZh, l10n: l10n),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.tarotDrawAgain),
                  onPressed: notifier.reset,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: state.isInterpreting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(state.isInterpreting
                      ? l10n.interpretLoading
                      : l10n.actionInterpret),
                  onPressed: state.isInterpreting ||
                          (state.briefInterpretation != null &&
                              state.detailedInterpretation != null)
                      ? null
                      : () => notifier.interpret(
                            tier: state.briefInterpretation == null
                                ? 'brief'
                                : 'detailed',
                            locale: Localizations.localeOf(context)
                                .toLanguageTag(),
                          ),
                ),
              ),
            ],
          ),

          if (state.briefInterpretation != null ||
              state.detailedInterpretation != null ||
              state.interpretError != null) ...[
            const SizedBox(height: 16),
            InterpretSection(
              l10n: l10n,
              brief: state.briefInterpretation,
              detailed: state.detailedInterpretation,
              error: state.interpretError,
              onRetry: state.isInterpreting
                  ? null
                  : () => notifier.interpret(
                        tier: state.briefInterpretation == null
                            ? 'brief'
                            : 'detailed',
                        locale:
                            Localizations.localeOf(context).toLanguageTag(),
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// 牌面布局 (按 spread 类型)
// ============================================================================

class _SingleCardLayout extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final bool isZh;
  final AppL10n l10n;
  const _SingleCardLayout({
    required this.cards,
    required this.isZh,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: _TarotCard(
            card: cards.first, isZh: isZh, l10n: l10n, expanded: true),
      ),
    );
  }
}

class _ThreeCardLayout extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final bool isZh;
  final AppL10n l10n;
  const _ThreeCardLayout({
    required this.cards,
    required this.isZh,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < cards.length && i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _TarotCard(card: cards[i], isZh: isZh, l10n: l10n),
          ),
        ],
      ],
    );
  }
}

class _CelticCrossLayout extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final bool isZh;
  final AppL10n l10n;
  const _CelticCrossLayout({
    required this.cards,
    required this.isZh,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    // 简化布局: 2 行 6+4 grid (凯尔特十字共 10 张)
    final firstRow = cards.take(6).toList();
    final secondRow = cards.skip(6).take(4).toList();
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.55,
          children: [
            for (final c in firstRow)
              _TarotCard(card: c, isZh: isZh, l10n: l10n, compact: true),
          ],
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childAspectRatio: 0.55,
          children: [
            for (final c in secondRow)
              _TarotCard(card: c, isZh: isZh, l10n: l10n, compact: true),
          ],
        ),
      ],
    );
  }
}

class _TarotCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final bool isZh;
  final AppL10n l10n;
  final bool expanded;
  final bool compact;
  const _TarotCard({
    required this.card,
    required this.isZh,
    required this.l10n,
    this.expanded = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final upright = card['upright'] as bool? ?? true;
    final reversed = card['reversed'] as bool? ?? false;
    final name = isZh
        ? (card['name'] as String? ?? '?')
        : (card['nameEn'] as String? ?? card['name'] as String? ?? '?');
    final meaning = card['meaning'] as String? ?? '';
    final rawPos = card['position'] as int? ?? 0;
    final positionLabel = card['positionLabel'] as String? ?? '';
    final keywords = (card['keywords'] as List? ?? []).cast<String>();
    final reversedThisCard = !upright && reversed;

    final cardTheme = Theme.of(context);
    final orientation = reversedThisCard
        ? l10n.tarotCardReversed
        : l10n.tarotCardUpright;

    return Transform.rotate(
      angle: reversedThisCard ? math.pi : 0,
      child: Card(
        elevation: 2,
        color: cardTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: reversedThisCard
                ? cardTheme.colorScheme.error
                : cardTheme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${l10n.tarotCardPosition} ${rawPos + 1}',
                      style: cardTheme.textTheme.labelSmall,
                    ),
                  ),
                  Text(
                    positionLabel,
                    style: cardTheme.textTheme.labelSmall?.copyWith(
                      color: cardTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                name,
                style: cardTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                orientation,
                style: cardTheme.textTheme.labelSmall?.copyWith(
                  color: reversedThisCard
                      ? cardTheme.colorScheme.error
                      : cardTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              if (!compact && keywords.isNotEmpty)
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: keywords
                      .take(3)
                      .map((k) => Chip(
                            label: Text(k,
                                style: cardTheme.textTheme.labelSmall),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              if (meaning.isNotEmpty && !compact) ...[
                const SizedBox(height: 6),
                Text(
                  meaning,
                  style: cardTheme.textTheme.bodySmall,
                  maxLines: expanded ? null : 4,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                ),
              ],
              if (meaning.isNotEmpty && compact)
                Text(
                  meaning,
                  style: cardTheme.textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
