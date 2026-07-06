// lib/core/divination_base.dart
// 各术数屏共用的排盘+解读状态机, 消除 Bazi/Tarot/Qimen 模式在 5 个新屏上的重复.
// 表单输入由各屏的 StatefulWidget 自持, 提交时把参数传进 run().
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/fortune_repository.dart';
import 'widgets/interpret_section.dart';

class DivinationState {
  final bool isSubmitting;
  final String? error;
  final Map<String, dynamic>? result;
  final bool isInterpreting;
  final String? interpretError;
  final InterpretResult? brief;
  final InterpretResult? detailed;

  const DivinationState({
    this.isSubmitting = false,
    this.error,
    this.result,
    this.isInterpreting = false,
    this.interpretError,
    this.brief,
    this.detailed,
  });

  DivinationState copyWith({
    bool? isSubmitting,
    String? error,
    Map<String, dynamic>? result,
    bool? isInterpreting,
    String? interpretError,
    InterpretResult? brief,
    InterpretResult? detailed,
    bool clearError = false,
    bool clearResult = false,
    bool clearInterpretError = false,
    bool clearBrief = false,
    bool clearDetailed = false,
  }) {
    return DivinationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      result: clearResult ? null : (result ?? this.result),
      isInterpreting: isInterpreting ?? this.isInterpreting,
      interpretError:
          clearInterpretError ? null : (interpretError ?? this.interpretError),
      brief: clearBrief ? null : (brief ?? this.brief),
      detailed: clearDetailed ? null : (detailed ?? this.detailed),
    );
  }
}

class DivinationNotifier extends StateNotifier<DivinationState> {
  final FortuneRepository repo;

  /// interpret 的 system id ('ziwei' | 'iching' | 'meihua' | 'astro' | 'dream')
  final String system;

  DivinationNotifier(this.repo, this.system) : super(const DivinationState());

  /// 执行排盘. job 由屏幕层提供 (闭包捕获表单参数).
  Future<void> run(Future<Map<String, dynamic>> Function(FortuneRepository) job) async {
    if (state.isSubmitting) return;
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearResult: true,
      clearInterpretError: true,
      clearBrief: true,
      clearDetailed: true,
    );
    try {
      final r = await job(repo);
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
        system: system,
        tier: tier,
        locale: locale,
        chart: Map<String, dynamic>.from(chartData),
      );
      if (tier == 'brief') {
        state = state.copyWith(brief: r, isInterpreting: false);
      } else {
        state = state.copyWith(
            detailed: r, clearBrief: true, isInterpreting: false);
      }
    } catch (e) {
      state = state.copyWith(interpretError: e.toString(), isInterpreting: false);
    }
  }

  void reset() => state = const DivinationState();
}

/// 结果页底部通用块: [再排一次 | AI 解读] 按钮行 + 解读展示区.
class DivinationActions extends StatelessWidget {
  final AppL10n l10n;
  final DivinationState state;
  final DivinationNotifier notifier;
  final String retryLabel;

  const DivinationActions({
    super.key,
    required this.l10n,
    required this.state,
    required this.notifier,
    required this.retryLabel,
  });

  // 自测版全解锁: 一键直出深度解读 (brief 档保留在后端, 未来做付费墙分层时再启用)
  void _interpret(BuildContext context) => notifier.interpret(
        tier: 'detailed',
        locale: Localizations.localeOf(context).toLanguageTag(),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
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
                onPressed: state.isInterpreting || state.detailed != null
                    ? null
                    : () => _interpret(context),
              ),
            ),
          ],
        ),
        if (state.brief != null ||
            state.detailed != null ||
            state.interpretError != null) ...[
          const SizedBox(height: 16),
          InterpretSection(
            l10n: l10n,
            brief: state.brief,
            detailed: state.detailed,
            error: state.interpretError,
            onRetry: state.isInterpreting ? null : () => _interpret(context),
          ),
        ],
      ],
    );
  }
}
