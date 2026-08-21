import 'package:equatable/equatable.dart';
import 'package:woolet/core/constants/app_enums.dart';

class TransactionEntity extends Equatable {
  final String uuid;
  final TransactionType type;
  final int amountMinor;
  final String accountUuid;
  final String? toAccountUuid;
  final String? categoryUuid;
  final String note;
  final DateTime occurredAt;
  final DateTime createdAt;

  const TransactionEntity({
    required this.uuid,
    required this.type,
    required this.amountMinor,
    required this.accountUuid,
    this.toAccountUuid,
    this.categoryUuid,
    this.note = '',
    required this.occurredAt,
    required this.createdAt,
  });

  bool get isValid =>
      amountMinor > 0 &&
      accountUuid.isNotEmpty &&
      (type == TransactionType.transfer
          ? toAccountUuid != null && toAccountUuid != accountUuid
          : categoryUuid != null);

  @override
  List<Object?> get props => [
    uuid,
    type,
    amountMinor,
    accountUuid,
    toAccountUuid,
    categoryUuid,
    note,
    occurredAt,
    createdAt,
  ];
}
