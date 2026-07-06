// lib/features/qimen/qimen_screen.dart
// 奇门遁甲: 起局时间 (默认当下) → chart-qimen (自实现拆补法) → 九宫飞盘展示
// 镜像 Bazi/Tarot 的 Riverpod StateNotifier 模式.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mystic_theme.dart';
import '../../core/widgets/interpret_section.dart';
import '../../data/repositories/fortune_repository.dart';

// ============================================================================
// 状态
// ============================================================================

class QimenFormState {
  final DateTime when;
  final String? question;
  final bool isSubmitting;
  final String? error;
  final Map<String, dynamic>? result;

  final bool isInterpreting;
  final String? interpretError;
  final InterpretResult? briefInterpretation;
  final InterpretResult? detailedInterpretation;

  QimenFormState({
    DateTime? when,
    this.question,
    this.isSubmitting = false,
    this.error,
    this.result,
    this.isInterpreting = false,
    this.interpretError,
    this.briefInterpretation,
    this.detailedInterpretation,
  }) : when = when ?? DateTime.now();

  QimenFormState copyWith({
    DateTime? when,
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
    bool clearInterpretError = false,
    bool clearBriefInterpret = false,
    bool clearDetailedInterpret = false,
  }) {
    return QimenFormState(
      when: when ?? this.when,
      question: question ?? this.question,
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
}

class QimenFormNotifier extends StateNotifier<QimenFormState> {
  final FortuneRepository repo;
  QimenFormNotifier(this.repo) : super(QimenFormState());

  void setWhen(DateTime d) => state = state.copyWith(when: d, clearResult: true);
  void setQuestion(String? q) => state = state.copyWith(question: q);

  Future<void> submit({bool now = false}) async {
    if (state.isSubmitting) return;
    final when = now ? DateTime.now() : state.when;
    state = state.copyWith(
      when: when,
      isSubmitting: true,
      clearError: true,
      clearResult: true,
      clearInterpretError: true,
      clearBriefInterpret: true,
      clearDetailedInterpret: true,
    );
    try {
      final r = await repo.computeQimen(when: when, question: state.question);
      state = state.copyWith(result: r, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSubmitting: false);
    }
  }

  Future<void> interpret({required String tier, required String locale}) async {
    if (state.result == null || state.isInterpreting) return;
    state = state.copyWith(isInterpreting: true, clearInterpretError: true);
    try {
      final chartData = (state.result!['chart_data'] as Map?) ?? {};
      final r = await repo.interpret(
        system: 'qimen',
        tier: tier,
        locale: locale,
        chart: Map<String, dynamic>.from(chartData),
      );
      if (tier == 'brief') {
        state = state.copyWith(briefInterpretation: r, isInterpreting: false);
      } else {
        state = state.copyWith(
          detailedInterpretation: r,
          clearBriefInterpret: true,
          isInterpreting: false,
        );
      }
    } catch (e) {
      state = state.copyWith(interpretError: e.toString(), isInterpreting: false);
    }
  }

  void reset() => state = QimenFormState();
}

final qimenFormProvider =
    StateNotifierProvider<QimenFormNotifier, QimenFormState>((ref) {
  return QimenFormNotifier(ref.watch(fortuneRepositoryProvider));
});

// ============================================================================
// Screen
// ============================================================================

class QimenScreen extends ConsumerWidget {
  const QimenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(qimenFormProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemQimen)),
      body: SafeArea(
        child: state.result == null
            ? _QimenForm(l10n: l10n, state: state)
            : _QimenResult(l10n: l10n, state: state),
      ),
    );
  }
}

// ============================================================================
// 表单
// ============================================================================

