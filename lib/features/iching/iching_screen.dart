// lib/features/iching/iching_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../_stub.dart';

class IchingScreen extends ConsumerWidget {
  const IchingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.systemIching,
      description: l10n.systemIchingDesc,
    );
    // TODO(Week 7): 起卦方式选择 (金钱卦/蓍草) + 调用 taibu-core/liuyao
  }
}
