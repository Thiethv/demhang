import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:tallysheet_app/pages/input_page.dart';
import 'package:tallysheet_app/services/firestore.dart';
import 'package:tallysheet_app/services/infor_shipment.dart';
import 'package:tallysheet_app/util/shipment_data.dart';

class TallyPage extends StatefulWidget {
  final int selectedIndex;
  final Map<int, Map<String, dynamic>> selectedValues;

  const TallyPage({super.key, required this.selectedIndex, required this.selectedValues});

  @override
  State<TallyPage> createState() => _TallyPageState();
}

class _TallyPageState extends State<TallyPage> {
  final RealTimeDatabaseService  fireStoreService = RealTimeDatabaseService();
  final InforShipment inforShipment = InforShipment();
  List<ShipmentData> shipmentDataList = [];

  List<DataSnapshot> data = [];
  List<QueryDocumentSnapshot<Object?>> dataInfor = [];

  Map<String,Map<String, dynamic>> docDataMap = {};
  Map<String,Map<String, dynamic>> docInforMap = {};

  Set<String> idShipmentSet = {};

  String? selectedItem;

  String? contValue;
  String? styleCont;
  String? inforTruck;

  String? _selectedItem;
  String? _selectedShipment;
  String? _totalBox = "";
  String? _diff = "";
  final List<String> _dropdownItems = ['REF_NO', 'BUYER_PO', 'STYLE_NO', 'CT_NO'];

  ShipmentData? selectedData;
  int selectedIndex = -1;
    
  @override
  void initState() {
    super.initState();
    if (widget.selectedIndex != -1 && widget.selectedValues.containsKey(widget.selectedIndex)) {
      contValue = widget.selectedValues[widget.selectedIndex]!['cont'];
      styleCont = widget.selectedValues[widget.selectedIndex]!['type'];
      inforTruck = "$styleCont-$contValue";
    }
  }

  Future<void> clickReload() async {
    // Xóa các mục trong docDataMap có ID_SHIPMENT bằng với _selectedShipment
    docDataMap.removeWhere((key, value) => value['ID_SHIPMENT'] == _selectedShipment);


    data = await fireStoreService.getDataShipment(_selectedShipment!);
    for(var doc in data){
      var docData = Map<String, dynamic>.from(doc.value as Map);
      docDataMap[doc.key as String] = docData; // Ghi lại dữ liệu mới của id_shipment từ firestore vào docDataMap

      if (docData.containsKey('ID_SHIPMENT') ) {
        idShipmentSet.add(docData['ID_SHIPMENT']);
      }
    }
  }

