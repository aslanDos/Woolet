import 'package:drift/drift.dart';
import 'package:woolet/core/database/tables/accounts.dart';
import 'package:woolet/core/database/tables/categories.dart';

@DataClassName('TransactionRow')
class Transactions extends Table {
  TextColumn get uuid => text()();
  TextColumn get type => text()();
  IntColumn get amountMinor => integer()();
  @ReferenceName('sourceTransactions')
  TextColumn get accountUuid => text().references(Accounts, #uuid)();

  @ReferenceName('destinationTransactions')
  TextColumn get toAccountUuid =>
      text().nullable().references(Accounts, #uuid)();
  TextColumn get categoryUuid =>
      text().nullable().references(Categories, #uuid)();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get occurredAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}
