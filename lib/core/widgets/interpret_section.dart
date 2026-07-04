// lib/core/widgets/interpret_section.dart
// LLM 解读渲染区, Bazi / Tarot 等各术数结果页共用.
// 从 bazi_screen.dart 的私有 _InterpretSection 提取, 逻辑不变.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../data/repositories/fortune_repository.dart';

class InterpretSection extends StatelessWidget {
  final AppL10n l10n;
  final InterpretResult? brief;
  final InterpretResult? detailed;
  final String? error;
  final VoidCallback? onRetry;

  const InterpretSection({
    super.key,
    required this.l10n,
    this.brief,
    this.detailed,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final active = detailed ?? brief;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.onTertiaryContainer),
                const SizedBox(width: 8),
                Text(
                  detailed != null ? l10n.tierDetailed : l10n.tierBrief,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (active != null)
                  Text(
                    active.model.split('/').last,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiaryContainer,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(
                '${l10n.errorServer}\n$error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (active != null)
              SelectableText(
                active.text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              l10n.interpretDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
            ),
            if (error != null && onRetry != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: Text(l10n.interpretRetry),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
