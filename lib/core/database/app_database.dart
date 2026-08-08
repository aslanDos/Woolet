import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:woolet/core/database/tables/categories.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'woolet'));

  @override
  int get schemaVersion => 1;
}
