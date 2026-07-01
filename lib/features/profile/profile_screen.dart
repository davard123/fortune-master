// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../_stub.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.menuProfile,
      description: 'Birth info · Reading history · Subscription · Settings',
    );
    // TODO(Week 4): 读取 profiles 表 + 免费配额 (free_credits)
  }
}
