import 'package:finguard_app/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'model/category_model.dart';
import 'model/category_request.dart';

class DuplicateCategoryException implements Exception {
  final String categoryName;
  DuplicateCategoryException(this.categoryName);

  @override
  String toString() => 'Category "$categoryName" already exists';
}

class CategoryNotFoundException implements Exception {
  @override
  String toString() => 'Category not found or unauthorized';
}

class CategoryRepository {
  final ApiClient apiClient;

  CategoryRepository(this.apiClient);

  Future<List<CategoryModel>> getAll() async {
    final response = await apiClient.dio.get("/v1/categories");
    final List data = response.data;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> create(CategoryRequest request) async {
    try {
      final response = await apiClient.dio.post(
        "/v1/categories",
        data: request.toJson(),
      );
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw DuplicateCategoryException(request.name);
      }
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        throw CategoryNotFoundException();
      }
      throw Exception(_extractMessage(e));
    }
  }

  Future<CategoryModel> update(int id, CategoryRequest request) async {
    try {
      final response = await apiClient.dio.put(
        "/v1/categories/$id",
        data: request.toJson(),
      );
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw DuplicateCategoryException(request.name);
      }
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        throw CategoryNotFoundException();
      }
      throw Exception(_extractMessage(e));
    }
  }

  Future<void> delete(int id) async {
    try {
      await apiClient.dio.delete("/v1/categories/$id");
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 403) {
        throw CategoryNotFoundException();
      }
      throw Exception(_extractMessage(e));
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) {
        return error;
      }
    }
    return e.message ?? 'Category request failed';
  }
}
