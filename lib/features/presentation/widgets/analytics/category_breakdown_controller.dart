import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:woolet/core/constants/app_enums.dart';
import 'package:woolet/core/constants/app_icons.dart';
import 'package:woolet/features/domain/entities/analytics_entity.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';

class CategorySegment {
  const CategorySegment({
    required this.id,
    required this.name,
    required this.amountMinor,
    required this.color,
    required this.icon,
  });

  final String id;
  final String name;
  final int amountMinor;
  final Color color;
  final IconData icon;
}

class CategoryBreakdownController extends ChangeNotifier {
  CategoryBreakdownController({
    required List<AnalyticsCategoryTotal> incomeValues,
    required List<AnalyticsCategoryTotal> expenseValues,
    required List<CategoryEntity> categories,
    required int incomeTotalMinor,
    required int expenseTotalMinor,
  }) : _incomeValues = incomeValues,
       _expenseValues = expenseValues,
       _categories = categories,
       _incomeTotalMinor = incomeTotalMinor,
       _expenseTotalMinor = expenseTotalMinor,
       selectedType = expenseValues.isNotEmpty
           ? TransactionType.expense
           : TransactionType.income;

  static const _fallbackColors = [
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
  ];

  List<AnalyticsCategoryTotal> _incomeValues;
  List<AnalyticsCategoryTotal> _expenseValues;
  List<CategoryEntity> _categories;
  int _incomeTotalMinor;
  int _expenseTotalMinor;
  final Set<String> _selectedCategoryIds = {};
  bool _showAllCategories = true;
  String? _focusedSegmentId;

  TransactionType selectedType;

  List<AnalyticsCategoryTotal> get _values =>
      selectedType == TransactionType.income ? _incomeValues : _expenseValues;

  int get totalMinor => selectedType == TransactionType.income
      ? _incomeTotalMinor
      : _expenseTotalMinor;

  String get typeLabel =>
      selectedType == TransactionType.income ? 'Incomes' : 'Expenses';

  List<CategorySegment> get segments {
    final values = _values.where((value) => value.amountMinor > 0).toList()
      ..sort((a, b) => b.amountMinor.compareTo(a.amountMinor));
    return [
      for (var index = 0; index < values.length; index++)
        _toSegment(values[index], index),
    ];
  }

  Set<String> get _availableIds =>
      segments.map((segment) => segment.id).toSet();

  Set<String> get selectedCategoryIds =>
      _selectedCategoryIds.intersection(_availableIds);

  bool get allCategoriesSelected {
    final available = _availableIds;
    final selected = _selectedCategoryIds.intersection(available);
    return _showAllCategories ||
        (available.isNotEmpty && selected.length == available.length);
  }

  List<CategorySegment> get chartSegments {
    final values = segments;
    if (allCategoriesSelected) return values;
    final selected = selectedCategoryIds;
    return values
        .where((segment) => selected.contains(segment.id))
        .toList(growable: false);
  }

  int get chartTotalMinor =>
      chartSegments.fold<int>(0, (sum, segment) => sum + segment.amountMinor);

  CategorySegment? get focusedSegment {
    final id = _focusedSegmentId;
    if (id == null) return null;
    for (final segment in chartSegments) {
      if (segment.id == id) return segment;
    }
    return null;
  }

  bool isCategorySelected(String id) =>
      allCategoriesSelected || selectedCategoryIds.contains(id);

  bool isSegmentFocused(String id) => _focusedSegmentId == id;

  void update({
    required List<AnalyticsCategoryTotal> incomeValues,
    required List<AnalyticsCategoryTotal> expenseValues,
    required List<CategoryEntity> categories,
    required int incomeTotalMinor,
    required int expenseTotalMinor,
  }) {
    _incomeValues = incomeValues;
    _expenseValues = expenseValues;
    _categories = categories;
    _incomeTotalMinor = incomeTotalMinor;
    _expenseTotalMinor = expenseTotalMinor;
  }

  void selectType(TransactionType value) {
    if (selectedType == value) return;
    selectedType = value;
    _selectedCategoryIds.clear();
    _showAllCategories = true;
    _focusedSegmentId = null;
    notifyListeners();
  }

  void selectAll() {
    _selectedCategoryIds.clear();
    _showAllCategories = true;
    _focusedSegmentId = null;
    notifyListeners();
  }

  void toggleCategory(String id) {
    final available = _availableIds;
    _focusedSegmentId = null;
    if (_showAllCategories) {
      _selectedCategoryIds
        ..clear()
        ..addAll(available)
        ..remove(id);
      _showAllCategories = false;
      notifyListeners();
      return;
    }

    if (_selectedCategoryIds.contains(id)) {
      if (_selectedCategoryIds.length == 1) {
        notifyListeners();
        return;
      }
      _selectedCategoryIds.remove(id);
    } else {
      _selectedCategoryIds.add(id);
    }
    if (_selectedCategoryIds.containsAll(available)) {
      _selectedCategoryIds.clear();
      _showAllCategories = true;
    }
    notifyListeners();
  }

  void focusSegmentAt(int? index) {
    final values = chartSegments;
    _focusedSegmentId = index == null || index < 0 || index >= values.length
        ? null
        : values[index].id;
    notifyListeners();
  }

  CategorySegment _toSegment(AnalyticsCategoryTotal value, int index) {
    final category = _category(value.categoryUuid);
    return CategorySegment(
      id: value.categoryUuid ?? '__uncategorized__',
      name: category?.name ?? 'Uncategorized',
      amountMinor: value.amountMinor,
      color: category?.colorValue == null
          ? _fallbackColors[index % _fallbackColors.length]
          : Color(category!.colorValue!),
      icon: category == null
          ? LucideIcons.tags
          : AppIcon.fromCode(category.iconCode).icon,
    );
  }

  CategoryEntity? _category(String? uuid) {
    for (final category in _categories) {
      if (category.uuid == uuid) return category;
    }
    return null;
  }
}
