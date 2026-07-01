// lib/features/tarot/tarot_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../_stub.dart';

class TarotScreen extends ConsumerWidget {
  const TarotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.systemTarot,
      description: l10n.systemTarotDesc,
    );
    // TODO(Week 5): 牌阵选择 + 问题输入 + 调用 /functions/v1/chart-tarot
  }
}
