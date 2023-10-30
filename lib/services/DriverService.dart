import 'package:cloud_firestore/cloud_firestore.dart';

class DriverService {
  final CollectionReference drivers =
      FirebaseFirestore.instance.collection("drivers");

  Future<void> addUser(id) {
    return drivers.doc(id).set({"active": false, "coords": GeoPoint(0.0, 0.0)},
        SetOptions(merge: true));
  }

  Future<void> ToggleActive(id, bool active) {
    if (active) {
      return drivers.doc(id).update({"active": false});
    } else {
      return drivers.doc(id).update({"active": true});
    }
  }

  Future<void> ResetCoords(id) {
    return drivers.doc(id).update({"coords": GeoPoint(0.0, 0.0)});
  }

  Future<void> ResetActive(id) {
    return drivers.doc(id).update({"active": false});
  }

  Future<void> GetCoords(id, double lat, double long) {
    return drivers.doc(id).update({"coords": GeoPoint(lat, long)});
  }

  Stream<DocumentSnapshot> getDriversStream(id) {
    final driversStream = drivers.doc(id).snapshots();

    return driversStream;
  }

  Stream<QuerySnapshot> getActiveBuses() {
    final activeBusesStream =
        drivers.where("active", isEqualTo: true).snapshots();
    return activeBusesStream;
  }
}
