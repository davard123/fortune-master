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

  // 初始化 Supabase (URL/anon key 来自 build env / --dart-define).
  // 加超时兜底: 部分受限存储环境 (如沙箱 iframe) 下 GoTrue 读本地 session
  // 可能卡住, 不能让整个 App 因鉴权初始化挂起而永远白屏.
  try {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    ).timeout(const Duration(seconds: 6));
  } catch (e) {
    // 初始化失败/超时也继续渲染 UI; 具体网络请求届时各自报错, 不在此处吞掉.
    debugPrint('Supabase.initialize failed or timed out: $e');
  }

  runApp(
    const ProviderScope(
      child: FortuneMasterApp(),
    ),
  );
}
