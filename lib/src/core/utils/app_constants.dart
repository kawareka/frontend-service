// src/core/utils/app_constants.dart
class AppConstants {
  static const String bffUrl = 'localhost:8080';
  static const String orderServiceUrl = 'http://34.40.120.88:8080';
  static const String menuServiceUrl = 'http://34.40.120.88:8082';
  static const String paymentServiceUrl = 'http://34.40.120.88:8083';
  static const String branchId = 'f84f20dc-0d14-400b-a948-0777a2aed3fb';
  static const String menuApiKey = 'menu-service-staging-key-2024';

  static const String categoryUrl =
      '${AppConstants.menuServiceUrl}/api/v1/categories';
  // Diğer sabitler buraya eklenebilir
  static const String fetchProductsUrl =
      '${AppConstants.menuServiceUrl}/api/v1/branches/${AppConstants.branchId}/products?limit=50&offset=0&sort_by=sort_order&sort_order=asc';

  static const String fetchTablesUrl =
      '${AppConstants.orderServiceUrl}/api/v1/tables/branch/${AppConstants.branchId}';

  static const String addProductToBranchUrl =
      '${AppConstants.menuServiceUrl}/api/v1/branches/${AppConstants.branchId}/products';

  static const String addProductUrl =
      '${AppConstants.menuServiceUrl}/api/v1/products';
  static const String createOrderUrl =
      '${AppConstants.orderServiceUrl}/api/v1/orders';
  static const String getAllProductsUrl =
      '${AppConstants.menuServiceUrl}/api/v1/products/all';
}
