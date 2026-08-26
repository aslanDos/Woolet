import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/repositories/budget_repository.dart';

class CreateBudget implements UseCase<BudgetEntity, CreateBudgetParams> {
  const CreateBudget(this.repository);
  final BudgetRepository repository;
  @override
  Future<Either<Failure, BudgetEntity>> call(CreateBudgetParams params) =>
      repository.createBudget(params.budget);
}

class CreateBudgetParams extends Equatable {
  const CreateBudgetParams(this.budget);
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}
