// src/data/repositories/in_memory_table_repository.dart
import 'dart:async';

import 'package:gotpos/src/core/utils/app_constants.dart';
import 'package:gotpos/src/domain/entities/product.dart';
import 'package:gotpos/src/domain/repositories/payment_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class InMemoryPaymentRepository implements PaymentRepository {
  // InMemoryTableRepository() {}

  @override
  Future<bool> processPayment(
    String deviceId,
    String orderId,
    String paymentMethod,
    double amount,
  ) async {
    const url = 'http://34.40.120.88:8083/api/v1/payments/process';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'device_id': deviceId,
          'order_id': orderId,
          'payment_method': paymentMethod,
          'device_type': 'POS',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Ödeme işlemi başarılı
      } else {
        print('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchTables hatası: $e');
    }
    return false; // Ödeme işlemi başarılı
  }

  @override
  Future<String> createOrder(String branchId, price) async {
    const url = 'http://34.40.120.88:8080/api/v1/orders';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'branch_id': branchId,
          'items': [
            {
              'price': price, // Ödeme tutarını buraya ekliyoruz
              'quantity': 1, // Örnek olarak 1 adet ürün ekliyoruz
              'product_id':
                  'ce9d5c9b-1933-4c8e-a18d-81c52efe77c0', // Örnek ürün ID'si
            },
          ],
          // Diğer gerekli alanları buraya ekleyebilirsiniz
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final orderId = jsonResponse['data']['id'];
        print('Order created with ID: $orderId');
        return Future.value(
          orderId as String?,
        ); // Order ID'yi Long olarak döndürüyoruz
      } else {
        print('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchTables hatası: $e');
    }
    return Future.value(
      1234567890 as String?,
    ); // Örnek olarak sabit bir Long değer döndürüyoruz
  }

  @override
  Future<String> createOrderBulk(
    String branchId,
    List<Product> products,
  ) async {
    const url = 'http://34.40.120.88:8080/api/v1/orders';
    try {
      final response = await http.post(
        Uri.parse(AppConstants.createOrderUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'branch_id': branchId,
          'items':
              products.map((product) {
                return {
                  'price': product.price,
                  'quantity': product.quantity,
                  'product_id': product.id,
                };
              }).toList(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final orderId = jsonResponse['data']['id'];
        print('Order created with ID: $orderId');
        return Future.value(
          orderId as String?,
        ); // Order ID'yi Long olarak döndürüyoruz
      } else {
        print('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchTables hatası: $e');
    }
    return Future.value(
      '' as String?,
    ); // Örnek olarak sabit bir Long değer döndürüyoruz
  }
}
