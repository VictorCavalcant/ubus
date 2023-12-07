import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/providers/RegionProvider.dart';
import 'package:ubus/scripts/nearPoints.dart';

class StopProvider extends ChangeNotifier {
  String stopName;
  PointLatLng stopCoords;
  String? distance;
  String? duration;
  RegionProvider? region_provider;
  bool isNearStopsVisible;
  bool isStopInfoVisible;
  List nearsStops = [];
  LatLng? currentLoc;
  bool isGettingTD = false;

  StopProvider(
      {this.stopName = '',
      this.stopCoords = const PointLatLng(0.0, 0.0),
      this.isNearStopsVisible = false,
      this.isStopInfoVisible = false,
      this.currentLoc});

  getRegionProvider(RegionProvider regionProvider) {
    region_provider = regionProvider;
    notifyListeners();
  }

  getStopDestination(PointLatLng value, String name) async {
    stopName = name;
    stopCoords = value;
    notifyListeners();
  }

  hideNearStops() {
    stopCoords = PointLatLng(0.0, 0.0);
    distance = null;
    duration = null;
    isNearStopsVisible = false;
    isGettingTD = false;
    notifyListeners();
  }

  hideStopInfo() {
    stopCoords = PointLatLng(0.0, 0.0);
    distance = null;
    duration = null;
    isStopInfoVisible = false;
    isGettingTD = false;
  }

  dynamic showNearStops() async {
    isStopInfoVisible = false;
    isNearStopsVisible = true;
    isGettingTD = true;
    if (region_provider!.isInTheArea == false) {
      await region_provider!.checkPolygonEdge(currentLoc!);
    }
    nearsStops = await getNearPoints(region_provider!.stops, currentLoc!);
    notifyListeners();
  }

  getCurrentLoc(value) {
    currentLoc = value;
    notifyListeners();
  }

  setStopInfoTrue() {
    isNearStopsVisible = false;
    isStopInfoVisible = true;
    isGettingTD = true;
  }

  getDistance_n_Duration(distance_value, duration_value) {
    if (isGettingTD) {
      duration = duration_value;
      String removeM = '';
      String removeK = '';

      removeM = distance_value!.replaceAll('m', '');

      if (removeM.contains('k')) {
        removeK = removeM.replaceAll('k', '');
        double doubleValue = double.parse(removeK);
        int intValue = (doubleValue * 1000).toInt();
        if (doubleValue < 1) {
          distance = '${intValue} m';
        } else {
          distance = distance_value;
        }
      } else if (!removeM.contains('m')) {
        distance = distance_value;
      }

      notifyListeners();
    }
  }
}
