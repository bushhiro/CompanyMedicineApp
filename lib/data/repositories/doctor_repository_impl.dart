import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/doctor.dart';

class DoctorRepositoryImpl {
  final String baseUrl = "http://10.0.2.2:8081/api/v1";

  Future<DoctorAuthResponse?> login(DoctorLoginRequest request) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return DoctorAuthResponse.fromJson(jsonBody);
    } else {
      throw Exception('Ошибка авторизации: ${response.statusCode}');
    }
  }

  Future<DoctorResponse?> getCurrentDoctor(String token) async {
    final url = Uri.parse('$baseUrl/doctors/current');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return DoctorResponse.fromJson(jsonBody['data']);
    } else {
      throw Exception('Ошибка получения данных врача: ${response.statusCode}');
    }
  }
}