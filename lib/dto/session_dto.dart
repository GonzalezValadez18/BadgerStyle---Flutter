class SessionDto {
  final int activo;
  final int? idUsuario;

  SessionDto({required this.activo, this.idUsuario});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{'activo': activo};
    if (idUsuario != null) {
      map['id_usuario'] = idUsuario;
    }
    return map;
  }
}
