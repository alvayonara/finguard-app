import 'package:finguard_app/core/network/api_client.dart';
import 'model/category_model.dart';
import 'model/category_request.dart';

class CategoryRepository {
  final ApiClient apiClient;

  CategoryRepository(this.apiClient);

  Future<List<CategoryModel>> getAll() async {
    final response = await apiClient.dio.get("/v1/categories");
    final List data = response.data;
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> create(CategoryRequest request) async {
    final response = await apiClient.dio.post(
      "/v1/categories",
      data: request.toJson(),
    );
    return CategoryModel.fromJson(response.data);
  }
}
