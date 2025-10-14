import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbansensor/endpoints/auth.dart';

Future<Map<String, dynamic>> fetchProfile() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return {};
  }

  final response = await http.get(
    Uri.parse('${authService.baseUrl}/territorial/territorial_see_profile_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      print('Profile response: $responseData');
      return responseData;
    } catch (e) {
      print('Error decoding JSON: $e');
      return {};
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
    return {};
  }
}

Future<Map<String, dynamic>> editProfile(
    {String? nombre, String? apellido, String? correo}) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return {};
  }

  final response = await http.post(
    Uri.parse(
        '${authService.baseUrl}/territorial/territorial_edit_profile_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
    body: jsonEncode({
      if (nombre != null) 'nombre': nombre,
      if (apellido != null) 'apellido': apellido,
      if (correo != null) 'correo': correo,
    }),
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      print('Edit profile response: $responseData');
      return responseData;
    } catch (e) {
      print('Error decoding JSON: $e');
      return {};
    }
  } else {
    print('Request failed with status: ${response.statusCode}');
    return {};
  }
}
