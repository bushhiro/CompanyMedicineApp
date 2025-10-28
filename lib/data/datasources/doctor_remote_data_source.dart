import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';

class DoctorRemoteDataSource {
  final String baseUrl = 'http://192.168.29.112:65322/api/v1/login';

  Future<DoctorAuthResponse> login(String phone, String password, String deviceId) async {

    final body = {
      'phone': phone,
      'password': password,
      'device_id': 'mobile_app', // или другое значение для deviceId
    };

    print('=== LOGIN REQUEST ===');
    print('URL: $baseUrl');
    print('Body: $body');


    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);
      return DoctorAuthResponse.fromJson(data);
    } else {
      throw Exception('Ошибка авторизации: ${response.body}');
    }
  }
}