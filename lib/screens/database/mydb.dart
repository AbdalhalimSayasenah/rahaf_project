import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    _db ??= await _initializeDb();
    return _db;
  }

  Future<Database> _initializeDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'rahaf.db');
    final mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 3,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) {
    // Implement database schema changes when upgrading.
  }

  void _onCreate(Database db, int version) async {
    final batch = db.batch();

    _createClassesTable(batch);
    _createTeachersTable(batch);
    _createStudentsTable(batch);

    await batch.commit();
  }

  void _createClassesTable(Batch batch) {
    batch.execute('''
      CREATE TABLE "classes" (
        "cl_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "cl_name" TEXT NOT NULL,
        "cl_cost" INTEGER NOT NULL
      )
    ''');
    // print("Created 'classes' table");
  }

  void _createTeachersTable(Batch batch) {
    batch.execute('''
      CREATE TABLE "teachers" (
        "te_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        "te_name" TEXT NOT NULL,
        "te_class" INTEGER NOT NULL,
        "te_salary" INTEGER NOT NULL,
        FOREIGN KEY ("te_class") REFERENCES "classes" ("cl_id") ON DELETE NO ACTION ON UPDATE NO ACTION
      )
    ''');
    // print("Created 'teachers' table");
  }

  void _createStudentsTable(Batch batch) {
    batch.execute('''
    CREATE TABLE "students" (
      "st_id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      "st_name" TEXT NOT NULL,
      "st_class_id" INTEGER NOT NULL,
      "st_responsible" TEXT NOT NULL,
      "st_mobile" TEXT NOT NULL,
      "st_payment" INT,
      FOREIGN KEY ("st_class_id") REFERENCES "classes" ("cl_id") ON DELETE NO ACTION ON UPDATE NO ACTION
    )
  ''');
    // print("Created 'students' table");
  }

  Future<List<Map<String, dynamic>>> readData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawQuery(sql);
    return response;
  }

  Future<int> insertData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<int> updateData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawUpdate(sql);
    return response;
  }

  Future<int> deleteData(String sql) async {
    final mydb = await db;
    final response = await mydb!.rawDelete(sql);
    return response;
  }

  Future<void> close() async {
    final mydb = await db;
    if (mydb != null && mydb.isOpen) {
      await mydb.close();
      _db =
          null; // Set _db to null after closing to allow it to be re-opened later if needed.
    }
  }
}
