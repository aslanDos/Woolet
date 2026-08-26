import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pie_menu/pie_menu.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/screens/budgets_screen.dart';
import 'package:woolet/features/presentation/screens/home_screen.dart';
import 'package:woolet/features/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:woolet/features/presentation/sheets/transaction_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/navbar.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;
  AccountEntity? _homeAccount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
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
    return BlocProvider(
      create: (_) =>
          sl<TransactionBloc>()..add(const TransactionLoadRequested()),
      child: Builder(
        builder: (context) => PieCanvas(
          theme: context.pieTheme,
          child: Scaffold(
            extendBody: true,
            bottomNavigationBar: Navbar(
              activeIndex: _currentIndex,
              onTap: _navigateTo,
              onAddTap: (type) {
                final transactionBloc = context.read<TransactionBloc>();
                context.openBottomSheet(
                  child: BlocProvider.value(
                    value: transactionBloc,
                    child: TransactionFormSheet(
                      initialTransactionType: type,
                      initialAccount: _homeAccount,
                    ),
                  ),
                );
              },
            ),
            body: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                HomeScreen(
                  onAccountSelectionChanged: (account) {
                    _homeAccount = account;
                  },
                ),
                const BudgetsScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
