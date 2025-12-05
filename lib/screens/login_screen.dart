import 'package:flutter/material.dart';
import 'package:leofluter/dao/session_dao.dart';
import 'package:leofluter/dao/user_dao.dart';
import 'package:leofluter/dto/session_dto.dart';
import 'package:leofluter/screens/home_screen.dart';
import 'package:leofluter/screens/register_screen.dart';
import 'package:leofluter/utils/dialog_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserDao _userDao = UserDao();
  final SessionDao _sessionDao = SessionDao();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final user = await _userDao.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user != null) {
        // Crear la sesión
        await _sessionDao.createSession(
          SessionDto(activo: 1, idUsuario: user.id),
        );

        DialogHelper.showSuccessDialog(
          context: context,
          title: '¡Éxito!',
          message: 'Bienvenido de vuelta, ${user.nombre}.',
          onOk: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        );
      } else {
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Error de Autenticación',
          message: 'El usuario o la contraseña son incorrectos.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- IMAGEN DE FONDO ----------
            // Se oculta la imagen si el teclado está abierto
            if (!isKeyboardOpen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/login-background.webp",
                  height: screenHeight * 0.45,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            // ---------- FORMULARIO ----------
            Positioned.fill(
              // Se ajusta la posición superior si el teclado está abierto
              top: isKeyboardOpen ? 0 : screenHeight * 0.38,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TITULO
                          const Text(
                            "Hola, Bienvenido",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          // ---------- USERNAME ----------
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "Usuario",
                              filled: true,
                              fillColor: const Color(0xFFF0F0F0),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa un usuario o correo';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          // ---------- PASSWORD ----------
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Contraseña",
                              filled: true,
                              fillColor: const Color(0xFFF0F0F0),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              suffixIcon: const Icon(Icons.visibility_off),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          // ---------- FORGOT PASSWORD ----------
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Olvidaste tu contraseña?",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // ---------- BOTÓN LOGIN ----------
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loginUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A237E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text("Entrar"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ---------- SIGN UP ----------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("No tienes una cuenta? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Regístrate",
                                  style: TextStyle(
                                    color: Color(0xFF536DFE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
