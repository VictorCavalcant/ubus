import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ubus/pages/SignIn.dart';
import 'dart:ui' as ui;

import 'package:ubus/services/Auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    Geolocator.getPositionStream(
        locationSettings: LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    )).listen((Position position) {
      _currentP = LatLng(position.latitude, position.longitude);
      _cameraToPosition();
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
  }

  BitmapDescriptor _BusLocMarker = BitmapDescriptor.defaultMarker;

  GetClocation() {
    _cameraToPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
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
              leading: Icon(Icons.science),
              title: Text("Teste"),
              onTap: () {
                print("teste ${_currentP}");
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
            onPressed: () {
              print("Valor de _currentP ---> $_currentP");
            },
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
                          icon: _BusLocMarker)
                    },
                  ),
                ),
                Expanded(
                  child: Container(
                      height: 60,
                      padding: const EdgeInsets.all(6),
                      color: const Color(0xFF0057DA),
                      child: Container()),
                )
              ],
            ),
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
    if (_currentP != null) {
      _customMarkerIcon();
      final GoogleMapController controller = await _mapController.future;
      controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentP!, zoom: 15),
        ),
      );
    }
  }

  // Location Section

  void getCurrentPosition() async {
    Position? _currentL = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentP = LatLng(_currentL.latitude, _currentL.longitude);
    });
  }
}
