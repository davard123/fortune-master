// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../_stub.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.actionSignIn,
      description: l10n.i18nInfo,
    );
    // TODO(Week 4): supabase.auth.signInWithOAuth / signInWithPassword
  }
}
