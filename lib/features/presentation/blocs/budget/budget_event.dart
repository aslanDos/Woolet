part of 'budget_bloc.dart';

sealed class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => const [];
}

final class BudgetLoadRequested extends BudgetEvent {
  const BudgetLoadRequested({this.now});
  final DateTime? now;
  @override
  List<Object?> get props => [now];
}

final class BudgetCreateRequested extends BudgetEvent {
  const BudgetCreateRequested(this.budget);
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}

final class BudgetUpdateRequested extends BudgetEvent {
  const BudgetUpdateRequested(this.budget);
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}

final class BudgetDeleteRequested extends BudgetEvent {
  const BudgetDeleteRequested(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}

final class BudgetTransactionsChanged extends BudgetEvent {
  const BudgetTransactionsChanged(this.transactions, {this.now});
  final List<TransactionEntity> transactions;
  final DateTime? now;

  @override
  List<Object?> get props => [transactions, now];
}

final class BudgetPeriodShifted extends BudgetEvent {
  const BudgetPeriodShifted(this.period, this.direction);

  final BudgetPeriod period;
  final int direction;

  @override
  List<Object?> get props => [period, direction];
}
