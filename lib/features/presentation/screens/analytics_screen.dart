import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics', style: context.t.headlineLarge),
        centerTitle: false,
      ),
      body: const SafeArea(top: false, child: Center(child: Text('Analytics'))),
    );
  }
}
