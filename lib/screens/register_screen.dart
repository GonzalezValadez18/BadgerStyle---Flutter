import 'package:flutter/material.dart';
import 'package:leofluter/dao/user_dao.dart';
import 'package:leofluter/dto/user_dto.dart';
import 'package:leofluter/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final UserDao _userDao = UserDao();

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final userDto = UserDto(
        nombre: _nameController.text,
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      final id = await _userDao.insertUser(userDto);

      if (id != -1) {
        print('Usuario registrado con éxito con ID: $id');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // Mostrar un error
        print('Error al registrar el usuario');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
            if (!isKeyboardOpen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/login-background.webp",
                  height: screenHeight * 0.40,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            // ---------- FORMULARIO ----------
            Positioned.fill(
              top: isKeyboardOpen ? 0 : screenHeight * 0.25,
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
                            "Crear una Cuenta",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),
                          // ---------- NOMBRE ----------
                          _buildTextFormField(
                            controller: _nameController,
                            hintText: "Nombre completo",
                          ),
                          const SizedBox(height: 18),
                          // ---------- USERNAME ----------
                          _buildTextFormField(
                            controller: _usernameController,
                            hintText: "Nombre de usuario",
                          ),
                          const SizedBox(height: 18),
                          // ---------- EMAIL ----------
                          _buildTextFormField(
                            controller: _emailController,
                            hintText: "Correo electrónico",
                          ),
                          const SizedBox(height: 18),
                          // ---------- PASSWORD ----------
                          _buildTextFormField(
                            controller: _passwordController,
                            hintText: "Contraseña",
                            obscureText: true,
                          ),
                          const SizedBox(height: 18),
                          // ---------- CONFIRM PASSWORD ----------
                          _buildTextFormField(
                            controller: _confirmPasswordController,
                            hintText: "Confirmar contraseña",
                            obscureText: true,
                          ),
                          const SizedBox(height: 25),
                          // ---------- BOTÓN REGISTRO ----------
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _registerUser,
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
                              child: const Text("Registrarse"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // ---------- SIGN IN ----------
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("¿Ya tienes una cuenta? "),
                                Text(
                                  "Inicia Sesión",
                                  style: TextStyle(
                                    color: Color(0xFF536DFE),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
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
          return 'Este campo es obligatorio';
        }
        if (hintText == "Confirmar contraseña") {
          if (value != _passwordController.text) {
            return 'Las contraseñas no coinciden';
          }
        }
        if (hintText == "Correo electrónico") {
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Ingresa un correo electrónico válido';
          }
        }
        return null;
      },
    );
  }
}
