import 'package:woolet/features/data/models/category_model.dart';

abstract interface class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();

  Future<CategoryModel?> getCategoryById(String uuid);

  Future<CategoryModel> createCategory(CategoryModel category);

  Future<void> createCategories(List<CategoryModel> categories);

  Future<CategoryModel?> updateCategory(CategoryModel category);

  Future<void> deleteCategory(String uuid);
}
