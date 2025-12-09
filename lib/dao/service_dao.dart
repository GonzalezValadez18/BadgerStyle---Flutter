import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/service_dto.dart';
import 'package:leofluter/models/service_model.dart';
import 'package:sqflite/sqflite.dart';

class ServiceDao {
  final dbHelper = DatabaseHelper.database;

  Future<int> insertService(ServiceDto serviceDto) async {
    try {
      final db = await dbHelper;
      final id = await db.insert(
        'services',
        serviceDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Servicio creado con éxito con ID: $id');
      return id;
    } catch (e) {
      print("Error al insertar servicio: $e");
      return -1;
    }
  }

  Future<List<Service>> getAllServices() async {
    try {
      final db = await dbHelper;
      final List<Map<String, dynamic>> maps = await db.query('services');

      if (maps.isEmpty) {
        print("No se encontraron servicios.");
        return [];
      }

      return List.generate(maps.length, (i) {
        return Service.fromMap(maps[i]);
      });
    } catch (e) {
      print("Error al obtener todos los servicios: $e");
      return [];
    }
  }

  Future<int> countServices() async {
    final db = await dbHelper;
    final result = await db.rawQuery('SELECT COUNT(*) FROM services');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
