import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:woolet/core/di/service_locator.dart';
import 'package:woolet/core/extensions/pop_up_x.dart';
import 'package:woolet/core/extensions/theme_x.dart';
import 'package:woolet/core/extensions/localization_x.dart';
import 'package:woolet/core/settings/app_settings_controller.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';
import 'package:woolet/features/presentation/blocs/analytics/analytics_bloc.dart';
import 'package:woolet/features/presentation/blocs/category/category_bloc.dart';
import 'package:woolet/features/presentation/sheets/accounts_sheet.dart';
import 'package:woolet/features/presentation/sheets/periods_sheet.dart';
import 'package:woolet/features/presentation/widgets/account_selector.dart';
import 'package:woolet/features/presentation/widgets/analytics/category_breakdown.dart';
import 'package:woolet/features/presentation/widgets/analytics/income_expenses_chart.dart';
import 'package:woolet/features/presentation/widgets/period_selector.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<AnalyticsBloc>()),
      BlocProvider(
        create: (_) => sl<AccountBloc>()..add(const AccountLoadRequested()),
      ),
      BlocProvider(
        create: (_) => sl<CategoryBloc>()..add(const CategoryLoadRequested()),
      ),
    ],
    child: const _AnalyticsView(),
  );
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  late PeriodSelection _period;
  AccountEntity? _account;

  @override
  void initState() {
    super.initState();
    _period = PeriodSelection.forType(
      sl<AppSettingsController>().value.analyticsPeriod,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final range = _periodRange(_period);
    context.read<AnalyticsBloc>().add(
      AnalyticsLoadRequested(
        AnalyticsQuery(
          start: range.$1,
          endExclusive: range.$2,
          accountUuid: _account?.uuid,
        ),
      ),
    );
  }

  Future<void> _openAccounts() async {
    await context.openBottomSheet(
      child: AccountsSheet(
        allowAllAccounts: true,
        onAccountTap: (account) {
          setState(() => _account = account);
          Navigator.pop(context);
          _load();
        },
      ),
    );
  }

  Future<void> _openPeriods() async {
    final selected = await context.openBottomSheet<PeriodSelection>(
      child: PeriodsSheet(selected: _period),
    );
    if (selected == null || !mounted) return;
    setState(() => _period = selected);
    _load();
  }

  void _shiftPeriod(int direction) {
    setState(() => _period = _period.shifted(direction));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.chevron_left),
        ),
        title: Text(context.l10n.analytics, style: context.t.headlineMedium),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state.status == AnalyticsStatus.initial ||
                (state.status == AnalyticsStatus.loading &&
                    state.analytics == const AnalyticsEntity.empty())) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == AnalyticsStatus.failure) {
              return Center(
                child: Text(state.errorMessage ?? context.l10n.loadFailed),
              );
            }
            return _buildContent(context, state.analytics);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsEntity analytics) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AccountSelector(
              account: _account,
              allAccounts: _account == null,
              background: true,
              onTap: _openAccounts,
            ),
            const SizedBox(width: 12),
            PeriodSelector(
              period: _period,
              onTap: _openPeriods,
              onPrevious: () => _shiftPeriod(-1),
              onNext: () => _shiftPeriod(1),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_period.type != PeriodType.allTime)
          IncomeExpensesChart(
            income: analytics.incomeTrend,
            expenses: analytics.spendingTrend,
            period: _period,
          ),
        if (analytics.categoryTotals.isNotEmpty ||
            analytics.incomeCategoryTotals.isNotEmpty) ...[
          const SizedBox(height: 12),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) => CategoryBreakdown(
              incomeValues: analytics.incomeCategoryTotals,
              expenseValues: analytics.categoryTotals,
              categories: state.categories,
              incomeTotalMinor: analytics.incomeMinor,
              expenseTotalMinor: analytics.expenseMinor,
              symbol: null,
            ),
          ),
        ],
      ],
    );
  }

  (DateTime?, DateTime?) _periodRange(PeriodSelection period) {
    final now = DateTime.now();
    switch (period.type) {
      case PeriodType.day:
        final start = DateTime(
          period.anchor.year,
          period.anchor.month,
          period.anchor.day,
        );
        return (start, start.add(const Duration(days: 1)));
      case PeriodType.week:
        final day = DateTime(
          period.anchor.year,
          period.anchor.month,
          period.anchor.day,
        );
        final start = sl<AppSettingsController>().value.weekStart.startOfWeek(
          day,
        );
        return (start, start.add(const Duration(days: 7)));
      case PeriodType.month:
        return (
          DateTime(period.anchor.year, period.anchor.month),
          DateTime(period.anchor.year, period.anchor.month + 1),
        );
      case PeriodType.year:
        return (DateTime(period.anchor.year), DateTime(period.anchor.year + 1));
      case PeriodType.lastWeek:
        final day = DateTime(now.year, now.month, now.day);
        final thisWeek = sl<AppSettingsController>().value.weekStart
            .startOfWeek(day);
        return (thisWeek.subtract(const Duration(days: 7)), thisWeek);
      case PeriodType.lastMonth:
        return (
          DateTime(now.year, now.month - 1),
          DateTime(now.year, now.month),
        );
      case PeriodType.allTime:
        return (null, null);
      case PeriodType.custom:
        return (period.start, period.end?.add(const Duration(days: 1)));
    }
  }
}
