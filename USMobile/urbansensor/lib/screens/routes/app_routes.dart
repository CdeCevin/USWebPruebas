import 'package:flutter/material.dart';
import 'package:urbansensor/screens/Dashboard/Dashboard.dart';
import 'package:urbansensor/screens/ErrorScreen/ErrorScreen.dart';
import 'package:urbansensor/screens/Perfil/Perfil.dart';
import 'package:urbansensor/screens/enviadas_plantilla/encuestas_enviadas.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/home_tipo_plantilla.dart';
import 'package:urbansensor/screens/recuperar_password/recuperar_password.dart';
import 'package:urbansensor/screens/screen_formulario/main_formulario.dart';
import 'package:urbansensor/screens/screen_login/screen_login.dart';
import 'package:urbansensor/screens/triptico.dart';
import 'package:urbansensor/screens/Perfil/editar_perfil.dart';

class AppRoutes {
  static const initialRoute = 'login';
  static Map<String, Widget Function(BuildContext)> routes = {
    'login': (BuildContext context) => LoginScreen(),
    'plantillas': (BuildContext context) => Encuestas(),
    'enviadas': (BuildContext context) => Enviadas(),
    'formulario': (BuildContext context) => PaginaFormulario(),
    'perfil': (BuildContext context) => Perfil(),
    'dashboard': (BuildContext context) => Dashboard(),
    'recuperar_contraseña': (BuildContext context) => recuperarPassword(),
    'editar perfil': (BuildContext context) => EditarInformacion(),
    'triptico': (BuildContext context) => TripticoScreen(),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (context) => ErrorScreen());
  }
}
