import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:urbansensor/screens/Dashboard/estados.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:urbansensor/endpoints/encuestas_service.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:urbansensor/helpers/database_helper.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int encuestasActivas = 0;
  bool hasConnection = true;
  Map<String, int> encuestasData = {
    'Abiertas': 0,
    'Finalizadas': 0,
    'Derivada': 0,
    'En Proceso': 0,
    'Iniciada': 0
  };

  @override
  void initState() {
    super.initState();
    _checkConnectionAndLoadData();
  }

  Future<void> _checkConnectionAndLoadData() async {
    hasConnection = await InternetConnectionChecker().hasConnection;

    if (hasConnection) {
      // Con conexión a internet, obtenemos datos del servidor
      final data = await fetchEncuestasTotal();
      setState(() {
        encuestasData = data;
      });
    } else {
      // Sin conexión, obtenemos datos de la base de datos local
      final dbHelper = DatabaseHelper.instance;
      final iniciadas = await dbHelper.getEncuestasIniciadas();
      final finalizadas = await dbHelper.getEncuestasFinalizadas();
      final derivadas = await dbHelper.getEncuestasDerivadas();
      final enProceso = await dbHelper.getEncuestasProceso();

      setState(() {
        encuestasData = {
          'Iniciada': iniciadas.length,
          'Finalizadas': finalizadas.length,
          'Derivada': derivadas.length,
          'En Proceso': enProceso.length,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Ir a encuestas Activas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, 'triptico');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.19),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardItem(
                    icon: Icons.approval,
                    title: 'Iniciadas',
                    total: encuestasData['Iniciada']!,
                    color: Color.fromARGB(255, 32, 255, 80),
                  ),
                  SizedBox(width: 16.0),
                  DashboardItem(
                    icon: Icons.check_circle_outline,
                    title: 'Finalizadas',
                    total: encuestasData['Finalizadas']!,
                    color: Color.fromARGB(255, 17, 188, 240),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15.0),
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.19),
                    spreadRadius: 6,
                    blurRadius: 15,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DashboardItem(
                    icon: Icons.autorenew,
                    title: 'Derivadas',
                    total: encuestasData['Derivada']!,
                    color: Color.fromARGB(255, 240, 154, 27),
                  ),
                  SizedBox(width: 16.0),
                  DashboardItem(
                    icon: Icons.hourglass_empty,
                    title: 'En Proceso',
                    total: encuestasData['En Proceso']!,
                    color: Color.fromARGB(255, 245, 255, 110),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25.0),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (encuestasData.values.reduce((a, b) => a > b ? a : b))
                            .toDouble() +
                        5,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        margin: 10,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return 'Finalizadas';
                            case 1:
                              return 'Iniciadas';
                            case 2:
                              return 'En Proceso';
                            case 3:
                              return 'Derivadas';
                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            y: encuestasData['Finalizadas']!.toDouble(),
                            colors: [Colors.blue],
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            y: encuestasData['Iniciada']!.toDouble(),
                            colors: [Colors.green],
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            y: encuestasData['En Proceso']!.toDouble(),
                            colors: [Colors.yellow],
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 3,
                        barRods: [
                          BarChartRodData(
                            y: encuestasData['Derivada']!.toDouble(),
                            colors: [Colors.orange],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            BotonGenerico(
              text: 'Ir a solicitudes',
              onPressed: () {
                Navigator.pushReplacementNamed(context, 'enviadas');
              },
              icon: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
