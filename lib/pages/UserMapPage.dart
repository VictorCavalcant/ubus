import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ubus/components/BottomMenu.dart';
import 'package:ubus/components/StopInfo.dart';
import 'package:ubus/data/regions_points.dart';
import 'dart:ui' as ui;
import 'package:ubus/data/stops.dart';
import 'package:ubus/providers/RegionProvider.dart';
import 'package:ubus/providers/StopProvider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ubus/providers/UserLocationProvider.dart';
import 'package:ubus/services/DriverService.dart';
import 'package:ubus/services/StopService.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  Set<Marker> aB_markers = Set();
  Map<PolylineId, Polyline> polylines = {};
  List activeBuses = [];
  Marker emptyMarker = Marker(markerId: MarkerId(""));

  testeFunction() {
    final region_provider = context.read<RegionProvider>();
    final userLoc_provider = context.read<UserLocationProvider>();

    print(region_provider.isInTheArea);
    print(userLoc_provider.userLoc);
    print(
        "stops de RegionProvider ta vazio? ---> ${region_provider.stops.isEmpty}");
  }

  rebuild() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    StopService().getCollectionData(function: rebuild);
    Timer(Duration(seconds: 3), () {
      getCurrentPosition();
      UpdateLocation();
    });
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _customStopMarkerIcon();
    _customBusMarkerIcon();
  }

  BitmapDescriptor _stopMarkerIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor _busMarkerIcon = BitmapDescriptor.defaultMarker;

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

        if (stops_t.isEmpty) {
          return Scaffold(
            body: const Center(
              child: const SpinKitRing(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
            stream: DriverService().getActiveBuses(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                activeBuses.clear();
              }

              if (snapshot.hasData) {
                activeBuses = snapshot.data!.docs;
                Timer(Duration(seconds: 4), () {
                  setState(() {});
                });
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
                  title: const Text(
                    'ubus',
                    style: const TextStyle(
                        fontFamily: 'Flix', color: Colors.white, fontSize: 37),
                  ),
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
                                ...stops_t.map(
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
                                                  PointLatLng(
                                                      stp.coords.latitude,
                                                      stp.coords.longitude)),
                                            ),
                                          );
                                        },
                                        position: stp.coords,
                                        icon: _stopMarkerIcon);
                                  },
                                ),
                                if (activeBuses.isEmpty)
                                  emptyMarker
                                else
                                  ...activeBuses.map((aB) {
                                    return Marker(
                                        markerId: MarkerId('Ônibus'),
                                        position: LatLng(aB['coords'].latitude,
                                            aB['coords'].longitude),
                                        icon: _busMarkerIcon);
                                  })
                              },
                              polylines:
                                  stop_provider.stopCoords.latitude != 0.0
                                      ? Set<Polyline>.of(polylines.values)
                                      : {},
                              polygons: {
                                ...regions_points.map(
                                  (rp) {
                                    return Polygon(
                                        polygonId: PolygonId(rp.name),
                                        points: rp.points,
                                        fillColor:
                                            Color.fromARGB(156, 33, 149, 243),
                                        strokeColor:
                                            Color.fromARGB(60, 0, 0, 0),
                                        strokeWidth: 2);
                                  },
                                )
                              },
                            ),
                          ),
                          Expanded(child: BottomMenu())
                        ],
                      ),
              );
            });
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

  _customStopMarkerIcon() async {
    final Uint8List customIcon =
        await getBytesFromAssets("assets/Bus_marker.png", 120);
    _stopMarkerIcon = BitmapDescriptor.fromBytes(customIcon);
    setState(() {});
  }

  _customBusMarkerIcon() async {
    final Uint8List customIcon =
        await getBytesFromAssets("assets/bus_LocMark.png", 120);
    _busMarkerIcon = BitmapDescriptor.fromBytes(customIcon);
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
    final region_provider = context.read<RegionProvider>();

    await userLoc_provider.getCurrentLocation();
  }

  void UpdateLocation() async {
    final userLoc_provider = context.read<UserLocationProvider>();

    await userLoc_provider.updateLocation(
      cameraFunction: _cameraToPosition,
    );
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
        result.points.forEach(
          (PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          },
        );
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
    setState(
      () {
        polylines[id] = polyline;
      },
    );
  }
}
