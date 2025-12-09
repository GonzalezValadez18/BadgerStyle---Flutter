class Date {
  final int id;
  final int asunto; // service_id
  final String fecha;
  final String hora;
  final int userId;
  final String createdAt;
  final String updatedAt;

  Date({
    required this.id,
    required this.asunto,
    required this.fecha,
    required this.hora,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Date.fromMap(Map<String, dynamic> map) {
    return Date(
      id: map['id'],
      asunto: map['asunto'],
      fecha: map['fecha'],
      hora: map['hora'],
      userId: map['user_id'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
