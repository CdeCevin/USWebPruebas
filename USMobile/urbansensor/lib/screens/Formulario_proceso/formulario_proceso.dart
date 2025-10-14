import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/barranavegacion.dart';
import 'package:urbansensor/widgets/location_service.dart';
import 'package:urbansensor/endpoints/finalizar_cerrar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:urbansensor/widgets/formulario/botones_multimedia.dart';
import 'package:urbansensor/widgets/formulario/texto_divisor.dart';
import 'package:urbansensor/widgets/formulario/ubicacion_mapa.dart';
import 'package:urbansensor/widgets/formulario/common_widgets.dart';
import 'package:urbansensor/widgets/formulario/detalles_formulario.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart'; // Usar este para verificar conectividad
import 'package:urbansensor/helpers/offline_helper.dart';
import 'package:intl/intl.dart';

class FormularioEnProceso extends StatefulWidget {
  final String id;

  FormularioEnProceso({required this.id});

  @override
  _FormularioEnProcesoState createState() => _FormularioEnProcesoState();
}

class _FormularioEnProcesoState extends State<FormularioEnProceso> {
  Future<Map<String, dynamic>?>? _formularioDataOnline;
  Future<Map<String, dynamic>?>? _formularioDataOffline;
  List<String> imageUrls = [];
  List<String> videoUrls = [];
  final LocationService _locationService = LocationService();
  AudioPlayer _audioPlayer = AudioPlayer();
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      if (isConnected) {
        _formularioDataOnline = fetchEncuestaDetalles(
          widget.id,
        ); // Método online
      } else {
        _formularioDataOffline = fetchEncuestaDetallesFromLocalDatabase(
          widget.id,
        ); // Método offline
      }
    });
  }

  @override
  void dispose() {
    _locationService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight = MediaQuery.of(context).size.height * 0.15;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double mapHeight = screenHeight * 0.15;
    final double mapWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: MyAppBar(title: 'En Proceso', appBarHeight: appBarHeight),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: isConnected ? _formularioDataOnline : _formularioDataOffline,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los datos.'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No se encontraron datos.'));
          } else {
            final data = snapshot.data!['request_data'];
            List<dynamic> detalles = data['Detalles'] ?? [];
            imageUrls.clear();
            videoUrls.clear();

            double latitud = 0.0;
            double longitud = 0.0;

            for (int i = 0; i < detalles.length; i++) {
              double value = _parseDouble(detalles[i]);

              // Verificamos si el valor parece una latitud o longitud válida
              if (value >= -90 && value <= 90 && latitud == 0.0) {
                latitud =
                    value; // Asignamos la latitud solo si aún no tiene un valor válido
              } else if (value >= -180 && value <= 180 && longitud == 0.0) {
                longitud =
                    value; // Asignamos la longitud solo si aún no tiene un valor válido
              }
            }

            _locationService.updateLocation(LatLng(latitud, longitud));
            print('Latitud: $latitud, Longitud: $longitud');

            //convierte el formato de la fecha
            String fechaFormateada = DateFormat(
              'dd-MM-yyyy',
            ).format(DateTime.parse(data['Fecha creación'].toString()));

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.0),
                    UbicacionMapa(
                      mapHeight: mapHeight,
                      mapWidth: mapWidth,
                      latitud: latitud,
                      longitud: longitud,
                      addressStream: _locationService.addressStream,
                    ),
                    SizedBox(height: 15.0),
                    TextoConDivisor(
                      title: 'Nombre:',
                      text: data['Nombre'].toString(),
                    ),
                    TextoConDivisor(
                      title: 'Estado:',
                      text: data['Estado'].toString(),
                    ),
                    TextoConDivisor(
                      title: 'Cuadrilla:',
                      text: data['Cuadrilla'].toString(),
                    ),
                    TextoConDivisor(
                      title: 'Fecha creación:',
                      text: fechaFormateada,
                    ),
                    for (int i = 0; i < detalles.length; i++)
                      if (detalles[i].toString().isNotEmpty)
                        _buildDetailWidget(detalles[i], i),
                    if (imageUrls.isNotEmpty || videoUrls.isNotEmpty)
                      BotonesMultimedia(
                        videoUrls: videoUrls,
                        imageUrls: imageUrls,
                        onShowVideoPopup:
                            () =>
                                DialogUtils.showVideoPopup(context, videoUrls),
                        onShowPhotoPopup:
                            () =>
                                DialogUtils.showPhotoPopup(context, imageUrls),
                      ),
                    SizedBox(height: 15.0),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [SizedBox(width: 16.0)],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: BarraNavegacion(currentIndex: 0),
    );
  }

  Widget _buildDetailWidget(dynamic detail, int index) {
    if (detail == null || detail.toString().isEmpty) return SizedBox.shrink();
    final text = detail.toString();

    return buildDetailWidget(
      text: text,
      index: index,
      imageUrls: imageUrls,
      videoUrls: videoUrls,
      audioPlayer: _audioPlayer,
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }
}
