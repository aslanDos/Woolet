import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/budget_entity.dart';
import 'package:woolet/features/domain/repositories/budget_repository.dart';

class UpdateBudget implements UseCase<BudgetEntity, UpdateBudgetParams> {
  const UpdateBudget(this.repository);
  final BudgetRepository repository;
  @override
  Future<Either<Failure, BudgetEntity>> call(UpdateBudgetParams params) =>
      repository.updateBudget(params.budget);
}

class UpdateBudgetParams extends Equatable {
  const UpdateBudgetParams(this.budget);
  final BudgetEntity budget;
  @override
  List<Object?> get props => [budget];
}
