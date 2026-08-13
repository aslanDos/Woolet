part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => const [];
}

final class AccountLoadRequested extends AccountEvent {
  const AccountLoadRequested();
}

final class AccountCreateRequested extends AccountEvent {
  final AccountEntity account;

  const AccountCreateRequested(this.account);

  @override
  List<Object?> get props => [account];
}

final class AccountUpdateRequested extends AccountEvent {
  final AccountEntity account;

  const AccountUpdateRequested(this.account);

  @override
  List<Object?> get props => [account];
}

final class AccountDeleteRequested extends AccountEvent {
  final String uuid;

  const AccountDeleteRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}
