class ServiceDto {
  final String servicio;
  final String descripcion;
  final double precio;
  final String img;

  ServiceDto({
    required this.servicio,
    required this.descripcion,
    required this.precio,
    required this.img,
  });

  Map<String, dynamic> toMap() {
    return {
      'servicio': servicio,
      'descripcion': descripcion,
      'precio': precio,
      'img': img,
    };
  }
}
