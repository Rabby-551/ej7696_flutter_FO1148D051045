import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPException implements Exception {
  final String message;
  final bool cancelled;
  const IAPException(this.message, {this.cancelled = false});

  @override
  String toString() => message;
}

class AppleIAPService {
  static final AppleIAPService _instance = AppleIAPService._internal();
  factory AppleIAPService() => _instance;
  AppleIAPService._internal();

  static const String kSixMonthSubscriptionId = 'six_month_subscriptions';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<PurchaseDetails>? _activePurchaseCompleter;

  bool _initialized = false;
  bool _storeAvailable = false;

  bool get isStoreAvailable => _storeAvailable;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (!Platform.isIOS && !Platform.isMacOS) return;

    _storeAvailable = await _iap.isAvailable();
    if (!_storeAvailable) {
      debugPrint('AppleIAPService: App Store not available.');
      return;
    }

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        debugPrint('AppleIAPService: purchaseStream error: $error');
        _completeWithError(IAPException(error.toString()));
      },
    );

    debugPrint('AppleIAPService: initialized, store available=$_storeAvailable');
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      _processPurchase(purchase);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    debugPrint(
      'AppleIAPService: purchase update '
      'productId=${purchase.productID} status=${purchase.status}',
    );

    switch (purchase.status) {
      case PurchaseStatus.pending:
        // Still processing — nothing to do yet.
        return;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Acknowledge the transaction with Apple.
        await _iap.completePurchase(purchase);
        _completeWithSuccess(purchase);

      case PurchaseStatus.error:
        await _iap.completePurchase(purchase);
        final msg =
            purchase.error?.message ?? 'Purchase failed. Please try again.';
        _completeWithError(IAPException(msg, cancelled: false));

      case PurchaseStatus.canceled:
        _completeWithError(
          const IAPException('Purchase cancelled.', cancelled: true),
        );
    }
  }

  void _completeWithSuccess(PurchaseDetails purchase) {
    if (_activePurchaseCompleter == null ||
        _activePurchaseCompleter!.isCompleted) {
      return;
    }
    _activePurchaseCompleter!.complete(purchase);
    _activePurchaseCompleter = null;
  }

  void _completeWithError(IAPException error) {
    if (_activePurchaseCompleter == null ||
        _activePurchaseCompleter!.isCompleted) {
      return;
    }
    _activePurchaseCompleter!.completeError(error);
    _activePurchaseCompleter = null;
  }

  /// Load the 6-month subscription product from the App Store.
  /// Returns null if unavailable or not found.
  Future<ProductDetails?> loadSubscriptionProduct() async {
    if (!_storeAvailable) {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) return null;
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(
      {kSixMonthSubscriptionId},
    );

    if (response.error != null) {
      debugPrint(
        'AppleIAPService: queryProductDetails error: ${response.error}',
      );
      return null;
    }

    if (response.productDetails.isEmpty) {
      debugPrint(
        'AppleIAPService: no products found for $kSixMonthSubscriptionId',
      );
      return null;
    }

    return response.productDetails.first;
  }

  /// Initiate a purchase for the given [product].
  /// Returns a [PurchaseDetails] when the purchase completes successfully.
  /// Throws [IAPException] on failure or cancellation.
  Future<PurchaseDetails> purchase(ProductDetails product) async {
    if (!_storeAvailable) {
      throw const IAPException(
        'The App Store is not available on this device.',
      );
    }

    if (_activePurchaseCompleter != null &&
        !_activePurchaseCompleter!.isCompleted) {
      throw const IAPException('A purchase is already in progress.');
    }

    _activePurchaseCompleter = Completer<PurchaseDetails>();

    final purchaseParam = PurchaseParam(productDetails: product);
    final bool initiated =
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);

    if (!initiated) {
      _activePurchaseCompleter = null;
      throw const IAPException('Could not start the purchase. Please try again.');
    }

    return _activePurchaseCompleter!.future;
  }

  /// Restore previous purchases. Completed purchases come back through
  /// the purchaseStream as [PurchaseStatus.restored].
  Future<void> restorePurchases() async {
    if (!_storeAvailable) return;
    await _iap.restorePurchases();
  }

  void dispose() {
    _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _initialized = false;
  }
}
