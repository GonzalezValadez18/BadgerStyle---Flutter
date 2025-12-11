class User {
  final int? id;
  final String nombre;
  final String email;
  final String password;
  final String username;
  final String? createdAt;
  final String? updatedAt;
  final String? token;

  User({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.username,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nombre:
          map['name'] ??
          map['nombre'], // Acepta 'name' de Laravel o 'nombre' de la BD local
      email: map['email'],
      password:
          map['password'] ?? '', // La contraseña no debería venir del servidor
      username: map['username'] ?? '',
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
      token: map['token'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      // No incluimos la contraseña al convertir a mapa para evitar sobreescribir hashes locales.
      'username': username,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'token': token,
    };
  }
}
