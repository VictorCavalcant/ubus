import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/BottomMenu.dart';
import 'package:ubus/components/StopInfo.dart';
import 'dart:ui' as ui;
import 'package:ubus/data/stops.dart';
import 'package:ubus/providers/StopProvider.dart';
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
  int zoomValue = 17;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
    getLocationUpdates();
  }

  BitmapDescriptor _stopMarkerIcon = BitmapDescriptor.defaultMarker;

  Future<void> updatePolylines() {
    return getLocationUpdates().then(
      (_) => getPolylinePoints().then(
        (coordinates) => generatePolyLineFromPoints(coordinates),
      ),
    );
  }

  setUpdatePolyline() =>
      {context.watch<StopProvider>().getUpdatePolyline(updatePolylines)};

  testeFunction() {}

  @override
  Widget build(BuildContext context) {
    setUpdatePolyline();
    final stop_provider = Provider.of<StopProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: testeFunction,
              icon: Icon(
                Icons.science,
                color: Colors.white,
              ))
        ],
        leading: stop_provider.isNearStopsVisible
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: stop_provider.hideNearStops,
              )
            : stop_provider.isStopInfoVisible
                ? IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: stop_provider.hideStopInfo,
                  )
                : null,
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
          : Column(children: [
              Expanded(
                  flex: stop_provider.isNearStopsVisible ? 2 : 5,
                  child: GoogleMap(
                    mapToolbarEnabled: false,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: ((GoogleMapController controller) =>
                        _mapController.complete(controller)),
                    initialCameraPosition:
                        CameraPosition(target: _currentP!, zoom: 15),
                    zoomControlsEnabled: false,
                    markers: {
                      ...stops.map((stp) {
                        return Marker(
                            markerId: MarkerId(stp.name),
                            onTap: () {
                              showModalBottomSheet(
                                  shape: LinearBorder(side: BorderSide.none),
                                  context: context,
                                  builder: (context) => StopInfo(
                                      stp.name,
                                      PointLatLng(stp.coords.latitude,
                                          stp.coords.longitude)));
                            },
                            position: stp.coords,
                            icon: _stopMarkerIcon);
                      }),
                    },
                    polylines: stop_provider.stopCoords.latitude != 0.0
                        ? Set<Polyline>.of(polylines.values)
                        : {},
                  )),
              Expanded(child: BottomMenu())
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
    print("Valor de pos: $pos");
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(target: pos, zoom: 17);
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
    if (context.read<StopProvider>().stopCoords.latitude != 0.0) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['GOOGLE_MAPS_KEY'].toString(),
        PointLatLng(_currentP!.latitude, _currentP!.longitude),
        context.read<StopProvider>().stopCoords,
        travelMode: TravelMode.walking,
      );

      // setState(() {
      //   duration = result.duration;

      //   String removeKm = result.distance!.replaceAll('km', '');
      //   double doubleValue = double.parse(removeKm);
      //   int intValue = (doubleValue * 1000).toInt();
      //   if (doubleValue >= 1) {
      //     distance = result.distance;
      //   } else {
      //     distance = '$intValue m';
      //   }
      // });

      context
          .read<StopProvider>()
          .getDistance_n_Duration(result.distance, result.duration);

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }
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
