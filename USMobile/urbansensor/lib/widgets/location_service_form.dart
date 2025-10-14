import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _singleton = LocationService._internal();

  factory LocationService() {
    return _singleton;
  }

  LocationService._internal();

  final StreamController<LatLng?> _locationController =
      StreamController<LatLng?>.broadcast();
  final StreamController<String?> _addressController =
      StreamController<String?>.broadcast();

  Stream<LatLng?> get locationStream => _locationController.stream;
  Stream<String?> get addressStream => _addressController.stream;

  void updateLocation(LatLng? newLocation) {
    _locationController.sink.add(newLocation);
    if (newLocation != null) {
      _getAddressFromLatLng(newLocation);
    } else {
      _addressController.sink.add(null);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '${place.street}, ${place.locality}, ${place.country}';
        _addressController.sink.add(address);
      }
    } catch (e) {
      _addressController.sink.add('Dirección no encontrada');
    }
  }

  void dispose() {
    _locationController.close();
    _addressController.close();
  }
}
