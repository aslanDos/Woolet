import 'package:equatable/equatable.dart';

class AccountEntity extends Equatable {
  static const int maxNameLength = 48;
  static const Object _unset = Object();

  final String uuid;
  final String name;
  final int sortOrder;
  final String iconCode;
  final String currencyCode;
  final int balanceMinor;
  final DateTime createdAt;
  final int? colorValue;
  final bool visible;

  const AccountEntity({
    required this.uuid,
    required this.name,
    this.sortOrder = -1,
    required this.iconCode,
    this.currencyCode = 'KZT',
    this.balanceMinor = 0,
    required this.createdAt,
    this.colorValue,
    this.visible = true,
  });

  bool get isValid {
    final normalizedName = name.trim();
    return normalizedName.isNotEmpty &&
        normalizedName.length <= maxNameLength &&
        currencyCode.trim().length == 3;
  }

  AccountEntity copyWith({
    String? uuid,
    String? name,
    int? sortOrder,
    String? iconCode,
    String? currencyCode,
    int? balanceMinor,
    DateTime? createdAt,
    Object? colorValue = _unset,
    bool? visible,
  }) {
    return AccountEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      iconCode: iconCode ?? this.iconCode,
      currencyCode: currencyCode ?? this.currencyCode,
      balanceMinor: balanceMinor ?? this.balanceMinor,
      createdAt: createdAt ?? this.createdAt,
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
    currencyCode,
    balanceMinor,
    createdAt,
    colorValue,
    visible,
  ];
}
