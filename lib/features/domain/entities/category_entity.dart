import 'package:equatable/equatable.dart';
import 'package:woolet/core/constants/app_enums.dart';

class CategoryEntity extends Equatable {
  static const int maxNameLength = 48;
  static const Object _unset = Object();

  final String uuid;
  final String name;
  final int sortOrder;
  final String iconCode;
  final DateTime createdAt;
  final CategoryType type;
  final int? colorValue;
  final bool visible;

  const CategoryEntity({
    required this.uuid,
    required this.name,
    this.sortOrder = -1,
    required this.iconCode,
    required this.createdAt,
    required this.type,
    this.colorValue,
    this.visible = true,
  });

  bool get isValid {
    final normalizedName = name.trim();

    return normalizedName.isNotEmpty && normalizedName.length <= maxNameLength;
  }

  CategoryEntity copyWith({
    String? uuid,
    String? name,
    int? sortOrder,
    String? iconCode,
    DateTime? createdAt,
    CategoryType? type,
    Object? colorValue = _unset,
    bool? visible,
  }) {
    return CategoryEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      iconCode: iconCode ?? this.iconCode,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      colorValue: identical(colorValue, _unset)
          ? this.colorValue
          : colorValue as int?,
      visible: visible ?? this.visible,
    );
  }

  @override
  List<Object?> get props => [
    uuid,
    name,
    sortOrder,
    iconCode,
    createdAt,
    type,
    colorValue,
    visible,
  ];
}
