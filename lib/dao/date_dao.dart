import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/dto/date_dto.dart';
import 'package:sqflite/sqflite.dart';

class DateDao {
  final dbHelper = DatabaseHelper.database;

  Future<int> insertDate(DateDto dateDto) async {
    try {
      final db = await dbHelper;
      final id = await db.insert(
        'dates',
        dateDto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return id;
    } catch (e) {
      print("Error al insertar la cita: $e");
      return -1;
    }
  }
}
