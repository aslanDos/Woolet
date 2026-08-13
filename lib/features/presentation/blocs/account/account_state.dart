part of 'account_bloc.dart';

enum AccountStatus { initial, loading, success, failure }

final class AccountState extends Equatable {
  final AccountStatus status;
  final List<AccountEntity> accounts;
  final bool isProcessing;
  final String? errorMessage;

  const AccountState({
    this.status = AccountStatus.initial,
    this.accounts = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  AccountState copyWith({
    AccountStatus? status,
    List<AccountEntity>? accounts,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountState(
      status: status ?? this.status,
      accounts: accounts ?? this.accounts,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, accounts, isProcessing, errorMessage];
}
