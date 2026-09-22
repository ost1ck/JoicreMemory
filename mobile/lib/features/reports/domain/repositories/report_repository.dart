import '../entities/user_report.dart';

abstract interface class ReportRepository {
  Future<UserReport> getMyReport();
}
