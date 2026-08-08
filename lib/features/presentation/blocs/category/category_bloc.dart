import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:woolet/core/usecases/usecase.dart';
import 'package:woolet/features/domain/entities/category_entity.dart';
import 'package:woolet/features/domain/usecases/category/category_usecases.dart';

part 'category_event.dart';
part 'category_state.dart';

EventTransformer<Event> _sequential<Event>() {
  return (events, mapper) => events.asyncExpand(mapper);
}

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories _getCategories;
  final CreateCategory _createCategory;
  final UpdateCategory _updateCategory;
  final DeleteCategory _deleteCategory;

  CategoryBloc({
    required GetCategories getCategories,
    required CreateCategory createCategory,
    required UpdateCategory updateCategory,
    required DeleteCategory deleteCategory,
  }) : _getCategories = getCategories,
       _createCategory = createCategory,
       _updateCategory = updateCategory,
       _deleteCategory = deleteCategory,
       super(const CategoryState()) {
    on<CategoryEvent>(_onEvent, transformer: _sequential());
  }

  Future<void> _onEvent(
    CategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    switch (event) {
      case CategoryLoadRequested():
        return _onLoadRequested(event, emit);
      case CategoryCreateRequested():
        return _onCreateRequested(event, emit);
      case CategoryUpdateRequested():
        return _onUpdateRequested(event, emit);
      case CategoryDeleteRequested():
        return _onDeleteRequested(event, emit);
    }
  }

  Future<void> _onLoadRequested(
    CategoryLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CategoryStatus.loading,
        isProcessing: false,
        clearError: true,
      ),
    );

    final result = await _getCategories(const NoParams());

    result.fold(
      (failure) => emit(_failure(failure.message)),
      (categories) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: _sorted(categories),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onCreateRequested(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _createCategory(
      CreateCategoryParams(category: event.category),
    );

    result.fold(
      (failure) => emit(_failure(failure.message)),
      (category) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: _sorted([...state.categories, category]),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _updateCategory(
      UpdateCategoryParams(category: event.category),
    );

    result.fold((failure) => emit(_failure(failure.message)), (category) {
      final categories = state.categories
          .map((item) => item.uuid == category.uuid ? category : item)
          .toList(growable: false);

      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: _sorted(categories),
          isProcessing: false,
          clearError: true,
        ),
      );
    });
  }

  Future<void> _onDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await _deleteCategory(
      DeleteCategoryParams(uuid: event.uuid),
    );

    result.fold(
      (failure) => emit(_failure(failure.message)),
      (_) => emit(
        state.copyWith(
          status: CategoryStatus.success,
          categories: List.unmodifiable(
            state.categories.where((category) => category.uuid != event.uuid),
          ),
          isProcessing: false,
          clearError: true,
        ),
      ),
    );
  }

  CategoryState _failure(String message) {
    return state.copyWith(
      status: CategoryStatus.failure,
      isProcessing: false,
      errorMessage: message,
    );
  }

  List<CategoryEntity> _sorted(Iterable<CategoryEntity> categories) {
    final sortedCategories = List<CategoryEntity>.of(categories)
      ..sort((first, second) {
        final orderComparison = first.sortOrder.compareTo(second.sortOrder);
        if (orderComparison != 0) return orderComparison;

        return first.name.compareTo(second.name);
      });

    return List.unmodifiable(sortedCategories);
  }
}
