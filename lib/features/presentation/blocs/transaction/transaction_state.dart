part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, success, failure }

final class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final bool isProcessing;
  final String? errorMessage;
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionEntity>? transactions,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) => TransactionState(
    status: status ?? this.status,
    transactions: transactions ?? this.transactions,
    isProcessing: isProcessing ?? this.isProcessing,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
  @override
  List<Object?> get props => [status, transactions, isProcessing, errorMessage];
}
