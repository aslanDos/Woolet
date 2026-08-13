import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class DeleteAccount implements UseCase<Unit, DeleteAccountParams> {
  final AccountRepository _repository;

  const DeleteAccount(this._repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteAccountParams params) {
    return _repository.deleteAccount(params.uuid);
  }
}

class DeleteAccountParams extends Equatable {
  final String uuid;

  const DeleteAccountParams({required this.uuid});

  @override
  List<Object?> get props => [uuid];
}
