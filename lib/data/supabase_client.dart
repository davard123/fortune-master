// lib/data/supabase_client.dart
// Supabase 全局单例代理
// main.dart 已直接调用 Supabase.initialize() 并使用全局静态 Supabase.instance.client
// 这里只是导出便捷 getter，避免分散 import
import 'package:supabase_flutter/supabase_flutter.dart';

/// 全局 Supabase client (等价于 Supabase.instance.client，但包了一层便于将来替换)
SupabaseClient get supabaseClient => Supabase.instance.client;

/// 当前用户 (nullable，未登录时返回 null)
User? get currentUser => supabaseClient.auth.currentUser;