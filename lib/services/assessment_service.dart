import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_constants.dart';
import 'dart:io';

class AssessmentService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> analyzeFace(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.analyze,
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['error'] ?? 'No face detected or analysis failed',
      };
    }
  }

  Future<Map<String, dynamic>> saveAssessment(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        ApiConstants.saveAssessment,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to save assessment',
      };
    }
  }

  Future<Map<String, dynamic>> updateAssessment(int assessmentId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.saveAssessment}/$assessmentId',
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to update assessment',
      };
    }
  }

  Future<Map<String, dynamic>> getAssessments({int? doctorId, int? patientId}) async {
    try {
      final response = await _dio.get(
        ApiConstants.getAssessments,
        queryParameters: {
          if (doctorId != null) 'doctorid': doctorId,
          if (patientId != null) 'patientid': patientId,
        },
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to fetch assessments',
      };
    }
  }
}
