// lib/features/astro/astro_screen.dart
// 西方占星: 生日/时间/经纬度 → chart-astro → 太阳星座 + 行星落宫 + AI 解读
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/divination_base.dart';
import '../../core/mystic_theme.dart';
import '../../data/repositories/fortune_repository.dart';

final astroProvider =
    StateNotifierProvider<DivinationNotifier, DivinationState>((ref) {
  return DivinationNotifier(ref.watch(fortuneRepositoryProvider), 'astro');
});

class AstroScreen extends ConsumerWidget {
  const AstroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final state = ref.watch(astroProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.systemHoroscope)),
      body: SafeArea(
        child: state.result == null
            ? _AstroForm(l10n: l10n)
            : _AstroResult(l10n: l10n, state: state),
      ),
    );
  }
}

class _AstroForm extends ConsumerStatefulWidget {
  final AppL10n l10n;
  const _AstroForm({required this.l10n});

  @override
  ConsumerState<_AstroForm> createState() => _AstroFormState();
}

class _AstroFormState extends ConsumerState<_AstroForm> {
  DateTime? _date;
  TimeOfDay? _time;
  final _latCtrl = TextEditingController(text: '39.9');
  final _lngCtrl = TextEditingController(text: '116.4');

  @override
  void dispose() {
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final state = ref.watch(astroProvider);
    final notifier = ref.read(astroProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.systemHoroscopeDesc,
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.formBirthDate,
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
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
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: Text(_time == null
                      ? l10n.formBirthTime
                      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}'),
                  onPressed: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _time ?? const TimeOfDay(hour: 12, minute: 0),
                    );
                    if (t != null) setState(() => _time = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _latCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: l10n.astroLatitude,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _lngCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    labelText: l10n.astroLongitude,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
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
                : const Icon(Icons.public),
            label: Text(
                state.isSubmitting ? l10n.loading : l10n.actionStartReading),
            onPressed: state.isSubmitting || _date == null || _time == null
                ? null
                : () => notifier.run((repo) => repo.invokeChart('chart-astro', {
                      'birthYear': _date!.year,
                      'birthMonth': _date!.month,
                      'birthDay': _date!.day,
                      'birthHour': _time!.hour,
                      'birthMinute': _time!.minute,
                      'latitude': double.tryParse(_latCtrl.text) ?? 39.9,
                      'longitude': double.tryParse(_lngCtrl.text) ?? 116.4,
                    })),
          ),
        ],
      ),
    );
  }
}

class _AstroResult extends ConsumerWidget {
  final AppL10n l10n;
  final DivinationState state;
  const _AstroResult({required this.l10n, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chart = (state.result!['chart_data'] as Map?) ?? {};
    final natal = (chart['natal'] as Map?) ?? {};
    final sun = (natal['sunSign'] as Map?) ?? {};
    final bodies = ((natal['bodies'] as List?) ?? []).cast<Map<String, dynamic>>();

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
                  Text('${sun['label'] ?? ''}', style: MysticFonts.heading(28)),
                  Text(
                    '${l10n.astroSun} · ${sun['element'] ?? ''} · ${sun['modality'] ?? ''}',
                    style: MysticFonts.body(12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l10n.astroBodies, style: MysticFonts.title(16)),
          const SizedBox(height: 8),
          for (final b in bodies)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text('${b['label']}', style: MysticFonts.title(13)),
                  ),
                  Text(
                    '${(b['sign'] as Map?)?['label'] ?? ''}',
                    style: MysticFonts.body(13),
                  ),
                  const Spacer(),
                  Text('H${b['house']}',
                      style:
                          MysticFonts.body(12, color: MysticColors.goldBright)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          DivinationActions(
            l10n: l10n,
            state: state,
            notifier: ref.read(astroProvider.notifier),
            retryLabel: l10n.actionRetry,
          ),
        ],
      ),
    );
  }
}
