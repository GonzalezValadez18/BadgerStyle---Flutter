import 'package:flutter/material.dart';
import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------
  // 1. Inicializa la base de datos
  // ------------------------------------
  await DatabaseHelper.initDB();

  // ------------------------------------
  // 2. Exportar automáticamente la BD
  //    (solo para pruebas)
  // ------------------------------------
  await DatabaseHelper.exportDB();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
