import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' ;

class DatabaseManager {
  static Future<Database> getDatebase() async {
   // await deleteDatabase( join(await getDatabasesPath(), 'art_course.db'));
    return openDatabase(
      join(await getDatabasesPath(), 'art_course.db'),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE [clock]([Id] INTEGER PRIMARY KEY AUTOINCREMENT, '
            '[course] VARCHAR(64) NOT NULL,'
            '[number] INTEGER NOT NULL, '
            '[datetime] DATETIME, '
            '[is_checked] BOOL DEFAULT False,'
            '[icon_date] VARCHAR(256));');
      },
    );
  }
  static Future closeDb(Database db) async=>db.close();
}
