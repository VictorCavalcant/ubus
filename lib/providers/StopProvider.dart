import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  double CurrentLoc_lat;
  bool isGettingTD = false;

  StopProvider(
      {this.stopName = '',
      this.stopCoords = const PointLatLng(0.0, 0.0),
      this.isNearStopsVisible = false,
      this.isStopInfoVisible = false,
      this.nearsStops,
      this.CurrentLoc_lat = 0.0});

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

  dynamic showNearStops() {
    isNearStopsVisible = true;
    isGettingTD = true;
    nearsStops = getNearPoints(stops, CurrentLoc_lat);
    notifyListeners();
  }

  void getCurrentLat(value) {
    CurrentLoc_lat = value;
  }

  setStopInfoTrue() {
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
