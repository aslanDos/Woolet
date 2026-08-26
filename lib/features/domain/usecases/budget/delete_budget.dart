import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/budget_repository.dart';

class DeleteBudget implements UseCase<Unit, DeleteBudgetParams> {
  const DeleteBudget(this.repository);
  final BudgetRepository repository;
  @override
  Future<Either<Failure, Unit>> call(DeleteBudgetParams params) =>
      repository.deleteBudget(params.uuid);
}

class DeleteBudgetParams extends Equatable {
  const DeleteBudgetParams(this.uuid);
  final String uuid;
  @override
  List<Object?> get props => [uuid];
}
