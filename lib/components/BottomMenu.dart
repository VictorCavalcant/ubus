import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ubus/components/BottomMain.dart';
import 'package:ubus/components/NearStops.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu(this.NP_visible, this.showNS, this.nearStops,
      this.getStopCoords, this.distance, this.time_distance, this.stopName);

  final bool NP_visible;
  final Function() showNS;
  final List nearStops;
  final Function(PointLatLng, String) getStopCoords;
  final String? distance;
  final String? time_distance;
  final String stopName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      color: const Color(0xFF0057DA),
      child: Container(
        child: NP_visible
            ? NearStops(nearStops, getStopCoords, distance, time_distance, stopName)
            : MainMenu(showNS),
      ),
    );
  }
}
