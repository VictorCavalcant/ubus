import 'package:flutter/material.dart';
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
          ...stop_provider.nearsStops!.map((ns) =>
              CardStop(ns.name, ns.coords.latitude, ns.coords.longitude))
        ],
      ),
    );
  }
}
