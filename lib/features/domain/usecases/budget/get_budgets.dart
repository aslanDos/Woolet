import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/repositories/budget_repository.dart';

class GetBudgets implements UseCase<List<BudgetEntity>, NoParams> {
  const GetBudgets(this.repository);
  final BudgetRepository repository;
  @override
  Future<Either<Failure, List<BudgetEntity>>> call(NoParams params) =>
      repository.getBudgets();
}