  Future<void> clickQuery() async {
    if (_selectedShipment != null){
      if (docDataMap.isEmpty){
        data = await fireStoreService.getDataShipment(_selectedShipment!);

        for (var doc in data){
          var docData = Map<String, dynamic>.from(doc.value as Map);
          docDataMap[doc.key as String] = docData; // Ghi dữ liệu của id_shipment mới vào docDataMap
          if (docData.containsKey('ID_SHIPMENT')){
            idShipmentSet.add(docData['ID_SHIPMENT']);
          }
        }
      } 
      else if (!idShipmentSet.contains(_selectedShipment)){
        data = await fireStoreService.getDataShipment(_selectedShipment!);

        for (var doc in data){
          var docData = Map<String, dynamic>.from(doc.value as Map);
          docDataMap[doc.key as String] = docData; // Ghi dữ liệu của id_shipment mới vào docDataMap

          if (docData.containsKey('ID_SHIPMENT')){
            idShipmentSet.add(docData['ID_SHIPMENT']);
          }
        }
      }
    }

    if (docDataMap.isNotEmpty && idShipmentSet.contains(_selectedShipment)){
      Map<String, Map<String, dynamic>> itemData = {};
      Set<String> uniquePO = {};
      Set<String> uniqueCont = {};
      Set<String> uniqueScanned = {};
      int totalCount = 0;
      int totalCtn = 0;
      int totalScanned = 0;

      String customer = _selectedShipment!.substring(0, 4);
      String? itemValue;

      shipmentDataList = [];

      for (var entry in docDataMap.entries){
        var docData = entry.value;
        if (docData['ID_SHIPMENT'] == _selectedShipment){
          
          if (docData.containsKey('CTN')){
            totalCtn += (docData['CTN'] as num).toInt();
          }

          if (docData.containsKey('Tallysheet')) {
            totalCount += (docData['Tallysheet'] as num).toInt();
          }

          if (docData.containsKey('PO_NO')){
            uniquePO.add(docData['PO_NO']);
          }

          if (docData.containsKey('Cont_Truck')){
            if(docData['Cont_Truck'] != ''){
              uniqueCont.add(docData['Cont_Truck']);
            }
            
          }

          if (docData.containsKey('Scanned')){
            if (docData['Scanned'] != ''){
              uniqueScanned.add(docData['Scanned']);
            }
          }

          if (docData.containsKey(_selectedItem)) {
            String selectItem = docData[_selectedItem];

            if (!itemData.containsKey(selectItem)) {
              itemData[selectItem] = {
                'CTN':0,
                'uniqueScanned': <String>{}, // Sử dụng Set để đảm bảo giá trị là duy nhất
                'totalTallysheet': 0,
                'uniqueUCC': <String>{},
                'uniqueStyle': <String>{}
              };
            }

            if (docData.containsKey('Tallysheet')) {
              itemData[selectItem]!['totalTallysheet'] += (docData['Tallysheet'] as num).toInt();
            }
            if(docData.containsKey('CTN')){
              itemData[selectItem]!['CTN'] += (docData['CTN'] as num).toInt();
            }

            if (docData.containsKey('UCC')) {
              itemData[selectItem]!['uniqueUCC'].add(docData['UCC']);
            }
            if (docData.containsKey('Scanned')) {
              if (docData['Scanned'] != ""){
                itemData[selectItem]!['uniqueScanned'].add(docData['Scanned']);
              }
              
            }

            if (docData.containsKey('STYLE_NO')){
              itemData[selectItem]!['uniqueStyle'].add(docData['STYLE_NO']);
            }
          }
        }
      }
      
      for (var entry in itemData.entries) {
        String item = entry.key;
        String uniStyle = entry.value['uniqueStyle'].first;
        String style = uniStyle.substring(uniStyle.length - 5);

        int uniqueUCC = entry.value['uniqueUCC'].length;
        int scanned = entry.value['uniqueScanned'].length;
        int ctn = 0;
        int count = entry.value['totalTallysheet'];

        int notScan = scanned - uniqueUCC;
        int notCount = count - uniqueUCC;

        if (customer == 'MUJI' && (_selectedItem == 'BUYER_PO' || _selectedItem == 'CT_NO')){
          itemValue = "$style \n $item";
        }
        else{
          itemValue = item;
        }

        if (uniquePO.contains('NULL') && _selectedItem != "REF_NO"){
          if (customer == 'MUJI' && _selectedItem == 'STYLE_NO'){
            ctn = entry.value['CTN'];
          } else {
            ctn = uniqueUCC;
          }
          
        }else{
          ctn = entry.value['CTN'];
        }
        int diff = uniqueUCC - ctn;

        shipmentDataList.add(ShipmentData(
          itemValue,
          ctn,
          diff,
          notScan,
          notCount,
        ));
      }

      shipmentDataList.sort((a, b) => a.refNo.compareTo(b.refNo));

      totalScanned = uniqueScanned.length;
      setState(() {
        _totalBox = '$totalCount/$totalCtn';
        _diff = (totalCount - totalCtn).toString();
      });

      if (uniqueCont.isNotEmpty){
        if (!uniqueCont.contains(inforTruck)){
          showDialog(
            // ignore: use_build_context_synchronously
            context: context, 
            builder: (context) {
              return AlertDialog(
                title: const Text("Cảnh báo"),
                content: Text('ID_Shipment này đã được đếm trong xe ${uniqueCont.join(", ")}'),
                actions: [
                  TextButton(
                    onPressed: (){
                      Navigator.of(context).pop();
                    }, 
                    child: const Text('Đóng')
                  )
                ],
              );
            }
          );
        }
        
      }

      addInforShipment(totalCount, totalScanned, (totalCount-totalCtn), uniqueCont.join(", "));

    }
    
  }

