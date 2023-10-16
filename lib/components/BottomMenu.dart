import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/BottomMain.dart';
import 'package:ubus/components/NearStops.dart';
import 'package:ubus/components/StopInfoRoute.dart';
import 'package:ubus/providers/StopProvider.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu();

  @override
  Widget build(BuildContext context) {
    final stop_provider = Provider.of<StopProvider>(context);
    return Container(
      height: 60,
      padding: const EdgeInsets.all(6),
      color: const Color(0xFF0057DA),
      child: Container(
        child: stop_provider.isStopInfoVisible
            ? StopInfoRoute()
            : stop_provider.isNearStopsVisible
                ? NearStops()
                : MainMenu(),
      ),
    );
  }
}
