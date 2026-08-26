import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';

abstract interface class BudgetRepository {
  Future<Either<Failure, List<BudgetEntity>>> getBudgets();
  Future<Either<Failure, BudgetEntity>> createBudget(BudgetEntity value);
  Future<Either<Failure, BudgetEntity>> updateBudget(BudgetEntity value);
  Future<Either<Failure, Unit>> deleteBudget(String uuid);
}
