import 'package:sqflite/sqflite.dart';
import '../../models/patient_group.dart';
import '../database_helper.dart';

class PatientGroupDao {
  final DBHelper _dbHelper = DBHelper();

  Future<void> insertGroup(PatientGroupShortResponse group) async {
    final db = await _dbHelper.database;
    print('Saving to DB: ${group.toJson()}');
    await db.insert(
      'patient_group',
      group.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PatientGroupShortResponse>> getAllGroups() async {
    final db = await _dbHelper.database;
    final maps = await db.query('patient_group', orderBy: 'created_at DESC');

    return List.generate(maps.length, (i) {
      return PatientGroupShortResponse.fromJson(maps[i]);
    });
  }

  Future<void> deleteGroup(int id) async {
    final db = await _dbHelper.database;
    await db.delete('patient_group', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _dbHelper.database;
    await db.delete('patient_group');
  }
}