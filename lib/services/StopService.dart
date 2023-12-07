import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ubus/data/regions_stops.dart';
import 'package:ubus/data/stops.dart';
import 'package:ubus/models/RegionStops.dart';
import 'package:ubus/models/Stop.dart';

class StopService {
  final CollectionReference stops_regions =
      FirebaseFirestore.instance.collection("stop-regions");
  final stop_group = FirebaseFirestore.instance.collectionGroup('stops');
  List stops = [];
  List<String> regionsNames = [];

  Future getCollectionData({dynamic function}) async {
    List<Stop> Ceara_Osvaldo_Cruz = [];

    List<Stop> Uespi_UFDPAR = [];

    await stop_group.get().then(
      (QuerySnapshot snapshot) {
        final docs = snapshot.docs;
        for (var data in docs) {
          stops.add(data.data());
        }
      },
    );

    for (var stop_fb in stops) {
      var stop_name = stop_fb['name'].replaceAll('\\n', '\n');

      stops_t.add(
        Stop(
            stop_name,
            LatLng(stop_fb['coords'].latitude, stop_fb['coords'].longitude),
            stop_fb['region']),
      );
    }

    QuerySnapshot querySnapshot = await stops_regions.get();

    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      regionsNames.add(data['name']);
      print("Dados: ${data['name']}");
    }

    // for (var stop in stops_t) {
    //   if (stop.region == "Ceará - Osvaldo Cruz") {
    //     Ceara_Osvaldo_Cruz.add(stop);
    //   } else if (stop.region == "UESPI - UFDPAR") {
    //     Uespi_UFDPAR.add(stop);
    //   }
    // }

    for (var regionName in regionsNames) {
      final stopsFilter =
          stops_t.where((stp) => stp.region == regionName).toList();
      regions_stops.add(RegionStops(regionName, stopsFilter));
    }

    // regions_stops.addAll([
    //   RegionStops("Ceará - Osvaldo Cruz", Ceara_Osvaldo_Cruz),
    //   RegionStops("UESPI - UFDPAR", Uespi_UFDPAR)
    // ].toList());
  }

  Stream<QuerySnapshot> getStopsStream() {
    final stopsStream = stops_regions.snapshots();

    return stopsStream;
  }
}