class _QimenForm extends ConsumerWidget {
  final AppL10n l10n;
  final QimenFormState state;
  const _QimenForm({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(qimenFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.systemQimenDesc,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),

          Text(l10n.qimenDatetime,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule),
            label: Text(
              '${state.when.year}-${state.when.month.toString().padLeft(2, '0')}-${state.when.day.toString().padLeft(2, '0')} '
              '${state.when.hour.toString().padLeft(2, '0')}:${state.when.minute.toString().padLeft(2, '0')}',
            ),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: state.when,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (d == null || !context.mounted) return;
              final t = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(state.when),
              );
              if (t == null) return;
              notifier.setWhen(
                  DateTime(d.year, d.month, d.day, t.hour, t.minute));
            },
          ),
          const SizedBox(height: 16),

          Text(l10n.formQuestion,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.formQuestionHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: notifier.setQuestion,
          ),
          const SizedBox(height: 24),

          if (state.error != null) ...[
            Text(state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 12),
          ],

          FilledButton.icon(
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.explore),
            label: Text(state.isSubmitting
                ? l10n.loading
                : l10n.actionStartReading),
            onPressed: state.isSubmitting ? null : () => notifier.submit(),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.bolt),
            label: Text(l10n.qimenCastNow),
            onPressed:
                state.isSubmitting ? null : () => notifier.submit(now: true),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 结果: 四柱 + 局信息 + 洛书九宫
// ============================================================================

/// 洛书排布: 上(南)排 4-9-2, 中排 3-5-7, 下(北)排 8-1-6
const List<int> _kLuoShuOrder = [4, 9, 2, 3, 5, 7, 8, 1, 6];

class _QimenResult extends ConsumerWidget {
  final AppL10n l10n;
  final QimenFormState state;
  const _QimenResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(qimenFormProvider.notifier);
    final chart = (state.result!['chart_data'] as Map?) ?? {};
    final siZhu = (chart['siZhu'] as Map?) ?? {};
    final zhiFu = (chart['zhiFu'] as Map?) ?? {};
    final zhiShi = (chart['zhiShi'] as Map?) ?? {};
    final palaces = ((chart['palaces'] as List?) ?? [])
        .cast<Map<String, dynamic>>();
    final byIndex = {for (final p in palaces) p['palaceIndex'] as int: p};
    final dunLabel =
        '${chart['dunType'] == 'yang' ? '阳遁' : '阴遁'}${chart['juNumber']}局 · ${chart['yuan'] ?? ''}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    '${siZhu['year']}年 ${siZhu['month']}月 ${siZhu['day']}日 ${siZhu['hour']}时',
                    style: MysticFonts.title(17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${chart['dateInfo']?['jieQi'] ?? ''} · $dunLabel',
                    style: MysticFonts.body(12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.qimenZhiFu}: ${zhiFu['star']}(${zhiFu['palace']}宫) · '
                    '${l10n.qimenZhiShi}: ${zhiShi['door']}(${zhiShi['palace']}宫)',
                    style: MysticFonts.body(12, color: MysticColors.goldBright),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 洛书九宫
          AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (final idx in _kLuoShuOrder)
                  _PalaceCell(palace: byIndex[idx], index: idx),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.actionRetry),
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
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome),
                  label: Text(state.isInterpreting
                      ? l10n.interpretLoading
                      : l10n.actionInterpret),
                  onPressed: state.isInterpreting ||
                          state.detailedInterpretation != null
                      ? null
                      : () => notifier.interpret(
                            tier: 'detailed',
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
                        tier: 'detailed',
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

class _PalaceCell extends StatelessWidget {
  final Map<String, dynamic>? palace;
  final int index;
  const _PalaceCell({required this.palace, required this.index});

  static const _names = {
    1: '坎', 2: '坤', 3: '震', 4: '巽', 5: '中', 6: '乾', 7: '兑', 8: '艮', 9: '离',
  };

  @override
  Widget build(BuildContext context) {
    final p = palace;
    final isCenter = index == 5;
    return Container(
      decoration: BoxDecoration(
        color: isCenter ? MysticColors.ink : MysticColors.ink2,
        border: Border.all(
            color: isCenter ? MysticColors.hairlineSoft : MysticColors.hairline),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('${_names[index]}$index',
              style: MysticFonts.body(9, color: MysticColors.moonFaint)),
          const SizedBox(height: 2),
          if (p?['god'] != null)
            Text(p!['god'] as String,
                style: MysticFonts.body(10, color: MysticColors.cinnabar)),
          if (p?['star'] != null)
            Text(p!['star'] as String, style: MysticFonts.title(12)),
          Text((p?['diPan'] as String?) ?? '',
              style: MysticFonts.title(14, color: MysticColors.goldBright)),
          if (p?['door'] != null)
            Text(p!['door'] as String,
                style: MysticFonts.body(10, color: MysticColors.jade)),
        ],
      ),
    );
  }
}
