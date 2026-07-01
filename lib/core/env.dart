// lib/core/env.dart
// 环境变量集中管理 (通过 --dart-define 注入)
// 例: flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co
class Env {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // FreeLLMAPI / DeepSeek 切换由 Edge Function 决定, 这里只放公共配置
  // LLM 详情见 supabase/functions/interpret/

  // 启动检查: 缺一不可
  static void assertConfigured() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        'Missing --dart-define SUPABASE_URL / SUPABASE_ANON_KEY\n'
        'Run: flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co '
        '--dart-define=SUPABASE_ANON_KEY=xxx',
      );
    }
  }
}
