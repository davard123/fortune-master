// lib/features/bazi/bazi_screen.dart
// 八字模块首页: 出生日期/时辰/性别输入 → 调用 chart-bazi → 展示四柱
// 双语 MVP, Week 5 实装, 2026-07-01 实装第一个完整 flow

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/interpret_section.dart';
import '../../data/repositories/fortune_repository.dart';

// ============================================================================
// 表单状态 (Riverpod StateNotifier)
// ============================================================================

class BaziFormState {
  final DateTime? birthDate;
  final int? birthHour;        // 0-23, null 表示未填
  final String gender;         // 'male' | 'female' | 'other'
  final bool isSubmitting;
  final String? error;
  final Map<String, dynamic>? result;       // chart-bazi 返回的完整 JSON
  final InterpretResult? briefInterpretation;   // brief 解读 (返回 null = 未请求)
  final InterpretResult? detailedInterpretation; // detailed 解读
  final bool isInterpreting;
  final String? interpretError;

  const BaziFormState({
    this.birthDate,
    this.birthHour,
    this.gender = 'male',
    this.isSubmitting = false,
    this.error,
    this.result,
    this.briefInterpretation,
    this.detailedInterpretation,
    this.isInterpreting = false,
    this.interpretError,
  });

  BaziFormState copyWith({
    DateTime? birthDate,
    int? birthHour,
    String? gender,
    bool? isSubmitting,
    String? error,
    Map<String, dynamic>? result,
    InterpretResult? briefInterpretation,
    InterpretResult? detailedInterpretation,
    bool? isInterpreting,
    String? interpretError,
    bool clearError = false,
    bool clearResult = false,
    bool clearInterpretError = false,
    bool clearBriefInterpret = false,
    bool clearDetailedInterpret = false,
  }) {
    return BaziFormState(
      birthDate: birthDate ?? this.birthDate,
      birthHour: birthHour ?? this.birthHour,
      gender: gender ?? this.gender,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
      briefInterpretation: clearBriefInterpret
          ? null
          : (briefInterpretation ?? this.briefInterpretation),
      detailedInterpretation: clearDetailedInterpret
          ? null
          : (detailedInterpretation ?? this.detailedInterpretation),
      isInterpreting: isInterpreting ?? this.isInterpreting,
      interpretError:
          clearInterpretError ? null : (interpretError ?? this.interpretError),
    );
  }

  bool get isReady => birthDate != null && birthHour != null;
}

class BaziFormNotifier extends StateNotifier<BaziFormState> {
  final FortuneRepository repo;
  BaziFormNotifier(this.repo) : super(const BaziFormState());

  void setBirthDate(DateTime? d) =>
      state = state.copyWith(birthDate: d,
          clearResult: true,
          clearBriefInterpret: true,
          clearDetailedInterpret: true);
  void setBirthHour(int? h) =>
      state = state.copyWith(birthHour: h,
          clearResult: true,
          clearBriefInterpret: true,
          clearDetailedInterpret: true);
  void setGender(String g) => state = state.copyWith(gender: g);

  Future<void> submit() async {
    if (!state.isReady || state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearResult: true,
      clearBriefInterpret: true,
      clearDetailedInterpret: true,
    );
    try {
      final r = await repo.computeBazi(
        birthYear: state.birthDate!.year,
        birthMonth: state.birthDate!.month,
        birthDay: state.birthDate!.day,
        birthHour: state.birthHour!,
        gender: state.gender,
      );
      state = state.copyWith(result: r, isSubmitting: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSubmitting: false);
    }
  }

  /// 调用 LLM 解读. tier 升档会自动清空上一档 (brief→detailed 只保留 detailed).
  Future<void> interpret({required String tier, required String locale}) async {
    if (state.result == null || state.isInterpreting) return;
    state = state.copyWith(
      isInterpreting: true,
      clearInterpretError: true,
    );
    try {
      final chartData = (state.result!['chart_data'] as Map?) ?? {};
      final r = await repo.interpret(
        system: 'bazi',
        tier: tier,
        locale: locale,
        chart: Map<String, dynamic>.from(chartData),
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

  void reset() => state = const BaziFormState();
}

final baziFormProvider = StateNotifierProvider<BaziFormNotifier, BaziFormState>((ref) {
  final repo = ref.watch(fortuneRepositoryProvider);
  return BaziFormNotifier(repo);
});

// ============================================================================
// Screen
// ============================================================================

class BaziScreen extends ConsumerWidget {
  const BaziScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(baziFormProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemBazi)),
      body: SafeArea(
        child: state.result == null
            ? _BaziForm(l10n: l10n, state: state)
            : _BaziResult(l10n: l10n, state: state),
      ),
    );
  }
}

// ============================================================================
// 表单视图
// ============================================================================

