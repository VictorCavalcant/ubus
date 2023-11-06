import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ubus/misc/consts.dart';
import 'package:ubus/pages/SignIn.dart';
import 'package:ubus/providers/BusDriverProvider.dart';
import 'dart:ui' as ui;

import 'package:ubus/services/Auth_service.dart';
import 'package:ubus/services/DriverService.dart';

class DriverMapPage extends StatefulWidget {
  const DriverMapPage({super.key});

  @override
  State<DriverMapPage> createState() => _DriverMapPageState();
}

class _DriverMapPageState extends State<DriverMapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  Set<Marker> marker = Set();

  LatLng? _currentP;
  final _currentDriverName = FirebaseAuth.instance.currentUser!.displayName;
  final _currentDriverId = FirebaseAuth.instance.currentUser!.uid;
  Marker Bus_Marker = Marker(
    markerId: MarkerId(''),
  );

  addMarker(Position position) {
    Marker resultMarker = Marker(
      markerId: MarkerId("Ônibus"),
      position: LatLng(position.latitude, position.longitude),
      icon: _BusLocMarker,
      anchor: Offset(0.5, 0.5),
    );

    marker = {};
    marker.add(resultMarker);
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    updatePosition();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
    context.read<BusDriverProvider>().getDriverID(_currentDriverId);
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
    final driver_provider = Provider.of<BusDriverProvider>(context);
    return StreamBuilder<DocumentSnapshot>(
      stream: DriverService().getDriversStream(_currentDriverId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: const Center(
              child: const SpinKitRing(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          );
        }

        final driverDocument = snapshot.data;

        driver_provider.getStatus(driverDocument!["active"]);

        if (!driver_provider.isActive) {
          DriverService().ResetCoords(_currentDriverId);
        }

        return Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: primaryColor,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text('${_currentDriverName}'),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Sair"),
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
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 80),
            child: SizedBox(
              width: 40,
              height: 40,
              child: FloatingActionButton(
                  child: const Icon(Icons.gps_fixed),
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
                icon: const Icon(Icons.science),
              )
            ],
            iconTheme: const IconThemeData(color: Colors.white),
            toolbarHeight: 45,
            title: const Text('ubus',
                style: const TextStyle(
                    fontFamily: 'Flix', color: Colors.white, fontSize: 37)),
            centerTitle: true,
            backgroundColor: const Color(0xFF0057DA),
          ),
          body: driver_provider.driverLoc == null
              ? const Center(
                  child: const SpinKitRing(
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
                          myLocationButtonEnabled: false,
                          mapToolbarEnabled: false,
                          onMapCreated: ((GoogleMapController controller) =>
                              _mapController.complete(controller)),
                          initialCameraPosition: CameraPosition(
                              target: driver_provider.driverLoc!, zoom: 15),
                          zoomControlsEnabled: false,
                          markers: marker),
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.all(6),
                        color: const Color(0xFF0057DA),
                        child: Center(
                          child: ClipOval(
                            child: Material(
                              color: !driver_provider.isActive
                                  ? Colors.green
                                  : Colors.red, // Button color
                              child: InkWell(
                                onTap: () {
                                  DriverService().ToggleActive(_currentDriverId,
                                      driver_provider.isActive);
                                  if (!driver_provider.isActive) {
                                    DriverService().getCoords(
                                        _currentDriverId,
                                        driver_provider.driverLoc!.latitude,
                                        driver_provider.driverLoc!.longitude);
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
                                    ),
                                  ),
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
      },
    );
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
    final driver_provider = context.read<BusDriverProvider>();
    final GoogleMapController controller = await _mapController.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: driver_provider.driverLoc!, zoom: 18),
      ),
    );
  }

  // Location Section

  void getCurrentPosition() async {
    final driver_provider = context.read<BusDriverProvider>();

    await driver_provider.getCurrentLocation();
  }

  void updatePosition() async {
    final driver_provider = context.read<BusDriverProvider>();

    await driver_provider.updateLocation(
      cameraFunction: _cameraToPosition,
      addMarker: addMarker,
    );
  }
}
