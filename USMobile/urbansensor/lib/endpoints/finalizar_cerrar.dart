import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbansensor/endpoints/auth.dart';

Future<Map<String, dynamic>?> fetchEncuestaDetalles(String id) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    print('CSRF token or session ID is null');
    return null;
  }

  final url = Uri.parse(
    '${authService.baseUrl}/territorial/territorial_request_view_ep/$id',
  );
  print('Fetching details from URL: $url');

  final response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      print('Decoded response data: $responseData');
      return responseData;
    } catch (e) {
      print('Error decoding JSON: $e');
      return null;
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
    return null;
  }
}

Future<void> cerrarIncidencia(String id) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    print('CSRF token or session ID is null');
    return;
  }

  final url = Uri.parse(
    '${authService.baseUrl}/territorial/territorial_close_request_ep/$id',
  );
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  print('Response status code cerrar: ${response.statusCode}');
  print('Response body cerrar: ${response.body}');

  if (response.statusCode == 200) {
    print('Incidencia cerrada con éxito.');
  } else {
    print(
      'Error al cerrar la incidencia. Código de estado: ${response.statusCode}',
    );
    throw Exception('Error al cerrar la incidencia');
  }
}
