part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => const [];
}

final class CategoryLoadRequested extends CategoryEvent {
  const CategoryLoadRequested();
}

final class CategoryCreateRequested extends CategoryEvent {
  final CategoryEntity category;

  const CategoryCreateRequested(this.category);

  @override
  List<Object?> get props => [category];
}

final class CategoryUpdateRequested extends CategoryEvent {
  final CategoryEntity category;

  const CategoryUpdateRequested(this.category);

  @override
  List<Object?> get props => [category];
}

final class CategoryDeleteRequested extends CategoryEvent {
  final String uuid;

  const CategoryDeleteRequested(this.uuid);

  @override
  List<Object?> get props => [uuid];
}
