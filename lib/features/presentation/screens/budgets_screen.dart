import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budgets', style: context.t.headlineLarge),
        centerTitle: false,
      ),
      body: const SafeArea(top: false, child: Center(child: Text('Budgets'))),
    );
  }
}
