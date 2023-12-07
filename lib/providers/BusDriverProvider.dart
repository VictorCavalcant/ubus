import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/services/DriverService.dart';

class BusDriverProvider extends ChangeNotifier {
  LatLng? driverLoc;
  String? driver_name;
  String? driver_id;
  bool isActive = false;

  BusDriverProvider({this.driverLoc, this.driver_name});

  getStatus(bool value) {
    isActive = value;
  }

  getDriverID(dynamic id) {
    driver_id = id;
  }

  Future<void> getCurrentLocation() async {
    Position? _currentL = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    driverLoc = await LatLng(_currentL.latitude, _currentL.longitude);
    notifyListeners();
  }

  Future<void> updateLocation({
    Future<void> Function()? cameraFunction,
    dynamic addMarker,
  }) async {
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
        addMarker(position);
        print(isActive);
        if (isActive) {
          print("estou ativo");
          await DriverService()
              .getCoords(driver_id, driverLoc!.latitude, driverLoc!.longitude);
        } else {
          print("estou inativo");
        }
        notifyListeners();
      },
    );
  }
}
