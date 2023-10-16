import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/StopInfoButton.dart';
import 'package:ubus/providers/StopProvider.dart';

class StopInfo extends StatelessWidget {
  StopInfo(this.stopName, this.stopCoords);

  String stopName = '';
  PointLatLng stopCoords;

  @override
  Widget build(BuildContext context) {
    final stop_provider = Provider.of<StopProvider>(context);
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            height: 170,
            child: Image.asset(
              'assets/parada_de_onibus.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Parada São Sebastião",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Rua tal num sei o que la')),
          ),
          Divider(
            color: Color.fromARGB(40, 0, 0, 0),
            height: 30,
            thickness: 1,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StopInfoButton(
                    title: 'Traçar Rota',
                    icon: Icons.directions,
                    function: () {
                      stop_provider.getStopDestination(stopCoords, stopName);
                      stop_provider.setStopInfoTrue();
                      Navigator.pop(context);
                    }),
                StopInfoButton(
                  title: 'Lista de Ônibus',
                  image: 'assets/bus_search_icon.png',
                ),
              ])
        ],
      ),
    );
  }
}
