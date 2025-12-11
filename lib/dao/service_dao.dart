import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // Nuevo método para sincronizar desde la API
  Future<List<Service>> syncServicesFromApi() async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/services');
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> servicesJson = jsonDecode(response.body);
        final List<Service> services = servicesJson
            .map((json) => Service.fromMap(json))
            .toList();

        // Una vez obtenidos los servicios, los guardamos en la BD local
        await _cacheServices(services);
        return services;
      } else {
        // Si la API falla, intentamos cargar desde la caché
        print('Error de API: ${response.statusCode}. Cargando desde caché.');
        return getAllServices();
      }
    } catch (e) {
      // Si hay un error de conexión, también cargamos desde la caché
      print('Error de conexión: $e. Cargando desde caché.');
      return getAllServices();
    }
  }

  // Método para guardar los servicios en la BD local
  Future<void> _cacheServices(List<Service> services) async {
    final db = await dbHelper;
    final batch = db.batch();

    // Limpiar la tabla antes de insertar para eliminar servicios viejos
    batch.delete('services');

    for (final service in services) {
      batch.insert(
        'services',
        service.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
