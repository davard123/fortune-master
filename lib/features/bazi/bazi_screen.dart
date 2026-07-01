// lib/features/bazi/bazi_screen.dart
// 八字模块首页: 出生日期时间输入 → 调用 /functions/v1/chart-bazi
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../_stub.dart';

final baziInputProvider = StateProvider<BaziInput?>((ref) => null);

class BaziInput {
  final DateTime birthDate;
  final int hour;
  final String gender;
  BaziInput({required this.birthDate, required this.hour, required this.gender});
}

class BaziScreen extends ConsumerWidget {
  const BaziScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.systemBazi,
      description: l10n.systemBaziDesc,
    );
    // TODO(Week 5): 完整表单 + 排盘 + 解读 tier 选择 + 广告/订阅墙
  }
}
