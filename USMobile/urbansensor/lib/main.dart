import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbansensor/screens/routes/app_routes.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/helpers/database_helper.dart';
import 'package:urbansensor/endpoints/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear una instancia de AuthService
  final authService = AuthService();

  // Verificar el estado de la sesión
  final isLoggedIn = await authService.checkLoginStatus();

  // Inicializar la base de datos
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.printTableNames();

  // Ejecutar la aplicación con el estado de la sesión
  runApp(MyApp(sessionActive: isLoggedIn));
}

class MyApp extends StatefulWidget {
  final bool sessionActive;

  const MyApp({Key? key, required this.sessionActive}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasInternet = false;
  bool showOnlineMessage = false;
  bool _showOfflineMessage = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    listenForConnectionChanges();
  }

  void checkInternetConnection() async {
    hasInternet = await InternetConnectionChecker().hasConnection;
    setState(() {
      _showOfflineMessage = !hasInternet;
    });
  }

  void listenForConnectionChanges() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      final isConnected = status == InternetConnectionStatus.connected;
      setState(() {
        hasInternet = isConnected;
        _showOfflineMessage = !isConnected;
        if (isConnected) {
          showOnlineMessage = true;
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              showOnlineMessage = false;
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Urban Sensor',
      initialRoute: widget.sessionActive ? 'triptico' : AppRoutes.initialRoute,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 255, 255, 255),
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: Stack(
            children: [
              child!,
              if (_showOfflineMessage)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    color: Colors.grey[800],
                    child: Center(
                      child: Text(
                        "Sin conexión a internet",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
              if (showOnlineMessage)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    color: Colors.green,
                    child: Center(
                      child: Text(
                        "Conectado a internet",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

