import 'package:flutter/material.dart';

class Metrics extends StatelessWidget {
  const Metrics(this.distance, this.time_distance);

  final String? distance;
  final String? time_distance;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.directions_walk),
        Text(
          distance!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19,
          ),
        ),
        const SizedBox(
          width: 7,
        ),
        const Icon(Icons.timer),
        Text(
          time_distance!,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 19,
          ),
        ),
      ],
    );
  }
}
