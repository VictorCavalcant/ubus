import 'package:flutter/material.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mpt;
import 'package:ubus/data/regions_points.dart';
import 'package:ubus/data/regions_stops.dart';
import 'package:ubus/models/RegionStops.dart';
import 'package:ubus/models/Stop.dart';

class RegionProvider extends ChangeNotifier {
  bool isInTheArea = false;
  List<RegionStops> regionStop = [];
  List<RegionStops> regionStop_edge = [];

  List<Stop> stops = [];
  bool isNearEdge = false;

  resetStops() {
    stops.clear();
  }

  checkUpdatedLocation(dynamic currentLoc) async {
    int i = 0;
    while (i < regions_points.length) {
      List<mpt.LatLng> convertedPolygonPoints = regions_points[i]
          .points
          .map(
            (point) => mpt.LatLng(point.latitude, point.longitude),
          )
          .toList();

      isInTheArea = mpt.PolygonUtil.containsLocation(
          mpt.LatLng(currentLoc.latitude, currentLoc.longitude),
          convertedPolygonPoints,
          false);

      if (isInTheArea) {
        regionStop = regions_stops
            .where((rg) => rg.name == regions_points[i].name)
            .toList();
        stops = regionStop[0].stops;
        print(stops.isEmpty);
        break;
      }
      i++;
    }
    print(i);
    notifyListeners();
  }

  Future<void> checkPolygonEdge(dynamic currentLoc) async {
    int i = 0;
    int tol = 300;

    while (i > -1) {
      List<mpt.LatLng> convertedPolygonPoints = regions_points[i]
          .points
          .map(
            (point) => mpt.LatLng(point.latitude, point.longitude),
          )
          .toList();

      isNearEdge = mpt.PolygonUtil.isLocationOnEdge(
          mpt.LatLng(currentLoc.latitude, currentLoc.longitude),
          convertedPolygonPoints,
          false,
          tolerance: tol);

      if (isNearEdge) {
        regionStop_edge = regions_stops
            .where((rg) => rg.name == regions_points[i].name)
            .toList();
        stops = regionStop_edge[0].stops;
        print("stops is empty? ---> ${stops.isEmpty}");
        break;
      }

      i++;

      if (i > regions_points.length - 1) {
        i = 0;
        tol += 100;
      }
    }

    notifyListeners();
  }
}
