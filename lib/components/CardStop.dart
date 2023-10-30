import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/Metrics.dart';
import 'package:ubus/providers/StopProvider.dart';

class CardStop extends StatelessWidget {
  CardStop(this.title, this.lat, this.long);

  final String title;
  final double lat;
  final double long;

  @override
  Widget build(BuildContext context) {
    final stop_provider = Provider.of<StopProvider>(context);
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 60,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              softWrap: true,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 19,
              ),
            ),
            IconButton(
              onPressed: () {
                context
                    .read<StopProvider>()
                    .getStopDestination(PointLatLng(lat, long), title);
              },
              icon: const Icon(
                Icons.directions,
                color: Colors.blue,
                size: 30,
              ),
            ),
            stop_provider.distance != null &&
                    stop_provider.duration != null &&
                    title == context.watch<StopProvider>().stopName
                ? Metrics(stop_provider.distance, stop_provider.duration)
                : Container()
          ],
        ),
      ),
    );
  }
}
