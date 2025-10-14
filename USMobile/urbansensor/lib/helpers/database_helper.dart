import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:urbansensor/endpoints/auth.dart';
import 'package:urbansensor/models/field.dart' as fie;
import 'package:urbansensor/models/poll.dart' as poll;
import 'package:urbansensor/models/incident.dart' as inc;
import 'package:urbansensor/models/request.dart';
import 'package:urbansensor/models/requestAnswer.dart';
import 'package:http/http.dart' as http;
import 'package:urbansensor/config/config.dart';
import 'dart:io'; // Para trabajar con archivos
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Para el MIME type
import 'package:mime/mime.dart'; // Para detectar el MIME type
import 'dart:convert'; // Para manejo de JSON
import 'package:http/http.dart' as multipart;

class DatabaseHelper {
  static final _databaseName = "EncuestasDB.db";
  static final _databaseVersion = 1;

  // URL base de tu servidor
  final String baseUrl = Config.baseUrl;

  // Nombre de la tabla existente
  static final tableEncuestas = 'encuestas';

  // Nombre de las nuevas tablas
  static final tableIncidents = 'incidents';
  static final tablePolls = 'polls';
  static final tableFields = 'fields';
  //static final tableRequest = 'request';
  static final tableDireccion = 'direccion';

  // Columnas de la tabla 'encuestas'
  static final columnId = 'id';
  static final columnPollId = 'poll_id';
  static final columnNameNeighbor = 'name_neighbor';
  static final columnRutNeighbor = 'rut_neighbor';
  static final columnMailNeighbor = 'mail_neighbor';
  static final columnPhoneNeighbor = 'phone_neighbor';
  static final columnIncidencePriority = 'incidence_priority';
  static final columnIncidenceDescription = 'incidence_description';
  static final columnIncidenceLatitud = 'incidence_latitud';
  static final columnIncidenceLongitud = 'incidence_longitud';
  static final columnIncidenceImages = 'incidence_images';
  static final columnIncidenceVideo = 'incidence_video';
  static final columnIncidenceAudio = 'incidence_audio';
  static final columnIsSynced = 'is_synced';

  // Columnas de la tabla 'incidents'
  static final columnIncidentUserId = 'user_id';
  static final columnIncidentManagementId = 'management_id';
  static final columnIncidentDeparmentId = 'deparment_id';
  static final columnIncidentName = 'name';
  static final columnIncidentState = 'state';
  static final columnIncidentCreated = 'created';
  static final columnIncidentUpdated = 'updated';

  // Columnas de la tabla 'polls'
  static final columnPollUserId = 'user_id';
  static final columnPollIncidentId = 'incident_id';
  static final columnPollName = 'name';
  static final columnPollState = 'state';
  static final columnPollCreated = 'created';
  static final columnPollUpdated = 'updated';

  // Columnas de la tabla 'fields'
  static final columnFieldUserId = 'user_id';
  static final columnFieldPollId = 'poll_id';
  static final columnFieldName = 'name';
  static final columnFieldLabel = 'label';
  static final columnFieldPlaceholder = 'placeholder';
  static final columnFieldKind = 'kind';
  static final columnFieldKindField = 'kind_field';
  static final columnFieldState = 'state';
  static final columnFieldCreated = 'created';
  static final columnFieldUpdated = 'updated';

  // Columnas de la tabla 'direccion'
  static final columnDireccionCalle = 'calle';
  static final columnDireccionNumero = 'numero';
  static final columnDireccionComuna = 'comuna';

  DatabaseHelper._privateConstructor();
  DatabaseHelper();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    //print('Creando tablas en la base de datos');

    await db.execute('''
    CREATE TABLE incidents (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      management_id INTEGER,
      deparment_id INTEGER,
      name TEXT,
      state TEXT,
      created TEXT,
      updated TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE polls (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      incident_id INTEGER,
      name TEXT,
      state TEXT,
      created TEXT,
      updated TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE fields (
      id INTEGER PRIMARY KEY,
      user_id INTEGER,
      poll_id INTEGER,
      name TEXT,
      label TEXT,
      placeholder TEXT,
      kind TEXT,
      kind_field TEXT,
      state TEXT,
      created TEXT,
      updated TEXT
    )
  ''');

