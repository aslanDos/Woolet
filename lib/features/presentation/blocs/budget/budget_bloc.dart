import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/core/utils/date_utils.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/usecases/budget/budget_usecases.dart';
import 'package:woolet/features/domain/usecases/transaction/get_transactions.dart';

part 'budget_event.dart';
part 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  BudgetBloc({
    required GetBudgets getBudgets,
    required CreateBudget createBudget,
    required UpdateBudget updateBudget,
    required DeleteBudget deleteBudget,
    required GetTransactions getTransactions,
  }) : _getBudgets = getBudgets,
       _createBudget = createBudget,
       _updateBudget = updateBudget,
       _deleteBudget = deleteBudget,
       _getTransactions = getTransactions,
       super(const BudgetState()) {
    on<BudgetLoadRequested>(_load);
    on<BudgetCreateRequested>(_create);
    on<BudgetUpdateRequested>(_update);
    on<BudgetDeleteRequested>(_delete);
    on<BudgetTransactionsChanged>(_transactionsChanged);
    on<BudgetPeriodShifted>(_periodShifted);
  }

  final GetBudgets _getBudgets;
  final CreateBudget _createBudget;
  final UpdateBudget _updateBudget;
  final DeleteBudget _deleteBudget;
  final GetTransactions _getTransactions;

  Future<void> _load(
    BudgetLoadRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(status: BudgetStatus.loading, clearError: true));
    final budgetsResult = await _getBudgets(const NoParams());
    final transactionsResult = await _getTransactions(const NoParams());
    budgetsResult.fold(
      (failure) => emit(
        state.copyWith(
          status: BudgetStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (budgets) => transactionsResult.fold(
        (failure) => emit(
          state.copyWith(
            status: BudgetStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (transactions) => emit(
          state.copyWith(
            status: BudgetStatus.success,
            items: _buildItems(
              budgets,
              transactions,
              event.now ?? DateTime.now(),
              state.periodOffsets,
            ),
            transactions: transactions,
            clearError: true,
          ),
        ),
      ),
    );
  }

  Future<void> _create(
    BudgetCreateRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _createBudget(CreateBudgetParams(event.budget));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BudgetStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (value) => emit(
        state.copyWith(
          status: BudgetStatus.success,
          isProcessing: false,
          items: _buildItems(
            [...state.items.map((item) => item.budget), value],
            state.transactions,
            DateTime.now(),
            state.periodOffsets,
          ),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _update(
    BudgetUpdateRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _updateBudget(UpdateBudgetParams(event.budget));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BudgetStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (value) => emit(
        state.copyWith(
          status: BudgetStatus.success,
          isProcessing: false,
          items: _buildItems(
            state.items.map(
              (item) => item.budget.uuid == value.uuid ? value : item.budget,
            ),
            state.transactions,
            DateTime.now(),
            state.periodOffsets,
          ),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _delete(
    BudgetDeleteRequested event,
    Emitter<BudgetState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _deleteBudget(DeleteBudgetParams(event.uuid));
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BudgetStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: BudgetStatus.success,
          isProcessing: false,
          items: state.items
              .where((item) => item.budget.uuid != event.uuid)
              .toList(),
          clearError: true,
        ),
      ),
    );
  }

  void _transactionsChanged(
    BudgetTransactionsChanged event,
    Emitter<BudgetState> emit,
  ) {
    emit(
      state.copyWith(
        items: _buildItems(
          state.items.map((item) => item.budget),
          event.transactions,
          event.now ?? DateTime.now(),
          state.periodOffsets,
        ),
        transactions: event.transactions,
      ),
    );
  }

  void _periodShifted(BudgetPeriodShifted event, Emitter<BudgetState> emit) {
    final offsets = Map<BudgetPeriod, int>.of(state.periodOffsets);
    final next = (offsets[event.period] ?? 0) + event.direction;
    if (next == 0) {
      offsets.remove(event.period);
    } else {
      offsets[event.period] = next;
    }
    emit(
      state.copyWith(
        periodOffsets: Map.unmodifiable(offsets),
        items: _buildItems(
          state.items.map((item) => item.budget),
          state.transactions,
          DateTime.now(),
          offsets,
        ),
      ),
    );
  }

  List<BudgetItem> _buildItems(
    Iterable<BudgetEntity> budgets,
    List<TransactionEntity> transactions,
    DateTime now,
    Map<BudgetPeriod, int> periodOffsets,
  ) {
    final items =
        budgets.map((budget) {
          final range = budget.rangeAt(
            AppDateUtils.shiftBudgetPeriod(
              now,
              budget.period,
              periodOffsets[budget.period] ?? 0,
            ),
          );
          final spent = transactions
              .where(
                (transaction) =>
                    transaction.type == TransactionType.expense &&
                    !transaction.occurredAt.isBefore(range.start) &&
                    transaction.occurredAt.isBefore(range.end) &&
                    budget.categoryUuids.contains(transaction.categoryUuid) &&
                    (budget.accountUuid == null ||
                        budget.accountUuid == transaction.accountUuid),
              )
              .fold<int>(
                0,
                (sum, transaction) => sum + transaction.amountMinor,
              );
          return BudgetItem(budget: budget, spentMinor: spent, range: range);
        }).toList()..sort((a, b) {
          final byPeriod = a.budget.period.index.compareTo(
            b.budget.period.index,
          );
          if (byPeriod != 0) return byPeriod;
          final byEnd = a.range.end.compareTo(b.range.end);
          return byEnd != 0
              ? byEnd
              : a.budget.createdAt.compareTo(b.budget.createdAt);
        });
    return List.unmodifiable(items);
  }
}
