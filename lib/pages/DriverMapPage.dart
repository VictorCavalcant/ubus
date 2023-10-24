import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:ubus/misc/consts.dart';
import 'package:ubus/pages/SignIn.dart';
import 'dart:ui' as ui;

import 'package:ubus/services/Auth_service.dart';
import 'package:ubus/services/CloudStore.dart';

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;
  int zoomValue = 17;
  final _currentDriverName = FirebaseAuth.instance.currentUser!.displayName;
  final _currentDriverId = FirebaseAuth.instance.currentUser!.uid;
  bool isActive = false;

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position position) {
      setState(() {
        _currentP = LatLng(position.latitude, position.longitude);
        _customMarkerIcon();
        _cameraToPosition();
      });
      if (isActive) {
        print("valor de isActive -> $isActive");
        CloudStore().GetCoords(
            _currentDriverId, _currentP!.latitude, _currentP!.longitude);
      }
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
  }

  BitmapDescriptor _BusLocMarker = BitmapDescriptor.defaultMarker;

  GetClocation() {
    _cameraToPosition();
  }

  testeFunction() {
    print("Nome do motorista --> $_currentP ");
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: CloudStore().getDriversStream(_currentDriverId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitRing(
                color: Colors.blue,
                size: 50.0,
              ),
            );
          }

          final driverDocument = snapshot.data;

          isActive = driverDocument!["active"];

          if (!isActive) {
            CloudStore().ResetCoords(_currentDriverId);
          }

          return Scaffold(
            drawer: Drawer(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primaryColor,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    title: Text('${_currentDriverName}'),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text("Sair"),
                    onTap: () {
                      AuthService().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text("Configurações de Localização"),
                  ),
                ],
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 80),
              child: SizedBox(
                width: 40,
                height: 40,
                child: FloatingActionButton(
                    child: Icon(Icons.gps_fixed),
                    onPressed: () {
                      GetClocation();
                    }),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: testeFunction,
                  icon: Icon(Icons.science),
                )
              ],
              iconTheme: IconThemeData(color: Colors.white),
              toolbarHeight: 45,
              title: const Text('ubus',
                  style: TextStyle(
                      fontFamily: 'Flix', color: Colors.white, fontSize: 37)),
              centerTitle: true,
              backgroundColor: const Color(0xFF0057DA),
            ),
            body: _currentP == null
                ? const Center(
                    child: SpinKitRing(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: GoogleMap(
                          myLocationEnabled: true,
                          mapToolbarEnabled: false,
                          onMapCreated: ((GoogleMapController controller) =>
                              _mapController.complete(controller)),
                          initialCameraPosition:
                              CameraPosition(target: _currentP!, zoom: 15),
                          zoomControlsEnabled: false,
                          markers: {
                            Marker(
                                markerId: MarkerId(''),
                                position: _currentP!,
                                icon: _BusLocMarker,
                                anchor: Offset(0.5, 0.5))
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 60,
                          padding: const EdgeInsets.all(6),
                          color: const Color(0xFF0057DA),
                          child: Center(
                            child: ClipOval(
                              child: Material(
                                color: !driverDocument["active"]
                                    ? Colors.green
                                    : Colors.red, // Button color
                                child: InkWell(
                                  onTap: () {
                                    CloudStore().ToggleActive(_currentDriverId,
                                        driverDocument["active"]);
                                    if (!isActive) {
                                      CloudStore().GetCoords(
                                          _currentDriverId,
                                          _currentP!.latitude,
                                          _currentP!.longitude);
                                    }
                                  },
                                  child: SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Center(
                                        child: Text(
                                      !driverDocument["active"]
                                          ? "INICIAR"
                                          : "PARAR",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          );
        });
  }

  // || GoogleMap Services||

  // CustomIconMarker Section

  Future<Uint8List> getBytesFromAssets(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  _customMarkerIcon() async {
    final Uint8List customIcon =
        await getBytesFromAssets("assets/bus_LocMark.png", 120);
    _BusLocMarker = BitmapDescriptor.fromBytes(customIcon);
    setState(() {});
  }

  // Camera section

  Future<void> _cameraToPosition() async {
    if (_currentP != null) {
      _customMarkerIcon();
      final GoogleMapController controller = await _mapController.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentP!, zoom: 18),
        ),
      );
    }
  }

  // Location Section

  void getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location permission are denied');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are denied forever!');
    }

    Position? _currentL = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentP = LatLng(_currentL.latitude, _currentL.longitude);
    });
  }

  void location_settings() {
    late LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          //(Optional) Set foreground notification config to keep the app alive
          //when going to the background
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationText:
                "Ubus will continue to receive your location even when you aren't using it",
            notificationTitle: "Running in Background",
            enableWakeLock: true,
          ));
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 100,
        pauseLocationUpdatesAutomatically: true,
        // Only set to true if our app will be started up in the background.
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      );
    }

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      setState(() {
        _currentP = LatLng(position!.latitude, position.longitude);
        _customMarkerIcon();
        _cameraToPosition();
      });
      if (isActive) {
        print("valor de isActive -> $isActive");
        CloudStore().GetCoords(
            _currentDriverId, _currentP!.latitude, _currentP!.longitude);
      }
    });
  }
}
