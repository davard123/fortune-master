// lib/features/home/home_screen.dart
// 首页: 8 种术数入口. 视觉移植自 web-prototype/index.html 的宣纸鎏金主题.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/mystic_theme.dart';
import '../../core/widgets/gold_dust_backdrop.dart';
import '../../core/widgets/mystic_compass.dart';

/// 部署站点基址 (Cloudflare Pages). 改域名只需改这里一处.
const String _kSiteBaseUrl = 'https://fortune.fopusha.com';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = [
      _SystemItem('bazi', l10n.systemBazi, 'BAZI', Icons.access_time_filled),
      _SystemItem('ziwei', l10n.systemZiwei, 'ZI WEI DOU SHU', Icons.auto_awesome),
      _SystemItem('iching', l10n.systemIching, 'I CHING', Icons.grid_view_rounded),
      _SystemItem('meihua', l10n.systemMeihua, 'PLUM BLOSSOM', Icons.local_florist),
      _SystemItem('tarot', l10n.systemTarot, 'TAROT', Icons.style, hot: true),
      _SystemItem('qimen', l10n.systemQimen, 'QI MEN DUN JIA', Icons.explore),
      _SystemItem('astro', l10n.systemHoroscope, 'ASTROLOGY', Icons.public),
      _SystemItem('dream', l10n.systemDream, 'DREAM ORACLE', Icons.nightlight_round),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MysticColors.gold, width: 1),
              ),
              child: Text('卜', style: MysticFonts.title(16, color: MysticColors.gold)),
            ),
            const SizedBox(width: 10),
            Text(l10n.appName, style: MysticFonts.title(16)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: MysticColors.jade.withOpacity(.4)),
              borderRadius: BorderRadius.circular(2),
            ),
            alignment: Alignment.center,
            child: Text(
              l10n.homeSelfTestBadge,
              style: MysticFonts.body(10, color: MysticColors.jade),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.auto_stories_outlined),
            tooltip: l10n.menuLandingTooltip,
            onPressed: _openLanding,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.menuProfile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: GoldDustBackdrop(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Hero(l10n: l10n)),
              SliverToBoxAdapter(child: _SectionHeading(zh: l10n.homeScreenTitle, en: 'DIVINATION ARTS')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: .82,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _SystemCard(item: items[i]),
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/community'),
                    icon: const Icon(Icons.forum_outlined),
                    label: Text(l10n.menuCommunity),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/paywall'),
                    icon: const Icon(Icons.workspace_premium_outlined),
                    label: Text(l10n.actionSubscribe),
                  ),
                ],
              ),
              Divider(height: 4, color: MysticColors.hairlineSoft),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () => _openLegal(context, 'privacy'),
                    child: Text(l10n.legalPrivacy,
                        style: MysticFonts.body(11, color: MysticColors.moonFaint)),
                  ),
                  Text('·', style: MysticFonts.body(11, color: MysticColors.moonFaint)),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () => _openLegal(context, 'terms'),
                    child: Text(l10n.legalTerms,
                        style: MysticFonts.body(11, color: MysticColors.moonFaint)),
                  ),
                  Text('·', style: MysticFonts.body(11, color: MysticColors.moonFaint)),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () => _openLegal(context, 'cookies'),
                    child: Text(l10n.legalCookies,
                        style: MysticFonts.body(11, color: MysticColors.moonFaint)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final AppL10n l10n;
  const _Hero({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        children: [
          const MysticCompass(size: 220),
          Transform.translate(
            offset: const Offset(0, -70),
            child: Column(
              children: [
                Text(
                  l10n.appName,
                  textAlign: TextAlign.center,
                  style: MysticFonts.heading(40),
                ),
                const SizedBox(height: 6),
                Text(l10n.appTagline, style: MysticFonts.en(12)),
                const SizedBox(height: 14),
                Text(
                  l10n.homeScreenSubtitle,
                  textAlign: TextAlign.center,
                  style: MysticFonts.body(13, color: MysticColors.moonDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String zh;
  final String en;
  const _SectionHeading({required this.zh, required this.en});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          Text(zh, textAlign: TextAlign.center, style: MysticFonts.title(22)),
          const SizedBox(height: 6),
          Text(en, style: MysticFonts.en(10)),
          const SizedBox(height: 14),
          SizedBox(
            width: 140,
            child: Divider(color: MysticColors.goldDim, height: 1, thickness: .6),
          ),
        ],
      ),
    );
  }
}

class _SystemItem {
  final String route;
  final String title;
  final String en;
  final IconData icon;
  final bool hot;
  _SystemItem(this.route, this.title, this.en, this.icon, {this.hot = false});
}

/// 打开隐私 / 条款 / Cookie 静态页. 云端部署后 URL 形如:
///   https://fortune-master.pages.dev/privacy/
/// url_launcher 调用新 tab, 不离开 app.
Future<void> _openLegal(BuildContext context, String slug) async {
  final uri = Uri.parse('$_kSiteBaseUrl/$slug/');
  try {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uri.toString())),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uri.toString())),
      );
    }
  }
}

/// 打开八门术数介绍页 (Claude Design 营销页, 部署后为 /landing/).
/// 走 url_launcher, 新 tab, 不离开 app 主流程.
Future<void> _openLanding() async {
  final uri = Uri.parse('$_kSiteBaseUrl/landing/');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _SystemCard extends StatelessWidget {
  final _SystemItem item;
  const _SystemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MysticColors.ink2,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => context.push('/${item.route}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: MysticColors.hairlineSoft),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
          child: Stack(
            children: [
              if (item.hot)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: MysticColors.cinnabar.withOpacity(.5)),
                    ),
                    child: Text('热门', style: MysticFonts.body(9, color: MysticColors.cinnabar)),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: MysticColors.hairline),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.icon, size: 20, color: MysticColors.gold),
                  ),
                  const SizedBox(height: 16),
                  Text(item.title, style: MysticFonts.title(16)),
                  const SizedBox(height: 3),
                  Text(item.en, style: MysticFonts.en(9)),
                  const Spacer(),
                  Row(
                    children: [
                      Container(width: 18, height: 1, color: MysticColors.goldDim),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '立即排盘',
                          style: MysticFonts.body(10, color: MysticColors.goldDim),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
