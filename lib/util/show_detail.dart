import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tallysheet_app/services/firestore.dart';
import 'package:tallysheet_app/util/detail_adapter.dart';

class ShowDetail extends StatefulWidget {
  final Map<String, Map<String, dynamic>> docDataMap;
  final List<DetailAdapter> listData;
  final String? idShipment;
  const ShowDetail({super.key, required this.listData, required this.idShipment, required this.docDataMap});

  @override
  State<ShowDetail> createState() => _ShowDetailState();
}



class _ShowDetailState extends State<ShowDetail> {
  final RealTimeDatabaseService fireStoreService = RealTimeDatabaseService();
  List<DetailAdapter> listDataDetail = [];
  String? idShipment;
  Map<String,Map<String, dynamic>> docDataMap = {};

  int selectedIndex = -1;
  String? selectedItem;

  @override
  void initState(){
    super.initState();
    listDataDetail = widget.listData;
    idShipment = widget.idShipment;
    docDataMap = widget.docDataMap;
  }

  Future<void> updateData()async{
    if (selectedItem == null || selectedItem!.isEmpty) {
      // Nếu selectedItem chưa được chọn, hiển thị thông báo hoặc xử lý khác
      // ignore: avoid_print
      print("No item selected for update.");
      return;
    }
    await fireStoreService.updateNotesBasedOnCondition(
      'shipment', 
      idShipment!, 
      selectedItem!, 
      '', 
      0, 
      0, 
      0
    );

    // Xóa item khỏi listDataDetail sau khi cập nhật
    setState(() {
      listDataDetail.removeWhere((item) => item.id == selectedItem);
    });

    if (docDataMap.isNotEmpty){
      for(var doc in docDataMap.entries){
        var docData = doc.value;
        var docId = doc.key;
        if (docId == selectedItem){
          // Cập nhật docDataMap sau khi đã cập nhật Firestore
          docData['Cont_Truck'] = '';
          docData['So_dem'] = 0;
          docData['Tallysheet'] = 0;
          docData['STT'] = 0;
        }
      }
    }
  }

  void _navigateBack() {
    Navigator.pop(context, docDataMap); // Trả lại dữ liệu đã cập nhật
  }

  Widget setupAlertDialoadContainer(context) {
    return SizedBox(
      height: 500.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      
      child: Column(
        children: [
          const SizedBox(height: 10,),
          const Expanded(
            flex: 1,
            child: Column(
              children: [
                Text('Chi tiết đếm hàng', style: TextStyle(fontSize: 18, color: Colors.blue)),
                SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(flex: 1, child: Text('STT', textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('SỐ ĐẾM', textAlign: TextAlign.center)),
                    Expanded(flex: 1, child: Text('BẢN SCAN', textAlign: TextAlign.center)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 5),
          Expanded(
            flex: 4,
            child: ListView.builder(
              itemCount: listDataDetail.length,
              itemBuilder: (context, index) {
                final data = listDataDetail[index];
                bool isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      selectedIndex = index;
                    });
                    selectedItem = data.id;
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text(data.stt, textAlign: TextAlign.center),
                              ),
                              
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text('${data.counted}', textAlign: TextAlign.center),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                color: isSelected ? Colors.blue[200] : Colors.transparent,
                                child: Text('${data.scanned}', textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(thickness: 1, color: Color.fromARGB(255, 251, 235, 235),)
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Close button at the bottom
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          updateData();
                        },
                        child: const Text("Xóa", style: TextStyle(color: Colors.red),),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _navigateBack();
                        },
                        child: const Text("Đóng"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10,)
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: setupAlertDialoadContainer(context),
      
    );
  }
}
