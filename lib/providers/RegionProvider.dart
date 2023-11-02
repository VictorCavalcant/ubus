import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mpt;
import 'package:ubus/data/regions_points.dart';
import 'package:ubus/data/regions_stops.dart';
import 'package:ubus/models/RegionStops.dart';
import 'package:ubus/models/Stop.dart';

class RegionProvider extends ChangeNotifier {
  bool isInTheArea = false;
  List<RegionStops> regionStop = [];
  List<Stop> stops = [];

  void checkUpdatedLocation(LatLng pointLatLng) {
    for (var region in regions_points) {
      List<mpt.LatLng> convertedPolygonPoints = region.points
          .map(
            (point) => mpt.LatLng(point.latitude, point.longitude),
          )
          .toList();

      isInTheArea = mpt.PolygonUtil.containsLocation(
          mpt.LatLng(pointLatLng.latitude, pointLatLng.longitude),
          convertedPolygonPoints,
          false);

      if (isInTheArea) {
        regionStop =
            regions_stops.where((rg) => rg.name == region.name).toList();
        stops = regionStop[0].stops;
      }
    }


    
  }
}
