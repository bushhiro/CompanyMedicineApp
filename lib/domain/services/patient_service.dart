import 'dart:convert';
import 'package:http/http.dart' as http;

class PatientService {
  final String baseUrl;

  PatientService({required this.baseUrl});

  Future<void> createPatient(int groupId, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/patients/$groupId/create');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Пациент успешно создан: ${response.body}");
    } else {
      throw Exception(
        'Ошибка при создании пациента: ${response.statusCode}\n${response.body}',
      );
    }
  }
}