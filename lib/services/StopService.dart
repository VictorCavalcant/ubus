import 'package:cloud_firestore/cloud_firestore.dart';

class StopService {
  final CollectionReference stops = FirebaseFirestore.instance.collection("stops");

   Stream<QuerySnapshot> getStopsStream() {
    final stopsStream = stops.snapshots();

    return stopsStream;
  }

}