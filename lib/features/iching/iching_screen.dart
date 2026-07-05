// lib/features/iching/iching_screen.dart
// 周易六爻: 问题 → chart-liuyao (自动摇卦) → 本卦/变卦/卦辞象辞 + AI 解读
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/divination_base.dart';
import '../../core/mystic_theme.dart';
import '../../data/repositories/fortune_repository.dart';

final ichingProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier(ref.watch(fortuneRepositoryProvider), 'iching');
});

class IchingScreen extends ConsumerWidget {
  const IchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(ichingProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemIching)),
      body: SafeArea(
        child: state.result == null
            ? _IchingForm(l10n: l10n)
            : _IchingResult(l10n: l10n, state: state),
      ),
    );
  }
}

class _IchingForm extends ConsumerStatefulWidget {
  final AppL10n l10n;
  const _IchingForm({required this.l10n});

  @override
  ConsumerState<_IchingForm> createState() => _IchingFormState();
}

class _IchingFormState extends ConsumerState<_IchingForm> {
  final _questionCtrl = TextEditingController();

  @override
  void dispose() {
    _questionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = ref.watch(ichingProvider);
    final notifier = ref.read(ichingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.systemIchingDesc,
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
                : const Icon(Icons.change_history),
            label: Text(state.isSubmitting ? l10n.loading : l10n.ichingCast),
            onPressed: state.isSubmitting || _questionCtrl.text.trim().isEmpty
                ? null
                : () => notifier.run((repo) => repo.invokeChart(
                    'chart-liuyao', {'question': _questionCtrl.text.trim()})),
          ),
        ],
      ),
    );
  }
}

class _IchingResult extends ConsumerWidget {
  final AppL10n l10n;
  final DivinationState state;
  const _IchingResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = (state.result!['chart_data'] as Map?) ?? {};

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
                  Text('${chart['hexagramName'] ?? ''}',
                      style: MysticFonts.heading(30)),
                  Text(
                    '${chart['hexagramGong'] ?? ''}宫 · ${chart['hexagramElement'] ?? ''}',
                    style: MysticFonts.body(12),
                  ),
                  if (chart['changedHexagramName'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.ichingChanged}: ${chart['changedHexagramName']}',
                      style:
                          MysticFonts.title(15, color: MysticColors.goldBright),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (chart['guaCi'] != null)
            _TextBlock(label: l10n.ichingGuaCi, text: '${chart['guaCi']}'),
          if (chart['xiangCi'] != null)
            _TextBlock(label: l10n.ichingXiangCi, text: '${chart['xiangCi']}'),
          if (chart['hexagramBrief'] != null)
            _TextBlock(label: '', text: '${chart['hexagramBrief']}'),
          const SizedBox(height: 20),
          DivinationActions(
            l10n: l10n,
            state: state,
            notifier: ref.read(ichingProvider.notifier),
            retryLabel: l10n.actionRetry,
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String label;
  final String text;
  const _TextBlock({required this.label, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: MysticColors.goldDim)),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label.isNotEmpty)
              Text(label,
                  style:
                      MysticFonts.title(13, color: MysticColors.goldBright)),
            Text(text, style: MysticFonts.body(13)),
          ],
        ),
      ),
    );
  }
}
