import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubus/misc/SplashScreen.dart';
import 'package:ubus/misc/consts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ubus/pages/HomePage.dart';
import 'package:ubus/providers/BusDriverProvider.dart';
import 'package:ubus/providers/StopProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ubus/providers/UserLocationProvider.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future.wait([
    Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ),
    dotenv.load(fileName: ".env"),
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => StopProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => BusDriverProvider(),
        ),
        ChangeNotifierProxyProvider<StopProvider, UserLocationProvider>(
          create: (_) => UserLocationProvider(),
          update: (_, stop, userLoc) => userLoc!..getStopProvider(stop),
        )
      ],
      child: MaterialApp(
        title: 'Ubus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData().copyWith(
            primaryColor: primaryColor,
            colorScheme: ThemeData()
                .colorScheme
                .copyWith(primary: primaryColor, secondary: Colors.white),
            useMaterial3: true),
        home: SplashScreen(),
      ),
    );
  }
}
