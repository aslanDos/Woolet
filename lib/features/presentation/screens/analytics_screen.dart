import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.chevron_left),
        ),
        title: Text('Analytics', style: context.t.headlineMedium),
        // centerTitle: false,
      ),
      body: const SafeArea(top: false, child: Center(child: Text('Analytics'))),
    );
  }
}