class _BaziForm extends ConsumerWidget {
  final AppL10n l10n;
  final BaziFormState state;
  const _BaziForm({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(baziFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 副标题
          Text(
            l10n.homeScreenSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // 日期选择
          _DatePickerField(
            label: l10n.formBirthDate,
            value: state.birthDate,
            onChanged: notifier.setBirthDate,
          ),
          const SizedBox(height: 16),

          // 时辰选择
          _HourPickerField(
            label: l10n.formBirthTime,
            value: state.birthHour,
            onChanged: notifier.setBirthHour,
          ),
          const SizedBox(height: 16),

          // 性别选择
          Text(l10n.formGender, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'male', label: Text(l10n.formGenderMale)),
              ButtonSegment(value: 'female', label: Text(l10n.formGenderFemale)),
              ButtonSegment(value: 'other', label: Text(l10n.formGenderOther)),
            ],
            selected: {state.gender},
            onSelectionChanged: (s) => notifier.setGender(s.first),
          ),
          const SizedBox(height: 32),

          // 错误
          if (state.error != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${l10n.errorServer}\n${state.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 提交按钮
          FilledButton.icon(
            icon: state.isSubmitting
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.calculate),
            label: Text(state.isSubmitting ? l10n.loading : l10n.actionStartReading),
            onPressed: state.isReady && !state.isSubmitting ? notifier.submit : null,
          ),
          const SizedBox(height: 24),

          // 免责声明
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

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DatePickerField({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '—'
        : '${value!.year.toString().padLeft(4, '0')}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(1990, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

class _HourPickerField extends StatelessWidget {
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;
  const _HourPickerField({required this.label, required this.value, required this.onChanged});

  // 12 时辰, 每 2 小时一个. 中文硬编码 OK (时辰是中文专有术语, 英文 ARB 也用拼音 + 小时)
  static const List<String> _shiChen = [
    '子 (23-01)', '丑 (01-03)', '寅 (03-05)', '卯 (05-07)',
    '辰 (07-09)', '巳 (09-11)', '午 (11-13)', '未 (13-15)',
    '申 (15-17)', '酉 (17-19)', '戌 (19-21)', '亥 (21-23)',
  ];

  @override
  Widget build(BuildContext context) {
    final text = value == null ? '—' : _shiChen[value! ~/ 2];
    return InkWell(
      onTap: () async {
        final picked = await showModalBottomSheet<int>(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _shiChen.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(_shiChen[i]),
                  selected: value == i * 2,
                  onTap: () => Navigator.pop(ctx, i * 2),
                ),
              ),
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}

// ============================================================================
// 结果视图
// ============================================================================

class _BaziResult extends ConsumerWidget {
  final AppL10n l10n;
  final BaziFormState state;
  const _BaziResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = state.result!;
    final chartData = chart['chart_data'] as Map<String, dynamic>? ?? {};
    final fourPillars = chartData['fourPillars'] as Map<String, dynamic>? ?? {};
    final dayMaster = chartData['dayMaster'] as String? ?? '?';
    final notifier = ref.read(baziFormProvider.notifier);

    final pillars = ['year', 'month', 'day', 'hour'];
    final labels = [l10n.baziYearPillar, l10n.baziMonthPillar, l10n.baziDayPillar, l10n.baziHourPillar];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题 + 日主
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(l10n.baziDayMaster,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(dayMaster,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 四柱
          Row(
            children: List.generate(4, (i) {
              final pillar = fourPillars[pillars[i]] as Map<String, dynamic>?;
              final stem = pillar?['stem'] as String? ?? '?';
              final branch = pillar?['branch'] as String? ?? '?';
              return Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(labels[i],
                            style: Theme.of(context).textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Text(stem,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                )),
                        Text(branch,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                )),
                        const SizedBox(height: 4),
                        if (pillar?['tenGod'] != null)
                          Text(pillar!['tenGod'] as String,
                              style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
              );
            }).expand((w) => [w, const SizedBox(width: 8)]).toList()..removeLast(),
          ),
          const SizedBox(height: 16),

          // 隐藏十神 (藏干)
          ...pillars.map((p) {
            final pillar = fourPillars[p] as Map<String, dynamic>?;
            final hidden = pillar?['hiddenStems'] as List? ?? [];
            if (hidden.isEmpty) return const SizedBox.shrink();
            final hiddenTitle = p == 'year'
                ? l10n.baziYearHidden
                : p == 'month'
                    ? l10n.baziMonthHidden
                    : p == 'day'
                        ? l10n.baziDayHidden
                        : l10n.baziHourHidden;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hiddenTitle,
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      children: hidden.map<Widget>((h) {
                        final hm = h as Map<String, dynamic>;
                        return Chip(
                          label: Text('${hm['stem']} · ${hm['tenGod']} (${hm['qiType']})'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // 神煞摘要 (日柱的全部)
          if ((fourPillars['day'] as Map?)?['shenSha'] != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.baziDayShenSha,
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: ((fourPillars['day']!['shenSha'] as List?) ?? [])
                          .map<Widget>((s) => Chip(
                                label: Text(s.toString()),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondaryContainer,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 大运 / 命宫
          if (chartData['taiYuan'] != null || chartData['mingGong'] != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (chartData['taiYuan'] != null)
                      Column(
                        children: [
                          Text(l10n.baziTaiYuan, style: Theme.of(context).textTheme.labelMedium),
                          Text(chartData['taiYuan'].toString(),
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                    if (chartData['mingGong'] != null)
                      Column(
                        children: [
                          Text(l10n.baziMingGong, style: Theme.of(context).textTheme.labelMedium),
                          Text(chartData['mingGong'].toString(),
                              style: Theme.of(context).textTheme.headlineSmall),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 操作按钮
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
                                .languageCode,
                          ),
                ),
              ),
            ],
          ),

          // 解读展示
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
                            Localizations.localeOf(context).languageCode,
                      ),
            ),
          ],
        ],
      ),
    );
  }
}

// _InterpretSection 已提取为共享组件: lib/core/widgets/interpret_section.dart