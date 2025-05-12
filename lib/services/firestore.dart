import 'package:firebase_database/firebase_database.dart';

class RealTimeDatabaseService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  Stream<DatabaseEvent> getShipmentDocuments() {
    return databaseReference.child('shipment').onValue;
  }

  Future<List<DataSnapshot>> getDataShipment(String shipId) async {
    try {
      // Lấy collection con bên trong document chính
      DatabaseReference subCollectionRef = databaseReference.child('shipment').child(shipId);
      DataSnapshot subCollectionSnapshot = await subCollectionRef.get();
      
      if (subCollectionSnapshot.exists) {
        List<DataSnapshot> documents = [];
        for (var child in subCollectionSnapshot.children) {
          documents.add(child);
        }
        return documents;
      } else {
        return [];
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error getting shipment data: $e");
      return [];
    }
  }

  Future<void> updateNotesBasedOnCondition(
      String rootCollection,
      String idShipment,
      String docId,
      String cont,
      int sodem,
      int stt,
      int soluong) async {
    try {
      await databaseReference
          .child(rootCollection)
          .child(idShipment)
          .child(docId)
          .update({
        'Cont_Truck': cont,
        'So_dem': sodem,
        'STT': stt,
        'Tallysheet': soluong,
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error updating documents: $e");
    }
  }
}
