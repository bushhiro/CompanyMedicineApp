import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';

class PatientRepository {
  static const String _baseUrl = 'http://10.0.2.2:8081/api/v1/patients';

  /// Получить всех пациентов по ID группы
  Future<List<PatientResponse>> getPatientsByGroup(int groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('JWT токен не найден');

    final response = await http.get(
      Uri.parse('$_baseUrl/$groupId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => PatientResponse.fromJson(e)).toList();
    } else {
      throw Exception(
        'Ошибка при загрузке пациентов: ${response.statusCode}\n${response
            .body}',
      );
    }
  }

}

class AddPatientService {
  final String baseUrl;

  AddPatientService({required this.baseUrl});

  /// Отправка POST-запроса для создания нового пациента
  Future<void> addPatient({
      required int groupId,
      required String fullName,
      required DateTime birthDate,
      required bool isMale,
      required String position,
      required String division,
      required int examinationTypeId,
      required int examinationViewId,
      required int harmPointId,
      required String phone,
      required String email,
      required String address,
      required String docNumber,
      required String docSeries,
      required String snils,
      required String oms,
      int? documentTypeId,
    }) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("JWT токен не найден");

      final url = Uri.parse('$baseUrl/patients/$groupId/create');

      final Map<String, dynamic> body = {
        "full_name": fullName,
        "birth_date": birthDate.toUtc().toIso8601String(),
        "is_male": isMale,
        "position": position,
        "division": division,
        "examination_type_id": examinationTypeId,
        "examination_view_id": examinationViewId,
        "harm_point_id": harmPointId,
        "contact_info": {
          "phone": phone,
          "email": email,
          "address": address,
        },
        "personal_info": {
          "doc_number": docNumber,
          "doc_series": docSeries,
          "snils": snils,
          "oms": oms,
          if (documentTypeId != null) "document_type_id": documentTypeId,
        }
      };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

      print("URL: $url");
      print("Body: ${json.encode(body)}");


    if (response.statusCode != 200 && response.statusCode != 201) {print("URL: $url");
      throw Exception(
        'Ошибка при добавлении пациента: ${response.statusCode}\n${response.body}',
      );
    }
  }
}