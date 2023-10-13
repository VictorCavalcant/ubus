import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ubus/components/BottomMenu.dart';
import 'dart:ui' as ui;
import 'package:ubus/data/stops.dart';
import 'package:ubus/scripts/nearPoints.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  List nearStops = [];
  PointLatLng stopDestination = PointLatLng(0.0, 0.0);
  int distanceValue = 0;
  int durationValue = 0;
  int zoomValue = 17;

  Map<PolylineId, Polyline> polylines = {};

  showNearStops() {
    setState(() {
      nearStopsVisible = true;
      nearStops = getNearPoints(stops, _currentP!.longitude);
    });
  }

  hideNearStops() {
    setState(() {
      nearStopsVisible = false;
      stopDestination = PointLatLng(0.0, 0.0);
    });
  }

  @override
  void initState() {
    super.initState();
    zoomValue;
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
    getLocationUpdates().then(
      (_) => {
        getPolylinePoints().then((coordinates) => {
              generatePolyLineFromPoints(coordinates),
            }),
      },
    );
  }

  BitmapDescriptor _stopMarkerIcon = BitmapDescriptor.defaultMarker;

  getStopDestination(PointLatLng value) {
    setState(() {
      stopDestination = value;
      getLocationUpdates().then(
        (_) => {
          getPolylinePoints().then((coordinates) => {
                generatePolyLineFromPoints(coordinates),
              }),
        },
      );
    });
  }

  testeFunction() {
    print(dotenv.env['GOOGLE_MAPS_KEY']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: testeFunction, icon: Icon(Icons.science))
        ],
        leading: nearStopsVisible
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: hideNearStops,
              )
            : null,
        toolbarHeight: 50,
        title: const Text('ubus',
            style: TextStyle(
                fontFamily: 'Flix', color: Colors.white, fontSize: 40)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0057DA),
      ),
      body: _currentP == null
          ? const Center(
              child: Text("Loading..."),
            )
          : Column(children: [
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
                      }),
                    },
                    polylines: stopDestination.latitude != 0.0
                        ? Set<Polyline>.of(polylines.values)
                        : {},
                  )),
              Expanded(
                  child: BottomMenu(nearStopsVisible, showNearStops, nearStops,
                      getStopDestination))
            ]),
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
        await getBytesFromAssets("assets/Bus_marker.png", 120);
    _stopMarkerIcon = BitmapDescriptor.fromBytes(customIcon);
    setState(() {});
  }

  // Camera section

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  // Location Section

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

    getLoc() {
      setState(() {
        _currentP = LatLng(currentLocation.latitude, currentLocation.longitude);
        print(_currentP);
      });
    }

    getLoc();

    const LocationSettings locationSettings = LocationSettings(
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

  // Polyline Section

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env['GOOGLE_MAPS_KEY'].toString(),
      PointLatLng(_currentP!.latitude, _currentP!.longitude),
      stopDestination,
      travelMode: TravelMode.walking,
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }
}
