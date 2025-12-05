import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:leofluter/database/tables.dart';

class DatabaseHelper {
  static const String dbName = "badger_database.db";
  static Database? _db;

  static Future<Database> initDB() async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, dbName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        print(">>> CREANDO TABLAS POR PRIMERA VEZ <<<");
        // Crear la tabla de usuarios
        await db.execute(Tables.createSesionTable);
        await db.execute(Tables.createUsersTable);
        await db.execute(Tables.createServicesTable);
        await db.execute(Tables.createDatesTable);
        
      },
    );

    return _db!;
  }

  static Future<Database> get database async => await initDB();

  // ---------- exportDB corregida ----------
  static Future<void> exportDB() async {
    try {
      final dbPath = join(await getDatabasesPath(), dbName);

      // Carpeta media (para debugear en Android)
      final exportDir = Directory(
        "/storage/emulated/0/Android/media/com.example.leofluter",
      );

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final exportPath = join(exportDir.path, "badger_export.db");

      await File(dbPath).copy(exportPath);

      print("======================================");
      print("Se exporto la bd:");
      print(exportPath);
      print("======================================");
    } catch (e) {
      print("Error: $e");
    }
  }
}
