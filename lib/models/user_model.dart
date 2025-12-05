class User {
  final int? id;
  final String nombre;
  final String email;
  final String password;
  final String username;
  final String? createdAt;
  final String? updatedAt;

  User({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    required this.username,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nombre: map['nombre'],
      email: map['email'],
      password: map['password'],
      username: map['username'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'password': password,
      'username': username,
    };
  }
}
