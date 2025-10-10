import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_group.dart';

/// Сервис для получения групп пациентов с авторизацией
class PatientGroupImpl {
  final String baseUrl;

  PatientGroupImpl({required this.baseUrl});

  /// Получаем токен, сохранённый при логине
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    if (token == null || token.isEmpty) {
      throw Exception('JWT токен не найден. Авторизуйтесь заново.');
    }
    print("TOKEN IS $token");
    return token;
  }

  /// Получить группы пациентов по ID организации
  Future<List<PatientGroupShortResponse>> getGroupsByOrganization(String organizationId) async {
    final token = await _getToken();
    final Uri url = Uri.parse('$baseUrl/groups/$organizationId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // используем сохранённый токен
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> hits = jsonData['data']['hits'] ?? [];

      return hits
          .map((e) => PatientGroupShortResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Неавторизованный доступ. Токен недействителен или истек.');
    } else {
      throw Exception(
        'Ошибка при получении групп пациентов: ${response.statusCode}\n${response.body}',
      );
    }
  }
}