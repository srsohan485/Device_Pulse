import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db = await initDB();
    return _db!;
  }
  static Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'received_data.db');
    return await openDatabase(
      path, version: 1, onCreate: (db, version) async {
      await db.execute('''CREATE TABLE received (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sender TEXT,message TEXT,time TEXT
          )'''
      );
    },);
  }

  static Future<void> insertData(
      String sender, String message) async {
    final db = await database;
    await db.insert('received', {
      'sender': sender,'message': message,
      'time': DateTime.now().toString(),
    });
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await database;
    return await db.query('received', orderBy: 'id DESC');
  }


  static Future<void> deleteData(int id) async {
    final db = await database;
    await db.delete(
      'received',
      where: 'id = ?',
      whereArgs: [id],
    );
    print("Deleted ${id}");

  }


}
