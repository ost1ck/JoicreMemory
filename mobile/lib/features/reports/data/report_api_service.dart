import '../../../core/network/api_client.dart';
import 'user_report.dart';

class ReportApiService {
  const ReportApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<UserReport> getMyReport() async {
    final response = await _apiClient.dio.get('/reports/me');
    return UserReport.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}
