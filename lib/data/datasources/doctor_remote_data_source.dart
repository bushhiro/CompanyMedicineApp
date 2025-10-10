import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';

class DoctorRemoteDataSource {
  final String baseUrl = 'http://10.0.2.2:8081/api/v1/auth/login';

  Future<DoctorAuthResponse> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DoctorAuthResponse.fromJson(data);
    } else {
      throw Exception('Ошибка авторизации: ${response.body}');
    }
  }
}