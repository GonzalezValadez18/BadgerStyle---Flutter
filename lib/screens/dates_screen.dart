import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:leofluter/dao/date_dao.dart';
import 'package:leofluter/dao/service_dao.dart';
import 'package:leofluter/models/date_model.dart';
import 'package:leofluter/models/service_model.dart';
import 'package:leofluter/models/user_model.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final User currentUser;

  const MyAppointmentsScreen({super.key, required this.currentUser});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final DateDao _dateDao = DateDao();
  final ServiceDao _serviceDao = ServiceDao();
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _appointmentsFuture = _loadAppointments();
  }

  Future<List<Map<String, dynamic>>> _loadAppointments() async {
    try {
      // 1. Obtener las citas desde la API usando el nuevo método del DAO
      final List<Date> apiDates = await _dateDao.getDatesFromApi(
        widget.currentUser.id!,
      );

      if (apiDates.isEmpty) {
        return [];
      }

      // 2. Obtener todos los servicios para mapearlos por ID
      final allServices = await _serviceDao.getAllServices();
      final serviceMap = {for (var s in allServices) s.id: s};

      // 3. Combinar citas con sus servicios correspondientes
      final appointments = <Map<String, dynamic>>[];
      for (final date in apiDates) {
        final service = serviceMap[date.asunto];
        if (service != null) {
          appointments.add({'date': date, 'service': service});
        }
      }

      // 4. Ordenar las citas de la más reciente a la más antigua
      appointments.sort((a, b) {
        final dateA = _parseDate(a['date'].fecha, a['date'].hora);
        final dateB = _parseDate(b['date'].fecha, b['date'].hora);
        return dateB.compareTo(dateA);
      });

      return appointments;
    } catch (e) {
      print("Error al cargar citas de la API: $e");
      // Si hay un error, lo lanzamos para que el FutureBuilder lo muestre
      throw Exception('No se pudieron cargar las citas. $e');
    }
  }

  DateTime _parseDate(String fecha, String hora) {
    try {
      // Formato esperado: dd-MM-yyyy
      final dateParts = fecha.split('-');
      final timeParts = hora.split(':');
      return DateTime(
        int.parse(dateParts[2]),
        int.parse(dateParts[1]),
        int.parse(dateParts[0]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
    } catch (e) {
      print("Error parseando fecha '$fecha' y hora '$hora': $e");
      return DateTime.now();
    }
  }

  Future<void> _deleteAppointment(int appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Cita'),
          content: const Text('¿Deseas cancelar esta cita?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí, Cancelar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        // TODO: Añadir el token de autorización a la petición de borrado
        // NOTA: El token ya se obtiene y usa en getDatesFromApi, aquí también se necesitaría.
        // Eliminar de la API del servidor
        final response = await http
            .delete(
              Uri.parse('http://10.0.2.2:8000/api/dates/$appointmentId'),
              headers: {'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 || response.statusCode == 204) {
          // No es necesario borrar de la BD local si siempre cargamos de la API

          // Recargar las citas
          setState(() {
            _appointmentsFuture = _loadAppointments();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita cancelada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cancelar la cita en el servidor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Error al eliminar cita: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cancelar la cita'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mis Citas'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes citas agendadas',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          final appointments = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              final date = appointment['date'] as Date;
              final service = appointment['service'] as Service;
              final dateTime = _parseDate(date.fecha, date.hora);

              return AppointmentCard(
                service: service,
                date: date,
                dateTime: dateTime,
                onDelete: () => _deleteAppointment(date.id),
              );
            },
          );
        },
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Service service;
  final Date date;
  final DateTime dateTime;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.service,
    required this.date,
    required this.dateTime,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPast = dateTime.isBefore(DateTime.now());

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isPast
                  ? Colors.grey.shade100
                  : const Color(0xFF1A237E).withOpacity(0.05),
              isPast ? Colors.grey.shade50 : Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen del servicio
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      service.img,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Información de la cita
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del servicio
                        Text(
                          service.servicio,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A237E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Fecha
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              DateFormat(
                                'EEEE, dd MMM',
                                'es_ES',
                              ).format(dateTime),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Hora
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              date.hora,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Estado
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isPast
                                ? Colors.grey.shade300
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isPast ? 'Completada' : 'Pendiente',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPast
                                  ? Colors.grey.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Precio
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${service.precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Botón de eliminar
            if (!isPast)
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.red.shade700,
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
