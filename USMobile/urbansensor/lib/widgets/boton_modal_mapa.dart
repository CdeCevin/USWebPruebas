import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:urbansensor/widgets/appbar_generica.dart';
import 'package:urbansensor/widgets/boton_generico.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_places_flutter/model/prediction.dart';

class MapaScreen extends StatelessWidget {
  final LatLng? selectedLocation;

  const MapaScreen({Key? key, this.selectedLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalMapa(selectedLocation: selectedLocation);
  }
}

class ModalMapa extends StatefulWidget {
  final LatLng? selectedLocation;

  const ModalMapa({Key? key, this.selectedLocation}) : super(key: key);

  @override
  _ModalMapaState createState() => _ModalMapaState();
}

class _ModalMapaState extends State<ModalMapa> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  LatLng _currentPosition = LatLng(-33.4489, -70.6693);
  LatLng? _selectedPosition;
  bool _isFirstLoad = true;
  bool _isLoading = true;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.selectedLocation ?? LatLng(-33.8688, 151.2093);
    if (_currentLocation != null) {
      _selectedPosition = _currentLocation;
      _markers.add(
        Marker(
          markerId: MarkerId('selected-location'),
          position: _currentLocation!,
        ),
      );
    }
  }

  void _determinePosition() async {
    setState(() {
      _isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorDialog('Por favor, habilita el servicio de ubicación.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showErrorDialog('Los permisos de ubicación fueron denegados');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showErrorDialog(
        'Los permisos de ubicación están permanentemente denegados, no podemos solicitar permisos.',
      );
      return;
    }

    Position currentPosition = await Geolocator.getCurrentPosition();
    _currentPosition = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    _selectedPosition = _currentPosition;
    String address = await _getAddressFromLatLng(_currentPosition);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('miUbicacion'),
          position: _currentPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(title: 'Mi ubicación', snippet: address),
        ),
      );
      _isLoading = false;
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentPosition));
  }

  Future<String> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.street}, ${place.locality}, ${place.country}";
      }
    } catch (e) {
      return "Dirección no encontrada";
    }
    return "Dirección no encontrada";
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _centerCameraOnCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    String address = await _getAddressFromLatLng(_currentPosition);

    setState(() {
      _selectedPosition = _currentPosition;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId('miUbicacion'),
          position: _currentPosition,
          infoWindow: InfoWindow(title: 'Mi ubicación', snippet: address),
        ),
      );
    });
  }

  Widget placesAutoCompleteTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: GooglePlaceAutoCompleteTextField(
        textEditingController: searchController,
        googleAPIKey: "API_KEY",
        inputDecoration: InputDecoration(
          hintText: "Buscar una ubicación",
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        debounceTime: 400,
        countries: ["cl"],
        isLatLngRequired: true,
        focusNode: searchFocusNode,
        getPlaceDetailWithLatLng: (Prediction prediction) async {
          if (prediction.lat != null && prediction.lng != null) {
            LatLng selectedLocation = LatLng(
              double.parse(prediction.lat!),
              double.parse(prediction.lng!),
            );
            String address = await _getAddressFromLatLng(selectedLocation);
            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newLatLng(selectedLocation));

            setState(() {
              _selectedPosition = selectedLocation;
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: MarkerId('selectedLocation'),
                  position: selectedLocation,
                  infoWindow: InfoWindow(
                    title: 'Ubicación seleccionada',
                    snippet: address,
                  ),
                ),
              );
            });

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setDouble(
              'selectedLatitude',
              selectedLocation.latitude,
            );
            await prefs.setDouble(
              'selectedLongitude',
              selectedLocation.longitude,
            );
          }
        },
        itemClick: (Prediction prediction) {
          searchController.text = prediction.description ?? "";
          searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description?.length ?? 0),
          );
          FocusScope.of(context).requestFocus(searchFocusNode);
        },
        seperatedBuilder: Divider(),
        containerHorizontalPadding: 10,
        itemBuilder: (context, index, Prediction prediction) {
          return Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 7),
                Expanded(child: Text("${prediction.description ?? ""}")),
              ],
            ),
          );
        },
        isCrossBtnShown: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: MyAppBar(title: 'Mapa', appBarHeight: 100),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 11.4746,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                _determinePosition();
              },
              onTap: (LatLng location) async {
                String address = await _getAddressFromLatLng(location);
                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: location,
                      infoWindow: InfoWindow(
                        title: 'Ubicación seleccionada',
                        snippet: address,
                      ),
                    ),
                  );
                  _selectedPosition = location;
                });

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('selectedLatitude', location.latitude);
                await prefs.setDouble('selectedLongitude', location.longitude);
              },
              markers: _markers,
            ),
            if (_isLoading) Center(child: CircularProgressIndicator()),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: placesAutoCompleteTextField(),
            ),
            Positioned(
              bottom: 68,
              left: 100,
              right: 100,
              child: BotonGenerico(
                text: 'Seleccionar',
                onPressed: () {
                  Navigator.pop(context, _selectedPosition);
                },
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.15,
              right: MediaQuery.of(context).size.width * 0.02,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _centerCameraOnCurrentLocation,
                  child: Icon(Icons.my_location),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
