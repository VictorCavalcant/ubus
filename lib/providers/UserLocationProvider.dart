import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/providers/RegionProvider.dart';
import 'package:ubus/providers/StopProvider.dart';

class UserLocationProvider extends ChangeNotifier {
  LatLng userLoc = LatLng(0.0, 0.0);
  StopProvider? stop_provider;
  RegionProvider? regionProvider;

  getRegionProvider(RegionProvider region) {
    regionProvider = region;
    notifyListeners();
  }

  getStopProvider(StopProvider stop) {
    stop_provider = stop;
    notifyListeners();
  }

  Future<void> getCurrentLocation() async {
    Position? _currentL = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    userLoc = await LatLng(_currentL.latitude, _currentL.longitude);
    stop_provider!.getCurrentLoc(userLoc);
    regionProvider!.checkUpdatedLocation(userLoc);
    if (regionProvider!.isInTheArea == false) {
      regionProvider!.checkPolygonEdge(userLoc);
    }
    notifyListeners();
  }

  Future<void> updateLocation({
    Future<void> Function()? cameraFunction,
  }) async {
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    )).listen(
      (Position position) async {
        userLoc = await LatLng(position.latitude, position.longitude);
        cameraFunction!();
        stop_provider!.getCurrentLoc(userLoc);
        regionProvider!.checkUpdatedLocation(position);
        if (regionProvider!.isInTheArea == false) {
          regionProvider!.checkPolygonEdge(position);
        }
        notifyListeners();
      },
    );
  }
}
