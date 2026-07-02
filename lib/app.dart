// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/mystic_theme.dart';
import 'core/router.dart';

class FortuneMasterApp extends ConsumerWidget {
  const FortuneMasterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Fortune Master',
      theme: buildMysticTheme(),
      themeMode: ThemeMode.light,
      routerConfig: router,
      // i18n 配置: 由 l10n.yaml 自动生成
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
    );
  }
}
