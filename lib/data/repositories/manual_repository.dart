import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local/dao/manual_dao.dart';
import '../models/manual.dart';
import '../network/network_service.dart';

class ManualRemoteService {
  final String baseUrl;

  ManualRemoteService({required this.baseUrl});

  /// Получить все справочники (manuals) с сервера
  Future<List<ManualItem>> fetchManuals() async {
    final Uri url = Uri.parse('$baseUrl/manuals');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> data = jsonData['data'] ?? [];

      return data
          .map((item) => ManualItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('Неавторизованный доступ. Токен недействителен или истёк.');
    } else {
      throw Exception('Ошибка при получении справочников: ${response.statusCode}');
    }
  }
}

/// Репозиторий справочников с поддержкой онлайн/оффлайн логики
class ManualRepository {
  final ManualRemoteService remoteService;
  final ManualDao localDao = ManualDao();
  final NetworkService networkService = NetworkService();

  ManualRepository({required this.remoteService});

  /// Главный метод получения справочников (online → offline fallback)
  Future<List<ManualItem>> getManuals() async {
    final bool isOnline = await networkService.isConnected;

    if (isOnline) {
      try {
        final manuals = await remoteService.fetchManuals();

        // Сохраняем справочники в базу
        await insertManualsToDB(manuals);

        print('✅ Справочники успешно обновлены из сервера.');
        return manuals;
      } catch (e) {
        print('⚠ Ошибка при загрузке справочников: $e');
        // fallback — оффлайн режим
        final localData = await localDao.getAllManuals();
        return localData.map((e) => ManualItem.fromJson(e)).toList();
      }
    } else {
      print('Нет интернета — загрузка справочников из локальной базы данных.');
      final localData = await localDao.getAllManuals();
      return localData.map((e) => ManualItem.fromJson(e)).toList();
    }
  }

  /// Получение справочников по типу
  Future<List<ManualItem>> getManualsByType(String type) async {
    final bool isOnline = await networkService.isConnected;

    if (isOnline) {
      try {
        final manuals = await remoteService.fetchManuals();
        await insertManualsToDB(manuals);
      } catch (_) {}
    }

    final localData = await localDao.getManualsByType(type);
    return localData.map((e) => ManualItem.fromJson(e)).toList();
  }

  /// Отдельный метод: сохранение справочников в локальную БД
  Future<void> insertManualsToDB(List<ManualItem> manuals) async {

    final bool isOnline = await networkService.isConnected;

    if(isOnline) {
      try {
        await localDao.insertManuals(manuals.map((e) => e.toMap()).toList());
        print('Справочники успешно сохранены в базу (${manuals.length} записей).');
      } catch (e) {
        print('Ошибка при сохранении справочников: $e');
      }
    }
  }

  /// Очистка таблицы справочников
  Future<void> clearAllManuals() async {
    await localDao.clearManuals();
  }
}