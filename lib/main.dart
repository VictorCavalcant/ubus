import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubus/misc/SplashScreen.dart';
import 'package:ubus/misc/consts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ubus/providers/StopProvider.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StopProvider()),
      ],
      child: MaterialApp(
        title: 'Ubus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData().copyWith(
            primaryColor: primaryColor,
            colorScheme:
                ThemeData().colorScheme.copyWith(primary: primaryColor),
            useMaterial3: true),
        home: SplashScreen(),
      ),
    );
  }
}
