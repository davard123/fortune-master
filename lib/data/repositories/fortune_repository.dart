// lib/data/repositories/fortune_repository.dart
// 与 Supabase Edge Functions 通信的 Repository
// Edge Function URL 走 supabase.functions.invoke
import 'package:supabase_flutter/supabase_flutter.dart';

class FortuneRepository {
  final SupabaseClient _client;
  FortuneRepository(this._client);

  /// 调用 /functions/v1/chart-bazi 计算八字
  Future<Map<String, dynamic>> computeBazi({
    required int birthYear,
    required int birthMonth,
    required int birthDay,
    required int birthHour,
    required String gender,
  }) async {
    final res = await _client.functions.invoke(
      'chart-bazi',
      body: {
        'birthYear': birthYear,
        'birthMonth': birthMonth,
        'birthDay': birthDay,
        'birthHour': birthHour,
        'gender': gender,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// 调用 /functions/v1/chart-tarot 抽塔罗牌
  Future<Map<String, dynamic>> drawTarot({
    required String spread,
    String? question,
    int? randomSeed,
  }) async {
    final res = await _client.functions.invoke(
      'chart-tarot',
      body: {
        'spread': spread,
        if (question != null) 'question': question,
        if (randomSeed != null) 'randomSeed': randomSeed,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// 调用 /functions/v1/interpret 获取 LLM 解读
  /// Tier: 'brief' (免费/广告) | 'detailed' (订阅/付费)
  Future<String> interpret({
    required String readingId,
    required String tier,
    required String locale,
  }) async {
    final res = await _client.functions.invoke(
      'interpret',
      body: {
        'reading_id': readingId,
        'tier': tier,
        'locale': locale,
      },
    );
    return res.data['interpretation'] as String;
  }

  // === 后续添加更多术数的 compute 方法 ===
  // Future<Map<String, dynamic>> computeZiwei(...) async { ... }
  // Future<Map<String, dynamic>> computeQimen(...) async { ... }  // Week 3 Deno 验证后启用
}
