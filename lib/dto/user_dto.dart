class UserDto {
  final String nombre;
  final String email;
  final String password;
  final String username;

  UserDto({
    required this.nombre,
    required this.email,
    required this.password,
    required this.username,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'password':
          password, // Idealmente, la contraseña debería ser hasheada aquí o en el DAO.
      'username': username,
    };
  }
}
