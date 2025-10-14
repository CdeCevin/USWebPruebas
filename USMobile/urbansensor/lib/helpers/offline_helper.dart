import 'package:urbansensor/helpers/database_helper.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Future<Map<int, String>> _obtenerFieldIdsPorPollId(int pollId) async {
  final db = await DatabaseHelper.instance.database;// Asumiendo que tienes una función para obtener tu instancia de DB
  final List<Map<String, dynamic>> maps = await db.query(
    'fields',
    where: 'poll_id = ?',
    whereArgs: [pollId],
  );

  // Convertir los resultados en un mapa de {field_id: nombre}
  Map<int, String> fieldIds = {};
  for (var map in maps) {
    fieldIds[map['id']] = map['name'];
  }
  print(fieldIds);

  return fieldIds;
}

Future<List<Map<String, dynamic>>> fetchEncuestasFromLocalDatabase() async {
  final db = await DatabaseHelper.instance.database;

  final result = await db.rawQuery('''
    SELECT p.id, p.state, p.name, i.name AS incident_name 
    FROM polls p
    JOIN Incidents i ON p.incident_id = i.id
    WHERE p.state = 'Activo'
  ''');

  return result;
}

Future<String?> fetchEncuestaIdFromLocalDatabase(int encuestaId) async {
  final db = await DatabaseHelper.instance.database;

  // Imprimir encuestaId para verificar qué se está buscando
  print('Buscando detalles para la encuesta ID: $encuestaId');

  // Consulta para obtener la encuesta que coincide con el ID proporcionado
  final result = await db.rawQuery('''
    SELECT p.id 
    FROM polls p 
    WHERE p.state = 'Activo' AND p.id = ?
  ''', [encuestaId]); // Usar el ID directamente

  if (result.isNotEmpty) {
    print('Encuesta encontrada: ${result.first['id']}');
    return result.first['id']
        .toString(); // Devolver el ID de la encuesta activa encontrada
  } else {
    print(
        'No se encontraron encuestas activas que coincidan con el ID: $encuestaId');
  }

  return null; // Si no hay encuestas activas que coincidan, devuelve null
}

Future<Map<String, dynamic>?> fetchEncuestaDetallesFromLocalDatabase(String id) async {
  final db = await DatabaseHelper.instance.database;

  // Obtén y muestra los registros de `request_answers`
  final List<Map<String, dynamic>> results = await db.query(
    'request_answers',
    where: 'request_id = ?',
    whereArgs: [id],
  );
  print("Resultados de 'request_answers' para ID $id: $results");

  // Obtener y mostrar datos de la tabla `requests`
  final List<Map<String, dynamic>> requestData = await db.query(
    'requests',
    where: 'id = ?',
    whereArgs: [id],
  );
  print("Datos de 'requests' para ID $id: $requestData");

  if (results.isNotEmpty && requestData.isNotEmpty) {
    List<String> detalles = [];
    for (var row in results) {
      detalles.add(row['request_answer_text'].toString());
    }

    // Extrae latitud y longitud desde `requests` o establece 0.0 si están ausentes
    double latitud = double.tryParse(requestData[0]['request_latitud'].toString()) ?? 0.0;
    double longitud = double.tryParse(requestData[0]['request_longitud'].toString()) ?? 0.0;

    print("Detalles obtenidos: $detalles");
    print("Latitud: $latitud, Longitud: $longitud");

    return {
      'request_data': {
        'Nombre': requestData[0]['request_name'] ?? 'Nombre Ejemplo',
        'Estado': requestData[0]['request_state'] ?? 'Activo',
        'Cuadrilla': requestData[0]['brigade_id'].toString(),
        'Fecha creación': requestData[0]['request_date']?.toString() ?? DateTime.now().toString(),
        'Latitud': latitud,
        'Longitud': longitud,
        'Detalles': detalles, // Anida los detalles aquí
      }
    };
  } else {
    print("No se encontraron datos para ID $id.");
    return null;
  }
}

Future<Map<String, dynamic>?> fetchEncuestaDetallesLocal(String id) async {
  try {
    final db = await DatabaseHelper.instance.database;

    // Consulta para obtener los campos de la encuesta desde la tabla 'fields'
    final fieldsResult = await db.query(
      'fields',
      where: 'poll_id = ?',
      whereArgs: [int.parse(id)],
    );

    // Si no hay campos, devolvemos null para indicar que no se encontraron detalles
    if (fieldsResult.isEmpty) {
      print(
          'No se encontraron detalles en la base de datos para el ID de encuesta: $id');
      return null;
    }

    // Extraer los nombres de los campos, asegurándonos de que el campo 'name' existe y es de tipo String
    final pollFieldsStandard = fieldsResult.map((map) {
      final name = map['label'];
      if (name is String) {
        return name;
      } else {
        print(
            'Campo "name" no es de tipo String o está ausente en uno de los resultados.');
        return '';
      }
    }).toList();

    // Construir el mapa de detalles de la encuesta, simulando la estructura de la respuesta de la API
    final detallesEncuesta = {
      'poll_data': {
        'poll_fields_standard': pollFieldsStandard,
      }
    };

    return detallesEncuesta;
  } catch (e) {
    print(
        'Error al obtener detalles de la encuesta desde la base de datos: $e');
    return null;
  }
}

