import 'package:firebase_database/firebase_database.dart';

class InforVehicle {
  final DatabaseReference notes = FirebaseDatabase.instance.ref('TallySheet');
  // CREATE: add a new note
  Future<void> addNote(String newBaove, String newCont, String newContloi, String newCounter, String newDate, String newSeal, String newType){
    final newNoteRef = notes.child(newCont); // Tạo một ID mới
    return newNoteRef.set({
      'baove': newBaove,
      'cont': newCont,
      'contloi': newContloi,
      'counter': newCounter,
      'date': newDate,
      'seal': newSeal,
      'type': newType
    });
  }
  // READ: get data from database
  Stream<DatabaseEvent> getNoteStream(){
    return notes.onValue; // Lắng nghe thay đổi dữ liệu
  }

  // UPDATE: update data given doc id
  Future<void> updateNote(String docId, String newBaove, String newCont, String newContloi, String newCounter, String newDate, String newSeal) async{
    try {
      final DataSnapshot snapshot = await notes.child(docId).get();
      
      if (snapshot.exists){

        final Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);
        final String oldCont = data['cont'];

        await notes.child(newCont).set({
          'baove': newBaove,
          'cont': newCont,
          'contloi': newContloi,
          'counter': newCounter,
          'date': newDate,
          'seal': newSeal,
          'type': data['type']
        });

        if (oldCont != newCont){
          await notes.child(docId).remove();
        }
        
        return;
      }
      throw Exception('Node không tồn tại');
    }
    catch (e){
      throw Exception('Lỗi khi cập nhật: $e');
    }
  }

  // DELETE: delete data given doc id
  Future<void> deleteNote(String docId){
    return notes.child(docId).remove();
  }
}