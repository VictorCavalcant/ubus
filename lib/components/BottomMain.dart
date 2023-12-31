import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/BottomMenuItem.dart';
import 'package:ubus/providers/StopProvider.dart';

class MainMenu extends StatelessWidget {
  const MainMenu();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MenuItem('Paradas Próximas', 'assets/bus-stop.png',
            context.read<StopProvider>().showNearStops),
      ],
    );
  }
}


/*

Go to SearchPage

() {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SearchBus()));
        }

*/