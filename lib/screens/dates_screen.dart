import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final db = await _dateDao.dbHelper;
      final result = await db.query(
        'dates',
        where: 'user_id = ?',
        whereArgs: [widget.currentUser.id],
        orderBy: 'fecha DESC, hora DESC',
      );

      if (result.isEmpty) {
        setState(() {
          _appointments = [];
          _isLoading = false;
        });
        return;
      }

      // Cargar todos los servicios una sola vez
      final allServices = await _serviceDao.getAllServices();
      final serviceMap = {for (var service in allServices) service.id: service};

      final appointments = <Map<String, dynamic>>[];
      for (var dateMap in result) {
        final serviceId = dateMap['asunto'];
        final service = serviceMap[serviceId];
        if (service != null) {
          appointments.add({'date': Date.fromMap(dateMap), 'service': service});
        }
      }

      setState(() {
        _appointments = appointments;
        _isLoading = false;
      });
    } catch (e) {
      print("Error al cargar citas: $e");
      setState(() {
        _isLoading = false;
      });
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
        final db = await _dateDao.dbHelper;
        await db.delete('dates', where: 'id = ?', whereArgs: [appointmentId]);
        _loadAppointments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita cancelada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes citas agendadas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                final date = appointment['date'] as Date;
                final service = appointment['service'] as Service;

                // Parsear la fecha y hora (formato guardado: dd-MM-yyyy HH:mm)
                try {
                  final dateParts = date.fecha.split('-');
                  final timeParts = date.hora.split(':');
                  final dateTime = DateTime(
                    int.parse(dateParts[2]), // año
                    int.parse(dateParts[1]), // mes
                    int.parse(dateParts[0]), // día
                    int.parse(timeParts[0]), // hora
                    int.parse(timeParts[1]), // minuto
                  );

                  return AppointmentCard(
                    service: service,
                    date: date,
                    dateTime: dateTime,
                    onDelete: () => _deleteAppointment(date.id),
                  );
                } catch (e) {
                  print("Error al parsear fecha: $e");
                  return const SizedBox.shrink();
                }
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
