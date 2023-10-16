import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ubus/data/stops.dart';
import 'package:ubus/scripts/nearPoints.dart';

class StopProvider extends ChangeNotifier {
  String stopName;
  PointLatLng stopCoords;
  String? distance2;
  String? duration2;
  Future<void>? updatePolyline;
  bool isNearStopsVisible;
  List? nearsStops;
  double CurrentLoc_lat;
  bool isGettingTD = false;

  StopProvider(
      {this.stopName = '',
      this.stopCoords = const PointLatLng(0.0, 0.0),
      this.updatePolyline,
      this.isNearStopsVisible = false,
      this.nearsStops,
      this.CurrentLoc_lat = 0.0});

  void getStopDestination(PointLatLng value, String name) async {
    stopName = name;
    stopCoords = value;
    await updatePolyline;
    notifyListeners();
  }

  void getUpdatePolyline(props) {
    updatePolyline = props();
  }

  hideNearStops() {
    stopCoords = PointLatLng(0.0, 0.0);
    distance2 = null;
    duration2 = null;
    isNearStopsVisible = false;
    isGettingTD = false;
    notifyListeners();
  }

  dynamic showNearStops() {
    isNearStopsVisible = true;
    isGettingTD = true;
    nearsStops = getNearPoints(stops, CurrentLoc_lat);
  }

  void getCurrentLat(value) {
    CurrentLoc_lat = value;
  }

  getDistance_n_Duration(distance_value, duration_value) {
    if (isGettingTD) {
      duration2 = duration_value;
      String removeKm = distance_value!.replaceAll('km', '');
      double doubleValue = double.parse(removeKm);
      int intValue = (doubleValue * 1000).toInt();
      if (doubleValue >= 1) {
        distance2 = distance_value;
      } else {
        distance2 = '$intValue m';
      }
    }
  }
}
