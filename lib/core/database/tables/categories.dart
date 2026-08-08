import 'package:drift/drift.dart';

@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get uuid => text()();

  TextColumn get name => text().withLength(min: 1, max: 48)();

  IntColumn get sortOrder => integer()();

  TextColumn get iconCode => text()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get type => text()();

  IntColumn get colorValue => integer().nullable()();

  BoolColumn get visible => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {uuid};
}
