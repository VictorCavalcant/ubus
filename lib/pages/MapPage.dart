import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ubus/components/BottomMenu.dart';
import 'dart:ui' as ui;
import 'package:ubus/data/stops.dart';
import 'package:ubus/scripts/nearPoints.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  LatLng? _currentP;
  bool nearStopsVisible = false;
  dynamic nearStops;

  showNearStops() {
    setState(() {
      nearStopsVisible = true;
      nearStops = getNearPoints(stops, _currentP!.longitude);
    });
  }

  hideNearStops() {
    setState(() {
      nearStopsVisible = false;
    });
  }

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
    getLocationUpdates();
  }

  BitmapDescriptor _stopMarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        title: Text('ubus',
            style: TextStyle(
                fontFamily: 'Flix', color: Colors.white, fontSize: 40)),
        centerTitle: true,
        backgroundColor: Color(0xFF0057DA),
      ),
      body: _currentP == null
          ? Center(
              child: Text("Loading..."),
            )
          : Container(
              child: Column(children: [
                Expanded(
                  flex: nearStopsVisible ? 2 : 5,
                  child: GoogleMap(
                      mapToolbarEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: ((GoogleMapController controller) =>
                          _mapController.complete(controller)),
                      initialCameraPosition:
                          CameraPosition(target: _currentP!, zoom: 17),
                      zoomControlsEnabled: false,
                      markers: {
                        ...stops.map((stp) {
                          return Marker(
                              markerId: MarkerId(stp.name),
                              position: stp.coords,
                              icon: _stopMarkerIcon);
                        })
                      }),
                ),
                Expanded(
                    child: BottomMenu(
                        nearStopsVisible, showNearStops, hideNearStops))
              ]),
            ),
    );
  }

  // GoogleMap Services:

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
        await getBytesFromAssets("assets/Bus_marker.png", 120);
    _stopMarkerIcon = BitmapDescriptor.fromBytes(customIcon);
    setState(() {});
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
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
      return Future.error(
          'Location permissions permanently denied, we cannot request permissions');
    }

    var currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _currentP = LatLng(currentLocation.latitude, currentLocation.longitude);

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != currentLocation) {
        setState(() {
          _cameraToPosition(LatLng(position!.latitude, position.longitude));
        });
      }
    });
  }
}
