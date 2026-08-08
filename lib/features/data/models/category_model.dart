import 'package:drift/drift.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/database/app_database.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';

class CategoryModel {
  final String uuid;
  final String name;
  final int sortOrder;
  final String iconCode;
  final DateTime createdAt;
  final CategoryType type;
  final int? colorValue;
  final bool visible;

  const CategoryModel({
    required this.uuid,
    required this.name,
    required this.sortOrder,
    required this.iconCode,
    required this.createdAt,
    required this.type,
    required this.colorValue,
    required this.visible,
  });

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      uuid: entity.uuid,
      name: entity.name,
      sortOrder: entity.sortOrder,
      iconCode: entity.iconCode,
      createdAt: entity.createdAt,
      type: entity.type,
      colorValue: entity.colorValue,
      visible: entity.visible,
    );
  }

  factory CategoryModel.fromDrift(CategoryRow row) {
    return CategoryModel(
      uuid: row.uuid,
      name: row.name,
      sortOrder: row.sortOrder,
      iconCode: row.iconCode,
      createdAt: row.createdAt.toUtc(),
      type: CategoryType.values.byName(row.type),
      colorValue: row.colorValue,
      visible: row.visible,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      uuid: uuid,
      name: name,
      sortOrder: sortOrder,
      iconCode: iconCode,
      createdAt: createdAt.toUtc(),
      type: type,
      colorValue: colorValue,
      visible: visible,
    );
  }

  CategoriesCompanion toCompanion() {
    return CategoriesCompanion.insert(
      uuid: uuid,
      name: name,
      sortOrder: sortOrder,
      iconCode: iconCode,
      createdAt: createdAt.toUtc(),
      type: type.name,
      colorValue: Value(colorValue),
      visible: Value(visible),
    );
  }
}
