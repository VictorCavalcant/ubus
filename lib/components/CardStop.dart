import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


class CardStop extends StatelessWidget {
  const CardStop(this.title, this.getStopCoords, this.lat, this.long);

  final String title;
  final double lat;
  final double long;
  final Function(PointLatLng) getStopCoords;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        height: 60,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            margin: const EdgeInsets.only(left: 5),
            child: Image.asset(
              'assets/bus_stop-icon_t.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19,
            ),
          ),
          IconButton(
              onPressed: () => getStopCoords(PointLatLng(lat, long)),
              icon: const Icon(
                Icons.directions,
                color: Colors.blue,
                size: 30,
              ))
        ]),
      ),
    );
  }
}
