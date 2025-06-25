// src/domain/repositories/table_repository.dart
import '../entities/table_info.dart';

abstract class TableRepository {
  Future<List<TableInfo>> getTables();
  // Future<void> updateTableStatus(int tableId, TableStatus status); // Belki ileride
}
