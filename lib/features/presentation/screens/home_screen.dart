import 'package:flutter/material.dart';
import 'package:woolet/features/presentation/widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: TransactionCard(),
        ),
      ),
    );
  }
}
