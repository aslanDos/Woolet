import 'package:dartz/dartz.dart';
import 'package:woolet/core/errors/failures.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/repositories/account_repository.dart';

class SeedDefaultAccounts implements UseCase<Unit, NoParams> {
  final AccountRepository _repository;
  final List<AccountEntity> _defaultAccounts;

  SeedDefaultAccounts(this._repository, List<AccountEntity> defaultAccounts)
    : _defaultAccounts = List.unmodifiable(defaultAccounts);

  @override
  Future<Either<Failure, Unit>> call(NoParams params) async {
    final accountsResult = await _repository.getAccounts();

    return accountsResult.fold(Left.new, (accounts) async {
      if (accounts.isNotEmpty || _defaultAccounts.isEmpty) {
        return const Right(unit);
      }

      return _repository.createAccounts(_defaultAccounts);
    });
  }
}
