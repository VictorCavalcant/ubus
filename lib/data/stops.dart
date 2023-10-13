import 'package:google_maps_flutter/google_maps_flutter.dart';

class Stop {
  final String name;
  final LatLng coords;
  const Stop(this.name, this.coords);
}

const List<Stop> stops = [
  Stop('teste1', LatLng(-2.9216765178820934, -41.7621293583059)),
  Stop('teste2', LatLng(-2.923760302277007, -41.75973714057531)),
  Stop('teste3', LatLng(-2.920136661241771, -41.76098973218705)),
];
