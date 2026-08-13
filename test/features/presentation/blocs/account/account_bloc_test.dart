import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/data/datasources/account_local_data_source_impl.dart';
import 'package:woolet/features/data/repositories/account_repository_impl.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/usecases/account/account_usecases.dart';
import 'package:woolet/features/presentation/blocs/account/account_bloc.dart';

void main() {
  late AppDatabase database;
  late AccountBloc bloc;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    final repository = AccountRepositoryImpl(
      localDataSource: AccountLocalDataSourceImpl(database: database),
    );

    bloc = AccountBloc(
      getAccounts: GetAccounts(repository),
      createAccount: CreateAccount(repository),
      updateAccount: UpdateAccount(repository),
      deleteAccount: DeleteAccount(repository),
    );
  });

  tearDown(() async {
    await bloc.close();
    await database.close();
  });

  test('loads and applies account CRUD events', () async {
    final loadedState = _nextSuccess(bloc);
    bloc.add(const AccountLoadRequested());
    expect((await loadedState).accounts, isEmpty);

    final account = _account(name: 'Kaspi');
    final createdState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(AccountCreateRequested(account));
    expect((await createdState).accounts, [account]);

    final updatedAccount = account.copyWith(name: 'Kaspi Gold');
    final updatedState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(AccountUpdateRequested(updatedAccount));
    expect((await updatedState).accounts, [updatedAccount]);

    final deletedState = _nextSuccess(bloc, processingMustStart: true);
    bloc.add(AccountDeleteRequested(account.uuid));
    expect((await deletedState).accounts, isEmpty);
  });
}

Future<AccountState> _nextSuccess(
  AccountBloc bloc, {
  bool processingMustStart = false,
}) async {
  if (processingMustStart) {
    await bloc.stream.firstWhere((state) => state.isProcessing);
  }

  return bloc.stream.firstWhere(
    (state) => state.status == AccountStatus.success && !state.isProcessing,
  );
}

AccountEntity _account({required String name}) {
  return AccountEntity(
    uuid: '9e45a15e-564d-4a2d-b67d-a2f9fb50c420',
    name: name,
    sortOrder: 0,
    iconCode: 'wallet',
    createdAt: DateTime.utc(2026),
  );
}
