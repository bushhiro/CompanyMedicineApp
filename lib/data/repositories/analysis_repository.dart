import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../local/dao/analysis_dao.dart';
import '../models/analysis.dart';
import '../network/network_service.dart';
import 'package:http/http.dart' as http;

/// Сервис для получения анализов с сервера
class AnalysisRemoteService {
  final String baseUrl;

  AnalysisRemoteService({required this.baseUrl});

  /// Получение справочника анализов
  Future<List<AnalysisResponse>> fetchAnalyses() async {
    final url = Uri.parse('$baseUrl/analysis');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List<dynamic>;
      return data.map((e) => AnalysisResponse.fromJson(Map<String, dynamic>.from(e))).toList();
    } else {
      throw Exception('Ошибка при получении анализов: ${response.statusCode}');
    }
  }
}

/// Репозиторий для работы с анализами (онлайн + оффлайн)
class AnalysisRepository {
  final AnalysisRemoteService remoteService;
  final AnalysisDao localDao = AnalysisDao();
  final AnalysisOrderDao analysisOrderDao = AnalysisOrderDao();
  final NetworkService networkService = NetworkService();

  AnalysisRepository({required this.remoteService});

  /// Получение анализов с поддержкой оффлайн
  Future<List<AnalysisResponse>> getAnalyses() async {
    final bool isOnline = await networkService.isConnected;

    if (isOnline) {
      try {
        final remoteAnalyses = await remoteService.fetchAnalyses();
        // Сохраняем в локальную базу
        await insertAnalysesToDB(remoteAnalyses);
        return remoteAnalyses;
      } catch (e) {
        // fallback на локальную базу
        return await localDao.getAllAnalyses();
      }
    } else {
      return await localDao.getAllAnalyses();
    }
  }

  Future<void> savePatientAnalysisOrders(int patientId, List<AnalysisOrderItemResponse> items,
      {String? orderNumber}) async {
    // 1. Создаем объект заказа
    final analysisOrder = AnalysisOrderResponse(
      id: null, // если новый заказ, иначе реальный id
      orderNumber: orderNumber,
      totalAmount: items.fold<int>(
        0,
            (sum, item) => sum + item.analysis.price, // price уже int
      ),
      orderItems: items,
    );


    // 2. Сохраняем в локальную базу
    print('saving');
    await analysisOrderDao.insertOrUpdateOrder(patientId, analysisOrder);


    // 3. Пытаемся отправить на сервер, если есть интернет
    final bool isOnline = await networkService.isConnected;
    if (isOnline) {
      try {
        final url = Uri.parse('${remoteService.baseUrl}/analysis/update');
        final body = jsonEncode({
          "id": patientId,
          "order_number": orderNumber ?? "",
          "order_items": items.map((e) => {
            "analysis_id": e.analysisId,
            "is_completed": e.isCompleted,
          }).toList(),
        });

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        print(body);

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception('Ошибка обновления анализов: ${response.statusCode}');
        }
      } catch (e) {
        // Если нет интернета или ошибка, оставляем данные в локальной базе
        debugPrint('Не удалось отправить анализы на сервер: $e');
      }
    }
  }

  /// Сохранение списка анализов в локальную БД
  Future<void> insertAnalysesToDB(List<AnalysisResponse> analyses) async {
    for (var analysis in analyses) {
      await localDao.insertOrUpdateAnalysis(analysis);
    }
  }

  Future<List<AnalysisOrderResponse>> getOrdersByPatient(int patientId) async {
    return await analysisOrderDao.getOrdersByPatient(patientId);
  }

  /// Сохранение заказа анализов для пациента
  Future<void> saveOrderForPatient(int patientId, AnalysisOrderResponse order) async {
    await analysisOrderDao.insertOrUpdateOrder(patientId, order);
  }

}