class RequestAnswer {
  final int id;
  final int requestId;
  final int userId;
  final int fieldId;
  final String requestAnswerText;
  final String created;
  final String updated;

  RequestAnswer({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.fieldId,
    required this.requestAnswerText,
    required this.created,
    required this.updated,
  });

  // Convierte un objeto RequestAnswer a un mapa para la base de datos o JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request': requestId,  // Correspondiente al JSON
      'user': userId,
      'fields': fieldId,  // Correspondiente al JSON
      'request_answer_text': requestAnswerText,
      'created': created,
      'updated': updated,
    };
  }

  // Crea un objeto RequestAnswer desde un mapa o JSON
  factory RequestAnswer.fromJson(Map<String, dynamic> json) {
    return RequestAnswer(
      id: json['id'] as int? ?? 0,
      requestId: json['request'] as int? ?? 0,  // Correspondiente al JSON
      userId: json['user'] as int? ?? 0,
      fieldId: json['fields'] as int? ?? 0,  // Correspondiente al JSON
      requestAnswerText: json['request_answer_text'] as String? ?? '',
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  // Crea un objeto RequestAnswer desde un mapa de la base de datos
  factory RequestAnswer.fromMap(Map<String, dynamic> map) {
    return RequestAnswer(
      id: map['id'] as int? ?? 0,
      requestId: map['request_id'] as int? ?? 0,  // Debe coincidir con el campo en la base de datos
      userId: map['user_id'] as int? ?? 0,
      fieldId: map['field_id'] as int? ?? 0,
      requestAnswerText: map['request_answer_text'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
    );
  }

  // Convierte un objeto RequestAnswer a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'request_id': requestId,  // Correspondiente a la base de datos
      'user_id': userId,
      'field_id': fieldId,
      'request_answer_text': requestAnswerText,
      'created': created,
      'updated': updated,
    };
  }
}