import 'package:shared_preferences/shared_preferences.dart';

import '../local/dao/patient_dao.dart';
import '../models/patient.dart';
import '../network/network_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientRepository {
  final PatientDao localdao = PatientDao();
  final PatientRepositoryRemote remote;
  final NetworkService networkService;

  PatientRepository({required this.remote, required this.networkService});

  /// Получение списка пациентов группы
  Future<List<PatientResponse>> getPatients(int groupId) async {
    final bool isOnline = await networkService.isConnected;

    final prefs = await SharedPreferences.getInstance();
    final doctorId = prefs.getInt('doctorId') ?? 0;

    if (isOnline) {
      print(isOnline);
      try {
        // Получаем с сервера
        final patients = await remote.getPatientsByGroup(groupId, doctorId);
        // Сохраняем в локальную базу

        return patients;
      } catch (_) {
        print( 'fallback на локальную базу');
        return localdao.getAllPatientsByGroup(groupId);
      }
    } else {
      // оффлайн
      return localdao.getAllPatientsByGroup(groupId);
    }
  }

  Future<void> fetchAndSavePatientsByGroup(int groupId) async {
    final patients = await getPatients(groupId);
    for (var patient in patients) {
      await localdao.insertOrUpdatePatient(patient);
    }
    print('patients в локальной бд: $patients');
  }

  /// Отправка оффлайн изменений на сервер
  Future<void> syncDirtyPatients() async {
    final bool isOnline = await networkService.isConnected;
    if (!isOnline) return;

    final dirtyPatients = await localdao.getDirtyPatients();

    for (var p in dirtyPatients) {
      try {
        // Отправляем обновление на сервер
        await remote.addPatient(
          groupId: p.patientGroupID,
          fullName: p.fullName,
          birthDate: p.birthDate,
          gender: p.gender,
          position: p.position,
          division: p.division,
          examinationTypeId: p.examinationType ?? 0,
          examinationViewId: p.examinationView ?? 0,
          harmPointId: p.harmPoint.id,
          phone: p.contactInfo.phone,
          email: p.contactInfo.email,
          address: p.contactInfo.address,
          docNumber: p.personalInfo.docNumber,
          docSeries: p.personalInfo.docSeries,
          snils: p.personalInfo.snils,
          oms: p.personalInfo.oms,
          documentTypeId: p.personalInfo.documentType,
        );

        // После успешного обновления сбрасываем флаг
        await localdao.markAsDirty(p.id); // можно изменить метод markAsDirty чтобы обнулять флаг
      } catch (e) {
        // Если ошибка, оставляем is_dirty = 1 для повторной синхронизации
        continue;
      }
    }
  }

  /// Обновление пациента оффлайн (редактирование)
  Future<void> updatePatientOffline(PatientResponse p) async {
    final dbPatient = await localdao.getAllPatientsByGroup(p.patientGroupID);
    final exists = dbPatient.any((dp) => dp.id == p.id);
    if (exists) {
      await localdao.insertOrUpdatePatient(p);
      await localdao.markAsDirty(p.id);
    }
  }

  /// Удаление всех пациентов группы (вызывается при удалении списка)
  Future<void> deletePatientsByGroup(int groupId) async {
    await localdao.deletePatientsByGroup(groupId);
  }
}

class PatientRepositoryRemote {
  final String baseUrl;

  PatientRepositoryRemote({required this.baseUrl});

  Future<List<PatientResponse>> getPatientsByGroup(int groupId, int doctorId) async {

    final url = Uri.parse('$baseUrl/patient-groups/$groupId/$doctorId/patients');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      print(response.body);
      return data.map((e) => PatientResponse.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка при загрузке пациентов: ${response.statusCode}');
    }
  }

  Future<void> addPatient({
    required int groupId,
    required String fullName,
    required DateTime birthDate,
    required String gender,
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
    required String? snils,
    required String oms,
    int? documentTypeId,
  }) async {
    final url = Uri.parse('$baseUrl/patients');

    final Map<String, dynamic> body = {
      'full_name': fullName,
      'birth_date': birthDate.toUtc().toIso8601String(),
      'group_id': groupId,
      'gender': gender,
      'position': position,
      'division': division,
      'examination_type_id': examinationTypeId,
      'examination_view_id': examinationViewId,
      'harm_point_id': harmPointId,
      'contact_info': {'phone': phone, 'email': email, 'address': address},
      'personal_info': {
        'doc_number': docNumber,
        'doc_series': docSeries,
        'snils': snils,
        'oms': oms,
        if (documentTypeId != null) 'document_type_id': documentTypeId,
      },
    };

    print(body);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Ошибка при добавлении пациента: ${response.statusCode}');
    }
  }
}