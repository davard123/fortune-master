// lib/core/router.dart
// go_router 声明式路由
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/bazi/bazi_screen.dart';
import '../features/tarot/tarot_screen.dart';
import '../features/iching/iching_screen.dart';
import '../features/qimen/qimen_screen.dart';
import '../features/ziwei/ziwei_screen.dart';
import '../features/meihua/meihua_screen.dart';
import '../features/astro/astro_screen.dart';
import '../features/dream/dream_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/community/community_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/paywall/paywall_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 公共路由
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // 术数模块 (8 个首发, 2026-07-04 起全部实装)
      GoRoute(path: '/bazi', builder: (_, __) => const BaziScreen()),
      GoRoute(path: '/tarot', builder: (_, __) => const TarotScreen()),
      GoRoute(path: '/iching', builder: (_, __) => const IchingScreen()),
      GoRoute(path: '/qimen', builder: (_, __) => const QimenScreen()),
      GoRoute(path: '/ziwei', builder: (_, __) => const ZiweiScreen()),
      GoRoute(path: '/meihua', builder: (_, __) => const MeihuaScreen()),
      GoRoute(path: '/astro', builder: (_, __) => const AstroScreen()),
      GoRoute(path: '/dream', builder: (_, __) => const DreamScreen()),

      // 社区 + 个人中心
      GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/paywall', builder: (_, __) => const PaywallScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('404 · ${state.uri}')),
    ),
  );
});
