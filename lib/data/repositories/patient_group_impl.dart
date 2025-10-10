import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/patient_group.dart';

/// Реализация сервиса для получения групп пациентов
class PatientGroupImpl {
  final String baseUrl;

  PatientGroupImpl({required this.baseUrl});

  /// Получить группы пациентов по ID организации
  Future<List<PatientGroupShortResponse>> getGroupsByOrganization(String orgId) async {
    final url = Uri.parse('$baseUrl/groups/$orgId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Преобразуем в Map<String, dynamic>
      final Map<String, dynamic> jsonData = Map<String, dynamic>.from(json.decode(response.body));

      // Достаем список hits
      final List<dynamic> hits = jsonData['data']['hits'] as List<dynamic>;

      // Преобразуем каждый элемент в модель
      final groups = hits
          .map((e) => PatientGroupShortResponse.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return groups;
    } else {
      throw Exception('Ошибка при получении групп пациентов: ${response.statusCode}');
    }
  }
}