Future<void> guardarEncuestaOffline({
  required int pollId,
  required Map<int, String> respuestas, // Cambiado a Map<String, String>
  String? calle,
  String? numero,
  String? comuna,
  String? incidencePriority,
  double? incidenceLatitud,
  double? incidenceLongitud,
  List<File>? incidenceImages,
  File? incidenceVideo,
  File? incidenceAudio,
}) async {
  final db = await DatabaseHelper.instance.database;

  // Obtener el último id_encuesta, asegurando que no sea null
  final lastEncuestaId = Sqflite.firstIntValue(
    await db.rawQuery('SELECT COALESCE(MAX(id_encuesta), 0) FROM encuesta_detalles')
  );

  int newEncuestaId = (lastEncuestaId ?? 0) + 1;  // Usa 0 si lastEncuestaId es null

  // Guardar detalles únicos de la encuesta
  await db.insert(
    'encuesta_detalles',
    {
      'id_encuesta': newEncuestaId,
      'poll_id': pollId,
      'incidence_priority': incidencePriority ?? '',
      'incidence_latitud': incidenceLatitud ?? 0.0,
      'incidence_longitud': incidenceLongitud ?? 0.0,
      'incidence_images': incidenceImages != null && incidenceImages.isNotEmpty
          ? incidenceImages.map((file) => file.path).join(',')
          : '',
      'incidence_video': incidenceVideo?.path ?? '',
      'incidence_audio': incidenceAudio?.path ?? '',
      'is_synced': 0,
      'created': DateTime.now().toIso8601String(),
      'updated': DateTime.now().toIso8601String(),
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  // Obtener los field_ids y sus nombres
  Map<int, String> fieldIds = await _obtenerFieldIdsPorPollId(pollId);

  // Guardar las respuestas en la tabla encuesta_respuesta
for (var entry in respuestas.entries) {
  // Buscar el field_id correspondiente al campo actual
  int? fieldId = fieldIds.entries
      .firstWhere((element) => element.key == entry.key, orElse: () => MapEntry(-1, ''))
      .key;

  // Imprimir para verificar el field_id y la respuesta
  print('Intentando guardar respuesta: field_id = $fieldId, respuesta = ${entry.value}');

  // Solo guardar si se encontró un field_id válido
  if (fieldId != -1) {
    // Guardar la respuesta en la base de datos
    try {
      await db.insert(
        'encuesta_respuesta',
        {
          'id_encuesta': newEncuestaId,
          'poll_id': pollId,
          'field_id': fieldId,
          'respuesta_text': entry.value,
          'is_synced': 0,
          'created': DateTime.now().toIso8601String(),
          'updated': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Print para mostrar el field_id y la respuesta
      print('Guardada respuesta: field_id = $fieldId, respuesta = ${entry.value}');
    } catch (e) {
      print('Error al guardar la respuesta: $e');
    }
  } else {
    print('No se encontró field_id para la respuesta: ${entry.value}');
  }
}

  // Guardar la dirección si se proporciona
  if (calle != null || numero != null || comuna != null) {
    await db.insert(
      'direcciones',
      {
        'id_encuesta': newEncuestaId,
        'poll_id': pollId,
        'calle': calle ?? '',
        'numero': numero ?? '',
        'comuna': comuna ?? '',
        'is_synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  print('Encuesta guardada offline con id_encuesta: $newEncuestaId.');
  print('Encuesta y contenido: $respuestas');
  print('Encuesta guardada offline con pollId: $pollId, priority: $incidencePriority, latitud: $incidenceLatitud, longitud: $incidenceLongitud');
  print('Encuesta imagenes: $incidenceImages');
  print('Encuesta video: $incidenceVideo');
  print('Encuesta audio: $incidenceAudio');
}


Future<void> mostrarDatosGuardados(int pollId) async {
  // Obtener la instancia de la base de datos
  final db = await DatabaseHelper.instance.database;

  // Consultar las respuestas de la encuesta
  final List<Map<String, dynamic>> respuestas = await db.query(
    'encuesta_respuesta',
    where: 'poll_id = ?',
    whereArgs: [pollId],
  );

  // Consultar la dirección relacionada
  final List<Map<String, dynamic>> direcciones = await db.query(
    'direcciones',
    where: 'poll_id = ?',
    whereArgs: [pollId],
  );

  // Imprimir respuestas
  print('Respuestas guardadas para poll_id: $pollId');
  for (var respuesta in respuestas) {
    print(
        'field_id: ${respuesta['field_id']}, respuesta_text: ${respuesta['respuesta_text']}, '
        'incidence_priority: ${respuesta['incidence_priority']}, '
        'incidence_latitud: ${respuesta['incidence_latitud']}, '
        'incidence_longitud: ${respuesta['incidence_longitud']}, '
        'incidence_images: ${respuesta['incidence_images']}, '
        'incidence_video: ${respuesta['incidence_video']}, '
        'incidence_audio: ${respuesta['incidence_audio']}, '
        'is_synced: ${respuesta['is_synced']}, '
        'created: ${respuesta['created']}, '
        'updated: ${respuesta['updated']}');
  }

  // Imprimir direcciones
  print('Direcciones guardadas para poll_id: $pollId');
  for (var direccion in direcciones) {
    print(
        'calle: ${direccion['calle']}, numero: ${direccion['numero']}, comuna: ${direccion['comuna']}');
  }
}

// Función para obtener el field_id por el nombre del campo
Future<int> obtenerFieldIdPorNombre(String nombreCampo) async {
  final db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> result = await db.query(
    'fields',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [nombreCampo],
  );
  
  return result.isNotEmpty ? result.first['id'] : -1; // Retorna -1 si no se encuentra
}

// Función para obtener nombres de campos
Future<Map<int, String>> obtenerNombresCampos() async {
  final db = await DatabaseHelper.instance.database;
  List<Map<String, dynamic>> result = await db.query('fields');

  Map<int, String> nombresCampos = {};
  for (var row in result) {
    nombresCampos[row['id']] = row['name'];
  }

  return nombresCampos;
}
