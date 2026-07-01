// lib/main.dart
// 中西算命大全 / Fortune Master Flutter 应用入口
// 双语 MVP: 英文 + 简体中文 (l10n.yaml → lib/l10n/generated/app_localizations.dart)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'data/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase (URL/anon key 来自 build env / --dart-define)
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: FortuneMasterApp(),
    ),
  );
}
