import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DBHelper {
  // 1. Fungsi untuk membuka/membuat database
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();

    // Membuka file 'dompet_care.db'. Kalau belum ada, dia bikin baru (onCreate)
    return sql.openDatabase(
      path.join(dbPath, 'dompet_care.db'),
      onCreate: (db, version) {
        // Query SQL standard buat bikin tabel
        // Perhatikan: SQLite tidak punya tipe Boolean, kita pakai Integer (0/1)
        return db.execute(
          'CREATE TABLE user_transactions(id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category TEXT, isExpense INTEGER)',
        );
      },
      version: 1,
    );
  }

  // 2. Fungsi Insert Data
  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();

    // conflictAlgorithm: Kalau ID sama, data lama ditimpa (replace)
    await db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  // 3. Fungsi Ambil Data (Select All)
  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  // 4. Fungsi Hapus Data
  static Future<void> delete(String table, String id) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