    await db.execute('''
CREATE TABLE encuesta_respuesta (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  id_encuesta INTEGER NOT NULL,  -- ID único de la respuesta
  poll_id INTEGER NOT NULL,  -- Relacionada con la encuesta a la que pertenece
  field_id INTEGER NOT NULL,  -- Relacionada con el campo al que pertenece la respuesta
  respuesta_text TEXT,  -- La respuesta dada
  is_synced INTEGER NOT NULL DEFAULT 0,  -- Indica si ya fue sincronizada con el servidor (0: no, 1: sí)
  created TEXT NOT NULL,  -- Fecha de creación (timestamp)
  updated TEXT NOT NULL,  -- Fecha de última actualización (timestamp)
  UNIQUE (id_encuesta, field_id),  -- Asegura que no haya respuestas duplicadas para el mismo campo en la misma encuesta
  FOREIGN KEY (poll_id) REFERENCES polls (id),
  FOREIGN KEY (field_id) REFERENCES fields (id)
)
''');

    await db.execute('''
CREATE TABLE encuesta_detalles (
  id_encuesta INTEGER PRIMARY KEY,  -- ID único de la encuesta
  poll_id INTEGER NOT NULL,  -- ID de la encuesta, relaciona con encuesta_respuesta
  incidence_priority TEXT,    -- Prioridad de la incidencia
  incidence_latitud REAL,     -- Latitud de la incidencia
  incidence_longitud REAL,    -- Longitud de la incidencia
  incidence_images TEXT,       -- Rutas de las imágenes (puede ser un JSON o una cadena separada por comas)
  incidence_video TEXT,        -- Ruta del video
  incidence_audio TEXT,        -- Ruta del audio
  is_synced INTEGER DEFAULT 0, -- Indica si los datos han sido sincronizados (0 = no, 1 = sí)
  created TEXT NOT NULL,       -- Fecha de creación (timestamp)
  updated TEXT NOT NULL,       -- Fecha de última actualización (timestamp)
  FOREIGN KEY (poll_id) REFERENCES polls (id)
)
''');

    await db.execute('''
CREATE TABLE direcciones (
  id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Clave primaria para la tabla direcciones
  id_encuesta INTEGER NOT NULL,
  poll_id INTEGER NOT NULL,
  calle TEXT,
  numero TEXT,
  comuna TEXT,
  is_synced INTEGER DEFAULT 0,
  FOREIGN KEY (id_encuesta) REFERENCES encuesta_detalles(id_encuesta)  -- Referencia a la tabla encuesta_detalles
)
''');

    await db.execute('''
  CREATE TABLE requests (
    id INTEGER PRIMARY KEY,  -- ID único de la solicitud
    user_id INTEGER,
    poll_id INTEGER,
    department_id INTEGER,
    brigade_id INTEGER,
    request_name TEXT,
    request_date TEXT,
    request_delivery TEXT,
    request_accept TEXT,
    request_close TEXT,
    request_finish TEXT,
    request_state TEXT,
    created TEXT,
    updated TEXT
  )
''');

    await db.execute('''
  CREATE TABLE request_answers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,  -- ID único de la respuesta
    request_id INTEGER,  -- Referencia a la solicitud
    user_id INTEGER,
    field_id INTEGER,
    request_answer_text TEXT,
    created TEXT,
    updated TEXT,
    FOREIGN KEY (request_id) REFERENCES requests (id)  -- Referencia a la clave primaria en requests
  )
''');

