import 'package:flutter/material.dart';

class RecentBus extends StatelessWidget {
  const RecentBus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Text(
            'Recentes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          color: const Color(0xFFD7D7D7),
          clipBehavior: Clip.hardEdge,
          child: Container(
            height: 60,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/bus_icon.png',
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '01',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Conj. BrotherVille',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
