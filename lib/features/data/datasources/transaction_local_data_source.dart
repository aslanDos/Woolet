import 'package:woolet/features/data/models/transaction_model.dart';

abstract interface class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel> createTransaction(TransactionModel transaction);
  Future<TransactionModel?> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String uuid);
}
