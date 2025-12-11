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
      precio: double.tryParse(map['precio'].toString()) ?? 0.0,
      img: map['img'] as String,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'servicio': servicio,
      'descripcion': descripcion,
      'precio': precio,
      'img': img,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
