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
              stop_provider.stopName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 19,
              ),
            ),
            const SizedBox(
              width: 1,
            ),
            stop_provider.distance != null && stop_provider.duration != null
                ? Metrics(stop_provider.distance, stop_provider.duration)
                : Container()
          ],
        ),
      ),
    );
  }
}
