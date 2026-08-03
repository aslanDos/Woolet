import 'package:flutter/material.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/presentation/screens/analytics_screen.dart';
import 'package:woolet/features/presentation/screens/budgets_screen.dart';
import 'package:woolet/features/presentation/screens/home_screen.dart';
import 'package:woolet/features/presentation/widgets/navbar.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  static const _titles = ['Transactions', 'Analytics', 'Budgets', 'Settings'];

  late final TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: _currentIndex,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_currentIndex != _tabController.index) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateTo(int index) {
    if (index == _tabController.index) return;
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_titles[_currentIndex], style: context.t.headlineLarge),
        centerTitle: false,
      ),
      bottomNavigationBar: Navbar(
        activeIndex: _currentIndex,
        onTap: _navigateTo,
        onAddTap: () {
          // TODO: Open the create-transaction flow.
        },
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [HomeScreen(), AnalyticsScreen(), BudgetsScreen()],
      ),
    );
  }
}
