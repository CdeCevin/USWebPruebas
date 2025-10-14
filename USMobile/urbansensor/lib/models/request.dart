class Request {
  final int id; // ID único de la solicitud
  final int userId;
  final int pollId;
  final int departmentId;
  final int brigadeId;
  final String requestName;
  final String requestDate;
  final String? requestDelivery; // Campo que puede ser null
  final String? requestAccept; // Campo que puede ser null
  final String? requestClose; // Campo que puede ser null
  final String requestFinish;
  final String requestState;
  final String created;
  final String updated;

  Request({
    required this.id,
    required this.userId,
    required this.pollId,
    required this.departmentId,
    required this.brigadeId,
    required this.requestName,
    required this.requestDate,
    this.requestDelivery,
    this.requestAccept,
    this.requestClose,
    required this.requestFinish,
    required this.requestState,
    required this.created,
    required this.updated,
  });

  // Convierte un objeto Request a un mapa para la base de datos o JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'poll': pollId,
      'department': departmentId,
      'brigade': brigadeId,
      'request_name': requestName,
      'request_date': requestDate,
      'request_delivery': requestDelivery,
      'request_accept': requestAccept,
      'request_close': requestClose,
      'request_finish': requestFinish,
      'request_state': requestState,
      'created': created,
      'updated': updated,
    };
  }

  // Crea un objeto Request desde un mapa o JSON
  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'] as int? ?? 0,
      userId: json['user'] as int? ?? 0,
      pollId: json['poll'] as int? ?? 0,
      departmentId: json['department'] as int? ?? 0,
      brigadeId: json['brigade'] as int? ?? 0,
      requestName: json['request_name'] as String? ?? '',
      requestDate: json['request_date'] as String? ?? '',
      requestDelivery: json['request_delivery'] as String?,
      requestAccept: json['request_accept'] as String?,
      requestClose: json['request_close'] as String?,
      requestFinish: json['request_finish'] as String? ?? '',
      requestState: json['request_state'] as String? ?? '',
      created: json['created'] as String? ?? '',
      updated: json['updated'] as String? ?? '',
    );
  }

  // Crea un objeto Request desde un mapa de la base de datos
  factory Request.fromMap(Map<String, dynamic> map) {
    return Request(
      id: map['id'] as int? ?? 0,
      userId: map['user_id'] as int? ?? 0,
      pollId: map['poll_id'] as int? ?? 0,
      departmentId: map['department_id'] as int? ?? 0,
      brigadeId: map['brigade_id'] as int? ?? 0,
      requestName: map['request_name'] as String? ?? '',
      requestDate: map['request_date'] as String? ?? '',
      requestDelivery: map['request_delivery'] as String?,
      requestAccept: map['request_accept'] as String?,
      requestClose: map['request_close'] as String?,
      requestFinish: map['request_finish'] as String? ?? '',
      requestState: map['request_state'] as String? ?? '',
      created: map['created'] as String? ?? '',
      updated: map['updated'] as String? ?? '',
    );
  }

  // Convierte un objeto Request a un mapa para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'poll_id': pollId,
      'department_id': departmentId,
      'brigade_id': brigadeId,
      'request_name': requestName,
      'request_date': requestDate,
      'request_delivery': requestDelivery,
      'request_accept': requestAccept,
      'request_close': requestClose,
      'request_finish': requestFinish,
      'request_state': requestState,
      'created': created,
      'updated': updated,
    };
  }
}
