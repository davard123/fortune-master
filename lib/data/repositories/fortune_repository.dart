// lib/data/repositories/fortune_repository.dart
// 与 Supabase Edge Functions 通信的 Repository
// Edge Function URL 走 supabase.functions.invoke
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

/// LLM 解读返回结构 (与 supabase/functions/interpret/index.ts 一致)
class InterpretResult {
  final String text;
  final String model;
  final String tier;
  final String locale;
  final String system;
  final int charsLength;
  const InterpretResult({
    required this.text,
    required this.model,
    required this.tier,
    required this.locale,
    required this.system,
    required this.charsLength,
  });
}

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
  /// Spread: 'one' | 'three' | 'celtic' (外部别名, Edge Function 内部映射到 taibu-core)
  /// 注意: 不要传 randomSeed —— taibu-core 已修复此问题但仍建议客户端不传, 服务端随机
  Future<Map<String, dynamic>> drawTarot({
    required String spread,
    String? question,
  }) async {
    final res = await _client.functions.invoke(
      'chart-tarot',
      body: {
        'spread': spread,
        if (question != null && question.isNotEmpty) 'question': question,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  /// 调用 /functions/v1/interpret 获取 LLM 解读
  /// MVP 设计: 不持久化 readings 表, 直接把已有 chart 对象传给 interpret.
  /// 未来若开"解读历史"功能, 改为先 INSERT readings 再传 reading_id.
  ///
  /// [system]: 'bazi' | 'tarot' | 'qimen' | 'ziwei' | 'iching'
  /// [tier]:   'brief' | 'detailed' (brief ~200 words, detailed 800-1500 words)
  /// [locale]: 'en' | 'zh-CN'
  /// [chart]:  来自对应 chart-* Edge Function 的完整 chart_data / cards 等
  Future<InterpretResult> interpret({
    required String system,
    required String tier,
    required String locale,
    required Map<String, dynamic> chart,
  }) async {
    final res = await _client.functions.invoke(
      'interpret',
      body: {
        'system': system,
        'tier': tier,
        'locale': locale,
        'chart': chart,
      },
    );
    final data = Map<String, dynamic>.from(res.data);
    return InterpretResult(
      text: data['interpretation'] as String,
      model: data['model'] as String? ?? 'unknown',
      tier: data['tier'] as String? ?? tier,
      locale: data['locale'] as String? ?? locale,
      system: data['system'] as String? ?? system,
      charsLength: (data['charsLength'] as num?)?.toInt() ??
          (data['interpretation'] as String?)?.length ??
          0,
    );
  }

  // === 后续添加更多术数的 compute 方法 ===
  // Future<Map<String, dynamic>> computeZiwei(...) async { ... }
  // Future<Map<String, dynamic>> computeQimen(...) async { ... }
}

/// 全局单例, Riverpod Provider 注入.
/// 此前在 bazi_screen.dart 内定义, 现集中到 Repository 模块.
final fortuneRepositoryProvider = Provider<FortuneRepository>((ref) {
  return FortuneRepository(supabaseClient);
});
