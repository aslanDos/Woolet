import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';
import 'package:woolet/features/presentation/sheets/transaction_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_overview.dart';
import 'package:woolet/features/presentation/widgets/transaction_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onAccountSelectionChanged});

  final ValueChanged<AccountEntity?>? onAccountSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<AccountBloc>()..add(const AccountLoadRequested()),
        ),
        BlocProvider(
          create: (_) => sl<CategoryBloc>()..add(const CategoryLoadRequested()),
        ),
      ],
      child: _HomeContent(onAccountSelectionChanged: onAccountSelectionChanged),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent({this.onAccountSelectionChanged});

  final ValueChanged<AccountEntity?>? onAccountSelectionChanged;
  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String? _selectedAccountUuid;
  bool _allAccountsSelected = true;
  PeriodSelection _period = PeriodSelection.initial();

  void _changePeriod(int direction) {
    if (_period.canNavigate) {
      setState(() => _period = _period.shifted(direction));
    }
  }

  Future<void> _openPeriodSelector() async {
    final selected = await context.openBottomSheet<PeriodSelection>(
      child: PeriodsSheet(selected: _period),
    );
    if (selected != null && mounted) setState(() => _period = selected);
  }

  Future<void> _openAccountSelector() async {
    final bloc = context.read<AccountBloc>();
    await context.openBottomSheet(
      child: AccountsSheet(
        allowAllAccounts: true,
        onAccountTap: (account) {
          setState(() {
            _allAccountsSelected = account == null;
            _selectedAccountUuid = account?.uuid;
          });
          widget.onAccountSelectionChanged?.call(account);
          Navigator.pop(context);
        },
      ),
    );
    if (mounted) bloc.add(const AccountLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (previous, current) =>
          previous.transactions != current.transactions,
      listener: (context, state) {
        context.read<AccountBloc>().add(const AccountLoadRequested());
        context.read<CategoryBloc>().add(const CategoryLoadRequested());
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<AccountBloc, AccountState>(
            builder: (context, accountState) {
              final accounts = accountState.accounts
                  .where((a) => a.visible)
                  .toList();
              final selectedAccount = _allAccountsSelected
                  ? null
                  : _findAccount(accounts, _selectedAccountUuid) ??
                        (accounts.isEmpty ? null : accounts.first);
              final currencies = accounts.map((a) => a.currencyCode).toSet();
              final currency = sl<CurrencyController>();
              final overviewTransactions = context
                  .watch<TransactionBloc>()
                  .state
                  .transactions
                  .where(
                    (value) =>
                        (_allAccountsSelected ||
                            value.accountUuid == selectedAccount?.uuid ||
                            value.toAccountUuid == selectedAccount?.uuid) &&
                        _inPeriod(value.occurredAt),
                  );
              final incomeMinor = overviewTransactions
                  .where((value) => value.type == TransactionType.income)
                  .fold<int>(0, (sum, value) => sum + value.amountMinor);
              final expenseMinor = overviewTransactions
                  .where((value) => value.type == TransactionType.expense)
                  .fold<int>(0, (sum, value) => sum + value.amountMinor);
              return Column(
                children: [
                  AccountOverview(
                    account: selectedAccount,
                    currencySymbol: selectedAccount == null
                        ? currency.value.symbol
                        : currency.symbolForCode(selectedAccount.currencyCode),
                    allAccounts: _allAccountsSelected,
                    totalBalanceMinor: accounts.fold<int>(
                      0,
                      (sum, value) => sum + value.balanceMinor,
                    ),
                    totalCurrencySymbol: currencies.length == 1
                        ? currency.symbolForCode(currencies.single)
                        : null,
                    incomeMinor: incomeMinor,
                    expenseMinor: expenseMinor,
                    period: _period,
                    onAccountTap: _openAccountSelector,
                    onPeriodTap: _openPeriodSelector,
                    onPreviousPeriod: () => _changePeriod(-1),
                    onNextPeriod: () => _changePeriod(1),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, categoryState) =>
                          BlocBuilder<TransactionBloc, TransactionState>(
                            builder: (context, transactionState) {
                              final values = transactionState.transactions
                                  .where(
                                    (value) =>
                                        (_allAccountsSelected ||
                                            value.accountUuid ==
                                                selectedAccount?.uuid ||
                                            value.toAccountUuid ==
                                                selectedAccount?.uuid) &&
                                        _inPeriod(value.occurredAt),
                                  )
                                  .toList();
                              if (transactionState.status ==
                                      TransactionStatus.loading &&
                                  values.isEmpty) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (values.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No transactions for this period',
                                    style: context.t.bodyMedium?.copyWith(
                                      color: context.c.outline,
                                    ),
                                  ),
                                );
                              }
                              return _transactionList(
                                values,
                                accounts,
                                categoryState.categories,
                                currency,
                                selectedAccount,
                              );
                            },
                          ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _transactionList(
    List<TransactionEntity> values,
    List<AccountEntity> accounts,
    List<CategoryEntity> categories,
    CurrencyController currency,
    AccountEntity? selectedAccount,
  ) {
    final widgets = <Widget>[];
    DateTime? lastDay;
    for (final value in values) {
      final day = DateTime(
        value.occurredAt.year,
        value.occurredAt.month,
        value.occurredAt.day,
      );
      if (lastDay != day) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 20));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(_weekdays[day.weekday - 1], style: context.t.titleLarge),
                const SizedBox(width: 8),
                Text(
                  MaterialLocalizations.of(context).formatShortMonthDay(day),
                  style: context.t.bodyMedium?.copyWith(
                    color: context.c.outline,
                  ),
                ),
              ],
            ),
          ),
        );
        lastDay = day;
      }
      final account = _findAccount(accounts, value.accountUuid);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TransactionCard(
            transaction: value,
            account: account,
            toAccount: _findAccount(accounts, value.toAccountUuid),
            category: _findCategory(categories, value.categoryUuid),
            currencyController: currency,
            onTap: () async {
              final transactionBloc = context.read<TransactionBloc>();
              final categoryBloc = context.read<CategoryBloc>();
              await context.openBottomSheet(
                child: BlocProvider.value(
                  value: transactionBloc,
                  child: TransactionFormSheet(
                    transaction: value,
                    initialAccount: account,
                  ),
                ),
              );
              if (mounted) {
                categoryBloc.add(const CategoryLoadRequested());
              }
            },
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: widgets,
    );
  }

  AccountEntity? _findAccount(List<AccountEntity> values, String? uuid) {
    for (final value in values) {
      if (value.uuid == uuid) return value;
    }
    return null;
  }

  CategoryEntity? _findCategory(List<CategoryEntity> values, String? uuid) {
    for (final value in values) {
      if (value.uuid == uuid) return value;
    }
    return null;
  }

  bool _inPeriod(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    DateTime start;
    DateTime end;
    switch (_period.type) {
      case PeriodType.day:
        start = _period.anchor;
        end = start;
      case PeriodType.week:
        start = _period.anchor.subtract(
          Duration(days: _period.anchor.weekday - 1),
        );
        end = start.add(const Duration(days: 6));
      case PeriodType.month:
        start = DateTime(_period.anchor.year, _period.anchor.month);
        end = DateTime(_period.anchor.year, _period.anchor.month + 1, 0);
      case PeriodType.year:
        start = DateTime(_period.anchor.year);
        end = DateTime(_period.anchor.year, 12, 31);
      case PeriodType.lastWeek:
        final thisWeek = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));
        start = thisWeek.subtract(const Duration(days: 7));
        end = start.add(const Duration(days: 6));
      case PeriodType.lastMonth:
        start = DateTime(now.year, now.month - 1);
        end = DateTime(now.year, now.month, 0);
      case PeriodType.allTime:
        return true;
      case PeriodType.custom:
        start = _period.start!;
        end = _period.end!;
    }
    return !day.isBefore(start) && !day.isAfter(end);
  }
}
