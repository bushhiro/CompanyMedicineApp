import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/doctor.dart';

class DoctorRepositoryImpl {
  final String baseUrl = "http://192.168.29.112:65322/api/v1";

  /// === Авторизация врача ===
  Future<DoctorAuthResponse?> login(DoctorLoginRequest request) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    print('=== LOGIN REQUEST ===');
    print('URL: $baseUrl');
    print('Body: ${request.toJson()}');

    print('=== LOGIN RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final data = jsonBody['data'];

      if (data != null && data['session_id'] != null) {
        final sessionId = data['session_id'];
        await _saveSessionId(sessionId);
        print('✅ Session ID сохранён: $sessionId');
      } else {
        print('⚠️ Session ID не найден в ответе сервера.');
      }

      // Передаём именно объект data, а не весь json
      return DoctorAuthResponse.fromJson(data);
    } else {
      throw Exception('Ошибка авторизации: ${response.statusCode}');
    }
  }

  /// === Получение информации о текущем враче ===
  Future<DoctorResponse?> getCurrentDoctor(int doctorId) async {
    final url = Uri.parse('$baseUrl/doctors/$doctorId');

    // Достаём сохранённый session id
    final sessionId = await _getSessionId();
    if (sessionId == null) {
      throw Exception('Не найден X-Session-ID. Выполните вход заново.');
    }

    final response = await http.get(
      url,
      headers: {'session_id': sessionId},
    );

    print('=== GET DOCTOR RESPONSE ===');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return DoctorResponse.fromJson(jsonBody['data']);
    } else {
      throw Exception('Ошибка получения данных врача: ${response.statusCode}');
    }
  }

  /// === Вспомогательные методы для SharedPreferences ===
  Future<void> _saveSessionId(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
  }

  Future<String?> _getSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }
}