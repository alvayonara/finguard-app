import 'package:flutter/material.dart';
import '../data/category_repository.dart';
import '../data/model/category_model.dart';
import '../data/model/category_request.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository repository;

  CategoryViewModel(this.repository);

  List<CategoryModel> categories = [];
  bool isLoading = false;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    categories = await repository.getAll();

    isLoading = false;
    notifyListeners();
  }

  Future<CategoryModel?> createCategory({
    required String name,
    required String type,
    String? icon,
    String? color,
  }) async {
    final created = await repository.create(
      CategoryRequest(
        name: name,
        type: type,
        icon: icon ?? "📁",
        color: color ?? "#9E9E9E",
      ),
    );

    categories.add(created);
    notifyListeners();
    return created;
  }

  Future<CategoryModel> updateCategory({
    required int id,
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final updated = await repository.update(
      id,
      CategoryRequest(
        name: name,
        type: type,
        icon: icon,
        color: color,
      ),
    );

    final index = categories.indexWhere((c) => c.id == id);
    if (index != -1) {
      categories[index] = updated;
      notifyListeners();
    }
    return updated;
  }

  Future<void> deleteCategory(int id) async {
    await repository.delete(id);
    categories.removeWhere((c) => c.id == id);
    notifyListeners();
  }
}
