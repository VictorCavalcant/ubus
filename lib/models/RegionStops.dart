import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/models/Stop.dart';

class RegionStops {
  String name = '';
  List<Stop> stops = [];
  RegionStops(this.name, this.stops);
}
