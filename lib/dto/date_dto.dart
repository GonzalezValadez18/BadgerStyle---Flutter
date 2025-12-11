class DateDto {
  final int asunto; // Corresponds to service_id
  final int userId;
  final String fecha;
  final String hora;

  DateDto({
    required this.asunto,
    required this.userId,
    required this.fecha,
    required this.hora,
  });

  Map<String, dynamic> toMap() {
    return {'asunto': asunto, 'userId': userId, 'fecha': fecha, 'hora': hora};
  }

  Map<String, dynamic> toMapForApi() {
    return {
      'asunto': asunto,
      'user_id': userId, // Corrected for API
      'fecha': fecha,
      'hora': hora,
    };
  }
}
