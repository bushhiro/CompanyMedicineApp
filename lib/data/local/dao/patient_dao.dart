import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../models/patient.dart';
import '../database_helper.dart';

class PatientDao {
  final DBHelper _dbHelper = DBHelper();

  /// Добавление или обновление пациента
  Future<void> insertOrUpdatePatient(PatientResponse p) async {
    final db = await _dbHelper.database;

    await db.insert(
      'patient',
      {
        'id': p.id,
        'full_name': p.fullName,
        'birth_date': p.birthDate.toIso8601String(),
        'is_male': p.gender,
        'position': p.position,
        'division': p.division,
        'patient_group_id': p.patientGroupID,
        'examination_type_id': p.examinationType,
        'examination_view_id': p.examinationView,

        // вложенные структуры сериализуем в JSON
        'harm_point': jsonEncode(p.harmPoint.toJson()),
        'personal_info': jsonEncode(p.personalInfo.toJson()),
        'contact_info': jsonEncode(p.contactInfo.toJson()),
        'analysis_order': jsonEncode(p.analysisOrder.toJson()),
        'statistics': jsonEncode(p.statistics?.toJson()),
        'flgs': jsonEncode(p.flgs.map((e) => e.toJson()).toList()),
        'vaccines': jsonEncode(p.vaccines.map((e) => e.toJson()).toList()),
        'receptions': jsonEncode(p.receptions.map((e) => e.toJson()).toList()),
        'specializations': jsonEncode(p.specializations.map((e) => e.toJson()).toList()),

        'is_dirty': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получение всех пациентов по группе
  Future<List<PatientResponse>> getAllPatientsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patient',
      where: 'patient_group_id = ?',
      whereArgs: [groupId],
    );

    return maps.map((map) => _mapToPatient(map)).toList();
  }

  /// Преобразование строки JSON обратно в модель
  PatientResponse _mapToPatient(Map<String, dynamic> map) {
    return PatientResponse.fromJson({
      'id': map['id'],
      'full_name': map['full_name'],
      'birth_date': map['birth_date'],
      'age': 0, // при необходимости можно вычислять
      'gender': map['is_male']?.toString() ?? 'Не указано',
      'position': map['position'],
      'division': map['division'],
      'patient_group_id': map['patient_group_id'],
      'examination_type': map['examination_type_id'],
      'examination_view': map['examination_view_id'],
      'harm_point': jsonDecode(map['harm_point']),
      'personal_info': jsonDecode(map['personal_info']),
      'contact_info': jsonDecode(map['contact_info']),
      'analysis_order': jsonDecode(map['analysis_order']),
      'statistics': map['statistics'] != null ? jsonDecode(map['statistics']) : null,
      'flgs': map['flgs'] != null ? jsonDecode(map['flgs']) : [],
      'vaccines': map['vaccines'] != null ? jsonDecode(map['vaccines']) : [],
      'receptions': map['receptions'] != null ? jsonDecode(map['receptions']) : [],
      'specializations': map['specializations'] != null ? jsonDecode(map['specializations']) : [],
    });
  }

  Future<void> markAsDirty(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'patient',
      {'is_dirty': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletePatientsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'patient',
      where: 'patient_group_id = ?',
      whereArgs: [groupId],
    );
  }

  Future<List<PatientResponse>> getDirtyPatients() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patient',
      where: 'is_dirty = 1 AND is_deleted = 0',
    );
    return maps.map((map) => _mapToPatient(map)).toList();
  }
}