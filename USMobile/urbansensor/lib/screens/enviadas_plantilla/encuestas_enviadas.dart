import 'package:flutter/material.dart';
import 'package:urbansensor/screens/Formulario_proceso/formulario_proceso.dart';
import 'package:urbansensor/screens/triptico.dart';
import 'package:urbansensor/widgets/appbar_triptico.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/widgets/barrabus.dart';
import 'package:urbansensor/screens/home_tipo_plantilla/boton_plantilla_enviadas.dart';
import 'package:urbansensor/widgets/tarjeta_incidencia.dart';
import 'package:urbansensor/widgets/botonestados_desplegables.dart';
import 'package:urbansensor/screens/Formulario_finalizado/formulario_finalizado.dart';
import 'package:urbansensor/screens/Formulario_derivada/formulario_derivada.dart';
import 'package:urbansensor/screens/Formulario_iniciada/formulario_iniciada.dart';
import 'package:urbansensor/endpoints/encuestas_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/helpers/database_helper.dart';
import 'package:intl/intl.dart';

class Enviadas extends StatefulWidget {
  @override
  _EnviadasState createState() => _EnviadasState();
}

class _EnviadasState extends State<Enviadas> {
  String _selectedEstado = 'Todos';
  List<dynamic> _encuestasProceso = [];
  List<dynamic> _encuestasFinalizadas = [];
  List<dynamic> _encuestasDerivadas = [];
  List<dynamic> _encuestasIniciadas = [];
  List<dynamic> _encuestasFiltradas = [];

  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();

  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_filterEncuestas);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterEncuestas);
    searchController.dispose();
    super.dispose();
  }

  DateTime? parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error al convertir fecha: $e');
      return null;
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      print('Error al formatear la fecha: $e');
      return ''; // Devuelve una cadena vacía si hay un error
    }
  }

  Future<void> _fetchData() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;

    if (hasConnection) {
      _encuestasProceso = await fetchEncuestasProceso();
      _encuestasFinalizadas = await fetchEncuestasFinalizadas();
      _encuestasDerivadas = await fetchEncuestasDerivadas();
      _encuestasIniciadas = await fetchEncuestasIniciadas();
    } else {
      _encuestasProceso = await databaseHelper.getEncuestasProceso();
      _encuestasFinalizadas = await databaseHelper.getEncuestasFinalizadas();
      _encuestasDerivadas = await databaseHelper.getEncuestasDerivadas();
      _encuestasIniciadas = await databaseHelper.getEncuestasIniciadas();
    }

    setState(() {
      _encuestasFiltradas = _encuestasProceso +
          _encuestasFinalizadas +
          _encuestasDerivadas +
          _encuestasIniciadas;

      print("Encuestas Filtradas antes de ordenar: $_encuestasFiltradas");

      _encuestasFiltradas.sort((a, b) {
        final fechaA = a['Fecha creación'];
        final fechaB = b['Fecha creación'];

        if (fechaA == null || fechaB == null) {
          print('Error: Uno de los valores de fecha es null.');
          return 0; // O cambiar la lógica de ordenación si es necesario
        }

        // Asegurarse de que los valores son de tipo String
        if (fechaA is String && fechaB is String) {
          try {
            final dateA = DateTime.parse(fechaA);
            final dateB = DateTime.parse(fechaB);
            return dateB.compareTo(dateA);
          } catch (e) {
            print('Error al convertir fecha: $e');
            return 0; // O cambiar la lógica de ordenación si es necesario
          }
        } else {
          print('Error: Los valores de fecha no son de tipo String.');
          return 0; // O cambiar la lógica de ordenación si es necesario
        }
      });

      print("Encuestas Filtradas después de ordenar: $_encuestasFiltradas");

      _isLoading = false;
    });
  }

  void _filterEncuestas() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _encuestasFiltradas = _encuestasProceso +
            _encuestasFinalizadas +
            _encuestasDerivadas +
            _encuestasIniciadas;
      } else {
        _encuestasFiltradas = (_encuestasProceso +
                _encuestasFinalizadas +
                _encuestasDerivadas +
                _encuestasIniciadas)
            .where((encuesta) {
          String tipo = (encuesta['Nombre'] ?? '').toLowerCase();
          return tipo.contains(query);
        }).toList();
      }

      // Imprimir las encuestas antes de ordenar para depuración
      print("Encuestas Filtradas antes de ordenar: $_encuestasFiltradas");

      // Ordenar las encuestas por "Fecha creación"
      _encuestasFiltradas.sort((a, b) {
        // Asegurarse de que "Fecha creación" no sea null
        final fechaA = a['Fecha creación'];
        final fechaB = b['Fecha creación'];

        if (fechaA == null || fechaB == null) {
          print('Error: Uno de los valores de fecha es null.');
          return 0; // O cambiar la lógica de ordenación si es necesario
        }

        // Asegurarse de que los valores son de tipo String
        if (fechaA is String && fechaB is String) {
          // Intentar convertir a DateTime para una comparación más segura
          try {
            final dateA = DateTime.parse(fechaA);
            final dateB = DateTime.parse(fechaB);
            return dateB.compareTo(dateA);
          } catch (e) {
            print('Error al convertir fecha: $e');
            return 0; // O cambiar la lógica de ordenación si es necesario
          }
        } else {
          print('Error: Los valores de fecha no son de tipo String.');
          return 0; // O cambiar la lógica de ordenación si es necesario
        }
      });

      // Imprimir las encuestas después de ordenar para depuración
      print("Encuestas Filtradas después de ordenar: $_encuestasFiltradas");
    });
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;
    List<Widget> filteredTarjetas = _filterTarjetas(_selectedEstado);

    return Scaffold(
      appBar: MyAppBarTriptico(
        title: 'ENCUESTAS',
        appBarHeight: appBarHeight,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              BotonPlantillaEnviadas(
                texto1: 'Activas',
                texto2: 'Solicitudes',
                encuestasSelected: false,
                onPressed1: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          TripticoScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                onPressed2: () {},
              ),
              SizedBox(height: 25),
              BarraBusqueda3(searchController: searchController),
              SizedBox(height: 25),
              DropdownBotonEstado(
                onChanged: (newValue) {
                  setState(() {
                    _selectedEstado = newValue;
                  });
                },
              ),
              SizedBox(height: 15),
              Visibility(
                visible: _isLoading,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              Visibility(
                visible: !_isLoading,
                child: Column(
                  children: [
                    ...filteredTarjetas,
                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }

  List<Widget> _filterTarjetas(String estado) {
    List<dynamic> encuestas = [];

    if (estado == 'Todos') {
      encuestas = _encuestasFiltradas;
    } else if (estado == 'En proceso') {
      encuestas = _encuestasFiltradas
          .where((encuesta) => _encuestasProceso.contains(encuesta))
          .toList();
    } else if (estado == 'Finalizada') {
      encuestas = _encuestasFiltradas
          .where((encuesta) => _encuestasFinalizadas.contains(encuesta))
          .toList();
    } else if (estado == 'Derivada') {
      encuestas = _encuestasFiltradas
          .where((encuesta) => _encuestasDerivadas.contains(encuesta))
          .toList();
    } else if (estado == 'Iniciada') {
      encuestas = _encuestasFiltradas
          .where((encuesta) => _encuestasIniciadas.contains(encuesta))
          .toList();
    }

    encuestas
        .sort((a, b) => b['Fecha creación'].compareTo(a['Fecha creación']));

    List<Widget> tarjetasFiltradas = encuestas.map((encuesta) {
      bool enProceso = _encuestasProceso.contains(encuesta);
      bool finalizada = _encuestasFinalizadas.contains(encuesta);
      bool iniciada = _encuestasIniciadas.contains(encuesta);

      return TarjetaIncidencia(
        title: encuesta['Nombre'] ?? 'Nombre no disponible',
        subtitle:
            '${formatDate(encuesta['Fecha creación'])} - ${enProceso ? 'En proceso' : finalizada ? 'Finalizada' : iniciada ? 'Iniciada' : 'Derivada'}',
        icon: enProceso
            ? CustomIcons.enproceso
            : finalizada
                ? CustomIcons.finalizada
                : iniciada
                    ? CustomIcons.iniciada
                    : CustomIcons.derivada,
        iconColor: enProceso
            ? Color.fromARGB(255, 62, 68, 0)
            : finalizada
                ? Color.fromARGB(255, 8, 72, 92)
                : iniciada
                    ? Color.fromARGB(255, 32, 82, 34)
                    : Color.fromARGB(255, 0, 0, 0),
        iconBackgroundColor: enProceso
            ? Color(0xFFEAF471)
            : finalizada
                ? Color(0xFF69DBFF)
                : iniciada
                    ? Color(0xFF00C853)
                    : Color(0xFFEAA51E),
        id: enProceso
            ? 'En proceso'
            : finalizada
                ? 'Finalizada'
                : iniciada
                    ? 'Iniciada'
                    : 'Derivada',
        onTap: () async {
          bool hasConnection = await InternetConnectionChecker().hasConnection;

          if (hasConnection) {
            print('ID a pasar: ${encuesta['ID']}');
            String? id = encuesta['ID']?.toString();
            if (id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => enProceso
                      ? FormularioEnProceso(id: id)
                      : finalizada
                          ? FormularioFinalizado(id: id)
                          : iniciada
                              ? FormularioIniciada(id: id)
                              : FormularioDerivada(id: id),
                ),
              );
            } else {
              print('Error: El ID es nulo.');
            }
          } else {
            // Sin conexión, obtenemos el ID de la base de datos local
    int localId = encuesta['id'];  // Aquí usamos el ID local desde la tabla `requests`
    print('ID local a pasar: $localId');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => enProceso
            ? FormularioEnProceso(id: localId.toString())
            : finalizada
                ? FormularioFinalizado(id: localId.toString())
                : iniciada
                    ? FormularioIniciada(id: localId.toString())
                    : FormularioDerivada(id: localId.toString()),
              ),
            );
          }
        },
      );
    }).toList();

    List<Widget> tarjetasConSeparacion = [];
    for (int i = 0; i < tarjetasFiltradas.length; i++) {
      tarjetasConSeparacion.add(tarjetasFiltradas[i]);
      if (i < tarjetasFiltradas.length - 1) {
        tarjetasConSeparacion.add(SizedBox(height: 10));
      }
    }

    return tarjetasConSeparacion;
  }
}
