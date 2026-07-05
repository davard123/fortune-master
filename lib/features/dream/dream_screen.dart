// lib/features/dream/dream_screen.dart
// 周公解梦: 梦境描述 → interpret (LLM + 周公解梦传统象征体系)
// 无排盘端点, "排盘"步骤在本地构造 {dream: 文本} 后直接走 interpret.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/divination_base.dart';
import '../../data/repositories/fortune_repository.dart';

final dreamProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier(ref.watch(fortuneRepositoryProvider), 'dream');
});

class DreamScreen extends ConsumerStatefulWidget {
  const DreamScreen({super.key});

  @override
  ConsumerState<DreamScreen> createState() => _DreamScreenState();
}

class _DreamScreenState extends ConsumerState<DreamScreen> {
  final _dreamCtrl = TextEditingController();

  @override
  void dispose() {
    _dreamCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(dreamProvider.notifier);
    final text = _dreamCtrl.text.trim();
    // "排盘" = 本地构造 dream chart, 然后立即请求 brief 解读
    await notifier.run((_) async => {
          'chart_data': {'dream': text},
        });
    if (!mounted) return;
    await notifier.interpret(
      tier: 'brief',
      locale: Localizations.localeOf(context).toLanguageTag(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(dreamProvider);
    final busy = state.isSubmitting || state.isInterpreting;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemDream)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.systemDreamDesc,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 24),
              Text(l10n.dreamInputLabel,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _dreamCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: l10n.dreamInputHint,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.nightlight_round),
                label: Text(busy ? l10n.interpretLoading : l10n.actionInterpret),
                onPressed: busy || _dreamCtrl.text.trim().isEmpty
                    ? null
                    : _submit,
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (state.result != null) ...[
                const SizedBox(height: 20),
                DivinationActions(
                  l10n: l10n,
                  state: state,
                  notifier: ref.read(dreamProvider.notifier),
                  retryLabel: l10n.actionRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
