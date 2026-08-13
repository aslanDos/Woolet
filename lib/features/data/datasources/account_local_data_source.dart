import 'package:woolet/features/data/models/account_model.dart';

abstract interface class AccountLocalDataSource {
  Future<List<AccountModel>> getAccounts();

  Future<AccountModel?> getAccountById(String uuid);

  Future<AccountModel> createAccount(AccountModel account);

  Future<void> createAccounts(List<AccountModel> accounts);

  Future<AccountModel?> updateAccount(AccountModel account);

  Future<void> deleteAccount(String uuid);
}
