import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/screens/Dashboard/Dashboard.dart';
import 'package:urbansensor/screens/Perfil/Perfil.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/home_tipo_plantilla.dart';
import 'package:urbansensor/widgets/appbar_triptico.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/helpers/database_helper.dart';

class TripticoScreen extends StatefulWidget {
  final int index;

  TripticoScreen({this.index = 0});

  @override
  _TripticoScreenState createState() => _TripticoScreenState();
}

class _TripticoScreenState extends State<TripticoScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool hasInternet = false;
  late Stream<InternetConnectionStatus> internetStatusStream;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
    _pageController = PageController(initialPage: _currentIndex);
    _checkInternetConnection();
    _listenToInternetConnection();
  }

  // Verificar conexión inicial
  Future<void> _checkInternetConnection() async {
    bool result = await InternetConnectionChecker().hasConnection;
    setState(() {
      hasInternet = result;
    });
  }

  // Escuchar cambios en la conexión de internet
  void _listenToInternetConnection() {
    internetStatusStream = InternetConnectionChecker().onStatusChange;
    internetStatusStream.listen((status) {
      setState(() {
        hasInternet = status == InternetConnectionStatus.connected;
      });
    });
  }

  Future<void> _downloadData() async {
    setState(() {
      _isUpdating = true; // Iniciar la actualización
    });
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.downloadData();
    setState(() {
      _isUpdating = false; // Finalizar la actualización
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Datos actualizados con éxito')));
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;
    return Scaffold(
      appBar: MyAppBarTriptico(
        title: _appBarTitle(),
        appBarHeight: appBarHeight,
        bottomWidget:
            _currentIndex == 0 && hasInternet
                ? Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5.0,
                  ), // Ajuste del padding
                  child: SizedBox(
                    height: 35, // Ajuste de altura
                    width: 180, // Ajuste de ancho
                    child: ElevatedButton(
                      onPressed: _isUpdating ? null : _downloadData,
                      child:
                          _isUpdating
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Actualizar BD',
                                style: TextStyle(fontSize: 14),
                              ),
                    ),
                  ),
                )
                : null,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx < 0) {
            _changePage(_currentIndex + 1);
          } else {
            _changePage(_currentIndex - 1);
          }
        },
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: [Encuestas(), Dashboard(), Perfil()],
        ),
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: _currentIndex),
    );
  }

  void _changePage(int index) {
    if (index >= 0 && index < 3) {
      setState(() {
        _currentIndex = index;
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  String _appBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'ENCUESTAS';
      case 1:
        return 'DASHBOARD';
      case 2:
        return 'PERFIL';
      default:
        return '';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
