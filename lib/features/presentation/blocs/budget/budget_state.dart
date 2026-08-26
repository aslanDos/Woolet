part of 'budget_bloc.dart';

enum BudgetStatus { initial, loading, success, failure }

class BudgetItem extends Equatable {
  const BudgetItem({
    required this.budget,
    required this.spentMinor,
    required this.range,
  });
  final BudgetEntity budget;
  final int spentMinor;
  final BudgetPeriodRange range;
  double get progress =>
      budget.amountMinor == 0 ? 0 : spentMinor / budget.amountMinor;
  int get remainingMinor => budget.amountMinor - spentMinor;
  @override
  List<Object?> get props => [budget, spentMinor, range];
}

final class BudgetState extends Equatable {
  const BudgetState({
    this.status = BudgetStatus.initial,
    this.items = const [],
    this.transactions = const [],
    this.periodOffsets = const {},
    this.isProcessing = false,
    this.errorMessage,
  });
  final BudgetStatus status;
  final List<BudgetItem> items;
  final List<TransactionEntity> transactions;
  final Map<BudgetPeriod, int> periodOffsets;
  final bool isProcessing;
  final String? errorMessage;

  BudgetState copyWith({
    BudgetStatus? status,
    List<BudgetItem>? items,
    List<TransactionEntity>? transactions,
    Map<BudgetPeriod, int>? periodOffsets,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) => BudgetState(
    status: status ?? this.status,
    items: items ?? this.items,
    transactions: transactions ?? this.transactions,
    periodOffsets: periodOffsets ?? this.periodOffsets,
    isProcessing: isProcessing ?? this.isProcessing,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    transactions,
    periodOffsets,
    isProcessing,
    errorMessage,
  ];
}
