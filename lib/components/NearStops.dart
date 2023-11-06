import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/CardStop.dart';
import 'package:ubus/providers/StopProvider.dart';

class NearStops extends StatelessWidget {
  const NearStops();

  @override
  Widget build(BuildContext context) {
    final stop_provider = Provider.of<StopProvider>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stop_provider.nearsStops.isEmpty)
            Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: Align(
                    alignment: Alignment.center,
                    child: const SpinKitRing(
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                ),
              ]),
            )
          else
            ...stop_provider.nearsStops.map((ns) =>
                CardStop(ns.name, ns.coords.latitude, ns.coords.longitude))
        ],
      ),
    );
  }
}
