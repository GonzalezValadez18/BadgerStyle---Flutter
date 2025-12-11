import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/date_dto.dart';
import 'package:leofluter/models/user_model.dart';
import 'package:leofluter/models/date_model.dart'; // Assuming a Date model exists
import 'package:sqflite/sqflite.dart';

class DateDao {
  final dbHelper = DatabaseHelper.database;

  // Este método es probablemente para inserciones en la base de datos local.
  // Se mantiene aquí por completitud, pero la llamada a la API se usará para agendar.
  Future<int> insertDate(DateDto dateDto) async {
    try {
      final db = await dbHelper;
      final id = await db.insert(
        'dates', // Asumiendo que el nombre de la tabla es 'dates'
        dateDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Cita local creada con éxito con ID: $id');
      return id;
    } catch (e) {
      print("Error al insertar cita local: $e");
      return -1;
    }
  }

  Future<int> scheduleAppointmentApi(DateDto dateDto) async {
    try {
      // 1. Obtener el token del usuario desde la base de datos local
      final db = await dbHelper;
      final List<Map<String, dynamic>> userMaps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [dateDto.userId],
        limit: 1,
      );

      if (userMaps.isEmpty || userMaps.first['token'] == null) {
        throw Exception('Usuario no autenticado o token no encontrado.');
      }

      final token = userMaps.first['token'] as String;

      final url = Uri.parse(
        // URL actualizada para incluir el ID de usuario, como se solicitó.
        'http://10.0.2.2:8000/api/dates',
      );
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // 2. Añadir el token a la cabecera
        },
        body: jsonEncode(
          dateDto.toMapForApi(),
        ), // Usamos el mapeo específico para la API
      );

      if (response.statusCode == 201) {
        // 201 Created indica éxito
        final responseData = jsonDecode(response.body);
        int? newId;
        // Intentamos obtener el ID de la cita creada, que puede venir directamente o anidado
        if (responseData.containsKey('id')) {
          newId = responseData['id'];
        } else if (responseData.containsKey('date') &&
            responseData['date'].containsKey('id')) {
          newId = responseData['date']['id'];
        }

        if (newId != null) {
          print('Cita agendada en el servidor con ID: $newId');
          return newId;
        } else {
          print(
            'Cita agendada en el servidor, pero no se pudo obtener el ID. Asumiendo éxito.',
          );
          return 1; // Indicar éxito si el ID no se devuelve explícitamente pero el estado es 201
        }
      } else {
        final errorData = jsonDecode(response.body);
        print(
          'Error al agendar cita en el servidor - Código de estado: ${response.statusCode}',
        );
        print('Respuesta del servidor: ${response.body}');
        // Manejo de errores de validación de Laravel (código 422)
        if (response.statusCode == 422 && errorData['errors'] != null) {
          final errors = errorData['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          throw Exception(
            firstError.toString(),
          ); // Lanzar el primer error de validación
        }
        throw Exception(
          errorData['message'] ?? 'Error desconocido al agendar cita.',
        );
      }
    } on http.ClientException catch (e) {
      print("Error de conexión al agendar cita: $e");
      throw Exception(
        "Error de conexión: Asegúrate de que el servidor esté corriendo y la URL/IP sea correcta.",
      );
    } catch (e) {
      print("Error inesperado al agendar cita: $e");
      rethrow; // Re-lanzar para que la UI lo pueda manejar
    }
  }

  // Nuevo método para obtener las citas de un usuario desde la API
  Future<List<Date>> getDatesFromApi(int userId) async {
    try {
      // 1. Obtener el token del usuario desde la base de datos local
      final db = await dbHelper;
      final List<Map<String, dynamic>> userMaps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (userMaps.isEmpty || userMaps.first['token'] == null) {
        throw Exception('Usuario no autenticado o token no encontrado.');
      }
      final token = userMaps.first['token'] as String;

      // 2. Realizar la petición GET a la API
      final url = Uri.parse('http://10.0.2.2:8000/api/dates/$userId');
      final response = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      // 3. Procesar la respuesta
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> datesJson = responseData['dates'];
        final dates = datesJson.map((json) => Date.fromMap(json)).toList();
        return dates;
      } else {
        // Si la respuesta no es 200, lanza un error con el mensaje del servidor
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Error de la API (${response.statusCode}): ${errorData['message']}',
        );
      }
    } catch (e) {
      print("Error al obtener citas desde la API: $e");
      rethrow; // Re-lanzar para que la UI pueda manejarlo
    }
  }
}
