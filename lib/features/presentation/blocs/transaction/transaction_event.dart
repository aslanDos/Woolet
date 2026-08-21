part of 'transaction_bloc.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => const [];
}

final class TransactionLoadRequested extends TransactionEvent {
  const TransactionLoadRequested();
}

final class TransactionCreateRequested extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionCreateRequested(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

final class TransactionUpdateRequested extends TransactionEvent {
  final TransactionEntity transaction;
  const TransactionUpdateRequested(this.transaction);
  @override
  List<Object?> get props => [transaction];
}

final class TransactionDeleteRequested extends TransactionEvent {
  final String uuid;
  const TransactionDeleteRequested(this.uuid);
  @override
  List<Object?> get props => [uuid];
}
