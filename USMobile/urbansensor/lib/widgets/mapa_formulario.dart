import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class MapaWidget extends StatefulWidget {
  final double width;
  final double height;

  const MapaWidget({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  _MapaWidgetState createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  Completer<GoogleMapController>? _controllerCompleter;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-33.4489, -70.6693),
    zoom: 10.4746,
  );

  @override
  void initState() {
    super.initState();
    _controllerCompleter = Completer<GoogleMapController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                if (!_controllerCompleter!.isCompleted) {
                  _controllerCompleter!.complete(controller);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
