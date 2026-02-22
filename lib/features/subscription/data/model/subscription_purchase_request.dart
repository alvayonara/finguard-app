class SubscriptionPurchaseRequest {
  final String platform;
  final String productId;
  final String transactionData;

  const SubscriptionPurchaseRequest({
    required this.platform,
    required this.productId,
    required this.transactionData,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'productId': productId,
        'transactionData': transactionData,
      };
}
