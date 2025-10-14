class Field {
  final int id;
  final int userId;
  final int pollId;
  final String name;
  final String label;
  final String placeholder;
  final String kind;
  final String kindField;
  final String state;
  final String created;
  final String updated;

  Field({
    required this.id,
    required this.userId,
    required this.pollId,
    required this.name,
    required this.label,
    required this.placeholder,
    required this.kind,
    required this.kindField,
    required this.state,
    required this.created,
    required this.updated,
  });

  // Convierte un objeto Field a un mapa para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'poll_id': pollId,
      'name': name,
      'label': label,
      'placeholder': placeholder,
      'kind': kind,
      'kind_field': kindField,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }

  // Crea un objeto Field desde un mapa de la base de datos
  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      pollId: json['poll_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      label: json['label'] as String? ?? '',
      placeholder: json['placeholder'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      kindField: json['kind_field'] as String? ?? '',
      state: json['state'] as String? ?? '',
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  factory Field.fromMap(Map<String, dynamic> map) {
    return Field(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      pollId: map['poll_id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      label: map['label'] as String? ?? '',
      placeholder: map['placeholder'] as String? ?? '',
      kind: map['kind'] as String? ?? '',
      kindField: map['kind_field'] as String? ?? '',
      state: map['state'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'poll_id': pollId,
      'name': name,
      'label': label,
      'placeholder': placeholder,
      'kind': kind,
      'kind_field': kindField,
      'state': state,
      'created': created,
      'updated': updated,
    };
  }
}
