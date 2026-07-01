// lib/features/_stub.dart
// 占位屏幕工具: 给未实现的模块一个能跑的 UI, 等具体模块接入后替换.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StubScreen extends StatelessWidget {
  final String title;
  final String description;
  const StubScreen({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Home'),
              onPressed: () => context.go('/'),
            ),
          ],
        ),
      ),
    );
  }
}
