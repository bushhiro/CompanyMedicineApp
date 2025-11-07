// lib/data/repositories/organization_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../local/dao/organization_dao.dart';
import '../models/patient_group.dart';
import '../network/network_service.dart';

class OrganizationImpl {
  final String baseUrl;
  final NetworkService networkService = NetworkService();

  OrganizationImpl({required this.baseUrl});

  /// Получение организаций врача по doctorId
  Future<List<Organization>> getOrganizations(int doctorId) async {
    print('doc id is: $doctorId');
    final Uri url = Uri.parse('$baseUrl/organizations/$doctorId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('succes');
      print('Server response: ${response.body}');
      final Map<String, dynamic> jsonData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> hits = jsonData['data']['hits'] ?? [];



      return hits.map((e) => Organization.fromJson(Map<String, dynamic>.from(e))).toList();

    } else if (response.statusCode == 401) {
      throw Exception('Неавторизованный доступ. Токен недействителен или истек.');
    } else {
      throw Exception('Ошибка при получении организаций: ${response.statusCode}\n${response.body}');
    }
  }
}

class OrganizationRepository {
  final OrganizationImpl remoteService;
  final OrganizationDao localDao = OrganizationDao();
  final NetworkService networkService = NetworkService();

  OrganizationRepository({required this.remoteService});

  /// Получение организаций с поддержкой оффлайн
  Future<List<Organization>> getOrganizations() async {
    final bool isOnline = await networkService.isConnected;

    if (isOnline) {


      try {
        final prefs = await SharedPreferences.getInstance();
        final doctorId = prefs.getInt('doctorId') ?? 0;

        final remoteOrgs = await remoteService.getOrganizations(doctorId);

        // Сохраняем/обновляем в локальной базе
        for (var org in remoteOrgs) {
          await localDao.insertOrganization(org);
        }

        return remoteOrgs;
      } catch (e) {
        // fallback на локальные данные при ошибке
        return await localDao.getAllOrganizations();
      }
    } else {
      return await localDao.getAllOrganizations();
    }
  }

  Future<void> deleteOrganization(int id) async {
    await localDao.deleteOrganization(id);
  }

}