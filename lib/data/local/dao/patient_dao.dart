import 'package:sqflite/sqflite.dart';
import '../../models/patient.dart';
import '../database_helper.dart';

class PatientDao {
  final DBHelper _dbHelper = DBHelper();

  PatientDao();

  /// Добавление или обновление пациента
  Future<void> insertOrUpdatePatient(PatientResponse p) async {
    final db = await _dbHelper.database;
    await db.insert(
      'patient',
      {
        'id': p.id,
        'full_name': p.fullName,
        'birth_date': p.birthDate.toIso8601String(),
        'is_male': p.isMale ? "Мужской" : "Женский",
        'position': p.position,
        'division': p.division,
        'patient_group_id': p.patientGroupID,
        'examination_type_id': p.examinationType,
        'examination_view_id': p.examinationView,
        'harm_point_id': p.harmPoint.id,
        'phone': p.contactInfo.phone,
        'email': p.contactInfo.email,
        'address': p.contactInfo.address,
        'doc_number': p.personalInfo.docNumber,
        'doc_series': p.personalInfo.docSeries,
        'snils': p.personalInfo.snils,
        'oms': p.personalInfo.oms,
        'document_type_id': p.personalInfo.documentType,
        'is_dirty': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получить всех пациентов по ID группы
  Future<List<PatientResponse>> getAllPatientsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patient',
      where: 'patient_group_id = ?',
      whereArgs: [groupId],
      orderBy: 'full_name ASC',
    );

    return maps.map((map) => PatientResponse.fromJson(_mapToJson(map))).toList();
  }

  /// Пометить пациента как изменённого оффлайн
  Future<void> markAsDirty(int id) async {
    final db = await _dbHelper.database;
    await db.update(
      'patient',
      {'is_dirty': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Удаление всех пациентов группы (вызывается при удалении группы)
  Future<void> deletePatientsByGroup(int groupId) async {
    final db = await _dbHelper.database;
    await db.delete(
      'patient',
      where: 'patient_group_id = ?',
      whereArgs: [groupId],
    );
  }

  /// Получить список пациентов, которые изменены оффлайн
  Future<List<PatientResponse>> getDirtyPatients() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'patient',
      where: 'is_dirty = 1',
    );

    return maps.map((map) => PatientResponse.fromJson(_mapToJson(map))).toList();
  }

  /// Преобразование данных из SQLite в JSON для модели
  Map<String, dynamic> _mapToJson(Map<String, dynamic> map) {
    return {
      'id': map['id'],
      'full_name': map['full_name'],
      'birth_date': map['birth_date'],
      'is_male': map['is_male'] == "Мужской",
      'position': map['position'],
      'division': map['division'],
      'patient_group_id': map['patient_group_id'],
      'examination_type': map['examination_type_id'],
      'examination_view': map['examination_view_id'],
      'harm_point': {'id': map['harm_point_id'], 'value': ''},
      'contact_info': {
        'phone': map['phone'],
        'email': map['email'],
        'address': map['address'],
      },
      'personal_info': {
        'doc_number': map['doc_number'],
        'doc_series': map['doc_series'],
        'snils': map['snils'],
        'oms': map['oms'],
        'document_type': map['document_type_id'],
      },
    };
  }
}