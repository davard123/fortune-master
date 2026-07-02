// lib/features/home/home_screen.dart
// 首页: 8 种术数入口
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// 部署站点基址 (Cloudflare Pages). 改域名只需改这里一处.
const String _kSiteBaseUrl = 'https://fortune-master.pages.dev';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final items = [
      _SystemItem('bazi',     l10n.systemBazi,       l10n.systemBaziDesc,     Icons.access_time,     const Color(0xFF6750A4)),
      _SystemItem('tarot',    l10n.systemTarot,      l10n.systemTarotDesc,    Icons.auto_awesome,    const Color(0xFFD0BCFF)),
      _SystemItem('iching',   l10n.systemIching,     l10n.systemIchingDesc,   Icons.balance,         const Color(0xFF4A148C)),
      _SystemItem('ziwei',    l10n.systemZiwei,      l10n.systemZiweiDesc,    Icons.star,            const Color(0xFF1A237E)),
      _SystemItem('meihua',   l10n.systemMeihua,     l10n.systemMeihuaDesc,   Icons.spa,             const Color(0xFF00695C)),
      _SystemItem('qimen',    l10n.systemQimen,      l10n.systemQimenDesc,    Icons.gps_fixed,       const Color(0xFFE65100)),
      _SystemItem('astro',    l10n.systemHoroscope,  l10n.systemHoroscopeDesc,Icons.public,          const Color(0xFF1565C0)),
      _SystemItem('dream',    l10n.systemDream,      l10n.systemDreamDesc,    Icons.nightlight,      const Color(0xFF6A1B9A)),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: l10n.menuProfile,
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.homeScreenTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.homeScreenSubtitle,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.85,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) => _SystemCard(item: items[i]),
            ),
          ),
        ],
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
              const Divider(height: 4),
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
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  Text('·', style: Theme.of(context).textTheme.bodySmall),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () => _openLegal(context, 'terms'),
                    child: Text(l10n.legalTerms,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  Text('·', style: Theme.of(context).textTheme.bodySmall),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                    onPressed: () => _openLegal(context, 'cookies'),
                    child: Text(l10n.legalCookies,
                        style: Theme.of(context).textTheme.bodySmall),
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

class _SystemItem {
  final String route;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  _SystemItem(this.route, this.title, this.desc, this.icon, this.color);
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

class _SystemCard extends StatelessWidget {
  final _SystemItem item;
  const _SystemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/${item.route}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [item.color.withOpacity(0.85), item.color.withOpacity(0.55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(item.icon, size: 32, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
