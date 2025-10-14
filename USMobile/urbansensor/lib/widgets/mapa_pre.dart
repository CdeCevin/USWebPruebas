import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps; // Alias para Google Maps
import 'package:flutter_map/flutter_map.dart' as fmap; // Alias para Flutter Map
import 'package:latlong2/latlong.dart' as latlong;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MapaPrev extends StatefulWidget {
  final gmaps.LatLng? location; // Google Maps LatLng
  final double width;
  final double height;

  const MapaPrev({
    Key? key,
    this.location,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  _MapaPrevState createState() => _MapaPrevState();
}

class _MapaPrevState extends State<MapaPrev> {
  gmaps.GoogleMapController? _googleMapController;
  bool _hasInternet = true; // Asume que hay conexión al inicio

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  void _checkInternetConnection() async {
    bool hasConnection = await InternetConnectionChecker().hasConnection;
    setState(() {
      _hasInternet = hasConnection;
    });

    // Escuchar cambios en el estado de la conexión a Internet
    InternetConnectionChecker().onStatusChange.listen((status) {
      setState(() {
        _hasInternet = status == InternetConnectionStatus.connected;
      });
    });
  }

  @override
  void didUpdateWidget(MapaPrev oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != null && widget.location != oldWidget.location) {
      _updateCamera(widget.location!);
    }
  }

  void _updateCamera(gmaps.LatLng location) {
    _googleMapController?.animateCamera(gmaps.CameraUpdate.newLatLng(location));
  }

  @override
  Widget build(BuildContext context) {
    print('Coordenadas recibidas - location: ${widget.location}');
    return Container(
      width: widget.width,
      height: widget.height,
      child: _hasInternet
          ? gmaps.GoogleMap(
              initialCameraPosition: gmaps.CameraPosition(
                target: widget.location ?? gmaps.LatLng(-33.4489, -70.6693), // Posición por defecto
                zoom: 13.2,
              ),
              onMapCreated: (controller) {
                _googleMapController = controller;
                if (widget.location != null) {
                  _updateCamera(widget.location!);
                }
              },
              markers: widget.location != null
              
                  ? {
                      gmaps.Marker(
                        markerId: gmaps.MarkerId('selectedLocation'),
                        position: widget.location!,
                        infoWindow: gmaps.InfoWindow(
                          title: 'Ubicación seleccionada',
                          snippet: 'Latitud: ${widget.location!.latitude}, Longitud: ${widget.location!.longitude}',
                        ),
                      )
                    }
                  : {},
            )
          : Center( // Mostrar mensaje en lugar de mapa
              child: Text(
                'Mapa no disponible sin conexión, ingresar dirección manual en el formulario',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
    );
  }
}
