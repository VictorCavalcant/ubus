import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ubus/components/CardStop.dart';

class NearStops extends StatelessWidget {
  const NearStops(this.nearStops, this.getStopCoords, this.distance, this.time_distance, this.stopName);

  final List nearStops;
  final Function(PointLatLng, String) getStopCoords;
  final String? distance;
  final String? time_distance;
   final String stopName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...nearStops.map((ns) => CardStop(ns.name, getStopCoords, ns.coords.latitude, ns.coords.longitude, distance, time_distance, stopName))],
      ),
    );
  }
}
