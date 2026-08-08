part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, success, failure }

final class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<CategoryEntity> categories;
  final bool isProcessing;
  final String? errorMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.isProcessing = false,
    this.errorMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryEntity>? categories,
    bool? isProcessing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, isProcessing, errorMessage];
}
