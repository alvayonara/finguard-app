import 'package:finguard/core/network/api_client.dart';
import 'package:finguard/features/subscription/data/model/subscription_purchase_request.dart';

class SubscriptionRepository {
  final ApiClient apiClient;

  SubscriptionRepository({required this.apiClient});

  Future<void> purchaseSubscription({
    required String platform,
    required String productId,
    required String transactionData,
  }) async {
    await apiClient.dio.post(
      '/v1/subscription/purchase',
      data: SubscriptionPurchaseRequest(
        platform: platform,
        productId: productId,
        transactionData: transactionData,
      ).toJson(),
    );
  }
}
