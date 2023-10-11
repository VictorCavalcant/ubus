import 'package:flutter/material.dart';
import 'package:ubus/components/BottomMenuItem.dart';
import 'package:ubus/pages/SearchPage.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 60,
      padding: EdgeInsets.all(6),
      color: Color(0xFF0057DA),
      child: Center(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MenuItem('Paradas Próximas', 'assets/bus-stop.png',
              () => print("EAE GALERAAAAAAAA!")),
          VerticalDivider(),
          MenuItem('Buscar Ônibus', 'assets/bus_Search2.png', () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SearchBus()));
          })
        ],
      )),
    );
  }
}
