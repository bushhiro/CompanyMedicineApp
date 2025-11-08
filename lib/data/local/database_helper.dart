import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.local');

    return await openDatabase(
      path,
      version: 3, // увеличиваем версию для добавления новой таблицы
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {

    // Таблица для organization
    await db.execute('''
      CREATE TABLE organization (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE patient_group (
        id INTEGER PRIMARY KEY,
        code TEXT NOT NULL,
        created_at TEXT NOT NULL,
        organization_title TEXT NOT NULL,
        FOREIGN KEY (organization_title) REFERENCES organization(title)
      )
    ''');

    // Потом дочерние таблицы
    await db.execute('''
      CREATE TABLE patient (
        id INTEGER PRIMARY KEY,
        full_name TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        is_male TEXT NOT NULL,
        position TEXT,
        division TEXT,
        patient_group_id INTEGER NOT NULL,
        examination_type_id INTEGER,
        examination_view_id INTEGER,
        harm_point TEXT,
        personal_info TEXT,
        contact_info TEXT,
        analysis_order TEXT,
        statistics TEXT,
        flgs TEXT,
        vaccines TEXT,
        receptions TEXT,
        specializations TEXT,
        is_dirty INTEGER DEFAULT 0,
        FOREIGN KEY(patient_group_id) REFERENCES patient_group(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if(oldVersion < 4){

    }
  }

  Future<void> closeDB() async {
    final db = await database;
    await db.close();
  }
}