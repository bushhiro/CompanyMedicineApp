import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Создаём таблицу организаций
        await db.execute('''
          CREATE TABLE organizations(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            doctor TEXT,
            phone TEXT
          )
        ''');

        // Создаём таблицу пациентов
        await db.execute('''
          CREATE TABLE patients(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fullName TEXT,
            position TEXT,
            workplace TEXT,
            birthDate TEXT,
            age INTEGER,
            specialistsDone INTEGER,
            specialistsTotal INTEGER,
            testsDone INTEGER,
            testsTotal INTEGER
          )
        ''');

        // Создаём таблицу специалистов пациента
        await db.execute('''
          CREATE TABLE specialists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            patientId INTEGER,
            title TEXT,
            status INTEGER,
            FOREIGN KEY (patientId) REFERENCES patients(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  /// Пример: добавить организацию
  Future<int> insertOrganization(Map<String, dynamic> org) async {
    final db = await database;
    return await db.insert('organizations', org);
  }

  /// Пример: получить все организации
  Future<List<Map<String, dynamic>>> getOrganizations() async {
    final db = await database;
    return await db.query('organizations');
  }

  /// Пример: добавить пациента
  Future<int> insertPatient(Map<String, dynamic> patient) async {
    final db = await database;
    return await db.insert('patients', patient);
  }

  /// Пример: получить всех пациентов
  Future<List<Map<String, dynamic>>> getPatients() async {
    final db = await database;
    return await db.query('patients');
  }

  Future<void> clearOrganizations() async {
    final db = await database;
    await db.delete('organizations'); // удаляем все записи
  }

}
