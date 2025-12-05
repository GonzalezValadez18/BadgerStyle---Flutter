class Session {
  final int id;
  final int activo;
  final int? idUsuario;
  final String createdAt;
  final String updatedAt;

  Session({
    required this.id,
    required this.activo,
    this.idUsuario,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'],
      activo: map['activo'],
      idUsuario: map['id_usuario'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'activo': activo, 'id_usuario': idUsuario};
  }
}
