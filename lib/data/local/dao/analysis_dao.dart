import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../../models/analysis.dart';

class AnalysisDao {
  final DBHelper _dbHelper = DBHelper();

  /// Добавление или обновление анализа в справочник
  Future<void> insertOrUpdateAnalysis(AnalysisResponse analysis) async {
    final db = await _dbHelper.database;
    await db.insert(
      'analysis',
      {
        'id': analysis.id,
        'code': analysis.code,
        'title': analysis.title,
        'price': analysis.price,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получение всех анализов
  Future<List<AnalysisResponse>> getAllAnalyses() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('analysis');

    return maps.map((map) => AnalysisResponse(
      id: map['id'],
      code: map['code'],
      title: map['title'],
      price: map['price'],
    )).toList();
  }

  /// Очистка таблицы анализов
  Future<void> clearAllAnalyses() async {
    final db = await _dbHelper.database;
    await db.delete('analysis');
  }
}


class AnalysisOrderDao {
  final DBHelper _dbHelper = DBHelper();

  /// Добавление или обновление заказа анализа
  Future<void> insertOrUpdateOrder(int patientId,
      AnalysisOrderResponse order) async {
    final db = await _dbHelper.database;

    await db.insert(
      'analysis_order',
      {
        'id': order.id,
        'patient_id': patientId,
        'order_number': order.orderNumber,
        'total_amount': order.totalAmount,
        'order_items': jsonEncode(
            order.orderItems.map((e) => e.toJson()).toList()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получение всех заказов анализов для конкретного пациента
  Future<List<AnalysisOrderResponse>> getOrdersByPatient(int patientId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'analysis_order',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    return maps.map((map) {
      final List<dynamic> itemsJson = jsonDecode(map['order_items']);
      return AnalysisOrderResponse(
        id: map['id'],
        orderNumber: map['order_number'],
        totalAmount: map['total_amount'],
        orderItems: itemsJson
            .map((e) =>
            AnalysisOrderItemResponse.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }).toList();
  }

  /// Удаление заказа анализа
  Future<void> deleteOrder(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'analysis_order',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Очистка всех заказов анализов
  Future<void> clearAllOrders() async {
    final db = await _dbHelper.database;
    await db.delete('analysis_order');
  }
}