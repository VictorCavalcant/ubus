import 'package:flutter/material.dart';
import 'package:ubus/components/BottomMenuItem.dart';
import 'package:ubus/pages/SearchPage.dart';

class MainMenu extends StatelessWidget {
  const MainMenu(this.showNS);

  final Function() showNS;


  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MenuItem('Paradas Próximas', 'assets/bus-stop.png', showNS),
        VerticalDivider(),
        MenuItem('Buscar Ônibus', 'assets/bus_Search2.png', () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchBus()));
        })
      ],
    );
  }
}
