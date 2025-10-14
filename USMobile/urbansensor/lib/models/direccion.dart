class Direccion {
  final int pollId;
  final String calle;
  final String numero;
  final String comuna;

  Direccion({
    required this.pollId,
    required this.calle,
    required this.numero,
    required this.comuna,
  });

  // Convierte un objeto Direccion a un mapa para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'poll_id':pollId,
      'calle': calle,
      'numero': numero,
      'comuna': comuna,
    };
  }

  // Crea un objeto Direccion desde un mapa o JSON
  factory Direccion.fromJson(Map<String, dynamic> json) {
    return Direccion(
      pollId: json['poll_id'] as int? ?? 0,
      calle: json['calle'] as String? ?? '',
      numero: json['numero'] as String? ?? '',
      comuna: json['comuna'] as String? ?? '',
    );
  }

  // Crea un objeto Direccion desde un mapa de la base de datos
  factory Direccion.fromMap(Map<String, dynamic> map) {
    return Direccion(
      pollId: map['poll_id'] as int? ?? 0,
      calle: map['calle'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      comuna: map['comuna'] as String? ?? '',
    );
  }

  // Convierte un objeto Direccion a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'poll_id': pollId,
      'calle': calle,
      'numero': numero,
      'comuna': comuna,
    };
  }
}