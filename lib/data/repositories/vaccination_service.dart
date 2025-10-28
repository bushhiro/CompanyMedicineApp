import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VaccinationService {
  final String baseUrl;

  VaccinationService({required this.baseUrl});

  /// Добавление прививки
  Future<void> addVaccination({
    required int patientId,
    required int bodyPartId,
    required int certificateNumberId,
    required DateTime date,
    required int doseId,
    required int medicationId,
    required int methodId,
    required int numberId,
    required int placeId,
    required int resultId,
    required int titleId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception("JWT токен не найден");

    final url = Uri.parse('$baseUrl/vaccinations'); // Уточните endpoint

    final Map<String, dynamic> body = {
      "body_part_id": bodyPartId,
      "certificate_number_id": certificateNumberId,
      "date": date.toIso8601String().split('T')[0], // Формат "2023-12-31"
      "dose_id": doseId,
      "medication_id": medicationId,
      "method_id": methodId,
      "number_id": numberId,
      "patient_id": patientId,
      "place_id": placeId,
      "result_id": resultId,
      "title_id": titleId,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    print("Vaccination URL: $url");
    print("Vaccination Body: ${json.encode(body)}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Ошибка при добавлении прививки: ${response.statusCode}\n${response.body}',
      );
    }
  }
}