import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/models/Region.dart';

List<Region> regions_points = [
  Region('Ceará - Osvaldo Cruz', points_Ceara_Osvaldo_Cruz),
  Region('UESPI - UFDPAR', points_Uespi_UFDPAR)
];



List<LatLng> points_Ceara_Osvaldo_Cruz = [
  LatLng(-2.9200588831418286, -41.763133173014516), //start point
  LatLng(-2.9199960666828417, -41.7609843358566),
  LatLng(-2.920247539584505, -41.758878619653004),
  LatLng(-2.9238004777915085, -41.75972168100096),
  LatLng(-2.921700605528581, -41.76217500125567),
  LatLng(-2.9200588831418286, -41.763133173014516), // end point
];

List<LatLng> points_Uespi_UFDPAR = [
  LatLng(-2.904317752679684, -41.75861005031638), //start point
  LatLng(-2.9055981722671573, -41.75914510800857),
  LatLng(-2.9086568664262753, -41.75945273551252),
  LatLng(-2.909141193037212, -41.75376680492405),
  LatLng(-2.9043918731212854, -41.75351237610098),
  LatLng(-2.904317752679684, -41.75861005031638), // end point
];
