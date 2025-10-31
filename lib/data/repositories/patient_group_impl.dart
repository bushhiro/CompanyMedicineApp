import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient_group.dart';

/// Сервис для получения групп пациентов с авторизацией
class PatientGroupImpl {
  final String baseUrl;

  PatientGroupImpl({required this.baseUrl});

  /// Получить группы пациентов по ID организации
  Future<List<PatientGroupShortResponse>> getGroupsByOrganization(String organizationId) async {
    final Uri url = Uri.parse('$baseUrl/patient-groups/by-organization/$organizationId?page=1&perPage=10');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
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