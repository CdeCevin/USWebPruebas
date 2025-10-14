class Poll {
  final int id;
  final int userId;
  final int incidentId;
  final String name;
  final String state;
  final String created;
  final String updated;

  Poll({
    required this.id,
    required this.userId,
    required this.incidentId,
    required this.name,
    required this.state,
    required this.created,
    required this.updated,
  });

  // Convierte un objeto Poll a un mapa para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'incident_id': incidentId,
      'name': name,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }

  // Crea un objeto Poll desde un mapa de la base de datos
  factory Poll.fromJson(Map<String, dynamic> json) {
    return Poll(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      incidentId: json['incident_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      state: json['state'] as String? ?? '',
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      incidentId: map['incident_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      state: map['state'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'incident_id': incidentId,
      'name': name,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }
}
