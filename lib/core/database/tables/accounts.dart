import 'package:drift/drift.dart';

@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get uuid => text()();

  TextColumn get name => text().withLength(min: 1, max: 48)();

  IntColumn get sortOrder => integer()();

  TextColumn get iconCode => text()();

  TextColumn get currencyCode => text().withLength(min: 3, max: 3)();

  IntColumn get balanceMinor => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get colorValue => integer().nullable()();

  BoolColumn get visible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}
