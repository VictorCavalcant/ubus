import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/data/stops.dart';
import 'package:ubus/scripts/nearPoints.dart';

class StopProvider extends ChangeNotifier {
  String stopName;
  PointLatLng stopCoords;
  String? distance;
  String? duration;
  bool isNearStopsVisible;
  bool isStopInfoVisible;
  List? nearsStops;
  LatLng? currentLoc;
  bool isGettingTD = false;

  StopProvider(
      {this.stopName = '',
      this.stopCoords = const PointLatLng(0.0, 0.0),
      this.isNearStopsVisible = false,
      this.isStopInfoVisible = false,
      this.nearsStops,
      this.currentLoc});

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
    nearsStops = await getNearPoints(stops_t, currentLoc!);
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
      String removeKm = distance_value!.replaceAll('km', '');
      double doubleValue = double.parse(removeKm);
      int intValue = (doubleValue * 1000).toInt();
      if (doubleValue >= 1) {
        distance = distance_value;
      } else {
        distance = '$intValue m';
      }
      notifyListeners();
    }
  }
}
