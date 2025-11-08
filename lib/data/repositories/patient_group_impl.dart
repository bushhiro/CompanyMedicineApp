import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local/dao/patient_group_dao.dart';
import '../models/patient_group.dart';
import '../network/network_service.dart';

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


class PatientGroupRepository {
  final PatientGroupImpl remoteService;
  final PatientGroupDao localDao = PatientGroupDao();
  final NetworkService networkService = NetworkService();

  PatientGroupRepository({required this.remoteService});

  /// Получение групп пациентов по организации с поддержкой оффлайн
  Future<List<PatientGroupShortResponse>> getGroups(String organizationId) async {
    // Проверяем подключение к интернету
    final bool isOnline = await networkService.isConnected;

    if (isOnline) {
      try {
        // Получаем данные с сервера
        final remoteGroups = await remoteService.getGroupsByOrganization(organizationId);

        // Сохраняем или обновляем данные в локальной базе
        for (var group in remoteGroups) {
          await localDao.insertGroup(group);
        }

        final allOrgs = await localDao.getAllGroups();
        print('группы в базе после вставки: $allOrgs');

        return remoteGroups;
      } catch (e) {
        // Если произошла ошибка на сервере — fallback на локальные данные
        return await localDao.getAllGroups();
      }
    } else {
      // Если нет сети — берём данные из локальной базы
      return await localDao.getAllGroups();
    }
  }

  /// Удаление группы из локальной базы
  Future<void> deleteGroup(int id) async {
    await localDao.deleteGroup(id);
  }

  /// Очистка всех групп из локальной базы (по необходимости)
  Future<void> clearAllGroups() async {
    await localDao.clearAll();
  }
}