  void navigateToInputPage(){
    if (selectedItem!.isNotEmpty && docDataMap.isNotEmpty){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InputPage(
            idShipment: _selectedShipment, 
            selectedItem: selectedItem, 
            contTruck: inforTruck, 
            docDataTally: docDataMap, 
            item: _selectedItem
          )
        ),
      ).then((updateDocDataMap){
        // Cập nhật lại docDataMap sau khi quay lại từ InputPage
        if (updateDocDataMap != null){
          setState((){
            docDataMap = updateDocDataMap;
          });
        }
      });
    }
  }

  Future<void> addInforShipment(int totalCount, int totalScanned, int diff, String cont) async {
    String status = '';
    try {
      if (docInforMap.isEmpty || !idShipmentSet.contains(_selectedShipment)){
        DataSnapshot snapshot = await FirebaseDatabase.instance.ref().child('infor_shipment').get();

        for (DataSnapshot doc in snapshot.children) {
          Map<String, dynamic> docData = Map<String, dynamic>.from(doc.value as Map);
          docInforMap[doc.key as String] = docData;
        }

      }
      if (docInforMap.isNotEmpty){

        if (totalScanned == 0){
          status = 'Wait';
        } else if (cont == ''){
          status = 'Scanning';
        } else if (diff == 0){
          status = 'Done';
        } else {
          status = 'Loading';
        }

        for (var doc in docInforMap.entries) {
          var docData = doc.value;
          if (docData['ID_SHIPMENT'] == _selectedShipment) {
            inforShipment.updateNote(_selectedShipment!, cont, status);

            docData['Cont'] = cont;
            docData['Status'] = status;
            break;
          }

        }
      }
    } catch (e){
      // ignore: avoid_print
      print('Error: $e');
    }   

  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(        
        title: const Text(
          "E-SHIPMENT",
          style: TextStyle(fontSize: 22, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 136, 232, 237),
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.deepOrange,),
    
        ),
        
        actions: <Widget> [
          TextButton.icon(
            onPressed: navigateToInputPage,
            style: TextButton.styleFrom(
              backgroundColor: Colors.green[400],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_forward, color: Colors.deepOrange,),
            label: const Text('Đếm hàng',style: TextStyle(fontSize: 14),),
          )
        ],
        
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    inforTruck??'',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.lightBlueAccent),
                ),
        
                const SizedBox(width: 10,),
                Text(
                    '($_totalBox)',
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.redAccent),
                ),
        
                const SizedBox(width: 10,),
                
                Text(
                  '($_diff)',
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 14, color: Colors.red),
                )
              ],
            ),
        
            const SizedBox(height: 20,),
        
            StreamBuilder(
              stream: fireStoreService.getShipmentDocuments(),
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.hasData) {
                  List<DropdownMenuItem<String>> dropdownItems = [];
                  for (var data in snapshot.data!.snapshot.children) {

                    String value = data.key??'';
                    dropdownItems.add(DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ));
                  }
                  

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: const Text("Chọn số Shipment", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),),
                      value: _selectedShipment,
                      items: dropdownItems,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedShipment = newValue;
                        });
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),

            const SizedBox(height: 10,),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),

              child: DropdownButton<String> (
                isExpanded: true,
                underline: const SizedBox(),

                hint: const Text(
                    'Chọn loại hàng',
                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),

                ),
                value: _selectedItem,

                items: _dropdownItems.map((String item){
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item)
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedItem = newValue;
                  });
                },
              
              ),
                
            ),
            const SizedBox(height: 15,),

            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        clickQuery();
                      },
                      child: const Text('QUERY'),
                    )
                ),
                const SizedBox(width: 10,),
                
                Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        clickReload();
                      },
                      child: const Text('TẢI LẠI'),
                    )
                ),
              ],
            ),
            const SizedBox(height: 15,),
            
            const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(flex: 3,child: Text('TÊN HÀNG', textAlign: TextAlign.center,)),
                Expanded(flex: 1,child: Text('THÙNG', textAlign: TextAlign.center)),
                Expanded(flex: 1,child: Text('THIẾU', textAlign: TextAlign.center)),
                Expanded(flex: 1,child: Text('SCAN', textAlign: TextAlign.center)),
                Expanded(flex: 1,child: Text('ĐẾM', textAlign: TextAlign.center))
              ],
            ),
            const SizedBox(height: 15,),
            
            Expanded(
              child: ListView.builder(
                itemCount: shipmentDataList.length,
                itemBuilder: (context, index) {
                  
                  final data = shipmentDataList[index];
                  bool isSelected = index == selectedIndex;
                  return GestureDetector(
                    onTap: (){
                      setState(() {
                        selectedIndex = index;
                      });
                      selectedItem = data.refNo;
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
                                flex: 3,
                                child: Container(
                                  // padding: const EdgeInsets.all(8.0),
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  child: Text(data.refNo, textAlign: TextAlign.center),
                                ),
                                
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  // padding: const EdgeInsets.all(8.0),
                                  child: Text('${data.totalCtn}', textAlign: TextAlign.center),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  // padding: const EdgeInsets.all(8.0),
                                  child: Text('${data.diff}', textAlign: TextAlign.center),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  // padding: const EdgeInsets.all(8.0),
                                  child: Text('${data.scanned}', textAlign: TextAlign.center),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: isSelected ? Colors.blue[200] : Colors.transparent,
                                  // padding: const EdgeInsets.all(8.0),
                                  child: Text('${data.counted}', textAlign: TextAlign.center),
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
            )
          ],
        ),
      ),
    );
  }
}