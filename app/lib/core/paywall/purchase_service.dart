import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/subscription.dart';

enum PurchaseUpdate {
  purchased,
  restored,
  cancelled,
  error,
  pending,
}

class PurchaseService {
  PurchaseService({InAppPurchase? instance})
      : _iap = instance ?? InAppPurchase.instance;

  final InAppPurchase _iap;

  bool _available = false;
  bool get available => _available;

  final Map<String, ProductDetails> _products = {};
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final _updateController = StreamController<PurchaseUpdate>.broadcast();
  Stream<PurchaseUpdate> get updates => _updateController.stream;

  /// The last successfully purchased [PurchaseDetails], kept so the caller can
  /// call [completePurchase] after syncing with the backend.
  PurchaseDetails? _lastPurchase;
  PurchaseDetails? get lastPurchase => _lastPurchase;

  ProductDetails? productForPlan(SubscriptionPlan plan) {
    return _products[SubscriptionProducts.productIdFromPlan(plan)];
  }

  Future<void> initialize() async {
    _available = await _iap.isAvailable();
    if (!_available) return;

    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription = null,
      onError: (_) => _updateController.add(PurchaseUpdate.error),
    );

    final response = await _iap.queryProductDetails(
      SubscriptionProducts.allIds,
    );
    for (final product in response.productDetails) {
      _products[product.id] = product;
    }
  }

  Future<bool> buyProduct(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
          _lastPurchase = purchase;
          _updateController.add(PurchaseUpdate.purchased);
        case PurchaseStatus.restored:
          _lastPurchase = purchase;
          _updateController.add(PurchaseUpdate.restored);
        case PurchaseStatus.canceled:
          _updateController.add(PurchaseUpdate.cancelled);
        case PurchaseStatus.error:
          _updateController.add(PurchaseUpdate.error);
        case PurchaseStatus.pending:
          _updateController.add(PurchaseUpdate.pending);
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _updateController.close();
  }
}
