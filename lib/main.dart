import 'package:flutter/material.dart';
import 'package:leofluter/dao/session_dao.dart';
import 'package:leofluter/database/database_helper.dart';
import 'package:leofluter/screens/home_screen.dart';
import 'package:leofluter/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ------------------------------------
  // 1. Inicializa la base de datos
  // ------------------------------------
  await DatabaseHelper.initDB();

  // (Opcional) Exportar la BD para pruebas
  await DatabaseHelper.exportDB();

  // ------------------------------------
  // 2. Verificar si hay una sesión activa
  // ------------------------------------
  final sessionDao = SessionDao();
  final activeUserId = await sessionDao.getActiveUserId();

  // ------------------------------------
  // 3. Definir la pantalla inicial
  // ------------------------------------
  final Widget initialScreen = activeUserId != null
      ? const HomeScreen()
      : const LoginScreen();

  runApp(MainApp(initialScreen: initialScreen));
}

class MainApp extends StatelessWidget {
  final Widget initialScreen;
  const MainApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: initialScreen);
  }
}
