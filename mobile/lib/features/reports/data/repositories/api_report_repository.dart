import '../../domain/entities/user_report.dart';
import '../../../../core/network/guard_data.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_api_service.dart';

class ApiReportRepository implements ReportRepository {
  const ApiReportRepository(this._remote);
  final ReportApiService _remote;

  @override
  Future<UserReport> getMyReport() => guardData(() => _remote.getMyReport());
}
