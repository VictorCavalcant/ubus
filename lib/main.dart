import 'package:flutter/material.dart';
import 'package:ubus/pages/MapPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ubus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData().copyWith(
          primaryColor: Color(0xFF0057DA),
          colorScheme:
              ThemeData().colorScheme.copyWith(primary: Color(0xFF0057DA)),
          useMaterial3: true),
      home: MapPage(),
    );
  }
}
