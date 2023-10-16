import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/Metrics.dart';
import 'package:ubus/providers/StopProvider.dart';

class StopInfoRoute extends StatelessWidget {
  const StopInfoRoute({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final stop_provider = Provider.of<StopProvider>(context);
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
            stop_provider.stopName,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 19,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          stop_provider.distance2 != null && stop_provider.duration2 != null
              ? Metrics(stop_provider.distance2, stop_provider.duration2)
              : Container()
        ]),
      ),
    );
  }
}
