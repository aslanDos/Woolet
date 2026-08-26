import 'package:woolet/features/data/models/budget_model.dart';

abstract interface class BudgetLocalDataSource {
  Future<List<BudgetModel>> getBudgets();
  Future<BudgetModel> createBudget(BudgetModel model);
  Future<BudgetModel?> updateBudget(BudgetModel model);
  Future<void> deleteBudget(String uuid);
}
