// lib/features/common/coming_soon_screen.dart
// 未实装术数的占位页 (替代 404), 保持玄学主题风格.
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/mystic_theme.dart';

class ComingSoonScreen extends StatelessWidget {
  final String title;
  const ComingSoonScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: MysticColors.hairline),
              ),
              child: const Icon(Icons.hourglass_empty,
                  size: 36, color: MysticColors.gold),
            ),
            const SizedBox(height: 20),
            Text(l10n.comingSoon, style: MysticFonts.title(22)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                l10n.comingSoonBody,
                textAlign: TextAlign.center,
                style: MysticFonts.body(13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
