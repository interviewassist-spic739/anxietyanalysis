import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_constants.dart';
import 'dart:io';

class DoctorService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> getDashboardStats(int doctorId) async {
    try {
      final response = await _dio.get(
        ApiConstants.dashboardStats,
        queryParameters: {'doctorid': doctorId},
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to fetch stats',
      };
    }
  }

  Future<Map<String, dynamic>> getProfile(int doctorId) async {
    try {
      final response = await _dio.get(
        ApiConstants.profile,
        queryParameters: {'doctorid': doctorId},
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to fetch profile',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiConstants.profile,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to update profile',
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(int doctorId, File photoFile) async {
    try {
      String fileName = photoFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'doctorid': doctorId,
        'image': await MultipartFile.fromFile(photoFile.path, filename: fileName),
      });

      final response = await _dio.post(
        ApiConstants.profilePhoto,
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to upload photo',
      };
    }
  }
}
