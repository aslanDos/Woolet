import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/transaction_entity.dart';
import 'package:woolet/features/domain/usecases/transaction/transaction_usecases.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionBloc({
    required GetTransactions getTransactions,
    required CreateTransaction createTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  }) : _getTransactions = getTransactions,
       _createTransaction = createTransaction,
       _updateTransaction = updateTransaction,
       _deleteTransaction = deleteTransaction,
       super(const TransactionState()) {
    on<TransactionLoadRequested>(_load);
    on<TransactionCreateRequested>(_create);
    on<TransactionUpdateRequested>(_update);
    on<TransactionDeleteRequested>(_delete);
  }

  Future<void> _load(
    TransactionLoadRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, clearError: true));
    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (values) => emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: _sorted(values),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _create(
    TransactionCreateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _createTransaction(
      CreateTransactionParams(event.transaction),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (value) => emit(
        state.copyWith(
          status: TransactionStatus.success,
          isProcessing: false,
          transactions: _sorted([...state.transactions, value]),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _update(
    TransactionUpdateRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _updateTransaction(
      UpdateTransactionParams(event.transaction),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (value) => emit(
        state.copyWith(
          status: TransactionStatus.success,
          isProcessing: false,
          transactions: _sorted(
            state.transactions.map(
              (item) => item.uuid == value.uuid ? value : item,
            ),
          ),
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _delete(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));
    final result = await _deleteTransaction(
      DeleteTransactionParams(event.uuid),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionStatus.failure,
          isProcessing: false,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: TransactionStatus.success,
          isProcessing: false,
          transactions: state.transactions
              .where((item) => item.uuid != event.uuid)
              .toList(),
          clearError: true,
        ),
      ),
    );
  }

  List<TransactionEntity> _sorted(Iterable<TransactionEntity> values) {
    final result = List<TransactionEntity>.of(values)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return List.unmodifiable(result);
  }
}
