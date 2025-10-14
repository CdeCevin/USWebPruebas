import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:urbansensor/endpoints/auth.dart';
import 'package:flutter/material.dart';
import 'package:urbansensor/screens/screen_login/screen_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _clearCookies() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('csrftoken');
    await prefs.remove('sessionid');
    print('tokenn removido');
  } catch (e) {
    print('Error al limpiar cookies: $e');
  }
}

Future<Map<String, dynamic>> changePassword(
    BuildContext context, String password, String confirmPassword) async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    return {'Msj': 'No hay sesión activa'};
  }

  final response = await http.post(
    Uri.parse(
        '${authService.baseUrl}/territorial/territorial_edit_password_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
    body: jsonEncode(<String, String>{
      'password': password,
      'confirmacion_password': confirmPassword,
    }),
  );

  if (response.statusCode == 200) {
    try {
      final Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      await _clearCookies();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );

      return responseData;
    } catch (e) {
      return {'Msj': 'Error decodificando JSON'};
    }
  } else {
    return {'Msj': 'Error en la solicitud: ${response.statusCode}'};
  }
}
