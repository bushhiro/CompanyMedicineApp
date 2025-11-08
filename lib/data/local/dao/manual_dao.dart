import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';

class ManualDao {
  final dbHelper = DBHelper();

  Future<void> insertManuals(List<Map<String, dynamic>> manuals) async {
    final db = await dbHelper.database;

    final batch = db.batch();
    for (var manual in manuals) {
      batch.insert(
        'manuals',
        manual,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getManualsByType(String type) async {
    final db = await dbHelper.database;
    return await db.query('manuals', where: 'type = ?', whereArgs: [type]);
  }

  Future<List<Map<String, dynamic>>> getAllManuals() async {
    final db = await dbHelper.database;
    return await db.query('manuals');
  }

  Future<void> clearManuals() async {
    final db = await dbHelper.database;
    await db.delete('manuals');
  }
}