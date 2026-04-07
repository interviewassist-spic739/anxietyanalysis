import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_constants.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Failed to send OTP',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      return response.data;
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data?['message'] ?? 'Invalid OTP',
      };
    }
  }
}
