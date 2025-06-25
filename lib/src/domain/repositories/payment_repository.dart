// src/domain/repositories/table_repository.dart

import 'package:gotpos/src/domain/entities/product.dart';

abstract class PaymentRepository {
  Future<String> createOrder(String branchId, price);
  Future<String> createOrderBulk(String branchId, List<Product> products);
  Future<bool> processPayment(
    String deviceId,
    String orderId,
    String paymentMethod,
    double amount,
  );
}
