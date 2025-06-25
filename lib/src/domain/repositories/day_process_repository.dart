// src/domain/repositories/day_process_repository.dart
import '../entities/day_process_info.dart';

abstract class DayProcessRepository {
  Future<List<DayProcessInfo>> getDayProcesses();
  Future<void> startDay();
  Future<void> endDay();
  Future<void> addCashToRegister(double amount);
}
