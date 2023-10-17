import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusDriverProvider extends ChangeNotifier {
  LatLng? currentLoc;
  String? Driver_name;

  BusDriverProvider({this.currentLoc, this.Driver_name});

  void GetLoc(value) {
    currentLoc = value;
  }
}
