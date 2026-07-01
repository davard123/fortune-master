// lib/features/community/community_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../_stub.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.menuCommunity,
      description: 'Share your reading · Comment · Like · (举报机制接入)',
    );
    // TODO(Week 7): posts + post_reactions + 举报入口
  }
}
