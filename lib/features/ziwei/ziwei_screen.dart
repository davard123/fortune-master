// lib/features/ziwei/ziwei_screen.dart
// 紫微斗数: 生日/时辰/性别 → chart-ziwei → 命主身主/五行局 + 十二宫 + AI 解读
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/divination_base.dart';
import '../../core/mystic_theme.dart';
import '../../data/repositories/fortune_repository.dart';

final ziweiProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier(ref.watch(fortuneRepositoryProvider), 'ziwei');
});

class ZiweiScreen extends ConsumerWidget {
  const ZiweiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(ziweiProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemZiwei)),
      body: SafeArea(
        child: state.result == null
            ? _ZiweiForm(l10n: l10n)
            : _ZiweiResult(l10n: l10n, state: state),
      ),
    );
  }
}

class _ZiweiForm extends ConsumerStatefulWidget {
  final AppL10n l10n;
  const _ZiweiForm({required this.l10n});

  @override
  ConsumerState<_ZiweiForm> createState() => _ZiweiFormState();
}

class _ZiweiFormState extends ConsumerState<_ZiweiForm> {
  DateTime? _date;
  int? _hour;
  String _gender = 'male';

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = ref.watch(ziweiProvider);
    final notifier = ref.read(ziweiProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.systemZiweiDesc,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.formBirthDate,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label: Text(_date == null
                ? l10n.formBirthDate
                : '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}'),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date ?? DateTime(1990, 6, 15),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
          const SizedBox(height: 16),
          Text(l10n.formBirthTime,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            value: _hour,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              for (var h = 0; h < 24; h++)
                DropdownMenuItem(
                    value: h, child: Text('${h.toString().padLeft(2, '0')}:00')),
            ],
            onChanged: (v) => setState(() => _hour = v),
          ),
          const SizedBox(height: 16),
          Text(l10n.formGender, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'male', label: Text(l10n.formGenderMale)),
              ButtonSegment(value: 'female', label: Text(l10n.formGenderFemale)),
            ],
            selected: {_gender},
            onSelectionChanged: (s) => setState(() => _gender = s.first),
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
                : const Icon(Icons.auto_awesome),
            label: Text(
                state.isSubmitting ? l10n.loading : l10n.actionStartReading),
            onPressed: state.isSubmitting || _date == null || _hour == null
                ? null
                : () => notifier.run((repo) => repo.invokeChart('chart-ziwei', {
                      'birthYear': _date!.year,
                      'birthMonth': _date!.month,
                      'birthDay': _date!.day,
                      'birthHour': _hour,
                      'gender': _gender,
                    })),
          ),
        ],
      ),
    );
  }
}

class _ZiweiResult extends ConsumerWidget {
  final AppL10n l10n;
  final DivinationState state;
  const _ZiweiResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = (state.result!['chart_data'] as Map?) ?? {};
    final palaces =
        ((chart['palaces'] as List?) ?? []).cast<Map<String, dynamic>>();

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
                  Text('${chart['lunarDate'] ?? ''}',
                      style: MysticFonts.title(16)),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.ziweiSoul}: ${chart['soul']} · ${l10n.ziweiBody}: ${chart['body']} · ${l10n.ziweiFiveElement}: ${chart['fiveElement']}',
                    textAlign: TextAlign.center,
                    style: MysticFonts.body(12, color: MysticColors.goldBright),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.ziweiPalaces, style: MysticFonts.title(16)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final p in palaces)
                Container(
                  decoration: BoxDecoration(
                    color: MysticColors.ink2,
                    border: Border.all(color: MysticColors.hairlineSoft),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${p['name']} · ${p['heavenlyStem']}${p['earthlyBranch']}',
                        style: MysticFonts.title(13),
                      ),
                      Text(
                        ((p['majorStars'] as List?) ?? [])
                            .map((s) => s is Map ? s['name'] : s)
                            .join(' '),
                        style: MysticFonts.body(11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          DivinationActions(
            l10n: l10n,
            state: state,
            notifier: ref.read(ziweiProvider.notifier),
            retryLabel: l10n.actionRetry,
          ),
        ],
      ),
    );
  }
}
