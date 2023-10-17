import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ubus/components/HomePageButton.dart';
import 'package:ubus/pages/DriverMapPage.dart';
import 'package:ubus/pages/UserMapPage.dart';
import 'package:ubus/pages/SignIn.dart';

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
                        MaterialPageRoute(builder: (context) => UserMapPage()));
                  }),
                  HomePageButton('Motorista', 'assets/driver.png', () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ScreenRouter()));
                  })
                ])
          ]),
    );
  }
}

class ScreenRouter extends StatelessWidget {
  const ScreenRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DriverMapPage();
        } else {
          return SignInPage();
        }
      },
    );
  }
}
