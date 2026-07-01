// lib/features/paywall/paywall_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../_stub.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return StubScreen(
      title: l10n.actionSubscribe,
      description: '${l10n.subscribeMonthly}\n${l10n.subscribeYearly}',
    );
    // TODO(Week 6): RevenueCat offerings (iOS/Android) + Stripe checkout (Web)
  }
}
