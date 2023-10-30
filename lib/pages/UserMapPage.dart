import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:ubus/providers/UserLocationProvider.dart';
import 'package:ubus/services/DriverService.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mpt;
import 'package:ubus/services/StopService.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  List<LatLng> polygonPoints = [
    LatLng(-2.920113802393552, -41.76300037572107), //start point
    LatLng(-2.920136661241771, -41.76098973218705),
    LatLng(-2.9202529392014505, -41.75895636744167),
    LatLng(-2.923760302277007, -41.75973714057531),
    LatLng(-2.9216765178820934, -41.7621293583059),
    LatLng(-2.920113802393552, -41.76300037572107), // end point
  ];

  bool isInTheArea = true;

  void checkUpdatedLocation(LatLng pointLatLng) {
    List<mpt.LatLng> convertedPolygonPoints = polygonPoints
        .map(
          (point) => mpt.LatLng(point.latitude, point.longitude),
        )
        .toList();
    setState(() {
      isInTheArea = mpt.PolygonUtil.containsLocation(
          mpt.LatLng(pointLatLng.latitude, pointLatLng.longitude),
          convertedPolygonPoints,
          false);
    });
  }

  Map<PolylineId, Polyline> polylines = {};
  List activeBuses = [];
  Marker emptyMarker = Marker(markerId: MarkerId(""));

  testeFunction() async {
    // final userLoc_provider = context.read<UserLocationProvider>();
    // print(userLoc_provider.userLoc);
    dynamic distanceBetween = await Geolocator.distanceBetween(
        -2.9200933, -41.7620267, -2.920136661241771, -41.76098973218705);
    double result = distanceBetween as double;

    print("A distância foi de: ${result.ceil()}");
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
    UpdateLocation();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customMarkerIcon();
  }

  BitmapDescriptor _stopMarkerIcon = BitmapDescriptor.defaultMarker;

  @override
  Widget build(BuildContext context) {
    getPolylinePoints();
    final stop_provider = Provider.of<StopProvider>(context);
    final userLoc_provider = Provider.of<UserLocationProvider>(context);
    return StreamBuilder<QuerySnapshot>(
        stream: StopService().getStopsStream(),
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

          final stops_fb = snapshot.data!.docs;

          for (var stop_fb in stops_fb) {
            var stop_name = stop_fb['name'].replaceAll('\\n', '\n');

            stops.add(
              Stop(
                stop_name,
                LatLng(stop_fb['coords'].latitude, stop_fb['coords'].longitude),
              ),
            );
          }

          if (stops.isEmpty) {
            return Scaffold(
              body: const Center(
                child: const SpinKitRing(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  onPressed: testeFunction,
                  icon: const Icon(
                    Icons.science,
                    color: Colors.white,
                  ),
                )
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
                  style: const TextStyle(
                      fontFamily: 'Flix', color: Colors.white, fontSize: 37)),
              centerTitle: true,
              backgroundColor: const Color(0xFF0057DA),
            ),
            body: userLoc_provider.userLoc.latitude == 0.0
                ? const Center(
                    child: const SpinKitRing(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        flex: stop_provider.isNearStopsVisible ? 2 : 5,
                        child: GoogleMap(
                          mapToolbarEnabled: false,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onMapCreated: ((GoogleMapController controller) =>
                              _mapController.complete(controller)),
                          initialCameraPosition: CameraPosition(
                              target: userLoc_provider.userLoc, zoom: 15),
                          zoomControlsEnabled: false,
                          markers: {
                            ...stops.map(
                              (stp) {
                                return Marker(
                                    markerId: MarkerId(stp.name),
                                    onTap: () {
                                      showModalBottomSheet(
                                        shape: const LinearBorder(
                                            side: BorderSide.none),
                                        context: context,
                                        builder: (context) =>
                                            SingleChildScrollView(
                                          child: StopInfo(
                                              stp.name,
                                              PointLatLng(stp.coords.latitude,
                                                  stp.coords.longitude)),
                                        ),
                                      );
                                    },
                                    position: stp.coords,
                                    icon: _stopMarkerIcon);
                              },
                            ),
                          },
                          polylines: stop_provider.stopCoords.latitude != 0.0
                              ? Set<Polyline>.of(polylines.values)
                              : {},
                          polygons: {
                            Polygon(
                                polygonId: PolygonId("1"),
                                fillColor:
                                    const Color.fromARGB(75, 33, 149, 243),
                                strokeWidth: 1,
                                strokeColor: const Color.fromARGB(45, 0, 0, 0),
                                points: polygonPoints)
                          },
                        ),
                      ),
                      Expanded(child: BottomMenu())
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
        await getBytesFromAssets("assets/Bus_marker.png", 120);
    _stopMarkerIcon = BitmapDescriptor.fromBytes(customIcon);
    setState(() {});
  }

  // Camera section

  Future<void> _cameraToPosition() async {
    final userLoc_provider = context.read<UserLocationProvider>();
    final GoogleMapController controller = await _mapController.future;
    controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: userLoc_provider.userLoc, zoom: 17),
      ),
    );
  }

  // Location Section

  void getCurrentPosition() async {
    final userLoc_provider = context.read<UserLocationProvider>();

    await userLoc_provider.getCurrentLocation();
  }

  UpdateLocation() async {
    final userLoc_provider = context.read<UserLocationProvider>();

    await userLoc_provider.updateLocation(cameraFunction: _cameraToPosition);
  }

  // Polyline Section

  getPolylinePoints() async {
    final userLoc_provider = context.read<UserLocationProvider>();
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    if (context.read<StopProvider>().stopCoords.latitude != 0.0) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        dotenv.env['GOOGLE_MAPS_KEY'].toString(),
        PointLatLng(userLoc_provider.userLoc.latitude,
            userLoc_provider.userLoc.longitude),
        context.read<StopProvider>().stopCoords,
        travelMode: TravelMode.walking,
      );

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
      generatePolyLineFromPoints(polylineCoordinates);
    }
  }

  void generatePolyLineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = const PolylineId("poly");
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
