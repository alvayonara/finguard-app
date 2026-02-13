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
  }) async {
    final created = await repository.create(
      CategoryRequest(
        name: name,
        type: type,
        icon: "category",
        color: "#9E9E9E",
      ),
    );

    categories.add(created);
    notifyListeners();
    return created;
  }
}
