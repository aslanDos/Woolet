import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_overview.dart';
import 'package:woolet/features/presentation/widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountLoadRequested()),
      child: const _HomeContent(),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  String? _selectedAccountUuid;
  bool _allAccountsSelected = false;
  PeriodSelection _period = PeriodSelection.initial();

  void _changePeriod(int direction) {
    if (!_period.canNavigate) return;
    setState(() => _period = _period.shifted(direction));
  }

  Future<void> _openPeriodSelector() async {
    final selected = await context.openBottomSheet<PeriodSelection>(
      child: PeriodsSheet(selected: _period),
    );
    if (selected == null || !mounted) return;
    setState(() => _period = selected);
  }

  void _openAccountSelector() {
    context.openBottomSheet(
      child: AccountsSheet(
        allowAllAccounts: true,
        onAccountTap: (account) {
          setState(() {
            _allAccountsSelected = account == null;
            _selectedAccountUuid = account?.uuid;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocBuilder<AccountBloc, AccountState>(
          builder: (context, state) {
            final visibleAccounts = state.accounts
                .where((account) => account.visible)
                .toList(growable: false);
            final selectedAccount = _allAccountsSelected
                ? null
                : _findSelectedAccount(visibleAccounts);
            final currencies = visibleAccounts
                .map((account) => account.currencyCode)
                .toSet();

            return Column(
              children: [
                AccountOverview(
                  account: selectedAccount,
                  allAccounts: _allAccountsSelected,
                  totalBalanceMinor: visibleAccounts.fold<int>(
                    0,
                    (total, account) => total + account.balanceMinor,
                  ),
                  totalCurrencyCode: currencies.length == 1
                      ? currencies.single
                      : null,
                  period: _period,
                  onAccountTap: _openAccountSelector,
                  onPeriodTap: _openPeriodSelector,
                  onPreviousPeriod: () => _changePeriod(-1),
                  onNextPeriod: () => _changePeriod(1),
                ),
                const SizedBox(height: 16),
                const TransactionCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  AccountEntity? _findSelectedAccount(List<AccountEntity> accounts) {
    if (accounts.isEmpty) return null;

    for (final account in accounts) {
      if (account.uuid == _selectedAccountUuid) return account;
    }

    return accounts.first;
  }
}
