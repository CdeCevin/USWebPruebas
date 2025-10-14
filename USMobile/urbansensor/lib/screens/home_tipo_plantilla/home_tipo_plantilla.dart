import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/widgets/barrabus.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/tipo_encuestas.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/boton_plantilla_enviadas.dart';
import 'package:urbansensor/screens/enviadas_plantilla/encuestas_enviadas.dart';
import 'package:urbansensor/endpoints/encuestas_service.dart';
import 'package:urbansensor/screens/screen_formulario/main_formulario.dart';
import 'package:urbansensor/helpers/database_helper.dart';
import 'package:urbansensor/helpers/offline_helper.dart';

class Encuestas extends StatefulWidget {
  @override
  _EncuestasState createState() => _EncuestasState();
}

class _EncuestasState extends State<Encuestas> {
  List<dynamic> encuestas = [];
  List<dynamic> encuestasFiltradas = [];
  bool isLoading = true;
  bool hasInternet = false; // Declarar hasInternet como variable de estado
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEncuestas();
    searchController.addListener(_filterEncuestas);
    _listenToConnectivityChanges();
  }

  @override
  void dispose() {
    searchController.removeListener(_filterEncuestas);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEncuestas() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    hasInternet = await InternetConnectionChecker().hasConnection;
    List<dynamic> encuestasData;

    if (hasInternet) {
      encuestasData = await fetchEncuestas();
    } else {
      // Obtén los datos de la base de datos local
      final localData = await fetchEncuestasFromLocalDatabase();
      encuestasData = localData.map((map) {
        return {
          'Nombre': map['name'],
          'Tipo de incidencia':
              map['incident_name'], // Obtener el nombre del incidente
          'Ver Encuesta': map['id'].toString(),
        };
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      encuestas = encuestasData;
      encuestasFiltradas = encuestasData;
      isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _fetchEncuestas();
  }

  void _filterEncuestas() {
    String query = searchController.text.toLowerCase();
    setState(() {
      encuestasFiltradas = encuestas.where((encuesta) {
        String tipo = (encuesta['Tipo de incidencia'] ?? '').toLowerCase();
        return tipo.contains(query);
      }).toList();
    });
  }

  void _listenToConnectivityChanges() {
    InternetConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        hasInternet = (status == InternetConnectionStatus.connected);
      });
      if (hasInternet) {
        _fetchEncuestas();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, String>>> encuestasPorTipo = {};
    encuestasFiltradas.forEach((encuesta) {
      String tipo = encuesta['Tipo de incidencia'];
      String verEncuesta = encuesta['Ver Encuesta'] ?? '';
      if (verEncuesta.isNotEmpty) {
        if (!encuestasPorTipo.containsKey(tipo)) {
          encuestasPorTipo[tipo] = [];
        }
        encuestasPorTipo[tipo]!.add({
          'Nombre': encuesta['Nombre'] ?? '',
          'Tipo de incidencia': encuesta['Tipo de incidencia'] ?? '',
          'Ver Encuesta': verEncuesta,
        });
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                color: Color.fromARGB(255, 255, 255, 255),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    BotonPlantillaEnviadas(
                      texto1: 'Activas',
                      texto2: 'Solicitudes',
                      encuestasSelected: true,
                      onPressed1: () {},
                      onPressed2: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                Enviadas(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 3,
                          color: Color.fromARGB(255, 209, 209, 209),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Módulo',
                            style: TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3B69AE),
                            ),
                          ),
                        ),
                        Container(
                          width: 120,
                          height: 3,
                          color: Color.fromARGB(255, 209, 209, 209),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    BarraBusqueda3(searchController: searchController),
                    SizedBox(height: 20),
                    SizedBox(height: 20),
                    ...encuestasPorTipo.entries.map((entry) {
                      String tipo = entry.key;
                      List<Map<String, String>> encuestasTipo = entry.value;
                      return Column(
                        children: [
                          SizedBox(height: 20),
                          TipoEncuestas(
                            title: tipo,
                            children: encuestasTipo,
                            onTap: (verEncuesta) {
                              // Aquí se asegura de que verEncuesta tenga el nombre correcto o el ID
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaginaFormulario(
                                    verEncuesta:
                                        verEncuesta, // Asegúrate de que esto sea el nombre o identificador correcto
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
