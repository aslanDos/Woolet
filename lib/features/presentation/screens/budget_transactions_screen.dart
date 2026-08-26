import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/date_utils.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/presentation/blocs/budget/budget_bloc.dart';
import 'package:woolet/features/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:woolet/features/presentation/sheets/transaction_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/transaction_card.dart';

class BudgetTransactionsScreen extends StatelessWidget {
  const BudgetTransactionsScreen({
    super.key,
    required this.item,
    required this.accounts,
    required this.categories,
    this.onEditBudget,
  });

  final BudgetItem item;
  final List<AccountEntity> accounts;
  final List<CategoryEntity> categories;
  final VoidCallback? onEditBudget;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.budget.name, style: context.t.headlineMedium),
        actionsPadding: const EdgeInsets.only(right: 16),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(LucideIcons.chevron_left),
        ),
        actions: [
          if (onEditBudget != null)
            IconButton(
              onPressed: onEditBudget,
              icon: const Icon(LucideIcons.pencil),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            final transactions =
                state.transactions.where(_belongsToBudget).toList()..sort(
                  (first, second) =>
                      second.occurredAt.compareTo(first.occurredAt),
                );

            if (state.status == TransactionStatus.loading &&
                transactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  'No transactions for this budget period',
                  style: context.t.bodyMedium?.copyWith(
                    color: context.c.outline,
                  ),
                ),
              );
            }

            return _buildTransactionList(context, transactions);
          },
        ),
      ),
    );
  }

  bool _belongsToBudget(TransactionEntity transaction) {
    final budget = item.budget;
    return transaction.type == TransactionType.expense &&
        !transaction.occurredAt.isBefore(item.range.start) &&
        transaction.occurredAt.isBefore(item.range.end) &&
        budget.categoryUuids.contains(transaction.categoryUuid) &&
        (budget.accountUuid == null ||
            budget.accountUuid == transaction.accountUuid);
  }

  Widget _buildTransactionList(
    BuildContext context,
    List<TransactionEntity> transactions,
  ) {
    final widgets = <Widget>[];
    DateTime? lastDay;
    final currency = sl<CurrencyController>();

    for (final transaction in transactions) {
      final day = DateTime(
        transaction.occurredAt.year,
        transaction.occurredAt.month,
        transaction.occurredAt.day,
      );
      if (lastDay != day) {
        if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 20));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(
                  AppDateUtils.weekdayName(day),
                  style: context.t.titleLarge,
                ),
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

      final account = _findAccount(transaction.accountUuid);
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TransactionCard(
            transaction: transaction,
            account: account,
            toAccount: _findAccount(transaction.toAccountUuid),
            category: _findCategory(transaction.categoryUuid),
            currencyController: currency,
            onTap: () => _openTransaction(context, transaction, account),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: widgets,
    );
  }

  Future<void> _openTransaction(
    BuildContext context,
    TransactionEntity transaction,
    AccountEntity? account,
  ) async {
    final transactionBloc = context.read<TransactionBloc>();
    await context.openBottomSheet(
      child: BlocProvider.value(
        value: transactionBloc,
        child: TransactionFormSheet(
          transaction: transaction,
          initialAccount: account,
        ),
      ),
    );
  }

  AccountEntity? _findAccount(String? uuid) {
    for (final account in accounts) {
      if (account.uuid == uuid) return account;
    }
    return null;
  }

  CategoryEntity? _findCategory(String? uuid) {
    for (final category in categories) {
      if (category.uuid == uuid) return category;
    }
    return null;
  }
}
