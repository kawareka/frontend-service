// src/data/repositories/in_memory_table_repository.dart
import 'package:gotpos/src/core/utils/app_constants.dart';

import '../../domain/entities/table_info.dart';
import '../../domain/repositories/table_repository.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class InMemoryTableRepository implements TableRepository {
  late List<TableInfo> _tables;

  InMemoryTableRepository() {
    fetchTables(); // Başlangıçta verileri çek
  }

  Future<void> fetchTables() async {
    try {
      final response = await http.get(Uri.parse(AppConstants.fetchTablesUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final List<dynamic> tableList = json['data']['tables'];

        _tables =
            tableList.map((tableJson) {
              return TableInfo(
                id: tableJson['id'],
                name: tableJson['table_name'],
                capacity: tableJson['capacity'],
                status: _parseStatus(tableJson['status']),
              );
            }).toList();
      } else {
        print('Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('fetchTables hatası: $e');
    }
  }

  TableStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'OCCUPIED':
        return TableStatus.occupied;
      case 'AVAILABLE':
      default:
        return TableStatus.empty;
    }
  }

  @override
  Future<List<TableInfo>> getTables() async {
    return List.unmodifiable(_tables);
  }
}