    //print('Tablas creadas con éxito');
  }

  // Métodos para insertar datos...
  Future<int> insertIncident(inc.Incident incident) async {
    Database db = await instance.database;
    return await db.insert(
      'incidents',
      incident.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertPoll(poll.Poll poll) async {
    final db = await database;
    await db.insert(
      tablePolls,
      poll.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertField(fie.Field field) async {
    final db = await database;
    await db.insert(
      tableFields,
      field.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para insertar Request en la base de datos
  Future<void> insertRequest(Request request) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'requests',
      request.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertRequestAnswer(RequestAnswer requestAnswer) async {
    final db = await database;
    await db.insert(
      'request_answers',
      requestAnswer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Métodos para recuperar datos de las nuevas tablas
  Future<List<inc.Incident>> getAllIncidents() async {
    final db = await database;
    final result = await db.query(tableIncidents);
    return result.map((json) => inc.Incident.fromJson(json)).toList();
  }

  Future<List<poll.Poll>> getAllPolls() async {
    final db = await database;
    final result = await db.query(tablePolls);
    return result.map((json) => poll.Poll.fromJson(json)).toList();
  }

  Future<List<fie.Field>> getAllFields() async {
    final db = await database;
    final result = await db.query(tableFields);
    return result.map((json) => fie.Field.fromJson(json)).toList();
  }

  Future<List<Map<String, dynamic>>> getEncuestasIniciadas() async {
    final db = await database;
    final result = await db.query(
      'requests',
      where: "request_state = 'Iniciada'",
    );

    return result.map((row) {
      return {
        'Nombre': row['request_name'],
        'Fecha creación':
            row['created'], // Ajusta aquí según cómo mapeas las fechas
        ...row,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getEncuestasDerivadas() async {
    final db = await database;
    final result = await db.query(
      'requests',
      where: "request_state = 'Derivada'",
    );

    // Ajustar nombres de campos en el resultado
    return result.map((row) {
      return {
        'Nombre': row['request_name'],
        'Fecha creación': row['created'], // Mapear 'created' a 'Fecha creación'
        ...row,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getEncuestasFinalizadas() async {
    final db = await database;
    final result = await db.query(
      'requests',
      where: "request_state = 'Finalizada'",
    );

    // Ajustar nombres de campos en el resultado
    return result.map((row) {
      return {
        'Nombre': row['request_name'],
        'Fecha creación': row['created'], // Mapear 'created' a 'Fecha creación'
        ...row,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getEncuestasProceso() async {
    final db = await database;
    final result = await db.query(
      'requests',
      where: "request_state = 'Proceso'",
    );

    // Ajustar nombres de campos en el resultado
    return result.map((row) {
      return {
        'Nombre': row['request_name'],
        'Fecha creación': row['created'], // Mapear 'created' a 'Fecha creación'
        ...row,
      };
    }).toList();
  }

  Future<String?> fetchId() async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> results = await db!.query(
      'requests', // Nombre de la tabla
      columns: ['id'], // Columna que deseas obtener
      limit: 1, // Si solo necesitas un ID
    );

    if (results.isNotEmpty) {
      return results.first['id']
          .toString(); // Asegúrate de que sea del tipo correcto
    }
    return null; // Si no se encuentra ningún ID
  }

  Future<void> _saveCookies(String cookies) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', cookies);
  }

  // Función para descargar solo los nuevos datos
  Future<void> downloadData() async {
    print("Descargando datos...");

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cookies = prefs.getString('cookies');
      int? groupId = prefs.getInt('group_id');
      final String? username = prefs.getString('username');
      final String? password = prefs.getString('password');

      if (username == null || password == null) {
        print("No se encontraron las credenciales de inicio de sesión.");
        return;
      }

      if (groupId == null) {
        print(
          "No se encontró el group_id. Asegúrate de haber iniciado sesión correctamente.",
        );
        return;
      }

      // Obtener el último ID o marca de tiempo de la base de datos local
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        'SELECT MAX(id) as lastId FROM incidents',
      );
      final int? lastId =
          result.isNotEmpty ? result.first['lastId'] as int? : null;

      print("Último ID local: $lastId");

      // Paso 1: Intentar enviar encuestas locales al servidor
      await unificarYEnviarDatosTodasLasEncuestas(db);

      // Paso 2: Modificar la URL para descargar solo nuevos datos
      final String downloadUrl =
          lastId != null
              ? '$baseUrl/request_data_all?last_id=$lastId'
              : '$baseUrl/request_data_all';

      final response = await http.get(
        Uri.parse(downloadUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$username:$password')),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        print("Datos JSON recibidos:");
        print(jsonEncode(data));

        // Procesar los datos recibidos...
        await processIncidents(data, db);
        await processPolls(data, db);
        await processFields(data, db);
        await processRequests(data, db); // Añadir procesamiento de solicitudes
        await processRequestAnswers(
          data,
          db,
        ); //Añadir procesamiento de respuestas de solicitudes

        // Imprimir el contenido de las tablas después de guardar los datos
        await printTableContent('incidents');
        await printTableContent('polls');
        await printTableContent('fields');
        await printTableContent('requests'); // Imprimir contenido de requests
        await printTableContent('request_answers');
        await printTableContent('encuesta_respuesta');
        await printTableContent('direcciones');
      } else {
        print('Error al descargar datos: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
      }
    } catch (error) {
      print('Error al descargar datos: $error');
    }
  }

  // Función para procesar los incidentes
  Future<void> processIncidents(Map<String, dynamic> data, Database db) async {
    final List<dynamic> incidentesJson = data['incident'] as List<dynamic>;
    for (var incidente in incidentesJson) {
      if (incidente['id'] == null || incidente['id'] is! int) {
        print('Error: ID de incidente no válido: ${incidente['id']}');
        continue;
      }
      final incidenteMap = Map<String, dynamic>.from(incidente);
      final incidenteIncident = inc.Incident.fromJson(incidenteMap);
      await insertIncident(incidenteIncident);
    }
  }

  // Función para procesar las encuestas
  Future<void> processPolls(Map<String, dynamic> data, Database db) async {
    final List<dynamic> encuestasJson = data['poll'] as List<dynamic>;
    for (var encuesta in encuestasJson) {
      if (encuesta['incident_id'] == null || encuesta['incident_id'] is! int) {
        print(
          'Error: incident_id de encuesta no válido: ${encuesta['incident_id']}',
        );
        continue;
      }
      final encuestaMap = Map<String, dynamic>.from(encuesta);
      final encuestaPoll = poll.Poll.fromJson(encuestaMap);
      if (await incidentExists(encuestaPoll.incidentId)) {
        await insertPoll(encuestaPoll);
      } else {
        print(
          'Error: El incidentId ${encuestaPoll.incidentId} no existe. Omitiendo encuesta.',
        );
      }
    }
  }

  // Función para procesar los campos
  Future<void> processFields(Map<String, dynamic> data, Database db) async {
    final List<dynamic> fieldsJson = data['field'] as List<dynamic>;
    for (var field in fieldsJson) {
      if (field['poll_id'] == null || field['poll_id'] is! int) {
        print('Error: poll_id de campo no válido: ${field['poll_id']}');
        continue;
      }
      final fieldMap = Map<String, dynamic>.from(field);
      final fieldField = fie.Field.fromJson(fieldMap);
      await insertField(fieldField);
    }
  }

  // Función para procesar las solicitudes (Request)
  Future<void> processRequests(Map<String, dynamic> data, Database db) async {
    final List<dynamic> requestsJson = data['request'] as List<dynamic>;
    for (var request in requestsJson) {
      if (request['id'] == null || request['id'] is! int) {
        print('Error: ID de solicitud no válido: ${request['id']}');
        continue;
      }
      final requestMap = Map<String, dynamic>.from(request);
      final requestModel = Request.fromJson(requestMap);
      await insertRequest(requestModel);
    }
  }

  // Función para procesar las respuestas de solicitudes (RequestAnswer)
  Future<void> processRequestAnswers(
    Map<String, dynamic> data,
    Database db,
  ) async {
    final List<dynamic> requestAnswersJson =
        data['request_answer'] as List<dynamic>;
    for (var requestAnswer in requestAnswersJson) {
      if (requestAnswer['request'] == null ||
          requestAnswer['request'] is! int) {
        print(
          'Error: request_id de respuesta no válido: ${requestAnswer['request']}',
        );
        continue;
      }
      if (requestAnswer['user'] == null || requestAnswer['user'] is! int) {
        print(
          'Error: user_id de respuesta no válido: ${requestAnswer['user']}',
        );
        continue;
      }
      if (requestAnswer['fields'] == null || requestAnswer['fields'] is! int) {
        print(
          'Error: field_id de respuesta no válido: ${requestAnswer['fields']}',
        );
        continue;
      }

      final requestAnswerMap = Map<String, dynamic>.from(requestAnswer);
      final requestAnswerModel = RequestAnswer.fromJson(requestAnswerMap);
      await insertRequestAnswer(requestAnswerModel);
    }
  }

  // Función para imprimir el contenido de una tabla
  Future<void> printTableContent(String tableName) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(tableName);

    print('Contenido de la tabla $tableName:');
    for (var row in result) {
      print(row);
    }
  }

  Future<void> unificarYEnviarDatosTodasLasEncuestas(Database db) async {
    // Obtener todos los IDs de las encuestas disponibles en la base de datos
    final List<Map<String, dynamic>> encuestas = await db.query(
      'encuesta_respuesta',
      columns: ['id_encuesta'],
      distinct: true,
    );

    if (encuestas.isEmpty) {
      print('No se encontraron encuestas en la base de datos.');
      return;
    }

    // Obtener las cookies y tokens de sesión usando AuthService
    final AuthService authService = AuthService();
    final cookies = await authService.getCookies();
    final csrftoken = cookies['csrftoken'];
    final sessionid = cookies['sessionid'];

    if (csrftoken == null || sessionid == null) {
      print('No hay sesión activa');
      return;
    }

    for (var encuesta in encuestas) {
      int idEncuesta = encuesta['id_encuesta'];

      // Llamar a la función que unifica los datos por encuesta
      final http.MultipartRequest request = await unificarDatosPorEncuesta(
        db,
        idEncuesta,
        csrftoken,
        sessionid,
        authService,
      );

      if (request.fields.isEmpty && request.files.isEmpty) {
        print('No hay datos para enviar para id_encuesta $idEncuesta.');
        continue;
      }

      try {
        // Imprimir la solicitud para depuración
        print('Datos a enviar para id_encuesta $idEncuesta: ${request.fields}');
        if (request.files.isNotEmpty) {
          print('Archivos a enviar:');
          for (var file in request.files) {
            print(' - ${file.filename}');
          }
        }

        // Enviar la solicitud
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        // Verificar la respuesta del servidor
        if (response.statusCode == 200) {
          print('Datos enviados exitosamente para id_encuesta $idEncuesta');

          // Eliminar la encuesta de la base de datos local
          await db.delete(
            'encuesta_respuesta',
            where: 'id_encuesta = ?',
            whereArgs: [idEncuesta],
          );
          await db.delete(
            'encuesta_detalles',
            where: 'id_encuesta = ?',
            whereArgs: [idEncuesta],
          );
          await db.delete(
            'direcciones',
            where: 'id_encuesta = ?',
            whereArgs: [idEncuesta],
          );

          print('Encuesta $idEncuesta eliminada de la base de datos local.');
        } else {
          print(
            'Error al enviar datos para id_encuesta $idEncuesta: ${response.statusCode}',
          );
          final responseBody = await streamedResponse.stream.bytesToString();
          print('Respuesta del servidor: $responseBody');
        }
      } catch (e) {
        print('Error en la solicitud para id_encuesta $idEncuesta: $e');
      }
    }
  }

  Future<http.MultipartRequest> unificarDatosPorEncuesta(
    Database db,
    int idEncuesta,
    String csrftoken,
    String sessionid,
    AuthService authService,
  ) async {
    final uri = Uri.parse(
      '${authService.baseUrl}/territorial/territorial_request_save_ep/',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'X-CSRFToken': csrftoken,
        'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      });

    // Función que añade campos a la solicitud
    void agregarCampo(String key, dynamic value) {
      if (value != null) {
        // Convertir a cadena solo si no es double, así se mantiene el tipo numérico para coordenadas
        request.fields[key] =
            value is double ? value.toStringAsFixed(6) : value.toString();
      }
    }

    // Obtener las respuestas y detalles relacionados
    final List<Map<String, dynamic>> respuestas = await db.query(
      'encuesta_respuesta',
      where: 'id_encuesta = ?',
      whereArgs: [idEncuesta],
    );

    final List<Map<String, dynamic>> detalles = await db.query(
      'encuesta_detalles',
      where: 'id_encuesta = ?',
      whereArgs: [idEncuesta],
    );

    // Obtener el poll_id desde la base de datos (por ejemplo, de la tabla 'encuesta_detalles')
    if (detalles.isNotEmpty) {
      final pollId = detalles.first['poll_id'];
      agregarCampo('poll_id', pollId);
    }

    // Procesar respuestas
    for (var respuesta in respuestas) {
      final fieldId = respuesta['field_id'];
      final fieldData = await db.query(
        'fields',
        where: 'id = ?',
        whereArgs: [fieldId],
      );

      if (fieldData.isNotEmpty) {
        final fieldName = fieldData.first['name'] as String;
        var valor = respuesta['respuesta_text'];

        // Añadir campos de texto
        agregarCampo(fieldName, valor);

        // Manejar imágenes
        if (fieldName == 'incidence_images' && valor is List) {
          for (var imagePath in valor) {
            if (await File(imagePath).exists()) {
              request.files.add(
                await http.MultipartFile.fromPath('incidence_image', imagePath),
              );
            }
          }
        }
      }
    }

    // Buscar la dirección en la tabla direcciones y obtener coordenadas
    final List<Map<String, dynamic>> direcciones = await db.query(
      'direcciones',
      where: 'id_encuesta = ?',
      whereArgs: [idEncuesta],
    );

    double? latitud;
    double? longitud;

    if (direcciones.isNotEmpty) {
      final direccion = direcciones.first;
      final calle = direccion['calle'];
      final numero = direccion['numero'];
      final comuna = direccion['comuna'];

      if (calle != null && numero != null && comuna != null) {
        // Formar la dirección completa
        final direccionCompleta = '$calle $numero, $comuna';

        // Obtener las coordenadas de la dirección
        final coordenadas = await obtenerCoordenadas(direccionCompleta);
        if (coordenadas != null) {
          latitud = coordenadas['lat'];
          longitud = coordenadas['lng'];
        } else {
          print(
            "No se pudieron obtener coordenadas para la dirección: $direccionCompleta",
          );
        }
      }
    }

    // Procesar detalles
    if (detalles.isNotEmpty) {
      for (var detalle in detalles) {
        // Convertir las coordenadas a cadena para asegurar compatibilidad con el mapa
        agregarCampo(
          'incidence_latitud',
          (latitud ?? detalle['incidence_latitud']).toString(),
        );
        agregarCampo(
          'incidence_longitud',
          (longitud ?? detalle['incidence_longitud']).toString(),
        );
        agregarCampo('incidence_priority', detalle['incidence_priority']);

        // Manejar imágenes
        if (detalle['incidence_images'] != null) {
          List<String> imagePaths =
              (detalle['incidence_images'] is List)
                  ? List<String>.from(detalle['incidence_images'])
                  : [detalle['incidence_images']];
          for (var imagePath in imagePaths) {
            if (await File(imagePath).exists()) {
              request.files.add(
                await http.MultipartFile.fromPath('incidence_image', imagePath),
              );
            }
          }
        }

        // Manejar video y audio
        if (detalle['incidence_video'] != null) {
          if (await File(detalle['incidence_video']).exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'incidence_video',
                detalle['incidence_video'],
              ),
            );
          }
        }
        if (detalle['incidence_audio'] != null) {
          if (await File(detalle['incidence_audio']).exists()) {
            request.files.add(
              await http.MultipartFile.fromPath(
                'incidence_audio',
                detalle['incidence_audio'],
              ),
            );
          }
        }
      }
    }

    // Imprimir contenido unificado para depuración
    print(
      'Contenido unificado para id_encuesta $idEncuesta: ${request.fields}',
    );
    return request;
  }

  // Función para obtener coordenadas desde Google Maps
  Future<Map<String, double>?> obtenerCoordenadas(String address) async {
    final googleApiKey = 'API_KEY';
    final googleMapsUrl = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey',
    );

    try {
      final response = await http.get(googleMapsUrl);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'];
        if (results.isNotEmpty) {
          final location = results[0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        } else {
          print("No se encontraron resultados para la dirección $address");
        }
      } else {
        print('Error al consultar la API de Google Maps: ${response.body}');
      }
    } catch (error) {
      print('Error al consultar la API de Google Maps: $error');
    }
    return null;
  }

  Future<void> printTableNames() async {
    final Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table"',
    );
    print("Tablas en la base de datos:");
    for (var row in result) {
      print(row['name']);
    }
  }

  // Funciones auxiliares para verificar si existen incidentes y encuestas
  Future<bool> incidentExists(int incidentId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'incidents',
      where: 'id = ?',
      whereArgs: [incidentId],
    );
    return result.isNotEmpty;
  }

  Future<bool> pollExists(int pollId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'polls',
      where: 'id = ?',
      whereArgs: [pollId],
    );
    return result.isNotEmpty;
  }
}
