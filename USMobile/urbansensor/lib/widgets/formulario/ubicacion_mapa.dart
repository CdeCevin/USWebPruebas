import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbansensor/widgets/mapa_pre.dart';

class UbicacionMapa extends StatelessWidget {
  final double mapHeight;
  final double mapWidth;
  final double latitud;
  final double longitud;
  final Stream<String?> addressStream;

  UbicacionMapa({
    required this.mapHeight,
    required this.mapWidth,
    required this.latitud,
    required this.longitud,
    required this.addressStream,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Spacer(),
            Text(
              'Ubicación',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 8.0),
        Center(
          child: Container(
            height: mapHeight,
            width: mapWidth,
            child: MapaPrev(
              location: LatLng(latitud, longitud),
              width: mapWidth,
              height: mapHeight,
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Center(
          child: StreamBuilder<String?>(
            stream: addressStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'Obteniendo dirección...',
                  style: TextStyle(fontSize: 16.0),
                );
              } else if (snapshot.hasError) {
                return Text(
                  'Error al obtener la dirección',
                  style: TextStyle(fontSize: 16.0),
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                return Text(
                  'Dirección: ${snapshot.data}',
                  style: TextStyle(fontSize: 16.0),
                );
              } else {
                return Text(
                  'No se ha seleccionado una ubicación',
                  style: TextStyle(fontSize: 16.0),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
