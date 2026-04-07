import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_constants.dart';

class PatientService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> createPatient(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.patients,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to create patient',
      };
    }
  }

  Future<Map<String, dynamic>> getPatients(int doctorId, {int page = 1, int limit = 10}) async {
    try {
      int offset = (page - 1) * limit;
      print('DEBUG: [PatientService] Calling ${ApiConstants.patients} with doctorid=$doctorId');
      final response = await _dio.get(
        ApiConstants.patients,
        queryParameters: {
          'doctorid': doctorId,
          'page': page,
          'limit': limit,
          'offset': offset,
        },
      );
      print('DEBUG: [PatientService] SUCCESS: ${response.data['data']?.length ?? 0} patients found');
      return response.data;
    } on DioException catch (e) {
      print('DEBUG: [PatientService] ERROR: ${e.response?.data}');
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to fetch patients',
      };
    }
  }
}
