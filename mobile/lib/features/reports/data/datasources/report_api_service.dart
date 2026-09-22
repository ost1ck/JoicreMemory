import '../models/user_report_mapper.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/user_report.dart';

class ReportApiService {
  const ReportApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserReport> getMyReport() async {
    final response = await _apiClient.dio.get('/reports/me');
    return UserReportMapper.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
