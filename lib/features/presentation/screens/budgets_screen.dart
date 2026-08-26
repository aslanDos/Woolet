import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/settings/currency_controller.dart';
import 'package:woolet/core/utils/uuid.dart';
import 'package:woolet/core/utils/date_utils.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';
import 'package:woolet/features/domain/repositories/category_repository.dart';
import 'package:woolet/features/presentation/blocs/budget/budget_bloc.dart';
import 'package:woolet/features/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:woolet/features/presentation/screens/budget_transactions_screen.dart';
import 'package:woolet/features/presentation/sheets/budget_filter_sheet.dart';
import 'package:woolet/features/presentation/sheets/budget_form_sheet.dart';
import 'package:woolet/features/presentation/widgets/budget_card.dart';

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<BudgetBloc>()..add(const BudgetLoadRequested()),
    child: const _BudgetsView(),
  );
}

class _BudgetsView extends StatefulWidget {
  const _BudgetsView();
  @override
  State<_BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<_BudgetsView> {
  List<CategoryEntity> _categories = const [];
  List<AccountEntity> _accounts = const [];
  BudgetFilter _filter = const BudgetFilter();

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    final categories = await sl<CategoryRepository>().getCategories();
    final accounts = await sl<AccountRepository>().getAccounts();
    if (!mounted) return;
    setState(() {
      categories.fold((_) {}, (values) => _categories = values);
      accounts.fold((_) {}, (values) => _accounts = values);
    });
  }

  Future<void> _openForm([BudgetEntity? budget]) async {
    final categoryById = {for (final value in _categories) value.uuid: value};
    final accountById = {for (final value in _accounts) value.uuid: value};
    final initial = budget == null
        ? null
        : BudgetFormData(
            name: budget.name,
            amountMinor: budget.amountMinor,
            categories: budget.categoryUuids
                .map((uuid) => categoryById[uuid])
                .whereType<CategoryEntity>()
                .toList(),
            period: budget.period,
            startDay: budget.startDay,
            iconCode: budget.iconCode,
            colorValue: budget.colorValue,
            account: budget.accountUuid == null
                ? null
                : accountById[budget.accountUuid],
          );
    final result = await context.openBottomSheet<BudgetFormData>(
      child: BudgetFormSheet(initialValue: initial),
    );
    if (result == null || !mounted) return;
    final entity = BudgetEntity(
      uuid: budget?.uuid ?? createUuidV4(),
      name: result.name,
      amountMinor: result.amountMinor,
      categoryUuids: result.categories.map((value) => value.uuid).toList(),
      period: result.period,
      startDay: result.startDay,
      iconCode: result.iconCode,
      colorValue: result.colorValue,
      accountUuid: result.account?.uuid,
      createdAt: budget?.createdAt ?? DateTime.now(),
    );
    context.read<BudgetBloc>().add(
      budget == null
          ? BudgetCreateRequested(entity)
          : BudgetUpdateRequested(entity),
    );
  }

  Future<void> _openFilters() async {
    final selected = await context.openBottomSheet<BudgetFilter>(
      child: BudgetFilterSheet(filter: _filter),
    );
    if (selected == null || !mounted) return;
    setState(() => _filter = selected);
  }

  Future<void> _openTransactions(BudgetItem item) async {
    final transactionBloc = context.read<TransactionBloc>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: transactionBloc,
          child: BudgetTransactionsScreen(
            item: item,
            accounts: _accounts,
            categories: _categories,
            onEditBudget: () => _openForm(item.budget),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocListener<TransactionBloc, TransactionState>(
    listenWhen: (previous, current) =>
        previous.transactions != current.transactions,
    listener: (context, state) => context.read<BudgetBloc>().add(
      BudgetTransactionsChanged(state.transactions),
    ),
    child: Scaffold(
      appBar: AppBar(
        title: Text('Budgets', style: context.t.headlineLarge),
        actionsPadding: const EdgeInsets.only(right: 16),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: Icon(
              LucideIcons.sliders_horizontal,
              color: _filter.isDefault ? null : context.c.primary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(onPressed: _openForm, icon: const Icon(LucideIcons.plus)),
        ],
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            final items = state.items
                .where((item) => _filter.periods.contains(item.budget.period))
                .toList();
            if (state.status == BudgetStatus.loading && state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == BudgetStatus.failure && state.items.isEmpty) {
              return Center(
                child: Text(state.errorMessage ?? 'Could not load budgets'),
              );
            }
            if (state.items.isEmpty) {
              return const Center(child: Text('No budgets yet'));
            }
            if (items.isEmpty) {
              return Center(
                child: Text(
                  'No budgets for selected periods',
                  style: context.t.bodyMedium?.copyWith(
                    color: context.c.outline,
                  ),
                ),
              );
            }
            return _BudgetList(
              items: items,
              categories: _categories,
              accounts: _accounts,
              onTap: _openTransactions,
            );
          },
        ),
      ),
    ),
  );
}

class _BudgetList extends StatelessWidget {
  const _BudgetList({
    required this.items,
    required this.categories,
    required this.accounts,
    required this.onTap,
  });
  final List<BudgetItem> items;
  final List<CategoryEntity> categories;
  final List<AccountEntity> accounts;
  final ValueChanged<BudgetItem> onTap;

  @override
  Widget build(BuildContext context) {
    final expenseCategoryUuids = categories
        .where(
          (category) =>
              category.type == CategoryType.expense && category.visible,
        )
        .map((category) => category.uuid)
        .toSet();
    final accountById = {for (final value in accounts) value.uuid: value};
    final groups = <BudgetPeriodRange, List<BudgetItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.range, () => []).add(item);
    }
    final currency = sl<CurrencyController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      children: [
        for (final entry in groups.entries) ...[
          _BudgetPeriodHeader(
            label: AppDateUtils.formatRange(entry.key.start, entry.key.end),
            onPrevious: () => context.read<BudgetBloc>().add(
              BudgetPeriodShifted(entry.value.first.budget.period, -1),
            ),
            onNext: () => context.read<BudgetBloc>().add(
              BudgetPeriodShifted(entry.value.first.budget.period, 1),
            ),
          ),
          for (final item in entry.value) ...[
            BudgetCard(
              item: item,
              currencySymbol: item.budget.accountUuid == null
                  ? currency.value.symbol
                  : currency.symbolForCode(
                      accountById[item.budget.accountUuid]?.currencyCode ??
                          currency.value.code,
                    ),
              categoryCount:
                  expenseCategoryUuids.isNotEmpty &&
                      item.budget.categoryUuids.length ==
                          expenseCategoryUuids.length &&
                      item.budget.categoryUuids.every(
                        expenseCategoryUuids.contains,
                      )
                  ? null
                  : item.budget.categoryUuids.length,
              onTap: () => onTap(item),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _BudgetPeriodHeader extends StatelessWidget {
  const _BudgetPeriodHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          _PeriodArrow(icon: LucideIcons.chevron_left, onPressed: onPrevious),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.t.titleSmall?.copyWith(
                color: context.c.onSurfaceVariant,
              ),
            ),
          ),
          _PeriodArrow(icon: LucideIcons.chevron_right, onPressed: onNext),
        ],
      ),
    );
  }
}

class _PeriodArrow extends StatelessWidget {
  const _PeriodArrow({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(32),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
      ),
      icon: Icon(icon, size: 16),
    );
  }
}
