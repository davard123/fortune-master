// lib/features/meihua/meihua_screen.dart
// 梅花易数: 问题 → chart-meihua (时间起卦) → 主卦/互卦/变卦/动爻 + AI 解读
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/divination_base.dart';
import '../../core/mystic_theme.dart';
import '../../data/repositories/fortune_repository.dart';

final meihuaProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier(ref.watch(fortuneRepositoryProvider), 'meihua');
});

class MeihuaScreen extends ConsumerWidget {
  const MeihuaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(meihuaProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemMeihua)),
      body: SafeArea(
        child: state.result == null
            ? _MeihuaForm(l10n: l10n)
            : _MeihuaResult(l10n: l10n, state: state),
      ),
    );
  }
}

class _MeihuaForm extends ConsumerStatefulWidget {
  final AppL10n l10n;
  const _MeihuaForm({required this.l10n});

  @override
  ConsumerState<_MeihuaForm> createState() => _MeihuaFormState();
}

class _MeihuaFormState extends ConsumerState<_MeihuaForm> {
  final _questionCtrl = TextEditingController();

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = ref.watch(meihuaProvider);
    final notifier = ref.read(meihuaProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.systemMeihuaDesc,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.formQuestion,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _questionCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: l10n.formQuestionHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
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
                : const Icon(Icons.local_florist),
            label: Text(
                state.isSubmitting ? l10n.loading : l10n.actionStartReading),
            onPressed: state.isSubmitting || _questionCtrl.text.trim().isEmpty
                ? null
                : () => notifier.run((repo) => repo.invokeChart(
                    'chart-meihua', {'question': _questionCtrl.text.trim()})),
          ),
        ],
      ),
    );
  }
}

class _MeihuaResult extends ConsumerWidget {
  final AppL10n l10n;
  final DivinationState state;
  const _MeihuaResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = (state.result!['chart_data'] as Map?) ?? {};
    String hexName(String key) =>
        ((chart[key] as Map?)?['name'] as String?) ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(hexName('mainHexagram'), style: MysticFonts.heading(30)),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: [
                      Text('${l10n.meihuaNuclear}: ${hexName('nuclearHexagram')}',
                          style: MysticFonts.body(13)),
                      Text('${l10n.ichingChanged}: ${hexName('changedHexagram')}',
                          style: MysticFonts.body(13)),
                      Text('${l10n.meihuaMovingLine}: ${chart['movingLine'] ?? '-'}',
                          style: MysticFonts.body(
                              13, color: MysticColors.cinnabar)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          DivinationActions(
            l10n: l10n,
            state: state,
            notifier: ref.read(meihuaProvider.notifier),
            retryLabel: l10n.actionRetry,
          ),
        ],
      ),
    );
  }
}
