import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/account_entity.dart';
import 'package:woolet/features/domain/usecases/account/account_usecases.dart';

part 'account_event.dart';
part 'account_state.dart';

EventTransformer<Event> _sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccounts _getAccounts;
  final CreateAccount _createAccount;
  final UpdateAccount _updateAccount;
  final DeleteAccount _deleteAccount;

  AccountBloc({
    required GetAccounts getAccounts,
    required CreateAccount createAccount,
    required UpdateAccount updateAccount,
    required DeleteAccount deleteAccount,
  }) : _getAccounts = getAccounts,
       _createAccount = createAccount,
       _updateAccount = updateAccount,
       _deleteAccount = deleteAccount,
       super(const AccountState()) {
    on<AccountEvent>(_onEvent, transformer: _sequential());
  }

  Future<void> _onEvent(AccountEvent event, Emitter<AccountState> emit) async {
    switch (event) {
      case AccountLoadRequested():
        return _onLoadRequested(event, emit);
      case AccountCreateRequested():
        return _onCreateRequested(event, emit);
      case AccountUpdateRequested():
        return _onUpdateRequested(event, emit);
      case AccountDeleteRequested():
        return _onDeleteRequested(event, emit);
    }
  }

  Future<void> _onLoadRequested(
    AccountLoadRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AccountStatus.loading,
        isProcessing: false,
        clearError: true,
      ),
    );

    final result = await _getAccounts(const NoParams());
    result.fold(
      (failure) => emit(_failure(failure.message)),
      (accounts) => emit(
        state.copyWith(
          status: AccountStatus.success,
          accounts: _sorted(accounts),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCreateRequested(
    AccountCreateRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _createAccount(
      CreateAccountParams(account: event.account),
    );
    result.fold(
      (failure) => emit(_failure(failure.message)),
      (account) => emit(
        state.copyWith(
          status: AccountStatus.success,
          accounts: _sorted([...state.accounts, account]),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateRequested(
    AccountUpdateRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _updateAccount(
      UpdateAccountParams(account: event.account),
    );
    result.fold((failure) => emit(_failure(failure.message)), (account) {
      final accounts = state.accounts
          .map((item) => item.uuid == account.uuid ? account : item)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: AccountStatus.success,
          accounts: _sorted(accounts),
          isProcessing: false,
          clearError: true,
        ),
      );
    });
  }

  Future<void> _onDeleteRequested(
    AccountDeleteRequested event,
    Emitter<AccountState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _deleteAccount(DeleteAccountParams(uuid: event.uuid));
    result.fold(
      (failure) => emit(_failure(failure.message)),
      (_) => emit(
        state.copyWith(
          status: AccountStatus.success,
          accounts: List.unmodifiable(
            state.accounts.where((account) => account.uuid != event.uuid),
          ),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  AccountState _failure(String message) {
    return state.copyWith(
      status: AccountStatus.failure,
      isProcessing: false,
      errorMessage: message,
    );
  }

  List<AccountEntity> _sorted(Iterable<AccountEntity> accounts) {
    final sortedAccounts = List<AccountEntity>.of(accounts)
      ..sort((first, second) {
        final orderComparison = first.sortOrder.compareTo(second.sortOrder);
        if (orderComparison != 0) return orderComparison;

        return first.name.compareTo(second.name);
      });

    return List.unmodifiable(sortedAccounts);
  }
}
