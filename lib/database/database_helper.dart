import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:leofluter/dao/service_dao.dart';
import 'package:leofluter/dto/service_dto.dart';
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
        // La tabla de sesión ya no es necesaria si el token está en users
        // y la presencia de un token puede indicar una sesión activa.
        // Por simplicidad, la mantenemos por ahora, pero podría refactorizarse.
        await db.execute(Tables.createSesionTable);

        await db.execute(Tables.createUsersTable);
        await db.execute(Tables.createServicesTable);
        await db.execute(Tables.createDatesTable);

        // Ya no insertamos servicios iniciales desde aquí, vendrán de la API.
        // await _insertInitialServices(db);
      },
    );

    return _db!;
  }

  static Future<void> _insertInitialServices(Database db) async {
    final servicesToInsert = [
      ServiceDto(
        servicio: "Corte de Cabello Hombre",
        descripcion: "Corte moderno, clásico y con estilo personalizado.",
        precio: 120,
        img: "assets/images/services/corte-hombre.webp",
      ),
      ServiceDto(
        servicio: "Corte de Cabello Mujer",
        descripcion: "Corte a la moda adaptado a tu estilo único.",
        precio: 120,
        img: "assets/images/services/corte-mujer.webp",
      ),
      ServiceDto(
        servicio: "Corte de Cabello Niño",
        descripcion: "Corte cómodo y divertido para los más pequeños.",
        precio: 120,
        img: "assets/images/services/corte-nino.webp",
      ),
      ServiceDto(
        servicio: "Afeitado de Barba",
        descripcion: "Afeitado a navaja con toalla caliente.",
        precio: 100,
        img: "assets/images/services/afeitado.webp",
      ),
      ServiceDto(
        servicio: "Tinte de Cabello",
        descripcion: "Coloración profesional de alta calidad.",
        precio: 250,
        img: "assets/images/services/tinte.webp",
      ),
    ];

    for (final serviceDto in servicesToInsert) {
      await db.insert(
        'services',
        serviceDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    print(">>> ${servicesToInsert.length} SERVICIOS INICIALES INSERTADOS <<<");
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
