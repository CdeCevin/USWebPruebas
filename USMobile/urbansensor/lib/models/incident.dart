class Incident {
  final int id;
  final int userId;
  final int managementId;
  final int deparmentId;
  final String name;
  final String state;
  final String created;
  final String updated;

  Incident({
    required this.id,
    required this.userId,
    required this.managementId,
    required this.deparmentId,
    required this.name,
    required this.state,
    required this.created,
    required this.updated,
  });

  // Convierte un objeto Incident a un mapa para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'management_id': managementId,
      'deparment_id': deparmentId,
      'name': name,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }

  // Crea un objeto Incident desde un mapa de la base de datos
  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      managementId: json['management_id'] as int? ?? 0,
      deparmentId: json['deparment_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  // Método fromMap
  factory Incident.fromMap(Map<String, dynamic> map) {
    return Incident(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      managementId: map['management_id'] as int? ?? 0,
      deparmentId: map['deparment_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      state: map['state'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
    );
  }

  // Método toMap para convertir la instancia en un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'management_id': managementId,
      'deparment_id': deparmentId,
      'name': name,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }
}
