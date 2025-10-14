import 'package:http/http.dart' as http;
import 'package:urbansensor/endpoints/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> logout() async {
  final AuthService authService = AuthService();
  final cookies = await authService.getCookies();
  final csrftoken = cookies['csrftoken'];
  final sessionid = cookies['sessionid'];

  if (csrftoken == null || sessionid == null) {
    print('CSRFTOKEN o SESSIONID son nulos');
    return false;
  }

  final response = await http.post(
    Uri.parse('${authService.baseUrl}/territorial/territorial_logout_ep/'),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Cookie': 'csrftoken=$csrftoken; sessionid=$sessionid',
      'X-CSRFToken': csrftoken,
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    await _clearCookies();
    return true;
  } else {
    print('Request failed with status: ${response.statusCode}');
    return false;
  }
}

Future<void> _clearCookies() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('csrftoken');
  await prefs.remove('sessionid');
}
