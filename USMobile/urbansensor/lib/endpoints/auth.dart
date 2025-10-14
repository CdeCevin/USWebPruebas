import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbansensor/config/config.dart';

class AuthService {
  final String baseUrl = Config.baseUrl;

  // Método de inicio de sesión
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/territorial/territorial_login_ep/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'Basic ' + base64Encode(utf8.encode('$username:$password')),
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        if (cookies != null) {
          await _saveCookies(cookies);

          // Extraer el group_id de la respuesta JSON
          final Map<String, dynamic> responseData = json.decode(response.body);
          final int? groupId = responseData['group_id'];

          // Guardar los datos en SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
          await prefs.setString('password', password);
          await prefs.setBool(
            'is_logged_in',
            true,
          ); // Nuevo: almacena el estado de sesión

          if (groupId != null) {
            await prefs.setInt('group_id', groupId);
            return true;
          } else {
            return false;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Verificación de estado de sesión
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('sessionid');
    final groupId = prefs.getInt('group_id');

    // Verifica si los datos clave están en `SharedPreferences`
    return sessionId != null && groupId != null;
  }

  // Cerrar sesión
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionid = prefs.getString('sessionid');

      if (sessionid != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/territorial/territorial_logout_ep/'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Cookie': 'sessionid=$sessionid',
          },
        );

        if (response.statusCode == 200) {
          await _clearCookies();
          await prefs.setBool(
            'is_logged_in',
            false,
          ); // Marca la sesión como cerrada
          return true;
        } else {
          print('Error en la solicitud de logout: ${response.statusCode}');
          return false;
        }
      } else {
        print('No se encontró sessionid en SharedPreferences');
        return false;
      }
    } catch (e) {
      print('Error en la solicitud de logout: $e');
      return false;
    }
  }

  // Guardar cookies individualmente
  Future<void> _saveCookies(String cookiesHeader) async {
    final prefs = await SharedPreferences.getInstance();
    final cookieList =
        cookiesHeader.split(',').map((c) => c.split(';')[0]).toList();
    for (var cookie in cookieList) {
      if (cookie.startsWith('csrftoken=')) {
        await prefs.setString('csrftoken', cookie.split('=')[1]);
      } else if (cookie.startsWith('sessionid=')) {
        await prefs.setString('sessionid', cookie.split('=')[1]);
      }
    }
  }

  // Borrar cookies de SharedPreferences
  Future<void> _clearCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('csrftoken');
    await prefs.remove('sessionid');
    await prefs.remove('username');
    await prefs.remove('password');
    await prefs.remove('group_id');
  }

  // Obtener cookies almacenadas para solicitudes posteriores
  Future<Map<String, String?>> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    final csrftoken = prefs.getString('csrftoken');
    final sessionid = prefs.getString('sessionid');
    return {'csrftoken': csrftoken, 'sessionid': sessionid};
  }
}
