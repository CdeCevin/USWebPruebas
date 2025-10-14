import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbansensor/endpoints/auth.dart';
import 'dart:io';

Future<List<dynamic>> fetchEncuestas() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return [];
  }

  final response = await http.get(
    Uri.parse('${authService.baseUrl}/territorial/territorial_list_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> listado = responseData['Listado'];
      final List<dynamic> encuestasActivas =
          listado.where((encuesta) => encuesta['Estado'] == 'Activo').toList();

      return encuestasActivas;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return [];
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

Future<List<dynamic>> fetchEncuestasProceso() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return [];
  }

  final response = await http.get(
    Uri.parse(
      '${authService.baseUrl}/territorial/territorial_list_inprogress_ep/',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> listado = responseData['Listado'];
      return listado;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return [];
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

Future<List<dynamic>> fetchEncuestasDerivadas() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return [];
  }

  final response = await http.get(
    Uri.parse('${authService.baseUrl}/territorial/territorial_list_sent_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> listado = responseData['Listado'];
      //print('lista response: ${listado}');
      return listado;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return [];
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

Future<List<dynamic>> fetchEncuestasFinalizadas() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return [];
  }

  final response = await http.get(
    Uri.parse(
      '${authService.baseUrl}/territorial/territorial_list_finished_ep/',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> listado = responseData['Listado'];
      //print('lista response: ${listado}');
      return listado;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return [];
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

Future<List<dynamic>> fetchEncuestasIniciadas() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return [];
  }

  final response = await http.get(
    Uri.parse(
      '${authService.baseUrl}/territorial/territorial_request_list_ep/',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      final List<dynamic> listado = responseData['Listado'];
      //print('Lista completa: $listado');

      final List<dynamic> encuestasIniciadas =
          listado
              .where((encuesta) => encuesta['Estado'] == 'Iniciada')
              .toList();

      //print('Encuestas Iniciadas: $encuestasIniciadas');
      return encuestasIniciadas;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return [];
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

Future<Map<String, int>> fetchEncuestasTotal() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return {
      'Abiertas': 0,
      'Finalizadas': 0,
      'Derivada': 0,
      'En Proceso': 0,
      'Iniciada': 0,
    };
  }

  final response = await http.get(
    Uri.parse(
      '${authService.baseUrl}/territorial/territorial_request_list_ep/',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<dynamic> listado = responseData['Listado'];

      int abiertas = 0;
      int finalizadas = 0;
      int derivadas = 0;
      int enProceso = 0;
      int iniciadas = 0;

      for (var encuesta in listado) {
        switch (encuesta['Estado']) {
          case 'Abierta':
            abiertas++;
            break;
          case 'Finalizada':
            finalizadas++;
            break;
          case 'Derivada':
            derivadas++;
            break;
          case 'Proceso':
            enProceso++;
            break;
          case 'Iniciada':
            iniciadas++;
            break;
        }
      }

      return {
        'Abiertas': abiertas,
        'Finalizadas': finalizadas,
        'Derivada': derivadas,
        'En Proceso': enProceso,
        'Iniciada': iniciadas,
      };
    } catch (e) {
      //print('Error decoding JSON: $e');
      return {
        'Abiertas': 0,
        'Finalizadas': 0,
        'Derivada': 0,
        'En Proceso': 0,
        'Iniciada': 0,
      };
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return {
      'Abiertas': 0,
      'Finalizadas': 0,
      'Derivada': 0,
      'En Proceso': 0,
      'Iniciada': 0,
    };
  }
}

Future<Map<String, dynamic>?> fetchEncuestaDetalles(String id) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    //print('CSRF token or session ID is null');
    return null;
  }

  final url = Uri.parse(
    '${authService.baseUrl}/territorial/territorial_poll_view_ep/$id',
  );
  //print('Fetching details from URL: $url');

  final response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  //print('Response status code: ${response.statusCode}');
  //print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      //print('Decoded response data: $responseData');
      return responseData;
    } catch (e) {
      //print('Error decoding JSON: $e');
      return null;
    }
  } else {
    //print('Request failed with status: ${response.statusCode}');
    return null;
  }
}

Future<Map<String, dynamic>> guardarEncuesta({
  required int pollId,
  String? nameNeighbor,
  String? rutNeighbor,
  String? mailNeighbor,
  String? phoneNeighbor,
  String? incidencePriority,
  String? incidenceDescription,
  double? incidenceLatitud,
  double? incidenceLongitud,
  List<File>? incidenceImages,
  File? incidenceVideo,
  File? incidenceAudio,
  Map<String, String>? respuestas, // Cambiado a Map<String, String>
}) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return {'Msj': 'No hay sesión activa'};
  }

  final uri = Uri.parse(
    '${authService.baseUrl}/territorial/territorial_request_save_ep/',
  );
  final request = http.MultipartRequest('POST', uri)
    ..fields['poll_id'] = pollId.toString();
  if (nameNeighbor != null) {
    request.fields['name_neighbor'] = nameNeighbor;
  }
  if (rutNeighbor != null) {
    request.fields['rut_neighbor'] = rutNeighbor;
  }
  if (mailNeighbor != null) {
    request.fields['mail_neighbor'] = mailNeighbor;
  }
  if (phoneNeighbor != null) {
    request.fields['pohne_neighbor'] = phoneNeighbor;
  }
  if (incidencePriority != null) {
    request.fields['incidence_priority'] = incidencePriority;
  }
  if (incidenceDescription != null) {
    request.fields['incidence_description'] = incidenceDescription;
  }
  if (incidenceLatitud != null) {
    request.fields['incidence_latitud'] = incidenceLatitud.toString();
  }
  if (incidenceLongitud != null) {
    request.fields['incidence_longitud'] = incidenceLongitud.toString();
  }
  if (incidenceImages != null) {
    for (var image in incidenceImages) {
      request.files.add(
        await http.MultipartFile.fromPath('incidence_image', image.path),
      );
    }
  }
  if (incidenceVideo != null) {
    request.files.add(
      await http.MultipartFile.fromPath('incidence_video', incidenceVideo.path),
    );
  }
  if (incidenceAudio != null) {
    request.files.add(
      await http.MultipartFile.fromPath('incidence_audio', incidenceAudio.path),
    );
  }

  if (respuestas != null) {
    for (var entry in respuestas!.entries) {
      request.fields[entry.key] = entry.value;
    }
  }

  request.headers['Cookie'] = 'csrftoken=$csrftoken; sessionid=$sessionid';
  request.headers['X-CSRFToken'] = csrftoken;

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      //print('Response Status Code: ${response.statusCode}');
      return responseData;
    } else {
      return {'Msj': 'Error en la solicitud: ${response.statusCode}'};
    }
  } catch (e) {
    return {'Msj': 'Error en la solicitud: $e'};
  }
}
