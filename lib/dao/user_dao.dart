import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/user_dto.dart';
import 'package:leofluter/models/user_model.dart';
import 'package:sqflite/sqflite.dart';

class UserDao {
  final dbHelper = DatabaseHelper.database;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> registerUser(UserDto userDto) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': userDto.nombre,
          'username': userDto.username,
          'email': userDto.email,
          'password': userDto.password,
          'password_confirmation':
              userDto.password, // Laravel lo usa para validar
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 201 Created
        // El registro fue exitoso, devolvemos el usuario creado.
        return User.fromMap(responseData['user']);
      }

      // Si hay errores de validación (código 422)
      if (response.statusCode == 422 && responseData['errors'] != null) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        // Tomamos el primer mensaje de error y lo lanzamos.
        final firstError = errors.values.first;
        throw Exception(firstError);
      }

      throw Exception(
        responseData['message'] ?? 'Ocurrió un error desconocido.',
      );
    } catch (e) {
      print("Error en registerUser: $e");
      rethrow; // Re-lanzamos la excepción para que la UI la pueda manejar.
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      // URL de tu endpoint de login en Laravel
      // Usamos 10.0.2.2 para conectar desde el emulador de Android al localhost de tu PC.
      final url = Uri.parse('http://10.0.2.2:8000/api/login');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Si el login es exitoso (código 200 OK)
        final responseData = jsonDecode(response.body);

        // Laravel a menudo devuelve los datos del usuario dentro de una clave 'user'
        // y un 'token'. Ajusta esto según la respuesta de tu API.
        final userData = responseData['user'];

        // 1. Convertimos los datos de la API a nuestro modelo User.
        final user = User.fromMap(userData);

        // 2. Guardamos o actualizamos el usuario en la base de datos local.
        final db = await dbHelper;
        final userMap = user.toMap();

        // Usamos 'update' en lugar de 'insert' con 'replace' para no tocar la contraseña.
        // El método 'update' devuelve el número de filas afectadas.
        int rowsAffected = await db.update(
          'users',
          userMap,
          where: 'id = ?',
          whereArgs: [user.id],
        );

        // Si no se actualizó ninguna fila (porque el usuario no existía localmente), lo insertamos.
        if (rowsAffected == 0) {
          await db.insert(
            'users',
            userMap..['password'] = '',
          ); // Insertamos con password vacío
        }
        // (Opcional) Aquí puedes guardar el token para futuras peticiones.
        // final token = responseData['token'];

        // 3. Devolvemos el objeto 'user' para que la app continúe.
        return user;
      }
      // Si el código no es 200, el login falló.
      // Imprimimos más detalles para poder depurar.
      print('Error en el login - Código de estado: ${response.statusCode}');
      print('Respuesta del servidor: ${response.body}');
      return null;
    } on http.ClientException catch (e) {
      // Esto suele ser un error de conexión (red, DNS, etc.)
      print("Error de conexión en el login: $e");
      print(
        "Asegúrate de que el servidor de Laravel esté corriendo y la URL/IP sea correcta.",
      );
      return null;
    } catch (e) {
      // Otros errores (ej. JSON mal formado, etc.)
      print("Error inesperado en el login: $e");
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
