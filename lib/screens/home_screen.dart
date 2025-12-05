import 'package:flutter/material.dart';
import 'package:leofluter/dao/session_dao.dart';
import 'package:leofluter/dao/user_dao.dart';
import 'package:leofluter/dto/session_dto.dart';
import 'package:leofluter/models/user_model.dart';
import 'package:leofluter/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionDao _sessionDao = SessionDao();
  final UserDao _userDao = UserDao();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final userId = await _sessionDao.getActiveUserId();
    if (userId != null) {
      final user = await _userDao.getUserById(userId);
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Badger Style',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (_currentUser != null)
              UserAccountsDrawerHeader(
                accountName: Text(
                  _currentUser!.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                accountEmail: Text(
                  "${_currentUser!.username}\n${_currentUser!.email}",
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: const Color(0xFF1A237E),
                  ),
                ),
                decoration: const BoxDecoration(color: Color(0xFF1A237E)),
              ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirmar Cierre de Sesión'),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar la sesión?',
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await _sessionDao.createSession(SessionDto(activo: 0));
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: const [
            ServiceCard(
              image: "assets/images/services/corte-hombre.webp",
              title: "Corte de Cabello Hombre",
              description: "Corte moderno, clásico y con estilo personalizado.",
              price: 120,
            ),
            ServiceCard(
              image: "assets/images/services/corte-mujer.webp",
              title: "Corte de Cabello Mujer",
              description: "Corte a la moda adaptado a tu estilo único.",
              price: 120,
            ),
            ServiceCard(
              image: "assets/images/services/corte-nino.webp",
              title: "Corte de Cabello Niño",
              description: "Corte cómodo y divertido para los más pequeños.",
              price: 120,
            ),
            ServiceCard(
              image: "assets/images/services/afeitado.webp",
              title: "Afeitado de Barba",
              description: "Afeitado a navaja con toalla caliente.",
              price: 100,
            ),
            ServiceCard(
              image: "assets/images/services/tinte.webp",
              title: "Tinte de Cabello",
              description: "Coloración profesional de alta calidad.",
              price: 250,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final double price;

  const ServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen del servicio
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.asset(image, height: 170, fit: BoxFit.cover),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Descripción
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 12),

                // Precio
                Text(
                  "\$${price.toStringAsFixed(0)} MXN",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),

                const SizedBox(height: 14),

                // Botón de agendar cita
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navegar a pantalla de citas
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Agendar Cita",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
