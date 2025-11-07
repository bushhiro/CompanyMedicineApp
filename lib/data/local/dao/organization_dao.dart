// lib/data/local/dao/organization_dao.dart
import 'package:sqflite/sqflite.dart';
import '../../models/patient_group.dart';
import '../database_helper.dart';

class OrganizationDao {
  final DBHelper _dbHelper = DBHelper();

  Future<void> insertOrganization(Organization org) async {
    final db = await _dbHelper.database;
    await db.insert(
      'organization',
      org.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Organization>> getAllOrganizations() async {
    final db = await _dbHelper.database;
    final maps = await db.query('organization');
    return maps.map((map) => Organization.fromJson(map)).toList();
  }

  Future<void> deleteOrganization(int id) async {
    final db = await _dbHelper.database;
    await db.delete('organization', where: 'id = ?', whereArgs: [id]);
  }
}