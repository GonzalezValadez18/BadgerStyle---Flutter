import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/user_dto.dart';
import 'package:leofluter/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final dbHelper = DatabaseHelper.database;

  Future<int> insertUser(UserDto userDto) async {
    try {
      final db = await dbHelper;
      // Aquí es un buen lugar para hashear la contraseña antes de guardarla
      // por ejemplo, usando un paquete como `crypto`.
      final id = await db.insert(
        'users',
        userDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      print("Error al insertar usuario: $e");
      return -1;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      final db = await dbHelper;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: '(username = ? OR email = ?) AND password = ?',
        whereArgs: [username, username, password],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print("Error en el login: $e");
      return null;
    }
  }

  Future<User?> getUserById(int id) async {
    try {
      final db = await dbHelper;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return User.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      print("Error al obtener usuario por ID: $e");
      return null;
    }
  }
}
