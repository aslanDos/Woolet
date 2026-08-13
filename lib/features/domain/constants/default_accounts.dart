import 'package:woolet/features/domain/entities/account_entity.dart';

abstract final class DefaultAccounts {
  static List<AccountEntity> create({DateTime? createdAt}) {
    return List.unmodifiable([
      AccountEntity(
        uuid: 'c9062049-9195-491d-99a6-3b0df1321854',
        name: 'Cash',
        sortOrder: 0,
        iconCode: 'wallet',
        currencyCode: 'KZT',
        createdAt: (createdAt ?? DateTime.now()).toUtc(),
        colorValue: 0xFF2563EB,
      ),
    ]);
  }
}
