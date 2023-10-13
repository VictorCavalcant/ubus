import 'package:flutter/material.dart';
import 'package:ubus/components/HomePageButton.dart';
import 'package:ubus/pages/MapPage.dart';

class HomePage extends StatelessWidget {
  HomePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      color: Color(0xFF0469ff),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/splash.png',
              width: 300,
              height: 300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HomePageButton('Ir pro Mapa', 'assets/map_1.png', () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MapPage()));
                }),
                HomePageButton('Motorista', 'assets/driver.png', () {}),
              ],
            )
          ]),
    );
  }
}
