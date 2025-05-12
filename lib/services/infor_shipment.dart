import 'package:firebase_database/firebase_database.dart';

class InforShipment {
  final DatabaseReference notes = FirebaseDatabase.instance.ref().child('infor_shipment');

  // READ: get data from database
  Stream<DatabaseEvent> getNoteStream() {
    return notes.onValue;
  }

  // UPDATE: update data given doc id
  Future<void> updateNote(String docId, String cont, String status) async {
    await notes.child(docId).update({
      'Cont': cont,
      'Status': status,
    });
  }
}
