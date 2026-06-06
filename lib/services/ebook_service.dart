import '../models/api_response.dart';
import '../models/ebook_store_model.dart';
import '../utils/api_endpoints.dart';
import 'api_service.dart';

class EbookService {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<EbookStoreData>> getEbookStore() {
    return _apiService.get<EbookStoreData>(
      ApiEndpoints.resourceStore,
      fromJson: (json) => EbookStoreData.fromJson(_asMap(json)),
    );
  }

  Future<ApiResponse<List<EbookUpgradeAddOnOption>>> getUpgradeAddOnOptions() {
    return _apiService.get<List<EbookUpgradeAddOnOption>>(
      ApiEndpoints.resourceUpgradeAddonOptions,
      fromJson: (json) {
        if (json is List) {
          return json
              .map((item) => EbookUpgradeAddOnOption.fromJson(_asMap(item)))
              .toList(growable: false);
        }
        return const <EbookUpgradeAddOnOption>[];
      },
    );
  }

  Future<ApiResponse<EbookResourcePreview>> getResourcePreview({
    required String productId,
  }) {
    return _apiService.get<EbookResourcePreview>(
      ApiEndpoints.resourcePreview(productId),
      fromJson: (json) => EbookResourcePreview.fromJson(_asMap(json)),
    );
  }

  // STRIPE_DISABLED: createStripePaymentIntent removed.
  // STRIPE_DISABLED: confirmStripePayment removed.

  Future<ApiResponse<EbookPurchasedContent>> getPurchasedContent({
    required String productId,
  }) {
    return _apiService.get<EbookPurchasedContent>(
      ApiEndpoints.resourcePurchasedContent(productId),
      fromJson: (json) => EbookPurchasedContent.fromJson(_asMap(json)),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}
