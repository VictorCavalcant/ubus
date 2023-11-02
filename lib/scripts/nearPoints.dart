import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/data/stops.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:ubus/models/Stop.dart';

class CoordTime_Distance {
  String name = '';
  LatLng coords = LatLng(0.0, 0.0);
  double distance = 0;
  int duration = 0;

  CoordTime_Distance(this.name, this.coords, this.distance, this.duration);
}

Future<List<CoordTime_Distance>> getPointsTD(
    List<Stop> array, LatLng myLoc) async {
  List<CoordTime_Distance> points = [];
  String removeKm = '';
  double distance_double = 0.0;
  String removeMins = '';
  String removeMin = '';
  int duration_int = 0;

  for (var i = 0; i < array.length; i++) {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['GOOGLE_MAPS_KEY'].toString(),
      PointLatLng(myLoc.latitude, myLoc.longitude),
      PointLatLng(array[i].coords.latitude, array[i].coords.longitude),
      travelMode: TravelMode.walking,
    );

    removeKm = result.distance!.replaceAll('km', '');
    distance_double = double.parse(removeKm);
    removeMins = result.duration!.replaceAll('mins', '');

    if (removeMins.contains('min')) {
      removeMin = result.duration!.replaceAll('min', '');
    }

    if (removeMin == '') {
      duration_int = int.parse(removeMins);
    } else {
      duration_int = int.parse(removeMin);
    }

    points.add(CoordTime_Distance(
        array[i].name, array[i].coords, distance_double, duration_int));
  }
  return points;
}

getNearPoint(List<CoordTime_Distance> points) {
  CoordTime_Distance nearPoint;
  dynamic getSpecificPoint;
  String point_name;
  LatLng point_coords;
  double nearestDistance = points[0].distance;
  int time_minimun = points[0].duration;

  for (var i = 1; i < points.length; i++) {
    if (nearestDistance > points[i].distance) {
      nearestDistance = points[i].distance;
      time_minimun = points[i].duration;
    }

    if (nearestDistance == points[i].distance) {
      if (time_minimun > points[i].duration) {
        time_minimun = points[i].duration;
      }
    }
  }

  getSpecificPoint = points
      .where((point) =>
          point.distance == nearestDistance && point.duration == time_minimun)
      .toList();
  point_name = getSpecificPoint[0].name;
  point_coords = getSpecificPoint[0].coords;

  nearPoint = CoordTime_Distance(
      point_name, point_coords, nearestDistance, time_minimun);

  return nearPoint;
}

getThreeNearestPoints(List<CoordTime_Distance> points) {
  List<CoordTime_Distance> filterList = [];
  CoordTime_Distance near1, near2, near3;

  near1 = getNearPoint(points);
  filterList.add(near1);
  near2 =
      getNearPoint(points.where((point) => point.name != near1.name).toList());
  filterList.add(near2);
  near3 = getNearPoint(points
      .where((point) => point.name != near1.name && point.name != near2.name)
      .toList());
  filterList.add(near3);

  return filterList;
}

Future<List> getNearPoints(List<Stop> array, LatLng myLoc) async {
  List nearPoints;
  List<CoordTime_Distance> pointsTD = [];
  pointsTD = await getPointsTD(array, myLoc);

  nearPoints = getThreeNearestPoints(pointsTD);

  return nearPoints;
}


