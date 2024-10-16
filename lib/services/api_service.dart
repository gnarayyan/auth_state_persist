import 'package:dio/dio.dart';
import '../models/exception_model.dart';
import 'shared_pref_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final SharedPrefService sharedPrefService = SharedPrefService();

  final String baseUrl = "http://192.168.1.10:3000/api/v1";

  Future<void> sendOtp(String phoneNumber) async {
    final response = await _dio.post('$baseUrl/auth/login', data: {
      'phoneNumber': phoneNumber,
    });
    return response.data;
  }

  Future<String?> verifyOtp(String phoneNumber, String otp) async {
    final response = await _dio.post('$baseUrl/auth/login/verify', data: {
      'phoneNumber': phoneNumber,
      'otp': otp,
    });
    if (response.statusCode == 200) {
      // Access Token
      final authorizationHeader = response.headers['Authorization']!.first;
      // print('Authorization: $authorizationHeader');

      // Refresh Token
      final refreshToken = response.data['refreshToken'];

      await sharedPrefService.saveToken(authorizationHeader);
      await sharedPrefService.saveRefreshToken(refreshToken);

      return authorizationHeader;
    } else {
      throw Exception('OTP Verification failed');
    }
  }

  Future<String?> refreshToken() async {
    print('Token Refreshing.......');
    final token = await sharedPrefService.getRefreshToken();
    final response =
        await _dio.post('$baseUrl/auth/refresh', data: {'refreshToken': token});
    if (response.statusCode == 200) {
      final authorizationHeader = response.headers['Authorization']!.first;
      await sharedPrefService.saveToken(authorizationHeader);
      return authorizationHeader;
    } else {
      throw Exception('Refreshing token failed');
    }
  }

  Future<String> getUserAvatar() async {
    final token = await sharedPrefService.getToken();
    try {
      final response = await _dio.get('$baseUrl/profile/driver',
          options: Options(headers: {
            'Authorization': token, //'Bearer $token'
          }));
      return response.data['avatar'];
    } on DioException catch (e) {
      final response = e.response;
      if (response!.statusCode == 403) {
        throw InvalidTokenException(response.data['message']);
      }

      throw Exception('Unknown error at getUserAvatarService()');
    }
  }
}
