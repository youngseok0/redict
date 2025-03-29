import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = (await getApplicationDocumentsDirectory()).path + "/listening_app.db";
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE records (id INTEGER PRIMARY KEY, question TEXT, answer TEXT, correct INTEGER)");
    });
  }

  Future<void> saveRecord(String question, String answer, bool correct) async {
    final db = await database;
    await db.insert("records", {"question": question, "answer": answer, "correct": correct ? 1 : 0});
  }
}
