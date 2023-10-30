import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusDriverProvider extends ChangeNotifier {
  LatLng? driverLoc;
  String? Driver_name;

  BusDriverProvider({this.driverLoc, this.Driver_name});

  Future<void> getCurrentLocation() async {
    Position? _currentL = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    driverLoc = await LatLng(_currentL.latitude, _currentL.longitude);
    notifyListeners();
  }

  Future<void> updateLocation(
      {Future<void> Function()? cameraFunction, dynamic addMarker}) async {
    Geolocator.getPositionStream(
        locationSettings: AndroidSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
      forceLocationManager: true,
      useMSLAltitude: true,
    )).listen(
      (Position position) async {
        driverLoc = await LatLng(position.latitude, position.longitude);
        cameraFunction!();
        addMarker(position!);
        notifyListeners();
      },
    );
  }
}
