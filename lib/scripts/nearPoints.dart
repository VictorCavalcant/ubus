import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/data/stops.dart';

class Diflongs {
  String name = '';
  double difLong = 0.0;
  LatLng coords = LatLng(0.0, 0.0);

  Diflongs(this.name, this.difLong, this.coords);
}

  double getMaxValue(List array) {
    double big = array[0];
    for (var i = 1; i < array.length; i++) {
      big = max(big, array[i]);
    }
    return big;
  }

  List threeNearestPoints(List array) {
    var near1, near2, near3 = 0.0;
    List nears = [];
    final onlyValues = array.map((e) => e.difLong).toList();

    near1 = getMaxValue(onlyValues);
    near2 = getMaxValue(onlyValues.where((fl) => fl != near1).toList());
    near3 = getMaxValue(
        onlyValues.where((fl) => fl != near1 && fl != near2).toList());

    nears.addAll([near1, near2, near3].toList());
    nears.sort();
    List result;

    result = array.where((fl) => nears.contains(fl.difLong)).toList();
    return result;
  }

  List getNearPoints(List<Stop> array, myLocLong) {
    List nearPoints, difsLongs = [];

    for (var i = 0; i < array.length; i++) {
      var _difLong = myLocLong - array[i].coords.longitude;
      if (_difLong > 0) {
        _difLong *= -1;
      }
      difsLongs = [
        ...difsLongs,
        Diflongs(array[i].name, _difLong,
            LatLng(array[i].coords.latitude, array[i].coords.longitude))
      ];
    }

    nearPoints = threeNearestPoints(difsLongs);

    return nearPoints;
  }

