class DateDto {
  final int asunto; // service_id
  final String fecha;
  final String hora;
  final int userId;

  DateDto({
    required this.asunto,
    required this.fecha,
    required this.hora,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {'asunto': asunto, 'fecha': fecha, 'hora': hora, 'user_id': userId};
  }
}
