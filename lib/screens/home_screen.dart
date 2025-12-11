import 'package:flutter/material.dart';
import 'dart:async';
import 'package:leofluter/dao/session_dao.dart';
import 'package:leofluter/dao/service_dao.dart';
import 'package:leofluter/dao/user_dao.dart';
import 'package:leofluter/dto/session_dto.dart';
import 'package:leofluter/models/service_model.dart';
import 'package:leofluter/models/user_model.dart';
import 'package:leofluter/screens/login_screen.dart';
import 'package:leofluter/screens/book_date.dart';
import 'package:leofluter/screens/dates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionDao _sessionDao = SessionDao();
  final UserDao _userDao = UserDao();
  final ServiceDao _serviceDao = ServiceDao();
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadAllData();
  }

  Future<Map<String, dynamic>> _loadAllData() async {
    final userId = await _sessionDao.getActiveUserId();
    final user = userId != null ? await _userDao.getUserById(userId) : null;
    final services = await _serviceDao.syncServicesFromApi();

    // No pre-cargar imágenes, se cargarán bajo demanda en cada tarjeta
    return {'user': user, 'services': services};
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
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          final User? currentUser = snapshot.hasData
              ? snapshot.data!['user']
              : null;
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                if (currentUser != null)
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      currentUser.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    accountEmail: Text(
                      "${currentUser.username}\n${currentUser.email}",
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Color(0xFF1A237E),
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
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Mis Citas'),
                  onTap: () {
                    if (currentUser != null) {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyAppointmentsScreen(currentUser: currentUser),
                        ),
                      );
                    }
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
          );
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final User? currentUser = snapshot.data!['user'];
            final List<Service> services = snapshot.data!['services'];
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                return ServiceCard(
                  image: service.img,
                  title: service.servicio,
                  description: service.descripcion,
                  price: service.precio,
                  currentUser: currentUser,
                  service: service,
                );
              },
            );
          } else {
            return const Center(child: Text('No se encontraron datos.'));
          }
        },
      ),
    );
  }
}

class ServiceCard extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final double price;
  final User? currentUser;
  final Service service;

  const ServiceCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.currentUser,
    required this.service,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // Es importante llamar a super.build(context) cuando se usa el mixin.
    super.build(context);

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
            child: Image.asset(
              widget.image,
              height: 170,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error), // Manejo básico de errores
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                // Descripción
                Text(
                  widget.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const SizedBox(height: 12),

                // Precio
                Text(
                  "\$${widget.price.toStringAsFixed(0)} MXN",
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
                      if (widget.currentUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScheduleAppointmentScreen(
                              service: widget.service,
                              currentUser: widget.currentUser!,
                            ),
                          ),
                        );
                      }
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
