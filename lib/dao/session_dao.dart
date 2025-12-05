import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/session_dto.dart';
import 'package:sqflite/sqflite.dart';

class SessionDao {
  final dbHelper = DatabaseHelper.database;

  Future<int> createSession(SessionDto sessionDto) async {
    try {
      final db = await dbHelper;
      // Desactivar cualquier otra sesión activa
      await db.update('session', {
        'activo': 0,
        'id_usuario': null,
      }, where: 'activo = 1');

      final id = await db.insert(
        'session',
        sessionDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Sesión creada con éxito con ID: $id');
      return id;
    } catch (e) {
      print("Error al crear la sesión: $e");
      return -1;
    }
  }

  Future<int?> getActiveUserId() async {
    try {
      final db = await dbHelper;
      final List<Map<String, dynamic>> maps = await db.query(
        'session',
        columns: ['id_usuario'],
        where: 'activo = 1',
        limit: 1,
      );

      if (maps.isNotEmpty && maps.first['id_usuario'] != null) {
        return maps.first['id_usuario'] as int;
      }
      return null;
    } catch (e) {
      print("Error al obtener el ID de usuario activo: $e");
      return null;
    }
  }
}
