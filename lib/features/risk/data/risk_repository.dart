import 'dart:convert';

import 'package:finguard_app/core/network/api_client.dart';
import 'package:finguard_app/features/risk/data/model/risk_detail_response.dart';
import 'package:finguard_app/features/risk/data/model/risk_trend_item.dart';

class RiskRepository {
  final ApiClient apiClient;
  RiskRepository({required this.apiClient});

  Future<List<RiskTrendItem>> getTrend(int days) async {
    final response = await apiClient.dio.get(
      "/v1/risk/trend",
      queryParameters: {"days": days},
    );
    final Map<String, dynamic> json = response.data;
    final List<dynamic> points = json["points"] ?? [];
    return points.map((e) => RiskTrendItem.fromJson(e)).toList();
  }

  Future<RiskDetailResponse> getDetail() async {
    final response = await apiClient.dio.get("/v1/risk/detail");
    return RiskDetailResponse.fromJson(response.data);
  }
}
