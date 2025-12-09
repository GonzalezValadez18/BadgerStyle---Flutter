class Service {
  final int id;
  final String servicio;
  final String descripcion;
  final double precio;
  final String img;
  final String createdAt;
  final String updatedAt;

  Service({
    required this.id,
    required this.servicio,
    required this.descripcion,
    required this.precio,
    required this.img,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      servicio: map['servicio'],
      descripcion: map['descripcion'],
      precio: map['precio'],
      img: map['img'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }
}
